# TRABALHO CONTEMPLA AS SEGUINTES FERRAMENTAS:

#docker network create app_net
echo ""
echo "Parando todos os containers em execução... evitando conflito de portas..."
docker ps -q | xargs -r docker stop
echo ""
echo "Todos os containers foram parados."


### JUPYTER NOTEBOOK PARA REALIZAR OS TESTES:

docker-compose -f docker-compose-jupyter.yml up -d


### URLs DO PROJETO:

IP=$(curl -s --max-time 5 checkip.amazonaws.com 2>/dev/null || echo "localhost")
echo "Aguardando TOKEN (pode levar 2-5 min em Apple Silicon via emulação amd64)..."
ELAPSED=0
MAX_WAIT=300
while true; do
  LOGS=$(docker logs datacatalog-automl-1 2>&1)
  # Detecta NotebookApp (Jupyter 6.x) ou ServerApp (Jupyter 7.x)
  TOKEN_LINE=$(echo "$LOGS" | grep 'token' | grep '127\.' | grep -E 'NotebookApp|ServerApp' | head -1)
  if [ -n "$TOKEN_LINE" ]; then
    break
  fi
  if [ "$ELAPSED" -ge "$MAX_WAIT" ]; then
    echo ""
    echo "TIMEOUT: container não respondeu em ${MAX_WAIT}s."
    echo "Verifique: docker logs datacatalog-automl-1"
    exit 1
  fi
  printf "."
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done
echo ""
echo "Token Pronto. (${ELAPSED}s)"
TOKEN=$(echo "$TOKEN_LINE" | sed -n 's/.*?token=\([a-f0-9]*\).*/\1/p')
echo ""

echo ""
echo ""
echo "Config OK"
echo ""
echo "TRABALHO :  definir e implementar critérios de qualidade de dados."
echo ""
echo "   Gere um vídeo de até cinco (5) minutos utilizando a ferramenta https://www.loom.com/screen-recorder com as evidências de conclusão e respostas"
echo "   explicando cada um dos testes implementados."
echo ""
echo " - JUPYTER AUTO ML      : http://$IP:8789/?token=$TOKEN"
echo ""

