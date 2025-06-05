#!/usr/bin/env bash
set -euo pipefail

# Exit early if setup already ran
if [[ "${DEV_ENV_BUILT:-}" == "1" ]]; then
  echo "Development environment already built"
  exit 0
fi

# Load nvm if available
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
else
  # TODO: install nvm if not present
  echo "nvm not found"
fi

# Install Node version from .nvmrc
NODE_VERSION="$(cat .nvmrc)"
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

# Install Yarn matching packageManager field
YARN_VERSION="$(grep -oE '"packageManager":\s*"yarn@([^"]+)"' package.json | cut -d@ -f2 | tr -d '"')"
npm install -g "yarn@${YARN_VERSION}"

# Install JS dependencies
yarn install --frozen-lockfile

# Persist environment configuration
{
  echo 'export NVM_DIR="$HOME/.nvm"'
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  echo 'export DEV_ENV_BUILT=1'
} >> "$HOME/.profile"

export DEV_ENV_BUILT=1

echo "Dev environment setup complete"
