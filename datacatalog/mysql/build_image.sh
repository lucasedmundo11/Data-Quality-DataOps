docker build -f Dockerfile.mysql.curso_id_logs -t tonanuvem/mysql:curso_id_logs .
docker login
docker push tonanuvem/mysql:curso_id_logs
