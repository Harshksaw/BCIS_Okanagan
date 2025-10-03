# map.py
import json
import socket
from urllib.parse import urlparse

from crawl import crawl
from tracert import trace, asn


START_URL = "https://en.wikipedia.org/wiki/Canada"
STEPS = 100         
OUTFILE = "netdata.json"
OUTPUT: dict[str, dict] = {}

def main():

    urls = crawl(START_URL, STEPS)


    for url in urls:
        try:
            host = urlparse(url).netloc
            if not host:
                continue
            addr = socket.gethostbyname(host)
            route = trace(addr)

            prev = None
            for hop in route:

                if hop not in OUTPUT:
                    OUTPUT[hop] = {"urls": [url], "links": [], "asn": {}}
                else:

                    if url not in OUTPUT[hop]["urls"]:
                        OUTPUT[hop]["urls"].append(url)


                if prev:
                    if prev not in OUTPUT[hop]["links"]:
                        OUTPUT[hop]["links"].append(prev)
                    if hop not in OUTPUT[prev]["links"]:
                        OUTPUT[prev]["links"].append(hop)


                if not OUTPUT[hop]["asn"]:
                    info = asn(hop)
                    if info:
                        OUTPUT[hop]["asn"] = info

                prev = hop

        except Exception as e:
            print(f"[warn] skipping {url}: {e}")



    with open(OUTFILE, "a+") as f:
        f.write(json.dumps(OUTPUT, indent=2, sort_keys=True))

if __name__ == "__main__":
    main()
