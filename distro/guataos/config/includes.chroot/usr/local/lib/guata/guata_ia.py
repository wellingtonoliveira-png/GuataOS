# -*- coding: utf-8 -*-
"""Cliente de IA do Guatá — ponto ÚNICO usado por todos os apps (Assistente,
Ocara, Caderno da Mãe, Kurumim). Multi-provedor: Claude nativo + qualquer IA
no padrão OpenAI-compatível (OpenAI, Gemini, OpenRouter, Groq, Ollama/LM Studio).
Só stdlib (urllib). A chave fica por usuário em ~/.config/guata/ia.json (chmod 600).
"""
import os, json, urllib.request, urllib.error

CFG_DIR = os.path.expanduser("~/.config/guata")
CFG = os.path.join(CFG_DIR, "ia.json")

# tipo: "claude" (API nativa) | "openai" (compatível) | "proxy" (gateway do Guatá, sem chave)
PRESETS = {
    "claude":     {"nome": "Claude (Anthropic)",               "tipo": "claude", "base": "https://api.anthropic.com/v1",                      "modelo": "claude-sonnet-5"},
    "openai":     {"nome": "OpenAI (GPT)",                      "tipo": "openai", "base": "https://api.openai.com/v1",                        "modelo": "gpt-4o-mini"},
    "gemini":     {"nome": "Gemini (Google)",                  "tipo": "openai", "base": "https://generativelanguage.googleapis.com/v1beta/openai", "modelo": "gemini-1.5-flash"},
    "openrouter": {"nome": "OpenRouter",                       "tipo": "openai", "base": "https://openrouter.ai/api/v1",                     "modelo": "openai/gpt-4o-mini"},
    "groq":       {"nome": "Groq",                             "tipo": "openai", "base": "https://api.groq.com/openai/v1",                   "modelo": "llama-3.3-70b-versatile"},
    "local":      {"nome": "Local (Ollama/LM Studio)",         "tipo": "openai", "base": "http://localhost:11434/v1",                        "modelo": "llama3.1"},
    "outro":      {"nome": "Outro (OpenAI-compatível / Azure)","tipo": "openai", "base": "",                                                 "modelo": ""},
}
ORDEM = ["claude", "openai", "gemini", "openrouter", "groq", "local", "outro"]


def carregar_cfg():
    try:
        with open(CFG) as f:
            return json.load(f)
    except Exception:
        return {}


def salvar_cfg(d):
    os.makedirs(CFG_DIR, exist_ok=True)
    tmp = CFG + ".tmp"
    with open(tmp, "w") as f:
        json.dump(d, f, indent=2)
    os.replace(tmp, CFG)
    try:
        os.chmod(CFG, 0o600)
    except Exception:
        pass


def perfil(cfg=None):
    """Perfil ativo: {tipo, base, modelo, api_key}. Lê ~/.config/guata/ia.json se cfg=None."""
    if cfg is None:
        cfg = carregar_cfg()
    prov = cfg.get("provedor", "claude")
    if prov not in PRESETS:
        prov = "claude"
    preset = PRESETS[prov]
    p = cfg.get("perfis", {}).get(prov, {})
    return {
        "tipo": preset["tipo"],
        "base": (p.get("base") or preset["base"]).rstrip("/"),
        "modelo": p.get("modelo") or preset["modelo"],
        "api_key": p.get("api_key", ""),
    }


def precisa_chave(perfil_):
    """True se o provedor exige chave (nuvem) e ela está faltando."""
    return not perfil_["api_key"] and "localhost" not in perfil_["base"]


def _req(url, corpo, headers, timeout):
    req = urllib.request.Request(url, data=corpo, method="POST")
    for k, v in headers.items():
        req.add_header(k, v)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def _erro_http(e):
    try:
        det = json.loads(e.read().decode("utf-8")).get("error", {})
        det = det.get("message", "") if isinstance(det, dict) else str(det)
    except Exception:
        det = ""
    if e.code in (401, 403):
        return "Chave de API inválida ou sem permissão. Confira em Configurações."
    if e.code == 404:
        return "Endereço/modelo não encontrado (404). Confira o endpoint e o modelo."
    if e.code == 429:
        return "Limite de uso atingido. Tente de novo em instantes."
    return f"Erro da API ({e.code}). {det}".strip()


def chamar(perfil_, sistema, mensagens, max_tokens=1024, timeout=60):
    """Conversa (lista de mensagens {role,content}). Retorna (texto, erro)."""
    try:
        if perfil_["tipo"] == "claude":
            corpo = json.dumps({"model": perfil_["modelo"], "max_tokens": max_tokens,
                                "system": sistema, "messages": mensagens}).encode()
            d = _req(perfil_["base"] + "/messages", corpo,
                     {"x-api-key": perfil_["api_key"], "anthropic-version": "2023-06-01",
                      "content-type": "application/json"}, timeout)
            partes = [b.get("text", "") for b in d.get("content", []) if b.get("type") == "text"]
            return ("".join(partes).strip() or "(sem resposta)", None)
        else:
            msgs = [{"role": "system", "content": sistema}] + mensagens
            corpo = json.dumps({"model": perfil_["modelo"], "max_tokens": max_tokens, "messages": msgs}).encode()
            headers = {"content-type": "application/json"}
            if perfil_["api_key"]:
                headers["Authorization"] = "Bearer " + perfil_["api_key"]
            d = _req(perfil_["base"] + "/chat/completions", corpo, headers, timeout)
            return (d["choices"][0]["message"]["content"].strip(), None)
    except urllib.error.HTTPError as e:
        return (None, _erro_http(e))
    except urllib.error.URLError as e:
        return (None, f"Sem conexão com o provedor. {getattr(e, 'reason', '')}".strip())
    except Exception as e:
        return (None, f"Falha inesperada: {e}")


def chamar_texto(perfil_, sistema, texto, max_tokens=1024, timeout=60):
    """Atalho: uma única mensagem do usuário."""
    return chamar(perfil_, sistema, [{"role": "user", "content": texto}], max_tokens, timeout)


def chamar_visao(perfil_, prompt, img_b64, mime, max_tokens=1200, timeout=90):
    """Imagem + texto (modelos com visão). Retorna (texto, erro)."""
    try:
        if perfil_["tipo"] == "claude":
            conteudo = [{"type": "text", "text": prompt},
                        {"type": "image", "source": {"type": "base64", "media_type": mime, "data": img_b64}}]
            corpo = json.dumps({"model": perfil_["modelo"], "max_tokens": max_tokens,
                                "messages": [{"role": "user", "content": conteudo}]}).encode()
            d = _req(perfil_["base"] + "/messages", corpo,
                     {"x-api-key": perfil_["api_key"], "anthropic-version": "2023-06-01",
                      "content-type": "application/json"}, timeout)
            partes = [b.get("text", "") for b in d.get("content", []) if b.get("type") == "text"]
            return ("".join(partes).strip() or "(sem resposta)", None)
        else:
            conteudo = [{"type": "text", "text": prompt},
                        {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{img_b64}"}}]
            corpo = json.dumps({"model": perfil_["modelo"], "max_tokens": max_tokens,
                                "messages": [{"role": "user", "content": conteudo}]}).encode()
            headers = {"content-type": "application/json"}
            if perfil_["api_key"]:
                headers["Authorization"] = "Bearer " + perfil_["api_key"]
            d = _req(perfil_["base"] + "/chat/completions", corpo, headers, timeout)
            return (d["choices"][0]["message"]["content"].strip(), None)
    except urllib.error.HTTPError as e:
        return (None, _erro_http(e))
    except urllib.error.URLError as e:
        return (None, f"Sem conexão com o provedor. {getattr(e, 'reason', '')}".strip())
    except Exception as e:
        return (None, f"Falha inesperada: {e}")


def extrair_json(txt):
    """Pega o 1º objeto JSON de uma resposta (tolera prosa em volta)."""
    try:
        i = txt.index("{"); j = txt.rindex("}") + 1
        return json.loads(txt[i:j])
    except Exception:
        return None
