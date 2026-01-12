#!/usr/bin/env bash
set -euo pipefail

# Style checks intentionally kept simple and fast.
# Current scope: Markdown files tracked by git.

mapfile -t md_files < <(git ls-files '*.md')

if [[ ${#md_files[@]} -eq 0 ]]; then
    echo "No Markdown files found to style-check."
    exit 0
fi

failed=0

check_pattern() {
    local pattern="$1"
    local label="$2"
    local file="$3"

    if grep -nE "$pattern" "$file" >/dev/null; then
        echo "[style] ${label}: ${file}"
        grep -nE "$pattern" "$file"
        failed=1
    fi
}

check_tab_pattern() {
    local file="$1"
    if grep -n $'\t' "$file" >/dev/null; then
        echo "[style] tab character found: ${file}"
        grep -n $'\t' "$file"
        failed=1
    fi
}

check_crlf_pattern() {
    local file="$1"
    if grep -n $'\r' "$file" >/dev/null; then
        echo "[style] CRLF line ending found: ${file}"
        grep -n $'\r' "$file"
        failed=1
    fi
}

for file in "${md_files[@]}"; do
    check_pattern '[[:blank:]]+$' 'trailing whitespace' "$file"
    check_tab_pattern "$file"
    check_crlf_pattern "$file"
done

if [[ $failed -ne 0 ]]; then
    echo
    echo "Style check failed."
    exit 1
fi

echo "Style check passed (${#md_files[@]} Markdown files)."
