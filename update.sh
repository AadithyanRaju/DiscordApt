#!/bin/bash

set -e

mkdir -p pool/main
mkdir -p dists/stable/main/binary-amd64

echo "[+] Checking latest Discord version..."

LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} \
"https://discord.com/api/download?platform=linux&format=deb")

NEW_VERSION=$(echo "$LATEST_URL" | grep -oP 'discord-\K[0-9.]+')

echo "[+] Latest version: $NEW_VERSION"

OLD_VERSION=$(cat .version 2>/dev/null || echo "")

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
    echo "[+] No new version available."
    exit 0
fi

echo "[+] New version detected."

echo "$NEW_VERSION" > .version

echo "[+] Cleaning old packages..."
rm -f pool/main/*.deb

echo "[+] Downloading Discord..."

wget -O pool/main/discord.deb \
"https://discord.com/api/download?platform=linux&format=deb"

echo "[+] Generating package index..."

cd pool

dpkg-scanpackages main /dev/null \
| sed 's|Filename: |Filename: pool/|' \
> ../dists/stable/main/binary-amd64/Packages

cd ..

gzip -kf dists/stable/main/binary-amd64/Packages

echo "[+] Calculating hashes..."

PKG_SIZE=$(stat -c%s dists/stable/main/binary-amd64/Packages)
PKG_GZ_SIZE=$(stat -c%s dists/stable/main/binary-amd64/Packages.gz)

MD5_PKG=$(md5sum dists/stable/main/binary-amd64/Packages | awk '{print $1}')
MD5_GZ=$(md5sum dists/stable/main/binary-amd64/Packages.gz | awk '{print $1}')

SHA256_PKG=$(sha256sum dists/stable/main/binary-amd64/Packages | awk '{print $1}')
SHA256_GZ=$(sha256sum dists/stable/main/binary-amd64/Packages.gz | awk '{print $1}')

DATE=$(LC_ALL=C date -Ru)

echo "[+] Creating Release file..."

cat > dists/stable/Release <<EOF
Origin: DiscordApt
Label: DiscordApt
Suite: stable
Codename: stable
Version: 1.0
Date: $DATE
Architectures: amd64
Components: main
Description: Auto-updating Discord APT Repository
MD5Sum:
 $MD5_PKG $PKG_SIZE main/binary-amd64/Packages
 $MD5_GZ $PKG_GZ_SIZE main/binary-amd64/Packages.gz
SHA256:
 $SHA256_PKG $PKG_SIZE main/binary-amd64/Packages
 $SHA256_GZ $PKG_GZ_SIZE main/binary-amd64/Packages.gz
EOF

echo "[+] Repository updated successfully."