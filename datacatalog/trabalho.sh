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

IP=$(curl -s checkip.amazonaws.com)
echo "Aguardando TOKEN (geralmente 1 min)"
while [ "$(docker logs datacatalog-automl-1 2>&1 | grep token | grep 127. | grep NotebookApp | wc -l)" != "1" ]; do
  printf "."
  sleep 1
done
echo "Token Pronto."
TOKEN=$(docker logs datacatalog-automl-1 2>&1 | grep token | grep 127. | grep NotebookApp | sed -n 's/.*?token=\([a-f0-9]*\).*/\1/p')
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

