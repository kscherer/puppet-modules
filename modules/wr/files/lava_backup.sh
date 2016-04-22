#!/bin/bash

BACKUP="lava_backup-$(date '+%F').db.gz"
chmod 777 /tmp/lava-server
docker exec -it lava-server /bin/lava_db_dump.sh "/tmp/$BACKUP"

MONTH=$(date '+%Y-%m')
DIR=/net/ala-lpdfs01/pool/mentor/lavadb/
mkdir -p "$DIR/$MONTH"
mv -f "/tmp/lava-server/$BACKUP" "$DIR/$MONTH"
