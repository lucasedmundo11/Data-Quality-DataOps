# Rodar em cluster nao estava funcionando, vamos rodar local.

curl -sL -o docker-compose-metadata.yml https://github.com/open-metadata/OpenMetadata/releases/download/1.9.2-release/docker-compose.yml

# comentar (adicionar # no início) da linha que começa com "version:" no arquivo YAML:
sed -i '/^version:/ s/^/# /'  docker-compose-metadata.yml

docker-compose -f docker-compose-metadata.yml up -d
#docker-compose -f docker-local-openmetadata.yml up -d

AIRFLOW_msglog="INFO - Starting the scheduler"
OPENMETADATA_msglog="Started application"

echo ""
echo "Aguardando a configuração do OPEN METADATA."
while [ "$(docker logs openmetadata_ingestion 2>&1 | grep "$AIRFLOW_msglog" | wc -l)" != "1" ]; do
  printf "."
  sleep 1
done
while [ "$(docker logs openmetadata_server 2>&1 | grep "$OPENMETADATA_msglog" | wc -l)" != "1" ]; do
  printf "."
  sleep 1
done
