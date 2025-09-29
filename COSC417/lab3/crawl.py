# crawl.py
import re
import time
from random import choice
from urllib.parse import urljoin, urlparse
from urllib.request import Request, urlopen


agents = [
    "Mozilla/5.0 (X11; Linux x86_64)",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
]

HREF_RE = re.compile(r'href=[\'"]?([^\'" >]+)', re.IGNORECASE)

def create_request(url: str) -> Request:
    return Request(url, headers={"User-Agent": choice(agents)})

def fetch(req: Request, timeout_sec: int = 10) -> str | None:
    try:
        with urlopen(req, timeout=timeout_sec) as resp:
            # Only accept 200 OK
            if getattr(resp, "status", 200) != 200:
                return None
            raw = resp.read()
            # decode as best-effort
            return raw.decode("utf-8", errors="replace")
    except Exception:
        return None

def extract_links(html: str, base_url: str) -> list[str]:

    candidates = HREF_RE.findall(str(html))
    abs_links = []
    for link in candidates:
        link = urljoin(base_url, link)
        if link.startswith("http://") or link.startswith("https://"):
            abs_links.append(link.split("#")[0])  # drop fragments
    # unique list
    return list(dict.fromkeys(abs_links))

def crawl(start_url: str, steps: int = 10, delay_sec: int = 5) -> list[str]:
    queue = [start_url]
    crawled = []
    seen = set()

    while queue and len(crawled) < steps:
        url = queue.pop(0)
        if url in seen:
            continue
        seen.add(url)

        req = create_request(url)
        html = fetch(req)
        if html:
            links = extract_links(html, url)
            # simple breadth-first expansion
            for lk in links:
                if lk not in seen:
                    queue.append(lk)
        crawled.append(url)


        time.sleep(delay_sec)

    return crawled
