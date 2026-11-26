#!/usr/bin/env bash
#
# Boots the Hyperswitch backend (router, postgres, redis, web, mailhog) from the most
# recent published Docker image tag, for the Playwright suite.
#
#   ./start_hyperswitch.sh                               # newest tag that boots
#   HYPERSWITCH_TAG=2026.11.20.0 ./start_hyperswitch.sh  # pin a tag

set -u

REPO="https://github.com/juspay/hyperswitch"
IMAGE_REPO="juspaydotin/hyperswitch-router"
IMAGE="docker.juspay.io/${IMAGE_REPO}"

MAX_TRIES=5   # boot attempts before giving up on auto-discovery
MAX_SCAN=25   # tags to look at (tags without an image are skipped for free)
KNOWN_GOOD_TAG="${HYPERSWITCH_KNOWN_GOOD_TAG:-2026.11.20.0}"   # last resort
OVERRIDE_TAG="${HYPERSWITCH_TAG:-}"

# --- Preflight ---------------------------------------------------------------

command -v docker >/dev/null 2>&1 || { echo "Error: 'docker' not found on PATH." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running." >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Error: Docker Compose v2 ('docker compose') not found." >&2; exit 1; }

# --- Source checkout ---------------------------------------------------------

if [ -d hyperswitch/.git ]; then
  echo "Reusing existing ./hyperswitch checkout..."
  cd hyperswitch || exit 1
  git reset --hard --quiet || true
  git clean -fdq || true
elif [ -e hyperswitch ]; then
  echo "Error: ./hyperswitch exists but is not a git checkout. Remove it and retry." >&2
  exit 1
else
  git clone --depth 1 "$REPO" hyperswitch || { echo "Error: git clone failed" >&2; exit 1; }
  cd hyperswitch || exit 1
fi

git fetch --tags --quiet

# --- Boot one tag ------------------------------------------------------------

cleanup() {
  docker compose down -v --remove-orphans >/dev/null 2>&1 || true
  docker ps -aq --filter name=hyperswitch- | xargs docker rm -f >/dev/null 2>&1 || true
  docker network rm -f hyperswitch_router_net >/dev/null 2>&1 || true
}

# Returns 0 on success, 2 if the tag has no image, 1 if it failed to boot.
try_tag() {
  tag="$1"
  echo "==== Trying tag: $tag ===="

  if ! docker manifest inspect "$IMAGE:$tag" >/dev/null 2>&1; then
    echo "Docker image not available for $tag"
    return 2
  fi

  git reset --hard --quiet
  git checkout --quiet "$tag"

  # The router refuses to start without this config row.
  printf '%s\n' "INSERT INTO configs (key, config) VALUES ('payment_callback', '{\"mode\":\"enforced\"}') ON CONFLICT (key) DO UPDATE SET config = EXCLUDED.config;" > seed_configs.sql

  # Compose tweaks:
  #  - pin the router image to this tag
  #  - run the superposition seed with bash
  #  - run migrations with the Diesel CLI directly (installing `just` from GitHub
  #    gets rate-limited), then seed the config row above
  sed -i.bak \
    -e "s|${IMAGE_REPO}:standalone|${IMAGE_REPO}:${tag}|g" \
    -e 's|apk add --no-cache curl jq yq && sh /seed_superposition.sh|apk add --no-cache curl jq yq bash \&\& bash /seed_superposition.sh|g' \
    -e '/      if ! command -v just >\/dev\/null 2>\&1; then/,/      fi \&\&/d' \
    -e 's|      just migrate"|      diesel migration run --migration-dir /app/migrations --config-file /app/diesel.toml \&\& psql $$DATABASE_URL -f /app/seed_configs.sql"|' \
    -e 's|apt-get install -y curl xz-utils|apt-get install -y curl xz-utils rustfmt postgresql-client|' \
    docker-compose.yml && rm -f docker-compose.yml.bak

  # Enable payouts (disabled by default since 2026.11.26.0).
  sed -i.bak \
    -e 's|^"payouts.should_allow_payouts" = { value = false,|"payouts.should_allow_payouts" = { value = true,|' \
    config/superposition_seed.toml && rm -f config/superposition_seed.toml.bak

  echo "Starting docker compose..."
  if docker compose up -d pg redis-standalone migration_runner hyperswitch-server hyperswitch-web mailhog \
     && docker ps --format '{{.Names}}' | grep -q hyperswitch-server; then
    echo "SUCCESS: Working version -> $tag"
    return 0
  fi

  echo "FAILED: $tag"
  cleanup
  return 1
}

# --- Pick a tag --------------------------------------------------------------

if [ -n "$OVERRIDE_TAG" ]; then
  echo "HYPERSWITCH_TAG set -> using $OVERRIDE_TAG"
  try_tag "$OVERRIDE_TAG" && exit 0
  echo "Override tag $OVERRIDE_TAG failed to boot"
  exit 1
fi

attempts=0
scanned=0
for tag in $(git tag --sort=-creatordate); do
  [ "$attempts" -ge "$MAX_TRIES" ] && break
  [ "$scanned" -ge "$MAX_SCAN" ] && break
  scanned=$((scanned+1))

  try_tag "$tag"
  case $? in
    0) exit 0 ;;
    2) ;;                             # no image: does not count as an attempt
    *) attempts=$((attempts+1)) ;;
  esac
done

echo "Auto-discovery exhausted after $attempts boot attempt(s) across $scanned tag(s)"
echo "Falling back to known-good tag $KNOWN_GOOD_TAG"
try_tag "$KNOWN_GOOD_TAG" && exit 0

echo "No working tag found"
exit 1
