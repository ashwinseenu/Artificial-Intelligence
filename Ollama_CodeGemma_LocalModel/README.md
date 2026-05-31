# CodeGemma Local AI — Docker Setup

Run **CodeGemma** (Google's code-focused LLM) 100% locally using Docker Desktop.
Access it via a browser chat UI at `http://localhost:3000` and hook it into VS Code.

---

## Architecture

```
Browser (localhost:3000)
       │
       ▼ HTTP
┌──────────────────────────────────────────┐
│         Docker Desktop                   │
│                                          │
│  ┌─────────────────┐                     │
│  │   Open WebUI    │ ← chat interface    │
│  │   port 3000     │                     │
│  └────────┬────────┘                     │
│           │ REST API                     │
│  ┌────────▼────────┐   ┌──────────────┐  │
│  │  Ollama Server  │──▶│ CodeGemma 7b │  │
│  │  port 11434     │   │  (model)     │  │
│  └────────┬────────┘   └──────────────┘  │
│           │                              │
│  [ollama_data volume]                    │
└──────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| **Docker Desktop** | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) |
| **RAM** | 8 GB min (for 7b model), 4 GB if using 2b model |
| **Disk** | ~6 GB for the 7b model, ~2 GB for 2b |
| **OS** | macOS, Windows (WSL2), Linux |

---

## Quick Start

### Step 1 — Clone or copy this folder

```bash
cd ~/your-projects
# Copy all files from this folder here
```

### Step 2 — Make the helper script executable

```bash
chmod +x manage.sh
```

### Step 3 — Start the stack

```bash
./manage.sh start
```

Or directly with Docker Compose:

```bash
docker compose up -d
```

### Step 4 — Wait for model download (first run only)

The `ollama-init` service pulls `codegemma:7b` (~5 GB) automatically.
Watch progress:

```bash
./manage.sh logs
# OR
docker logs -f ollama-init
```

You'll see `>>> Model ready!` when it's done.

### Step 5 — Open in your browser

```
http://localhost:3000
```

That's it! Start chatting with CodeGemma.

---

## Using the API directly

The Ollama REST API is available at `http://localhost:11434`.

### Chat completion

```bash
curl http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codegemma:7b",
    "prompt": "Write a Python function to reverse a linked list",
    "stream": false
  }'
```

### List available models

```bash
curl http://localhost:11434/api/tags
```

### OpenAI-compatible endpoint (works with OpenAI SDK)

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codegemma:7b",
    "messages": [
      {"role": "user", "content": "Explain async/await in JavaScript"}
    ]
  }'
```

---

## Python integration

```python
# pip install ollama
import ollama

response = ollama.chat(
    model='codegemma:7b',
    messages=[{
        'role': 'user',
        'content': 'Write a FastAPI endpoint that accepts a JSON body and returns it reversed'
    }]
)
print(response['message']['content'])
```

Or via the OpenAI SDK (drop-in replacement):

```python
# pip install openai
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="not-needed"
)

response = client.chat.completions.create(
    model="codegemma:7b",
    messages=[{"role": "user", "content": "Write a SQL query to find duplicate emails"}]
)
print(response.choices[0].message.content)
```

---

## VS Code integration

### Option A — Continue (recommended)

1. Install the **Continue** extension from the VS Code marketplace
2. Copy `vscode-settings.json` contents into your VS Code settings
3. Use `Cmd+I` (Mac) / `Ctrl+I` (Windows) for inline AI edits
4. Use `Cmd+L` for the side panel chat

### Option B — CodeGPT extension

1. Install **CodeGPT** extension
2. Set provider to Ollama, model to `codegemma:7b`
3. API URL: `http://localhost:11434`

---

## Using the 2b model (low-RAM laptops)

Edit `docker-compose.yml` — change all occurrences of `codegemma:7b` to `codegemma:2b`:

```yaml
# ollama-init entrypoint
ollama pull codegemma:2b

# open-webui environment
- DEFAULT_MODELS=codegemma:2b
```

Or pull additional models alongside:

```bash
./manage.sh pull-model codegemma:2b
./manage.sh pull-model codellama:7b
./manage.sh pull-model deepseek-coder:6.7b
```

All models appear automatically in the Open WebUI dropdown.

---

## Management commands

```bash
./manage.sh start          # Start all services
./manage.sh stop           # Stop all services
./manage.sh logs           # Watch live logs
./manage.sh status         # Container status
./manage.sh pull-model     # Pull/update codegemma:7b
./manage.sh reset          # Full reset (deletes downloaded models!)
```

---

## Ports reference

| Port | Service | URL |
|---|---|---|
| `3000` | Open WebUI (browser chat) | http://localhost:3000 |
| `11434` | Ollama REST API | http://localhost:11434 |

---

## Troubleshooting

**Model not loading / UI shows "no models"**
```bash
# Check if Ollama is healthy
curl http://localhost:11434/api/tags

# Manually pull the model
docker exec ollama ollama pull codegemma:7b
```

**Out of memory / container crashing**
- Switch to `codegemma:2b` (uses ~3 GB RAM vs ~8 GB)
- Increase Docker Desktop memory limit: Docker Desktop → Settings → Resources → Memory → set to 10 GB+

**Port already in use**
- Change `"3000:8080"` to `"3001:8080"` in `docker-compose.yml`
- Access at `http://localhost:3001`

**Slow responses**
- Normal for CPU-only. First response after idle takes 10–30s (model loading)
- `OLLAMA_KEEP_ALIVE=24h` keeps model in memory between requests

**Windows WSL2 performance**
- Store project files inside WSL2 filesystem (`~/`) not on `/mnt/c/`
- Ensure WSL2 backend is enabled in Docker Desktop settings

---

## Security note

`WEBUI_AUTH=false` is set by default for easy local use.
To require a login, change it to `WEBUI_AUTH=true` and create an account on first visit.
