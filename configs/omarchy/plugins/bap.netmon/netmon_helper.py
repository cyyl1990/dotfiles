#!/usr/bin/env python3
"""Read /proc/net/dev and return bandwidth stats for active interfaces.

Usage: python3 netmon_helper.py [iface_pattern]

Reads /proc/net/dev, finds interfaces matching the pattern (default: all
non-loopback), and returns total RX+TX bytes since last reading (delta).
Writes one line to stdout: rX_bytes:TX_bytes (cumulative; caller subtracts
previous reading to get speed).
"""
import sys
import re

IFACE_RE = re.compile(
    r"^\s*(\w+):\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+)"
)


def main():
    pattern = sys.argv[1] if len(sys.argv) > 1 else ""
    totals = {"rx": 0, "tx": 0}

    try:
        with open("/proc/net/dev", "r") as f:
            for line in f:
                m = IFACE_RE.match(line)
                if not m:
                    continue
                iface, rx, tx = m.groups()
                if iface == "lo":
                    continue
                if pattern and pattern not in iface:
                    continue
                totals["rx"] += int(rx)
                totals["tx"] += int(tx)
    except OSError:
        pass

    print(f"{totals['rx']}:{totals['tx']}", flush=True)


if __name__ == "__main__":
    main()
