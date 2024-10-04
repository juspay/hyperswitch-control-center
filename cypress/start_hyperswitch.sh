git clone https://github.com/juspay/hyperswitch

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Navigate to the cloned directory
cd hyperswitch
sed 's|juspaydotin/hyperswitch-router:standalone|juspaydotin/hyperswitch-router:nightly-standalone|g' docker-compose.yml > docker-compose.tmp
mv docker-compose.tmp docker-compose.yml

#!/bin/bash

# Specify the correct file path to the TOML file
#!/bin/bash

# File path of the TOML file
toml_file="config/docker_compose.toml"  # Adjust the path if necessary

# Ensure the file exists
if [[ ! -f "$toml_file" ]]; then
  echo "Error: File $toml_file not found!"
  exit 1
fi

# Use sed to remove the [network_tokenization_service] section and all its keys
sed '/^\[network_tokenization_service\]/,/^\[.*\]/d' "$toml_file" > temp.toml
mv temp.toml "$toml_file"
echo "[network_tokenization_service] section removed from $toml_file."


chmod +x /usr/local/bin/docker-compose
# Start Docker Compose services in detached mode
docker-compose up -d pg redis-standalone migration_runner hyperswitch-server