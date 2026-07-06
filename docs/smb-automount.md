# SMB Automount

Shares from the home NAS automount under `~/smb` via autofs. An executable autofs map picks the NAS address at mount time: direct LAN IP when on the home network, Tailscale IP otherwise.

- Shares: `backup creative docs games media software`
- LAN host: `10.0.0.41`
- Tailscale host: `100.101.72.229`
- Mount root: `~/.autofs/smb`, with `~/smb` as a symlink to it
- Map: `/etc/auto_smb` (executable map, root-only — it contains the SMB password)

The SMB credentials are in Bitwarden. Never commit the real password to this repo.

## Install

1. Create the mount root and symlink:

```sh
mkdir -p "$HOME/.autofs/smb"
[ -e "$HOME/smb" ] || ln -s .autofs/smb "$HOME/smb"
```

2. Add this line to `/etc/auto_master` if not present (keep existing lines):

```
/Users/chris/.autofs/smb	/etc/auto_smb
```

3. Install `/etc/auto_smb` with the real password substituted for `SMB_PASSWORD` (ask the user for it; do not echo it into shell history if avoidable):

```sh
#!/bin/sh

KEY="$1"
USER="chris"
PASS='SMB_PASSWORD'
LAN_HOST='10.0.0.41'
TAILSCALE_HOST='100.101.72.229'
SHARES='backup creative docs games media software'

if [ $# -eq 0 ]; then
    for SHARE in $SHARES; do
        echo "$SHARE"
    done
    exit 0
fi

MATCHED=0
for SHARE in $SHARES; do
    if [ "$KEY" = "$SHARE" ]; then
        MATCHED=1
        break
    fi
done

if [ "$MATCHED" -ne 1 ]; then
    exit 1
fi

if /usr/bin/nc -G 1 -z "$LAN_HOST" 445 >/dev/null 2>&1; then
    HOST="$LAN_HOST"
elif /usr/bin/nc -G 1 -z "$TAILSCALE_HOST" 445 >/dev/null 2>&1; then
    HOST="$TAILSCALE_HOST"
else
    exit 1
fi

printf '%s\n' "-fstype=smbfs,soft,noowners,nosuid ://${USER}:${PASS}@${HOST}/${KEY}"
```

The map must be root-owned and executable, readable by no one else:

```sh
sudo install -m 0700 -o root -g wheel /path/to/auto_smb /etc/auto_smb
```

4. Reload autofs and verify:

```sh
sudo automount -cv
ls ~/smb/media   # triggers the mount on access
```

Notes:

- An executable map is queried by autofs: no args lists the keys, one arg prints the mount options for that share.
- Fallback requires Tailscale to be installed, signed in, and running before shares mount away from home.
