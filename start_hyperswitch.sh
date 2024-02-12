git clone https://github.com/juspay/hyperswitch

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Navigate to the cloned directory
cd hyperswitch
docker --version
chmod +x /usr/local/bin/docker-compose
# docker-compose
# docker-compose --version
# # Start Docker Compose services in detached mode
docker-compose up -d