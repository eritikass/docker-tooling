#!/bin/sh

# exit when any error
set -e

ARCH=$(arch)

# Set the ARCH variable to amd if it is empty
if [ -z "$ARCH" ]; then
  ARCH="amd64"
fi
echo "ARCH => $ARCH"

# Set timezone to UTC by default
ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
locale-gen C.UTF-8 || true

# Install yt-dlp via curl
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+x /usr/local/bin/yt-dlp
yt-dlp --version

# install Github CLI
echo " ***** install Github CLI *****"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update -y
apt-get install gh -y

# install yq
echo " ***** install yq *****"
export YQ_VERSION=3.4.1
export YQ_BINARY=yq_linux_amd64
if [ "$ARCH" = "aarch64" ]; then
  YQ_BINARY=yq_linux_arm64
fi
wget "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}"
chmod a+x "${YQ_BINARY}"
mv "${YQ_BINARY}" /usr/bin/yq
yq --version

# instal yq v3
wget "https://github.com/mikefarah/yq/releases/download/v3.4.1/${YQ_BINARY}"
cp "${YQ_BINARY}" /usr/bin/yq_v3 && chmod a+x /usr/bin/yq_v3
yq_v3 --version

# instal yq v4
wget "https://github.com/mikefarah/yq/releases/download/v4.34.2/${YQ_BINARY}"
cp "${YQ_BINARY}" /usr/bin/yq_v4 && chmod a+x /usr/bin/yq_v4
yq_v4 --version

# install gojq
echo " ***** install gojq *****"
GOJQ_ARCH="amd64"
if [ "$ARCH" = "aarch64" ]; then
  GOJQ_ARCH="arm64"
fi
GOJQ_URL="https://github.com/itchyny/gojq/releases/download/v0.12.13/gojq_v0.12.13_linux_${GOJQ_ARCH}.tar.gz"
mkdir -p /tmp/gojq-install && cd /tmp/gojq-install
curl --silent --show-error --location --fail --retry 3 --output /tmp/gojq-install/gojq.tar.gz $GOJQ_URL
tar xvzf gojq.tar.gz && chmod a+x gojq_*/gojq
mv gojq_*/gojq /usr/bin/gojq
cd / && rm -fr /tmp/gojq-install
gojq --version

# install postgresql-client from offical deb repo
echo " ***** install postgresql (client) *****"
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# check if psql apt from archive
apt-get update -y
apt-get install -y postgresql-client-15
psql --version
pg_dump --version

#
# move scripts to path
#

link_sh() {
  local old_name="$1"
  local new_name="$2"

  echo "$old_name -> $new_name"
  ln -s "$old_name" "$new_name"
  chmod a+x "$new_name"
}

for file in /scripts/*.sh
do
    if [[ -f $file ]]; then
        bname=$(basename "$file")
        link_sh "$file" "/bin/${bname%.*}"
    fi
done
