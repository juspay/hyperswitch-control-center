git clone https://github.com/juspay/hyperswitch

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Navigate to the cloned directory
cd hyperswitch
sed 's|juspaydotin/hyperswitch-router:standalone|juspaydotin/hyperswitch-router:nightly-standalone|g' docker-compose.yml > docker-compose.tmp
mv docker-compose.tmp docker-compose.yml
docker --version
# chmod +x /usr/local/bin/docker-compose
# docker-compose
# docker-compose --version
# # Start Docker Compose services in detached mode
docker-compose up -d pg redis-standalone migration_runner hyperswitch-server