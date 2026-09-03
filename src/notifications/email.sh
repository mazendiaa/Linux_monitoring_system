#!/bin/bash

send_email_alert() {
    local resource="${1:-}"
    local value="${2:-}"
    local level="${3:-}"

    # Email notifications are disabled by configuration.
    if [ "${EMAIL_NOTIFICATIONS_ENABLED:-false}" != "true" ]; then
        return 0
    fi

    # Required dependency.
    if ! command -v curl >/dev/null 2>&1; then
        echo "[EMAIL ERROR] curl is not installed." >&2
        return 1
    fi

    # API key must come from the environment, never from config files.
    if [ -z "${RESEND_API_KEY:-}" ]; then
        echo "[EMAIL ERROR] RESEND_API_KEY is not set." >&2
        return 1
    fi

    if [ -z "${EMAIL_RECIPIENT:-}" ] || [ -z "${EMAIL_FROM:-}" ]; then
        echo "[EMAIL ERROR] EMAIL_RECIPIENT or EMAIL_FROM is not configured." >&2
        return 1
    fi

    local hostname_value
    hostname_value=$(hostname 2>/dev/null || echo "unknown")

    local subject
    subject="[Linux Monitor] ${level}: ${resource} usage is ${value}%"

    local html
    html="<html><body>"
    html+="<h2>Linux System Monitoring Alert</h2>"
    html+="<p><strong>Resource:</strong> ${resource}</p>"
    html+="<p><strong>Level:</strong> ${level}</p>"
    html+="<p><strong>Current Value:</strong> ${value}%</p>"
    html+="<p><strong>Host:</strong> ${hostname_value}</p>"
    html+="<p><strong>Time:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>"
    html+="</body></html>"

    # Build valid JSON without requiring Python/jq.
    local payload
    payload=$(
        printf '%s\n%s\n%s\n%s\n' \
            "$EMAIL_FROM" \
            "$EMAIL_RECIPIENT" \
            "$subject" \
            "$html" |
        perl -MJSON::PP -0777 -e '
            my @values = split /\n/, <STDIN>, -1;
            pop @values if @values && $values[-1] eq "";
            print encode_json({
                from    => $values[0],
                to      => [$values[1]],
                subject => $values[2],
                html    => $values[3]
            });
        '
    )

    if [ -z "$payload" ]; then
        echo "[EMAIL ERROR] Failed to build JSON payload." >&2
        return 1
    fi

    local response
    local http_code

    response=$(curl -sS \
        -w '\n%{http_code}' \
        --connect-timeout 10 \
        --max-time 30 \
        -X POST "https://api.resend.com/emails" \
        -H "Authorization: Bearer ${RESEND_API_KEY}" \
        -H "Content-Type: application/json" \
        --data-raw "$payload" 2>&1) || {
        echo "[EMAIL ERROR] Failed to contact email provider." >&2
        return 1
    }

    http_code=$(printf '%s\n' "$response" | tail -n 1)
    response=$(printf '%s\n' "$response" | sed '$d')

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "[EMAIL] Alert sent successfully: ${resource} ${level} (${value}%)"
        return 0
    fi

    echo "[EMAIL ERROR] Provider returned HTTP ${http_code}: ${response}" >&2
    return 1
}
