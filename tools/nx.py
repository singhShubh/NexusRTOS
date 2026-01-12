#!/usr/bin/env python3
"""NexusRTOS build helper."""

from __future__ import annotations
import argparse
import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILD_ROOT = ROOT / "build"
BSP_ROOT = ROOT / "bsp"
TOOLCHAIN = ROOT / "build" / "toolchain.cmake"

def discover_boards() -> list[str]:
    boards = []
    for board_dir in sorted(BSP_ROOT.iterdir()):
        if not board_dir.is_dir():
            continue
        cfg = board_dir / "config" / f"{board_dir.name}.cmake"
        if cfg.exists():
            boards.append(board_dir.name)
    return boards

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
    build_dir = BUILD_ROOT / board / build_type

    configure_cmd = [
        "cmake",
        "-S", str(ROOT),
        "-B", str(build_dir),
        f"-DCMAKE_TOOLCHAIN_FILE={TOOLCHAIN}",
        f"-DNEXUS_BOARD={board}",
        f"-DCMAKE_BUILD_TYPE={build_type}",
    ]
    build_cmd = ["cmake", "--build", str(build_dir), "-j"]

    run(configure_cmd)
    run(build_cmd)

    artifacts = build_dir / "artifacts"
    print(f"Built ELF: {artifacts / ('nexus_' + board + '.elf')}")
    print(f"Built MAP: {artifacts / ('nexus_' + board + '.map')}")
    return 0

def cmd_clean(args: argparse.Namespace) -> int:
    if args.all:
        protected_build_dirs = {"cmake"}
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
    parser = argparse.ArgumentParser(description="NexusRTOS build helper")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("list-boards", help="List discovered boards")
    p.set_defaults(func=cmd_list_boards)

    p = sub.add_parser("build", help="Configure and build one board")
    p.add_argument("--board", required=True)
    p.add_argument("--type", default="debug")
    p.set_defaults(func=cmd_build)

    p = sub.add_parser("clean", help="Clean one board/type or the entire build tree")
    p.add_argument("--board")
    p.add_argument("--type")
    p.add_argument("--all", action="store_true")
    p.set_defaults(func=cmd_clean)

    args = parser.parse_args()
    return args.func(args)

if __name__ == "__main__":
    sys.exit(main())
