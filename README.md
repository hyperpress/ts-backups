# TS-Backup to Google Drive

<p style="text-align:center">![WordPress to Google Cloud Logo](https://themesurgeons.com/wp-to-gcloud.png)</p>

There's a lot to love about WordPress, but backups, syncing files and data, and migrations are not among them. Yes, there are plugins that you can download, and external services you can purchase that will accomplish the maintainance of your site. But plugins add load and impact performance, and exernal services can be pricey and not well supported.

My goal is to create scripts and publish scripts that avoid all that. They are scripts we use here at Theme Surgeons for our hosting customers and we love to share them.

A set of bash scripts for backing up files and data to cloud storage services like Google Drive and Cloud Storage. I will continue to add more utility scripts to make life easier. Feel free to Fork your own copy. Contributions are welcome and appreciated.


This script creates a backup target WordPress files and MySQL database and uploads them to your Google Drive. Files are retained for 7 days by default (configurable).

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
You can easily change variables to use this script for other backup uses.

**IMPORTANT: Change variables and absolute path variables to match your settings.
