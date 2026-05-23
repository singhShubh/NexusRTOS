#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_ELF="${ROOT_DIR}/build/mps2_an505/Debug/artifacts/nexus_mps2_an505.elf"

GDB_BIN="${GDB_BIN:-gdb-multiarch}"
ELF="${DEFAULT_ELF}"
GDB_HOST="${GDB_HOST:-localhost}"
GDB_PORT="${GDB_PORT:-3333}"
EXTRA_GDB_ARGS=()

usage() {
    cat <<USAGE
Usage: $(basename "$0") [options] [-- extra-gdb-args...]

Launch GDB for the NexusRTOS mps2_an505 ELF and attach to QEMU's GDB server.

Options:
  -e, --elf PATH       ELF with symbols (default: ${DEFAULT_ELF})
  -H, --host HOST      QEMU GDB server host (default: ${GDB_HOST})
  -p, --port PORT      QEMU GDB server port (default: ${GDB_PORT})
  -h, --help           Show this help

Environment:
  GDB_BIN              GDB executable (default: gdb-multiarch)
  GDB_HOST             Default QEMU GDB server host
  GDB_PORT             Default QEMU GDB server port

Examples:
  tools/gdb_mps2_an505.sh
  tools/gdb_mps2_an505.sh --port 3333
  tools/gdb_mps2_an505.sh -- --batch -ex 'info registers'
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--elf)
            [[ $# -ge 2 ]] || { echo "error: missing value for $1" >&2; exit 2; }
            ELF="$2"
            shift 2
            ;;
        -H|--host)
            [[ $# -ge 2 ]] || { echo "error: missing value for $1" >&2; exit 2; }
            GDB_HOST="$2"
            shift 2
            ;;
        -p|--port|--gdb-port)
            [[ $# -ge 2 ]] || { echo "error: missing value for $1" >&2; exit 2; }
            GDB_PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            EXTRA_GDB_ARGS+=("$@")
            break
            ;;
        *)
            echo "error: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! command -v "${GDB_BIN}" >/dev/null 2>&1; then
    echo "error: GDB executable not found: ${GDB_BIN}" >&2
    echo "Set GDB_BIN or install gdb-multiarch." >&2
    exit 1
fi

if [[ ! -f "${ELF}" ]]; then
    echo "error: ELF not found: ${ELF}" >&2
    echo "Build it with: python3 tools/nx.py build --board mps2_an505 --type debug" >&2
    exit 1
fi

GDB_ARGS=(
    "${ELF}"
    -ex "set architecture armv8-m.main"
    -ex "target remote ${GDB_HOST}:${GDB_PORT}"
)

printf 'Launching GDB: %q' "${GDB_BIN}"
printf ' %q' "${GDB_ARGS[@]}" "${EXTRA_GDB_ARGS[@]}"
printf '\n'
exec "${GDB_BIN}" "${GDB_ARGS[@]}" "${EXTRA_GDB_ARGS[@]}"
