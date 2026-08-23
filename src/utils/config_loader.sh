#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../../config/config.conf"

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[ERROR] Config file not found at $CONFIG_FILE" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    if [ -z "${CPU_THRESHOLD:-}" ] ||
       [ -z "${RAM_THRESHOLD:-}" ] ||
       [ -z "${DISK_THRESHOLD:-}" ] ||
       [ -z "${REFRESH_INTERVAL:-}" ]; then
        echo "[ERROR] One or more configuration variables are missing in $CONFIG_FILE" >&2
        return 1
    fi

    return 0
}
