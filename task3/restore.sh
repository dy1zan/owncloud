#!/bin/bash
#

# run WITH sudo!

# colours
COLOR_INFO='\033[0;36m'
COLOR_SUCCESS='\033[0;32m'
COLOR_ERROR='\033[0;31m'
COLOR_END='\033[0m'

# help message
usage() {
    printf "${COLOR_INFO}Usage${COLOR_END}: sudo bash restore.sh [password] [database_host] [file_dir]\n"
    echo "Please note, you may need run this script as sudo (root user) depending what you put as file_dir."
    echo "Also note, you must use an internal IP of a database host."
}
if [ "$1" == "--help" ]; then
    usage
    exit
fi

# checks that the user is not root, root has UID of 0
if [ "$EUID" -ne 0 ]; then
    echo ""
    printf "${COLOR_ERROR}Error${COLOR_END}: please run this script as root.\n"
    exit
fi

# added check for project_id & password. Without these, it will not work.
if [ -z "$1" ] || [ -z "$2" ]; then
    echo ""
    printf "${COLOR_ERROR}Error${COLOR_END}: project_id and password arguments are required!\n"
    echo "Please retry using sh ./restore.sh <password> <database_host> <file_dir>"
    exit
fi

username="owncloud"
dbname="owncloud"
password=$1
database=$2
file_dir=$3

gzip -dc $file_dir > backup.sql
mysql -u$username -p$password -h $database -e 'DROP DATABASE owncloud; CREATE DATABASE owncloud;'
mysql -u$username -p$password -h $database $dbname < backup.sql
rm -f backup.sql