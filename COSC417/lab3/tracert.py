# tracert.py
import os
import re
import json
import urllib.request

IP_REGEX = re.compile(r'(\d{1,3}(?:\.\d{1,3}){3})')

def trace(ip: str) -> list[str]:
    """
    Run traceroute and return the ordered list of hop IPs (deduped, in order).
    Uses -n to avoid DNS lookups; handles '*' hops gracefully by regex filtering.
    """

    cmd = f"traceroute -n -w 2 -q 1 {ip}"
    try:
        out = os.popen(cmd).read()
        hops = IP_REGEX.findall(out)
        # Preserve order while removing duplicates
        seen = set()
        ordered = []
        for h in hops:
            if h not in seen:
                seen.add(h)
                ordered.append(h)
        return ordered
    except Exception:
        return []

def asn(ip: str) -> dict | None:

    try:
        token = os.getenv("IPINFO_TOKEN")
        url = f"https://ipinfo.io/{ip}/json" + (f"?token={token}" if token else "")
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.load(r)
        org = data.get("org")  # e.g., "AS15169 Google LLC"
        asn_num = None
        org_name = None
        if org and org.startswith("AS"):
            parts = org.split(" ", 1)
            asn_num = parts[0]
            org_name = parts[1] if len(parts) > 1 else None
        return {
            "asn": asn_num,
            "org": org_name,
            "country": data.get("country"),
        }
    except Exception:
        # As instructed, return None on failure (and don’t crash callers)
        return None
