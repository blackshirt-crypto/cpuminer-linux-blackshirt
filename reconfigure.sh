#!/bin/bash
# cpuminer-blackshirt reconfigure script
# Blackshirt Crypto — blkshirtpool.com

INSTALL_DIR=~/cpuminer-blackshirt

clear
echo ""
echo "  cpuminer-blackshirt — Reconfigure"
echo "  ═══════════════════════════════════"
echo ""

# Find saved start scripts
SAVED=(~/cpuminer-blackshirt/start-*.sh)

if [ ${#SAVED[@]} -eq 0 ] || [ ! -f "${SAVED[0]}" ]; then
    echo "  No saved mining configs found."
    echo "  Run ~/cpuminer-blackshirt/setup-cpuminer-blackshirt.sh to create one."
    echo ""
    exit 0
fi

# If multiple configs, let user pick which one
if [ ${#SAVED[@]} -gt 1 ]; then
    echo "  Multiple configs found:"
    echo ""
    i=1
    for f in "${SAVED[@]}"; do
        ALGO=$(basename "$f" .sh | sed 's/start-//')
        echo "  $i) $ALGO"
        i=$((i+1))
    done
    echo ""
    read -p "  Which config to edit (1-$((i-1))): " PICK
    if ! [[ "$PICK" =~ ^[0-9]+$ ]] || [ "$PICK" -lt 1 ] || [ "$PICK" -gt $((i-1)) ]; then
        echo "  Invalid choice."
        exit 1
    fi
    SELECTED="${SAVED[$((PICK-1))]}"
else
    SELECTED="${SAVED[0]}"
fi

# Read current values from the selected config
CUR_ALGO=$(grep    '^ALGO='    "$SELECTED" | cut -d'=' -f2-)
CUR_POOL=$(grep    '^POOL='    "$SELECTED" | head -1 | cut -d'=' -f2-)
CUR_POOL2=$(grep   '^POOL2='   "$SELECTED" | cut -d'=' -f2-)
CUR_WALLET=$(grep  '^WALLET='  "$SELECTED" | cut -d'=' -f2- | cut -d'.' -f1)
CUR_WORKER=$(grep  '^WALLET='  "$SELECTED" | cut -d'=' -f2- | grep -oE '\.[a-zA-Z0-9_-]+$' | tr -d '.')
CUR_PASS=$(grep    '^PASS='    "$SELECTED" | cut -d'=' -f2-)
CUR_THREADS=$(grep '^THREADS=' "$SELECTED" | cut -d'=' -f2-)

# Truncate long values for display
display_val() {
    local val="$1"
    local max=40
    if [ ${#val} -gt $max ]; then
        echo "${val:0:$max}..."
    else
        echo "$val"
    fi
}

show_config() {
    clear
    echo ""
    echo "  cpuminer-blackshirt — Reconfigure"
    echo "  ═══════════════════════════════════"
    echo ""
    echo "  Config: $(basename $SELECTED)"
    echo ""
    echo "  ┌────────────────────────────────────────────┐"
    printf "  │ %-8s %-35s│\n" "ALGO:"    "$(display_val $CUR_ALGO)"
    printf "  │ %-8s %-35s│\n" "POOL:"    "$(display_val $CUR_POOL)"
    if [ -n "$CUR_POOL2" ]; then
    printf "  │ %-8s %-35s│\n" "BACKUP:"  "$(display_val $CUR_POOL2)"
    else
    printf "  │ %-8s %-35s│\n" "BACKUP:"  "(none)"
    fi
    printf "  │ %-8s %-35s│\n" "WALLET:"  "$(display_val $CUR_WALLET)"
    printf "  │ %-8s %-35s│\n" "WORKER:"  "${CUR_WORKER:-(none)}"
    printf "  │ %-8s %-35s│\n" "PASS:"    "$(display_val $CUR_PASS)"
    printf "  │ %-8s %-35s│\n" "THREADS:" "$CUR_THREADS"
    echo "  └────────────────────────────────────────────┘"
    echo ""
    echo "  What would you like to change?"
    echo "  1) Pool address"
    echo "  2) Wallet address"
    echo "  3) Worker name"
    echo "  4) Password"
    echo "  5) Threads"
    echo "  6) Start over (re-run full setup)"
    echo "  0) Exit — keep current settings"
    echo ""
}

show_config
read -p "  Choice: " WHAT

case $WHAT in
    1)
        echo ""
        echo "  Current pool: $CUR_POOL"
        echo "  Format: stratum+tcp://HOST:PORT"
        read -p "  New pool address (Enter to keep): " NEW_POOL
        if [ -n "$NEW_POOL" ]; then
            CUR_POOL="$NEW_POOL"
            sed -i "s|^POOL=.*|POOL=$NEW_POOL|" "$SELECTED"
            echo "  Pool updated."
        else
            echo "  No change."
        fi
        ;;
    2)
        echo ""
        echo "  Current wallet: $CUR_WALLET"
        read -p "  New wallet address: " NEW
        if [ -n "$NEW" ]; then
            CUR_WALLET="$NEW"
            sed -i "s|^WALLET=.*|WALLET=${NEW}${CUR_WORKER:+.$CUR_WORKER}|" "$SELECTED"
            echo "  Wallet updated."
        else
            echo "  No change."
        fi
        ;;
    3)
        echo ""
        echo "  Current worker: ${CUR_WORKER:-(none)}"
        read -p "  New worker name (Enter to keep, type 'none' to remove): " NEW
        if [ "$NEW" = "none" ]; then
            sed -i "s|^WALLET=.*|WALLET=$CUR_WALLET|" "$SELECTED"
            echo "  Worker removed."
        elif [ -n "$NEW" ]; then
            sed -i "s|^WALLET=.*|WALLET=$CUR_WALLET.$NEW|" "$SELECTED"
            echo "  Worker updated."
        else
            echo "  No change."
        fi
        ;;
    4)
        echo ""
        echo "  Current password: $CUR_PASS"
        read -p "  New password: " NEW
        if [ -n "$NEW" ]; then
            sed -i "s|^PASS=.*|PASS=$NEW|" "$SELECTED"
            echo "  Password updated."
        else
            echo "  No change."
        fi
        ;;
    5)
        echo ""
        MAX_THREADS=$(nproc)
        echo "  Current threads: $CUR_THREADS"
        echo "  Your device has $MAX_THREADS CPU cores available."
        while true; do
            read -p "  New thread count (1-$MAX_THREADS, Enter to keep): " NEW
            if [ -z "$NEW" ]; then
                echo "  No change."
                break
            fi
            if [[ "$NEW" =~ ^[0-9]+$ ]] && [ "$NEW" -ge 1 ] && [ "$NEW" -le "$MAX_THREADS" ]; then
                sed -i "s|^THREADS=.*|THREADS=$NEW|" "$SELECTED"
                echo "  Threads updated."
                break
            fi
            echo "  Please enter a number between 1 and $MAX_THREADS."
        done
        ;;
    6)
        exec ~/cpuminer-blackshirt/setup-cpuminer-blackshirt.sh
        ;;
    0)
        echo ""
        echo "  No changes made. Current settings kept."
        echo ""
        exit 0
        ;;
    *)
        echo "  Invalid choice."
        exit 1
        ;;
esac

echo ""
echo "  Config saved to: $SELECTED"
echo "  Run it with: $SELECTED"
echo ""
