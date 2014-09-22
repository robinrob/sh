#!/usr/bin/env sh

source creds.sh

URL="https://${HEROKU_APP}:${HEROKU_PASS}@${HEROKU_APP}.cloudant.com"
CONTENT_TYPE='Content-Type: application-json'

# One-time only
# curl -X PUT "${URL}/_replicator"

function wrap {
	echo '"'$1'"'
}

function backup_db {
	DB_NAME=$1
	DAY=$2
	
	echo "Backup up database `wrap ${DB_NAME}` ..."
	BACKUP_DB_NAME="${DB_NAME}-backup-${DAY}"
	
	# echo "Creating backup database `wrap ${BACKUP_DB_NAME}` ..."
	# cURL -X PUT "${URL}/${BACKUP_DB_NAME}"
	#
	# echo "Backing up database `wrap ${DB_NAME}` into database `wrap ${BACKUP_DB_NAME}` ..."
	# DATA="{`wrap _id`:"`wrap ${BACKUP_DB_NAME}`", `wrap source`:"`wrap ${URL}/$DB_NAME`", `wrap target`:"`wrap ${URL}/$BACKUP_DB_NAME`"}"
	# # echo $DATA
	#
	# curl -X PUT "${URL}/_replicator/$BACKUP_DB_NAME" -H "$CONTENT_TYPE" -d "${DATA}"
	
	echo "Getting replication Id ..."
	# repl_id=`curl "${URL}/_replicator/backup-monday" | jq -r '._replication_id'`
	output=`curl ${URL}/_replicator/backup-monday`
	echo $output
	# echo $repl_id
	
	# echo "Getting recorded sequence value ..."
	# recorded_seq=`curl "${URL}/original/_local/${repl_id}" | jq -r '.history[0].recorded_seq'`
}
