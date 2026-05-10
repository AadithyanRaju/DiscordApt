# DiscordApt
Self-hosted APT repo that tracks the latest Discord .deb for amd64 and makes it easy to keep Discord updated across devices.

## What this does
- Downloads the latest Discord .deb from discord.com.
- Generates `Packages`, `Packages.gz`, and `Release` metadata.
- Serves a minimal APT repository under `dists/` and `pool/`.

## Repo layout
```
.
├── dists/
│   └── stable/
│       ├── Release
│       └── main/
│           └── binary-amd64/
│               ├── Packages
│               └── Packages.gz
└── pool/
	└── main/
		└── discord.deb
```

## Add the repo on a client
```
echo "deb [arch=amd64 trusted=yes] https://aadithyanraju.github.io/DiscordApt stable main" | \
sudo tee /etc/apt/sources.list.d/discordapt.list
sudo apt-get update
sudo apt-get install -y discord
```

## Notes
- This repo is not signed. It uses `trusted=yes` for simplicity.
- Only `amd64` is supported by default.
- The package is downloaded from Discord's official URL.
