# RUN

# TRABALHO CONTEMPLA AS SEGUINTES FERRAMENTAS:
docker network create --driver overlay app_net
docker stack deploy --compose-file docker-compose-visualizador.yml dataops

## MYSQL e KAFKA 

echo ""
echo "Executando os componentes da solução:"
echo ""
# docker-compose -f docker-compose-curso.yml up -d
docker stack deploy --compose-file docker-compose-curso.yml dataops
echo ""


## JUPYTER NOTEBOOK PARA DEMONSTRAR AUTO ML

## ML FLOW PARA DEMONSTRAR FLUXO DE MLOPS

## OPEN METADATA PARA DEMONSTRAR GOVERNANÇA DE DADOS, ESPECIALMENTE DATA DISCOVERY E DATA QUALITY


# Executando local

### JUPYTER NOTEBOOK PARA DEMONSTRAR AUTO ML:

docker stack deploy --compose-file docker-compose-jupyter.yml dataops
#docker-compose -f docker-compose-jupyter.yml up -d
#docker run -it --name automl -v ${PWD}/ml:/opt/nb -p 8789:8888 -d mfeurer/auto-sklearn:master /bin/bash -c "mkdir -p /opt/nb && jupyter notebook --notebook-dir=/opt/nb --ip='0.0.0.0' --port=8888 --no-browser --allow-root"
#sudo yum install -y swig python3-devel

### ML FLOW PARA DEMONSTRAR FLUXO DE MLOPS:

#docker stack deploy --compose-file ../docker-compose-mlflow.yml dataops
#docker run -d --name mlflow-container -e TZ=UTC -p 5000:5000 ubuntu/mlflow:2.1.1_1.0-22.04_stable
#python3 -m venv mlflow
#source mlflow/bin/activate
#pip install mlflow
#mlflow server --host 0.0.0.0 --port 8089 &


### OPEN METADATA:

echo ""
echo "Rodando local o OPEN METADATA"
echo ""
sh ../local_run_openmetadata.sh

# rodando no cluster nao ta funcionando
# docker stack deploy --compose-file docker-swarm-openmetadata.yml dataops

echo ""
echo "Configurando o CDC"
echo ""
sh ../config_cdc.sh
### URLs DO PROJETO:

IP=$(curl -s checkip.amazonaws.com)
echo "Aguardando TOKEN (geralmente 1 min)"
while [ "$(docker service logs dataops_automl | grep token | grep 127. | grep NotebookApp | wc -l)" != "1" ]; do
  printf "."
  sleep 1
done
echo "Token Pronto."
TOKEN=$(docker service logs dataops_automl | grep token | grep 127. | grep NotebookApp | sed -n 's/.*?token=\([a-f0-9]*\).*/\1/p')

echo ""
echo ""
echo "Config OK"
echo ""
echo ""
echo "URLs do projeto:"
echo ""
echo " - CLUSTER UI           : http://$IP:8081"
echo ""
echo " - PHPMYADMIN MYSQL UI  : http://$IP:8082"
echo ""
echo " - KAFKA UI             : http://$IP:8070"
echo ""
echo " - JUPYTER AUTO ML      : http://$IP:8789/?token=$TOKEN"
echo ""
echo " - MLFLOW UI            : http://$IP:8089"
echo ""
echo " - OPEN METADATA        : http://$IP:8585   (login = admin@open-metadata.org, password = admin)"
echo ""
echo " - AIRFLOW COM EXEMPLOS : http://$IP:8080   (login = admin, password = admin)"
echo ""
