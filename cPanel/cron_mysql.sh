#!/bin/bash

# Define variables
source $HOME/cronscripts/.mycrontab.env
# Note: We avoid putting passwords directly in the script for security. 
# See the "Security Tip" below.

LOGFILE=$HOME/cronscripts/cron_mysql.log

# Execute the SQL
# Use -e for inline queries or < path/to/script.sql for files
# Test crontab execution
echo "DBUSR: $DBUSR" >$LOGFILE 2>&1
echo "DBNAME: $DEVAPIDB"  >>$LOGFILE 2>&1
echo "------------"  >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

# Cleanup expired sessions
SQL="SELECT count(*) FROM session WHERE expiresAt < NOW() - INTERVAL 1 MINUTE;"
echo "SQL: '$SQL'"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB --skip-column-names -e "$SQL" >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

SQL="DELETE FROM session WHERE expiresAt < NOW() - INTERVAL 1 MINUTE;"  >>$LOGFILE 2>&1
echo "SQL: '$SQL'"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB -e "$SQL" >>$LOGFILE 2>&1
echo "------------"  >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

# Cleanup 'updatepwd' confirmation email-links
echo >>$LOGFILE 2>&1
SQL="SELECT count(*) FROM member_email WHERE createdAt < NOW() - INTERVAL 10 MINUTE;"
echo "SQL: '$SQL'"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB --skip-column-names -e "$SQL" >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

SQL="DELETE FROM member_email WHERE createdAt < NOW() - INTERVAL 10 MINUTE;"
echo "SQL: $SQL"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB -e "$SQL" >>$LOGFILE 2>&1
echo "------------"  >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

# Cleanup any confirmation email older than 7 days
SQL="SELECT count(*) FROM member_email WHERE createdAt < NOW() - INTERVAL 7 DAY;"
echo "SQL: $SQL"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB --skip-column-names -e "$SQL" >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

SQL="DELETE FROM member_email WHERE createdAt < NOW() - INTERVAL 7 DAY;"
echo "SQL: $SQL"  >>$LOGFILE 2>&1
echo "------------"  >>$LOGFILE 2>&1
/usr/bin/mysql -u $DBUSR --password="$DBPWD" $DEVAPIDB -e "$SQL" >>$LOGFILE 2>&1
echo >>$LOGFILE 2>&1

# Optional: Log the execution
echo "Cron job ran at $(date)" >>$LOGFILE 2>&1