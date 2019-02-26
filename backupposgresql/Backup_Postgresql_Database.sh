#!/bin/bash
# Shell script to backup PSQL database 
# To backup Nysql databases file to /backup dir and later pick up by your 
# script. You can skip few databases from backup too.
# --------------------------------------------------------------------
# This is a free shell script under GNU GPL version 2.0 or above
# Copyright (C) 2004, 2005 nixCraft project
# Feedback/comment/suggestions : http://cyberciti.biz/fb/
# -------------------------------------------------------------------------
# This script is base on one of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------

PSQLUSER="${PSQL_USERNAME}"     # USERNAME
PSQLPASS="${PSQL_PASSWORD}"       # PASSWORD 
PSQLHOST="${PSQL_HOST}"          # Hostname

PSQLSTOREDAY="${PSQL_STORED_DAY}" # number of day to skip before remove.
# File to store current backup file
FILE=""
# List of DBS for  Backup e.g. "DB1 DB2 DB3"
DBS="${PSQL_DBNAMES}"

# DO NOT BACKUP these databases
DBEXCLUDE="pgadmin postgres template1 ${PSQL_EXCLUDE}"

# Include CREATE DATABASE in backup?
CREATE_DATABASE=yes

# Backup Dest directory, change this if you have someother location
DEST="${PSQL_BACKUP_DIR}"

# Get hostname
HOSTNAME="$(hostname)"

# Get data in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y")"

OBD="$(date -d "$PSQLSTOREDAY day ago" +"%Y-%m-%d")"
  
# Main directory where backup will be stored
MBD="$DEST/$NOW"

# Directory will be removed
REMOVE_DB_DAY="$DEST/$OBD"
  
# Separate backup directory and file for each DB? (yes or no)
SEPDIR=yes

# Linux bin paths, change this if it can not be autodetected via which command
PSQL="$(which psql)"
PSQLDUMP="$(which pg_dump)"
GZIP="$(which gzip)"
# CHOWN="$(which chown)"
# CHMOD="$(which chmod)"
DATE=`date +%Y-%m-%d`				# Datestamp e.g 2002-09-21
DOW=`date +%A`					# Day of the week e.g. Monday
DNOW=`date +%u`					# Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`					# Date of the Month e.g. 27
M=`date +%B`					# Month e.g January
W=`date +%V`					# Week Number e.g 37

# Only root can access it!
# $CHOWN 0.0 -R $DEST
# $CHMOD 0600 $DEST

# Get all database list first
#DBS="$($PSQL -u $PSQLUSER -h $PSQLHOST -p$PSQLPASS -Bse 'show databases')"

echo ======================================================================
echo AutoPostgreSQLBackup databases $DBS
echo 
echo Backup of Database Server - $PSQLHOST
echo ======================================================================

# Functions

# Database dump function
dbdump () {
PGPASSWORD="${PSQLPASS}" pg_dump --username=$PSQLUSER -h $PSQLHOST --no-owner $OPT $1 > $2
return 0
}

SUFFIX=""
compression () {
	gzip -9 "$1"
	echo
	echo Backup Information for "$1"
	gzip -l "$1.gz"
	SUFFIX=".gz"
	return 0
}

if [ "$SEPDIR" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
	if [ "$CREATE_DATABASE" = "no" ]; then
		OPT="$OPT"
	else
		OPT="$OPT --create"
	fi
else
	OPT="$OPT"
fi

#create the backup directory if it doesn't exist
[ ! -d $MBD ] && mkdir -p $MBD || :

# If backing up all DBs on the server
if [ "$DBS" = "all" ]; then
	DBS="`PGPASSWORD="${PSQLPASS}" ${PSQL} -U $PSQLUSER -h $PSQLHOST -l -A -F: | sed -ne "/:/ { /Name:Owner/d; /template0/d; s/:.*$//; p }"`"
	
	# If DBs are excluded
	for exclude in $DBEXCLUDE
	do
		DBS=`echo $DBS | sed "s/\b$exclude\b//g"`
	done
fi

if [ "$SEPDIR" = "yes" ]; then
	echo Backup Start Time `date`
	echo ======================================================================
	for DB in $DBS
	do
		# Prepare $DB for using
		DB="`echo $DB | sed 's/%/ /g'`"

	    skipdb=-1
	    if [ "$DBEXCLUDE" != "" ];
	    then
		for i in $DBEXCLUDE
		do
		    [ "$DB" == "$i" ] && skipdb=1 || :
		done
	    fi
	    
	    if [ "$skipdb" == "-1" ] ; then
			FILE="$MBD/${DB}.${PSQLHOST}_$DOW.$NOW.sql"
			GZIPFILE=$FILE.gz
			echo "Backup database $DB"
			# do all inone job in pipe,
			# connect to psql using psqldump for select psql database
			# and pipe it out to gz file in backup dir :)
			dbdump "$DB" "$FILE"
			compression "$FILE"
		    echo "$DB is backuped into: $GZIPFILE"


			#remove backupfile older than x days
			echo "remove backupfile older than $PSQLSTOREDAY"
			echo "the day to remove  is $OBD"
			mv $REMOVE_DB_DAY /tmp && rm -rf /tmp/$REMOVE_DB_DAY    
	    fi
	done
else
	echo Backup of Databases \( $DBS \)
	cho
	FILE="$MBD/ALL_${PSQLHOST}_$DOW.$NOW.sql"
	GZIPFILE=$FILE.gz
	dbdump "$DBS" "$FILE"
	compression "$GZIPFILE"

	echo ----------------------------------------------------------------------	
fi	


