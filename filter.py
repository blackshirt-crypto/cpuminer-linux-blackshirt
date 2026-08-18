#!/usr/bin/env python3
# filter.py — cpuminer-blackshirt output filter
# Blackshirt Crypto — blkshirtpool.com

import sys
import re
import time
from datetime import datetime

GREEN  = '\033[92m'
RED    = '\033[91m'
YELLOW = '\033[93m'
CYAN   = '\033[96m'
WHITE  = '\033[97m'
DIM    = '\033[2m'
RESET  = '\033[0m'

def ts():
    return datetime.now().strftime('%H:%M:%S')

def out(color, msg):
    print(f"{DIM}[{ts()}]{RESET} {color}{msg}{RESET}", flush=True)

algo    = sys.argv[1] if len(sys.argv) > 1 else 'unknown'
pool    = sys.argv[2] if len(sys.argv) > 2 else ''
threads = sys.argv[3] if len(sys.argv) > 3 else '--'

try:
    pool_name = pool.split('//')[1].split(':')[0]
except:
    pool_name = pool

hashrate  = None
nethash   = None
block     = '--'
netdiff   = '--'
accepted  = 0
rejected  = 0
last_hr   = 0
HR_INTERVAL = 5

print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}", flush=True)
print(f"{CYAN}  cpuminer-blackshirt | {algo} | {pool_name}{RESET}", flush=True)
print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}", flush=True)
out(WHITE, f"Starting miner | threads: {threads} | algo: {algo}")

try:
    for raw in sys.stdin:
        line = raw.strip()
        now  = time.time()

        # Connecting
        if 'Stratum connect stratum' in line:
            m = re.search(r'stratum\S+', line)
            if m:
                out(CYAN, f"Connecting to {m.group()}")

        # Connected
        elif 'Stratum connection established' in line:
            out(CYAN, f"Connected | block {block} | netdiff {netdiff}")

        # Connection lost
        elif 'connection failed' in line or 'Stratum connection reset' in line:
            out(RED, "Connection lost | reconnecting...")

        # New block/work — parse block number, netdiff AND hashrate from TTF line
        elif 'New Block' in line or 'New Work' in line or 'New Stratum Diff' in line:
            b = re.search(r'Block (\d+)', line)
            d = re.search(r'Netdiff ([0-9.]+)', line)
            if b: block = b.group(1)
            if d: netdiff = d.group(1)

        # TTF line — has live hashrate and net hashrate
        elif 'TTF @' in line:
            hr = re.search(r'TTF @ ([0-9.]+) h/s', line)
            nh = re.search(r'Net TTF @ ([0-9.]+) ([kmg]?h/s)', line, re.IGNORECASE)
            if hr: hashrate = hr.group(1)
            if nh: nethash = f"{nh.group(1)} {nh.group(2)}"

        # Net hash rate from "Net hash rate (est)" line
        elif 'Net hash rate' in line:
            nh = re.search(r'Net hash rate \(est\) ([0-9.]+) ([kmg]?h/s)', line, re.IGNORECASE)
            if nh: nethash = f"{nh.group(1)} {nh.group(2)}"

        # Hashrate from periodic report
        elif re.search(r'\([0-9]+\.[0-9]+h/s\)', line):
            m = re.search(r'\(([0-9.]+)h/s\)', line)
            if m: hashrate = m.group(1)

        # Accepted share — multiple possible formats
        elif re.search(r'\d+ Accepted \d+', line) or re.search(r'^\d+ A\d+ S\d+ R\d+ B\d+', line):
            accepted += 1
            d = re.search(r'Submitted Diff ([0-9.e+-]+)', line)
            diff_str = d.group(1) if d else '--'
            total = accepted + rejected
            ratio = f"{100*accepted/total:.1f}%" if total > 0 else "100.0%"
            out(GREEN, f"✓ ACCEPTED  #{accepted} | {ratio} | {rejected} rejected | diff {diff_str}")

        # Rejected share
        elif re.search(r'Rejected \d+', line) and 'Share' not in line and '%' not in line:
            rejected += 1
            r = re.search(r'Reject reason: (.+)', line)
            reason = r.group(1).strip() if r else 'unknown'
            total = accepted + rejected
            ratio = f"{100*accepted/total:.1f}%" if total > 0 else "0.0%"
            out(RED, f"✗ REJECTED  #{accepted} | {ratio} | {rejected} rejected | {reason}")

        # Block solved
        elif 'BLOCK SOLVED' in line or ('Solved' in line and 'block' in line.lower()):
            out(YELLOW, f"★ BLOCK FOUND  block {block} | submitting...")

        # Hashrate heartbeat
        if hashrate and (now - last_hr >= HR_INTERVAL):
            net_str = f" | Net {nethash}" if nethash else ""
            out(WHITE, f"Hashrate {hashrate} H/s{net_str} | block {block}")
            last_hr = now

except KeyboardInterrupt:
    pass

out(CYAN, "Miner stopped.")
sys.exit(0)
