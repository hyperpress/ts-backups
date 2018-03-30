### TOC
- [TS-Backup to Google Drive](#ts-backup-to-google-drive)
  * [Introduction](#introduction)
    + [wp_backup_to_drive.sh | Backup WordPress to Google Drive](#wp-backup-to-drivesh---backup-wordpress-to-google-drive)

# TS-Backup to Google Drive

<p style="text-align:center"><img src="https://themesurgeons.com/wp-to-gcloud.png" alt="WordPress to Google Drive Logo"</p>

A set of bash scripts for backing up files and data to cloud storage services like Google Drive and Cloud Storage. I will continue to add more utility scripts to make life easier. Feel free to send pull requests to add yours if you like, or fork your own copy. Contributions are welcome and appreciated.
  
## Introduction

There's a lot to love about WordPress, but backups, syncing files and data, and migrations are not among them. Yes, there are plugins that you can download, and external services you can purchase that will accomplish the maintainance of your site. But plugins add load and impact performance, and exernal services can be pricey and not well supported.

My goal is to create scripts and publish scripts that avoid all that, and are generic enough to to refactor for any type of MySQL and file data backups. They are scripts we use here at Theme Surgeons for our hosting customers and we love to share them.

### wp_backup_to_drive.sh | Backup WordPress to Google Drive

This script creates a backup target WordPress files and MySQL database and uploads them to your Google Drive. Files are retained for 7 days by default (highly configurable).

1. Check internet connection
2. Verify that gdrive executable is installed. If not, attempts to install it
3. Attempts to create a tar.gz backup of WordPress site files
4. Attempts to create a tar.gz export of WordPress database
5. Attempts to upload backup files to Google Drive target
6. Checks for backup files older than 7 (retention is configurable) days and deletes them
7. If successful, removes tmp backup files
8. Formats and mailtos logged results to recipient via mail() - Could use mutt or elm

Based on script authored by ASHUTOSH on newtechrepublic.com
Successfully Tested on Centos-6,7 on Webfaction Shared and VPS servers.
You can easily change variables to use this script for many other backup uses.

**IMPORTANT: Passing passwords via a bash script is a potential security vulnerability. There are many methods and arguments about how to secure passwords in bash scripts. None of them are bullet proof. Encrypting and decrypting is one suggested method, but it's not easy to accomplish, and ultimately you have to decrypt the password at destination anyway. I recommend setting file permissions as tightly as possible and still be able to run the script in a cron. Mine are set to CHMOD 700, so only the owner can read, write, or execute the script. Your mileage may vary.
