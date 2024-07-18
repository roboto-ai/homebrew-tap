#/bin/env bash
set -eufo pipefail

# A script to update the version and shas
version=${1/v/}
cli_cask="Casks/roboto.rb"
agent_cask="Casks/roboto-agent.rb"
download_url_prefix="https://github.com/roboto-ai/roboto-python-sdk/releases/download/v${version}"

if [ "$version" == "" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

inline=(-i)
if [ $(uname -o) == Darwin ]; then
    inline[1]=''
fi


for tuple in 'arm: aarch64' 'intel: x86_64'; do
  declare -a platform=($tuple)
  tag=${platform[0]}
  arch=${platform[1]}

  cli_url="${download_url_prefix}/roboto-macos-${arch}"
  cli_sha=$(curl -sSL ${cli_url} | sha256sum | cut -d ' ' -f 1)
  echo ${cli_sha}
  sed -f - "${inline[@]}" "${cli_cask}" <<EOF
s/version "[^"]*"/version "${version}"/
s/${tag} "[0-9a-f]*"/${tag} "${cli_sha}"/
EOF

  agent_url="${download_url_prefix}/roboto-agent-macos-${arch}"
  agent_sha=$(curl -sSL ${agent_url} | sha256sum | cut -d ' ' -f 1)
  echo ${agent_sha}
  sed -f - "${inline[@]}" "${agent_cask}" <<EOF
s/version "[^"]*"/version "${version}"/
s/${tag} "[0-9a-f]*"/${tag} "${agent_sha}"/
EOF
done

echo "Updated ${cli_cask} and ${agent_cask}, please review the changes then commit and push--thanks!"
