#!/bin/bash
echo "Verificando o Debezium CDC:"
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8073)" != "200" ]]; do printf "."; sleep 5; done'
echo "Debezium CDC is up"

#HOST_IP=$(curl checkip.amazonaws.com)
#echo $HOST_IP

echo "Configurando CDC para MySQL"
curl -s -X POST http://localhost:8073/connectors \
  -H "accept: */*" -H "Content-Type: application/json" \
  -d '{
      "name": "curso-mysql-connector",
      "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "cursomysql",
        "database.port": "3306",
        "database.user": "root",
        "database.password": "admin",
        "database.server.id": "223344",
        "database.server.name": "cursomysql",
        "database.include.list": "fiap",
        "database.history.kafka.bootstrap.servers": "kafka:9092",
        "database.history.kafka.topic": "cursomysql.fiap",
        "include.schema.changes": "true"
      }
    }' \
  | python3 -mjson.tool
