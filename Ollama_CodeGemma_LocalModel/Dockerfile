# ─────────────────────────────────────────────────────────────
#  Dockerfile — Ollama + CodeGemma
#
#  Builds a custom image with CodeGemma baked in.
#  Use this if you want a single portable image without
#  needing the separate ollama-init service.
#
#  Build:  docker build -t my-codegemma .
#  Run:    docker run -p 11434:11434 my-codegemma
# ─────────────────────────────────────────────────────────────

FROM ollama/ollama:latest

# Set model name as a build arg so you can swap easily
# Options: codegemma:2b (faster, <8GB RAM)
#          codegemma:7b (better quality, 8GB+ RAM)
ARG MODEL=qwen2.5-coder:7b

# Environment
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_KEEP_ALIVE=24h

# Pull the model during image build
# The server must be running in the background while we pull
RUN ollama serve & \
    sleep 8 && \
    ollama pull ${MODEL} && \
    pkill ollama || true

# Expose the Ollama API port
EXPOSE 11434

# Start Ollama in the foreground
ENTRYPOINT ["ollama", "serve"]
