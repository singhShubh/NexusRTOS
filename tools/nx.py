#!/usr/bin/env python3
"""NexusRTOS build helper."""

from __future__ import annotations
import argparse
import os
import pathlib
import re
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILD_ROOT = ROOT / "build"
BSP_CONFIG_ROOT = ROOT / "bsp_config"
TOOLCHAIN_ROOT = ROOT / "build" / "cmake"
MINIMUM_CMAKE = (3, 20, 0)

class NxHelpFormatter(
    argparse.ArgumentDefaultsHelpFormatter,
    argparse.RawDescriptionHelpFormatter,
):
    """Formatter that keeps example blocks readable while showing defaults."""

def parse_version(text: str) -> tuple[int, int, int] | None:
    for token in text.replace(",", " ").split():
        parts = token.split(".")
        if len(parts) < 2 or not all(part.isdigit() for part in parts[:2]):
            continue
        major = int(parts[0])
        minor = int(parts[1])
        patch = int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else 0
        return (major, minor, patch)
    return None

def cmake_version(path: str) -> tuple[int, int, int] | None:
    try:
        output = subprocess.check_output([path, "--version"], text=True, stderr=subprocess.STDOUT)
    except (OSError, subprocess.CalledProcessError):
        return None
    return parse_version(output)

def resolve_cmake() -> str:
    candidates: list[str] = []
    seen: set[str] = set()

    for raw in (
        shutil.which("cmake"),
        str(pathlib.Path.home() / ".local" / "bin" / "cmake"),
        "/usr/local/bin/cmake",
        "/opt/homebrew/bin/cmake",
        "/usr/bin/cmake",
    ):
        if not raw:
            continue
        candidate = os.path.realpath(raw) if os.path.exists(raw) else raw
        if candidate in seen:
            continue
        seen.add(candidate)
        candidates.append(candidate)

    best_path = None
    best_version = None
    for candidate in candidates:
        version = cmake_version(candidate)
        if version is None:
            continue
        if best_version is None or version > best_version:
            best_path = candidate
            best_version = version

    if best_path is None or best_version is None or best_version < MINIMUM_CMAKE:
        need = ".".join(str(part) for part in MINIMUM_CMAKE[:2])
        found = ".".join(str(part) for part in best_version) if best_version else "none"
        raise SystemExit(f"CMake {need}+ is required, but the best executable found was {found}.")

    return best_path

def discover_boards() -> list[str]:
    boards = []
    for board_dir in sorted(BSP_CONFIG_ROOT.iterdir()):
        if not board_dir.is_dir():
            continue
        cfg = board_dir / f"{board_dir.name}.cmake"
        if cfg.exists():
            boards.append(board_dir.name)
    return boards

def board_config_path(board: str) -> pathlib.Path:
    return BSP_CONFIG_ROOT / board / f"{board}.cmake"

def load_board_arch(board: str) -> str:
    cfg = board_config_path(board)
    if not cfg.exists():
        raise SystemExit(f"Board config not found: {cfg}")

    try:
        text = cfg.read_text(encoding="utf-8", errors="ignore")
    except OSError as exc:
        raise SystemExit(f"Failed to read board config '{cfg}': {exc}") from exc

    match = re.search(r"set\s*\(\s*NEXUS_BOARD_ARCH\s+\"?([A-Za-z0-9_.+-]+)\"?", text)
    if not match:
        raise SystemExit(f"Could not parse NEXUS_BOARD_ARCH from: {cfg}")

    return match.group(1)

def resolve_toolchain_for_board(board: str) -> pathlib.Path:
    arch = load_board_arch(board)
    toolchain = TOOLCHAIN_ROOT / f"toolchain_{arch}.cmake"
    if toolchain.exists():
        return toolchain

    available = sorted(
        p.name for p in TOOLCHAIN_ROOT.glob("toolchain_*.cmake")
        if p.is_file()
    )
    raise SystemExit(
        f"No toolchain file found for arch '{arch}' (board '{board}'). "
        f"Expected: {toolchain}. Available: {available}"
    )

def canonical_build_type(value: str) -> str:
    value = value.strip().lower()
    if value == "debug":
        return "Debug"
    if value == "release":
        return "Release"
    raise SystemExit(f"Unsupported build type: {value}. Use debug or release.")

def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True)

def _clear_stale_cmake_cache(build_dir: pathlib.Path, toolchain_path: pathlib.Path) -> None:
    cache_file = build_dir / "CMakeCache.txt"
    expected = str(toolchain_path.resolve())
    cmake_files_dir = build_dir / "CMakeFiles"
    stale = False

    if cache_file.exists():
        try:
            cache_text = cache_file.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            cache_text = ""

        cached = None
        for line in cache_text.splitlines():
            if line.startswith("CMAKE_TOOLCHAIN_FILE:"):
                cached = line.split("=", 1)[1].strip()
                break

        if cached is None:
            stale = True
        elif os.path.realpath(cached) != expected:
            stale = True

    # CMake stores the toolchain include in CMakeSystem.cmake. If it points to
    # a stale path, configure fails before the cache can be refreshed.
    if not stale and cmake_files_dir.exists():
        for system_file in cmake_files_dir.glob("*/CMakeSystem.cmake"):
            try:
                system_text = system_file.read_text(encoding="utf-8", errors="ignore")
            except OSError:
                continue
            for line in system_text.splitlines():
                if 'include("' not in line:
                    continue
                include_path = line.split('"')[1]
                include_name = os.path.basename(include_path)
                if not include_name.startswith("toolchain"):
                    continue
                if (not os.path.exists(include_path)) or (os.path.realpath(include_path) != expected):
                    stale = True
                break
            if stale:
                break

    if not stale:
        return

    try:
        cache_file.unlink(missing_ok=True)
    except OSError:
        pass
    if cmake_files_dir.exists():
        shutil.rmtree(cmake_files_dir, ignore_errors=True)

def artifact_paths(board: str, build_type: str) -> dict[str, pathlib.Path]:
    artifacts = BUILD_ROOT / board / build_type / "artifacts"
    stem = f"nexus_{board}"
    return {
        "artifacts_dir": artifacts,
        "elf": artifacts / f"{stem}.elf",
        "map": artifacts / f"{stem}.map",
        "secure_bin": artifacts / f"{stem}_secure.bin",
        "nonsecure_bin": artifacts / f"{stem}_nonsecure.bin",
    }

def build_board(board: str, build_type: str) -> dict[str, pathlib.Path]:
    build_dir = BUILD_ROOT / board / build_type
    cmake = resolve_cmake()
    toolchain = resolve_toolchain_for_board(board)
    _clear_stale_cmake_cache(build_dir, toolchain)

    configure_cmd = [
        cmake,
        "-S", str(ROOT),
        "-B", str(build_dir),
        f"-DCMAKE_TOOLCHAIN_FILE={toolchain}",
        f"-DNEXUS_BOARD={board}",
        f"-DCMAKE_BUILD_TYPE={build_type}",
    ]
    build_cmd = [cmake, "--build", str(build_dir), "-j"]

    run(configure_cmd)
    run(build_cmd)
    return artifact_paths(board, build_type)

def cmd_list_boards(_args: argparse.Namespace) -> int:
    boards = discover_boards()
    if not boards:
        print("No boards discovered.")
        return 1
    for board in boards:
        print(board)
    return 0

def cmd_build(args: argparse.Namespace) -> int:
    board = args.board
    if board not in discover_boards():
        raise SystemExit(f"Unknown board: {board}")

    build_type = canonical_build_type(args.type)
    artifacts = build_board(board, build_type)
    print(f"Built ELF: {artifacts['elf']}")
    print(f"Built MAP: {artifacts['map']}")
    if artifacts["secure_bin"].exists():
        print(f"Built Secure BIN: {artifacts['secure_bin']}")
    print(f"Built Non-secure BIN: {artifacts['nonsecure_bin']}")
    return 0

def cmd_flash_image(args: argparse.Namespace) -> int:
    board = args.board
    if board not in discover_boards():
        raise SystemExit(f"Unknown board: {board}")

    build_type = canonical_build_type(args.type)
    artifacts = build_board(board, build_type)
    print(f"Flash ELF: {artifacts['elf']}")
    if artifacts["secure_bin"].exists():
        print(f"Secure BIN: {artifacts['secure_bin']}")
    print(f"Non-secure BIN: {artifacts['nonsecure_bin']}")
    return 0

def cmd_clean(args: argparse.Namespace) -> int:
    if args.all:
        # Keep tracked build infrastructure helpers under build/.
        protected_build_dirs: set[str] = {"cmake"}
        # Clean all board-specific build directories
        if BUILD_ROOT.exists():
            for board_dir in BUILD_ROOT.iterdir():
                if board_dir.is_dir() and board_dir.name not in protected_build_dirs:
                    # Only remove board directories, keep tracked helpers/modules in build/.
                    try:
                        shutil.rmtree(board_dir)
                        print(f"Removed {board_dir}")
                    except Exception as e:
                        print(f"Warning: Could not remove {board_dir}: {e}")

        # Clean up CMake temporary files in project root
        cmake_temp_files = [
            ROOT / "CMakeCache.txt",
            ROOT / "CMakeFiles",
            ROOT / "cmake_install.cmake",
            ROOT / "compile_commands.json",
        ]
        for temp_file in cmake_temp_files:
            if temp_file.exists():
                try:
                    if temp_file.is_dir():
                        shutil.rmtree(temp_file)
                    else:
                        temp_file.unlink()
                    print(f"Removed {temp_file}")
                except Exception as e:
                    print(f"Warning: Could not remove {temp_file}: {e}")

        return 0

    if not args.board:
        raise SystemExit("clean requires --board <name> or --all")

    board_dir = BUILD_ROOT / args.board
    if args.type:
        target = board_dir / canonical_build_type(args.type)
    else:
        target = board_dir

    if target.exists():
        shutil.rmtree(target)
        print(f"Removed {target}")
    else:
        print(f"Nothing to remove: {target}")
    return 0

def main() -> int:
    parser = argparse.ArgumentParser(
        prog="nx.py",
        description="NexusRTOS build helper for board discovery, build, and cleanup.",
        epilog=(
            "Examples:\n"
            "  python3 tools/nx.py list-boards\n"
            "  python3 tools/nx.py build --board mps2_an505 --type debug\n"
            "  python3 tools/nx.py flash-image --board portenta_c33 --type release\n"
            "  python3 tools/nx.py clean --board mps2_an505 --type debug\n"
            "  python3 tools/nx.py clean --all"
        ),
        formatter_class=NxHelpFormatter,
    )
    sub = parser.add_subparsers(
        dest="cmd",
        required=True,
        title="commands",
        description="Use one of the commands below.",
    )

    p_list = sub.add_parser(
        "list-boards",
        help="List available board identifiers.",
        description="Print all board names discovered under bsp_config/<board>/<board>.cmake.",
        formatter_class=NxHelpFormatter,
    )
    p_list.set_defaults(func=cmd_list_boards)

    p_build = sub.add_parser(
        "build",
        help="Configure and build artifacts for one board.",
        description="Configure and build one board into build/<board>/<BuildType>/artifacts/.",
        formatter_class=NxHelpFormatter,
    )
    p_build.add_argument(
        "--board",
        required=True,
        metavar="BOARD",
        help="Board name (run 'list-boards' to see valid values).",
    )
    p_build.add_argument(
        "--type",
        default="debug",
        metavar="BUILD_TYPE",
        help="Build type: debug or release (case-insensitive).",
    )
    p_build.set_defaults(func=cmd_build)

    p_flash = sub.add_parser(
        "flash-image",
        help="Build and print flash-ready artifact paths.",
        description="Build one board and print the ELF plus secure/non-secure BIN paths for flashing.",
        formatter_class=NxHelpFormatter,
    )
    p_flash.add_argument(
        "--board",
        required=True,
        metavar="BOARD",
        help="Board name (run 'list-boards' to see valid values).",
    )
    p_flash.add_argument(
        "--type",
        default="debug",
        metavar="BUILD_TYPE",
        help="Build type: debug or release (case-insensitive).",
    )
    p_flash.set_defaults(func=cmd_flash_image)

    p_clean = sub.add_parser(
        "clean",
        help="Remove build output for one board or all boards.",
        description=(
            "Remove generated build directories.\n"
            "Use --all to wipe all board build directories.\n"
            "Without --all, provide --board and optionally --type."
        ),
        formatter_class=NxHelpFormatter,
    )
    p_clean.add_argument(
        "--board",
        metavar="BOARD",
        help="Board name to clean (required unless --all is used).",
    )
    p_clean.add_argument(
        "--type",
        metavar="BUILD_TYPE",
        help="Optional build type to clean for one board: debug or release.",
    )
    p_clean.add_argument(
        "--all",
        action="store_true",
        help="Clean all board build directories under build/.",
    )
    p_clean.set_defaults(func=cmd_clean)

    args = parser.parse_args()
    return args.func(args)

if __name__ == "__main__":
    sys.exit(main())
