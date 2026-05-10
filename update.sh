#!/usr/bin/env bash

set -e

echo "[+] Cleaning old package..."

rm -f pool/main/*.deb

mkdir -p pool/main

echo "[+] Downloading latest Discord package..."

wget -O pool/main/discord.deb \
"https://discord.com/api/download?platform=linux&format=deb"

echo "[+] Creating package metadata..."

mkdir -p dists/stable/main/binary-amd64

dpkg-scanpackages pool /dev/null \
> dists/stable/main/binary-amd64/Packages

gzip -kf dists/stable/main/binary-amd64/Packages

echo "[+] Calculating hashes..."

cd dists/stable

MD5=$(md5sum main/binary-amd64/Packages.gz | cut -d ' ' -f1)
SIZE=$(stat -c%s main/binary-amd64/Packages.gz)

SHA256=$(sha256sum main/binary-amd64/Packages.gz | cut -d ' ' -f1)

cat > Release <<EOF
Origin: DiscordApt
Label: DiscordApt
Suite: stable
Codename: stable
Architectures: amd64
Components: main
Description: Auto-updating Discord APT Repository
MD5Sum:
 $MD5 $SIZE main/binary-amd64/Packages.gz
SHA256:
 $SHA256 $SIZE main/binary-amd64/Packages.gz
EOF

cd ../..

echo "[+] Repository updated successfully."
