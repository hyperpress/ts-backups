#!/bin/bash

# This script creates a backup of target WordPress files and database and
# and transfers to Google Drive target. Files are retained for 7 days (configurable).
#
# 1. Check internet connection
# 2. Verify that gdrive executable is installed. If not, attempts to install it
# 3. Attempts to create a tar.gz backup of WordPress site files
# 4. Attempts to create a tar.gz export of WordPress database
# 5. Attempts to upload backup files to Google Drive target
# 6. Checks for backup files older than 7 (retention is configurable) days and deletes them
# 7. If successful, removes tmp backup files
# 8. Formats and mailtos logged results to recipient via mail() - Could use mutt or elm
#
# Based on script authored by ASHUTOSH on newtechrepublic.com
# Successfully Tested on Centos-6,7 on Webfaction Shared and VPS servers.
# You can easily change variables to use this script for other backup uses.
# IMPORTANT: Change variables and {PATH TO} to match your settings.

################################################
# Change server details to match your own server 
################################################

# Database credentials 
# YOU SHOULD MAKE SURE THAT FILE PERMISSIONS FOR THIS FILE ARE CHMOD 700
user="johnteague_surge"
password="8Hrmr0qC"
host="localhost" # change to ip or domain if applicable
db_name="johnteague_surge" # db_name="--all-databases" optional

# gdrive executable location
gdrivepath="gdrive"

# Local backup path
localbackuptmp="/home/johnteague/tmp" # no trailingslashit

# WordPress root folder path (or wp-content, etc.)
wplocalpath="/home/johnteague/webapps/surgeons"

# GDRIVE target backup path
gdrivepath="ts-backups/surgeons"

# number of days you want to retain backup on Google Drive
retainfor=7

# Email from name
fromname="John Teague"

# mailto address for status notifications
mailto="john@logicalphase.com"

#For cleanup
clean=rm

#################################################################################
# YOU SHOULD NOT MAKE CHANGES BELOW THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING
#################################################################################

# Test Internet Connection
IS=`ping -c 5 4.2.2.2 | grep -c "64 bytes"`

if (test "$IS" -gt "2") then
        internet_conn="1"

# Verify gdrive bin file exists 
file="~/gdrive"
if [ -f "$file" ]
then
	echo "Starting Backup Process...."
else

# If gdrive does not exist, download and install it: See https://github.com/prasmussen/gdrive
if [ `getconf LONG_BIT` = "64" ]
then
        wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" -O /bin/gdrive
        chmod 700 gdrive
	gdrive list
	clean
	echo "Starting Backup Process...."
else
        wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" -O /bin/gdrive
        chmod 700 gdrive
	gdrive list
	clean
	echo "Starting Backup Process...."
fi
fi

# Date prefix
dateprefix=$(date +"%Y-%m-%d")

# Retention prefix is compared against retainfor value setting.
backupage=$(date +"%Y-%m-%d" -d "-$retainfor days")

# Create array of sites based on folder names
sites=($(cd $wplocalpath; echo $PWD | rev | cut -d '/' -f 1 | rev))

# Create local backup tmp folder if not exists
mkdir -p /home/johnteague/tmp

# Verify that remote backup target folder exists on gdrive
backupid=$(gdrive list --no-header | grep $gdrivepath | grep dir | awk '{ print $1}')
    if [ -z "$backupid" ]; then
        gdrive mkdir $gdrivepath
        backupid=$(gdrive list --no-header | grep $gdrivepath | grep dir | awk '{ print $1}')
    fi

# Loop through and identify sites all directories
for site in $sites; do    
   
    # Get directory ID/NAME and prune old backups if they exist
    oldbackup=$(gdrive list --no-header | grep $backupage-$site | grep dir | awk '{ print $1}')
    if [ ! -z "$oldbackup" ]; then
        gdrive delete $oldbackup
    fi 

    # Create the local backup directory if not  exists
    if [ ! -e /home/johnteague/tmp/$site ]; then
        mkdir /home/johnteague/tmp/$site
    fi

    # Enter WordPress directory
    cd $wplocalpath/
  
    # Create WordPress files backup
    tar -czf /home/johnteague/tmp/$SITENAME/$site/$dateprefix-$site.tar.gz .

 
    # Export and create backup of MySQL database (You could pass additional mysql options here)
    mysqldump --user=$user --password=$password  --events --ignore-table=mysql.event --host=$host $db_name | gzip > /home/johnteague/tmp/$site/$dateprefix-$site.sql.gz

    # Get current folder ID/NAME
    sitefolderid=$(gdrive list --no-header | grep $site | grep dir | awk '{ print $1}')

    # Create GDRIVE target folder if not exists
    if [ -z "$sitefolderid" ]; then
        gdrive mkdir --parent $backupid $site
        sitefolderid=$(gdrive list --no-header | grep $site | grep dir | awk '{ print $1}')
    fi

    # Upload WordPress files .tar.gz
    gdrive upload --parent $sitefolderid --delete /home/johnteague/tmp/$site/$dateprefix-$site.tar.gz
    
    # Upload WordPress Mysql database .gz
    gdrive upload --parent $sitefolderid --delete /home/johnteague/tmp/$site/$dateprefix-$site.sql.gz

    # Log WordPress Files amd Fprmat mailto Results
    echo "Hi," >> /home/johnteague/tmp/log01
    echo " " >> /home/johnteague/tmp/log01
    gdrive list --no-header | grep $dateprefix-$site.tar.gz | awk '{ print $1}' > /home/johnteague/tmp/web_log.txt
    [ -s /home/johnteague/tmp/web_log.txt ] && echo "WordPress Files Backup Succeeded.. File Name $dateprefix-$site.tar.gz" >> /home/johnteague/tmp/log01 || echo " Web Server Data Backup Error..!!"  >> /home/johnteague/tmp/log01
   
    # Log Database Output and Format mailto Results
    gdrive list --no-header | grep $dateprefix-$site.sql.gz | awk '{ print $1}' > /home/johnteague/tmp/database_log.txt
    [ -s /home/johnteague/tmp/database_log.txt ] && echo "WordPress Database Backup Succeeded.. File Name - $dateprefix-$site.sql.gz" >> /home/johnteague/tmp/log01 || echo " Database Backup Error..!!" >> /home/johnteague/tmp/log01
   
    echo " " >> /home/johnteague/tmp/log01
    echo " " >> /home/johnteague/tmp/log01 
    echo "Thanks," >> /home/johnteague/tmp/log01
    echo "YOUR NAME"  >> /home/johnteague/tmp/log01

    # Backup Status - Send Mail
    cat -v /home/johnteague/tmp/log01 | mail -s "WordPress Backup Status Log - $(date)" $mailto

    # cleanup up the tmp files
    chmod -R 755 /home/johnteague/tmp/*
    $clean /home/johnteague/tmp/web_log.txt 
    $clean /home/johnteague/tmp/database_log.txt 
    $clean /home/johnteague/tmp/log01 

done
    # Internet Connection Error
else
   internet_conn="0"
   echo "########### Can't connect to Internet. Please Check Your Connection. ############"
fi