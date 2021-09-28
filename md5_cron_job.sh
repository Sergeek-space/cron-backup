#!/bin/bash

#######################################################################################################
##
## This cron job script checks the current user cron job and adds itself to cron (other jobs retain).
##   IMPORTANT! After adding itself (first iteration) the part responsible is self-commenting 
##   and requires manual intervention (uncomment strings 23 to 45) in order to work for another user,
##   or on anoter system if needed. Tested on CentOS 7.
##
## The second part is creating MD5 hash for the usr_list.txt file (RUN THE usr_list.sh FIRST) and 
## keep it in the current_users file, which is being overwritten in case of changes to the usr_list.txt
## (log kept in user_changes). The script is insusceptible for changing its name and a place to run from.
##
## Maintainer - Sergei Sheshukov. me@sergeek.space
##
########################################################################################################

# block 1 -  creating crontab entry

   #define variables

   #script's full path in case of renaming etc.
   SCRIPT_PATH_DIR=$(pwd)
   SCRIPT_PATH="$SCRIPT_PATH_DIR"`echo $0 |sed 's/^\.//'`

	
	#checking user's cron-job presence
	if [[ "$(crontab -l 2>&1 |egrep [*/])" =~ [*/]  ]]; then

		#checking wether the script is already in cron and ading along with other strings if not
		if [ ! "$(crontab -l |grep -o $SCRIPT_PATH)" == "$SCRIPT_PATH" ]; then
			TMP_CRON=`crontab -l |sed 's/\*/-s-/g'`
			TMP_CRON+=$'\n'
			TMP_CRON+="-s- -s-/1 -s- -s- -s- $SCRIPT_PATH"
			echo "$TMP_CRON" |sed 's/-s-/*/g' |crontab -
		fi 
	else
		echo "* */1 * * * $SCRIPT_PATH" |crontab -
	fi


   #pass the sript's current working dir to the block 2
   WORK_DIR="$SCRIPT_PATH_DIR"
   #self-commenting block 1 after first iteration
   sed -i '23,45s/^/#/' "$SCRIPT_PATH"

# block 2 - the first script output manipulations 

   #define variables
   
   #after the first iteration there is no more the variable; checking for presence, define if none 
   if [ -z ${WORK_DIR+x} ]; then WORK_DIR=$(crontab -l |grep -o $0 |sed 's/\(.*\)\/.*/\1/'); fi
   
   #due to insufficient privileges for the ordinary users I am manipulating with the output further in the script's dir
   OUTPUT_DIR="$WORK_DIR""/"
   #OUTPUT_DIR="/var/log/"
   
   WORK_DIR="$WORK_DIR""/"
	
	#MD5 sum save

	#checking for the file presence
	if [[ -f "$OUTPUT_DIR""current_users" ]]; then
		
		DA_STR=$(cat "$OUTPUT_DIR""current_users" |sed 's/^[[:space:]]*//g')
		DB_STR=$(cat "$WORK_DIR""usr_list.txt" |md5sum |sed 's/^[[:space:]]*//g')
		if ! diff <(echo "$DA_STR") <(echo "$DB_STR") >/dev/null 2>&1;then
			echo "$(date +%F%t%R) changes occured" >> "$OUTPUT_DIR""user_changes"; cat "$WORK_DIR""usr_list.txt" |md5sum > "$OUTPUT_DIR""current_users"
		fi
		
	else
                cat "$WORK_DIR""usr_list.txt" |md5sum > "$OUTPUT_DIR""current_users"
        fi
