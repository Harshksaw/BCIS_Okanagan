# tracert.py
# Network traceroute and ASN lookup utilities

import os
import re
import json
import urllib.request

# Regular expression to match IP addresses
IP_REGEX = re.compile(r'(\d{1,3}(?:\.\d{1,3}){3})')

def trace(ip: str) -> list[str]:
    """Perform traceroute to given IP and return list of unique hops in order."""
    cmd = f"traceroute -n -w 2 -q 1 {ip}"
    try:
        output = os.popen(cmd).read()
        hops = IP_REGEX.findall(output)
        # Remove duplicates while preserving order
        unique_hops = list(dict.fromkeys(hops))
        return unique_hops
    except Exception:
        return []

def asn(ip: str) -> dict | None:
    """Get ASN information for given IP address using ipinfo.io API."""
    try:
        token = os.getenv("IPINFO_TOKEN")
        url = f"https://ipinfo.io/{ip}/json"
        if token:
            url += f"?token={token}"
        
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.load(response)
        
        # Parse organization info (e.g., "AS15169 Google LLC")
        org = data.get("org", "")
        asn_num = None
        org_name = None
        
        if org.startswith("AS"):
            parts = org.split(" ", 1)
            asn_num = parts[0]
            if len(parts) > 1:
                org_name = parts[1]
        
        return {
            "asn": asn_num,
            "org": org_name,
            "country": data.get("country")
        }
    except Exception:
        return None
