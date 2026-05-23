#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_ELF="${ROOT_DIR}/build/mps2_an505/Debug/artifacts/nexus_mps2_an505.elf"

QEMU_BIN="${QEMU_BIN:-qemu-system-arm}"
ELF="${DEFAULT_ELF}"
GDB_PORT="${GDB_PORT:-3333}"
WAIT_FOR_GDB=1
EXTRA_QEMU_ARGS=()

usage() {
    cat <<USAGE
Usage: $(basename "$0") [options] [-- extra-qemu-args...]

Launch the NexusRTOS mps2_an505 ELF in QEMU with a GDB server enabled.

Options:
  -e, --elf PATH       ELF to run (default: ${DEFAULT_ELF})
  -p, --gdb-port PORT  GDB server TCP port (default: ${GDB_PORT})
  -S, --wait-for-gdb   Start QEMU paused until GDB continues execution (default)
      --no-wait        Start QEMU immediately without waiting for GDB
  -h, --help           Show this help

Environment:
  QEMU_BIN             QEMU executable (default: qemu-system-arm)
  GDB_PORT             Default GDB server port

Examples:
  tools/qemu_mps2_an505.sh
  tools/qemu_mps2_an505.sh --no-wait
  tools/qemu_mps2_an505.sh --elf build/mps2_an505/Debug/artifacts/nexus_mps2_an505.elf -- -d int
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--elf)
            [[ $# -ge 2 ]] || { echo "error: missing value for $1" >&2; exit 2; }
            ELF="$2"
            shift 2
            ;;
        -p|--gdb-port)
            [[ $# -ge 2 ]] || { echo "error: missing value for $1" >&2; exit 2; }
            GDB_PORT="$2"
            shift 2
            ;;
        -S|--wait-for-gdb)
            WAIT_FOR_GDB=1
            shift
            ;;
        --no-wait)
            WAIT_FOR_GDB=0
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            EXTRA_QEMU_ARGS+=("$@")
            break
            ;;
        *)
            echo "error: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! command -v "${QEMU_BIN}" >/dev/null 2>&1; then
    echo "error: QEMU executable not found: ${QEMU_BIN}" >&2
    echo "Set QEMU_BIN or install qemu-system-arm." >&2
    exit 1
fi

if [[ ! -f "${ELF}" ]]; then
    echo "error: ELF not found: ${ELF}" >&2
    echo "Build it with: python3 tools/nx.py build --board mps2_an505 --type debug" >&2
    exit 1
fi

QEMU_ARGS=(
    -M mps2-an505
    -cpu cortex-m33
    -kernel "${ELF}"
    -nographic
    -serial mon:stdio
    -gdb "tcp::${GDB_PORT}"
)

if [[ "${WAIT_FOR_GDB}" -eq 1 ]]; then
    QEMU_ARGS+=( -S )
fi

printf 'Launching QEMU: %q' "${QEMU_BIN}"
printf ' %q' "${QEMU_ARGS[@]}" "${EXTRA_QEMU_ARGS[@]}"
printf '\n'
exec "${QEMU_BIN}" "${QEMU_ARGS[@]}" "${EXTRA_QEMU_ARGS[@]}"
