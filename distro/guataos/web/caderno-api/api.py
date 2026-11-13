#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""API de busca de receitas do Caderno da Mãe (PWA/APK).
Porta da lógica do app desktop: busca no DuckDuckGo, lê schema.org/Recipe das
páginas e devolve a receita estruturada (sem anúncios). Só stdlib."""
import json, re, base64, urllib.request, urllib.parse, html as htmlmod
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

UA = ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) "
      "Chrome/122.0 Safari/537.36")


def _get(url, timeout=9):
    req = urllib.request.Request(url, headers={
        "User-Agent": UA, "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.6"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        cs = r.headers.get_content_charset() or "utf-8"
        return r.read().decode(cs, "replace")


def _clean(s):
    s = re.sub(r"<[^>]+>", "", str(s))
    s = htmlmod.unescape(htmlmod.unescape(s))
    return re.sub(r"\s+", " ", s).strip()


def _iso_tempo(iso):
    m = re.match(r"PT(?:(\d+)H)?(?:(\d+)M)?", str(iso or ""))
    if not m:
        return ""
    h, mi = m.group(1), m.group(2)
    out = []
    if h:  out.append(f"{h} h")
    if mi: out.append(f"{mi} min")
    return " ".join(out)


def _iter(data):
    if isinstance(data, list):
        for x in data:
            yield from _iter(x)
    elif isinstance(data, dict):
        yield data
        if "@graph" in data:
            yield from _iter(data["@graph"])


def _normalizar(o):
    name = _clean(o.get("name", ""))
    img = o.get("image")
    if isinstance(img, dict): img = img.get("url")
    if isinstance(img, list) and img:
        img = img[0].get("url") if isinstance(img[0], dict) else img[0]
    ings = o.get("recipeIngredient") or o.get("ingredients") or []
    if isinstance(ings, str): ings = [ings]
    ings = [_clean(i) for i in ings if _clean(i)]
    steps = []
    ins = o.get("recipeInstructions") or []
    if isinstance(ins, str):
        steps = [_clean(x) for x in re.split(r"\r?\n|\.(?=\s+[A-ZÀ-Ú0-9])", ins) if _clean(x)]
    else:
        for s in ins:
            if isinstance(s, dict):
                if str(s.get("@type", "")).lower() == "howtosection":
                    for s2 in s.get("itemListElement", []):
                        if isinstance(s2, dict): steps.append(_clean(s2.get("text", "")))
                else:
                    steps.append(_clean(s.get("text") or s.get("name") or ""))
            else:
                steps.append(_clean(s))
    steps = [s for s in steps if s]
    tempo = _iso_tempo(o.get("totalTime") or o.get("cookTime") or "")
    if not (name and ings and steps):
        return None
    return {"titulo": name, "tempo": tempo, "ingredientes": ings,
            "passos": steps, "imagem_url": img}


def _recipe_da_pagina(page):
    for m in re.finditer(r'<script[^>]+application/ld\+json[^>]*>(.*?)</script>',
                         page, re.DOTALL | re.IGNORECASE):
        raw = m.group(1).strip()
        try:
            data = json.loads(raw)
        except Exception:
            continue
        for obj in _iter(data):
            t = obj.get("@type")
            types = t if isinstance(t, list) else [t]
            if any(str(x).lower() == "recipe" for x in types):
                r = _normalizar(obj)
                if r:
                    return r
    return None


def _buscar_links(query):
    q = urllib.parse.quote(query + " receita")
    try:
        sr = _get(f"https://html.duckduckgo.com/html/?q={q}")
    except Exception:
        return []
    urls = []
    for l in re.findall(r'<a[^>]+class="result__a"[^>]+href="([^"]+)"', sr):
        m = re.search(r"uddg=([^&]+)", l)
        u = urllib.parse.unquote(m.group(1)) if m else l
        if u.startswith("http") and "duckduckgo.com" not in u:
            urls.append(u)
    return urls


def _baixar_img(url):
    if not url:
        return None
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=10) as r:
            data = r.read()
            if len(data) > 3_000_000:
                return None
            ct = r.headers.get_content_type() or "image/jpeg"
            return f"data:{ct};base64," + base64.b64encode(data).decode()
    except Exception:
        return None


def buscar_receita(query):
    for u in _buscar_links(query)[:5]:
        try:
            page = _get(u)
        except Exception:
            continue
        rec = _recipe_da_pagina(page)
        if rec:
            rec["fonte"] = u
            rec["foto"] = _baixar_img(rec.get("imagem_url"))
            return rec
    return None


class H(BaseHTTPRequestHandler):
    def _head(self, code=200):
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Cache-Control", "public, max-age=900")
        self.end_headers()

    def do_OPTIONS(self):
        self._head(204)

    def do_GET(self):
        p = urllib.parse.urlparse(self.path)
        if p.path in ("/", "/health"):
            self._head(200); self.wfile.write(b'{"ok":true}'); return
        qs = urllib.parse.parse_qs(p.query)
        q = (qs.get("q", [""])[0] or "").strip()
        if not q:
            self._head(400); self.wfile.write(json.dumps({"erro": "faltou o termo (q)"}).encode()); return
        try:
            rec = buscar_receita(q) or {"erro": "não achei uma receita boa pra isso"}
        except Exception:
            rec = {"erro": "falha na busca, tente de novo"}
        self._head(200)
        self.wfile.write(json.dumps(rec, ensure_ascii=False).encode("utf-8"))

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    print("caderno-api ouvindo em :8080", flush=True)
    ThreadingHTTPServer(("0.0.0.0", 8080), H).serve_forever()
