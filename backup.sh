#!/usr/bin/env sh

url='https://app9733063.heroku:JQElgaMaHvF8oT4NA1HmPJYO@app9733063.heroku.cloudant.com'
ct='Content-Type: application-json'

# curl -X PUT "${url}/_replicator"

function backup_db {
	DB_NAME=$1
	DAY=$2
	
	BACKUP_DB_NAME="${DB_NAME}-backup-${DAY}"
	
	curl -X PUT "${url}/${BACKUP_DB_NAME}"
	
	curl -X PUT "${url}/_replicator/$BACKUP_DB_NAME" -H "$ct" -d '@-' <<END
	{
	  "_id": "${BACKUP_DB_NAME}",
	  "source": "${url}/postcodes",
	  "target": "${url}/postcodes-backup-monday"
	}

	END
}

create_backups_db "postcodes-backup-monday"
create_backups_db "vacancies-backup-monday"
create_backups_db "vacancies-backup-backup-monday"
create_backups_db "vacancies-dev-backup-monday"





# repl_id=$(curl "${url}/_replicator/backup-monday" | jq -r '._replication_id')
#
# recorded_seq=$(curl "${url}/original/_local/${repl_id}" | jq -r '.history[0].recorded_seq')
#
# $ curl -X PUT "${url}/_replicator/backup-tuesday" -H "${ct}" -d '@-' <<END
# {
#   "_id": "backup-tuesday",
#   "source": "${url}/original",
#   "target": "${url}/backup-tuesday",
#   "since_seq": "${recorded_seq}"
# }
#
# END