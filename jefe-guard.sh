#!/bin/bash
#
# jefe-guard.sh
#

# print text with color
out() {
#     Num  Colour    #define         R G B
#     0    black     COLOR_BLACK     0,0,0
#     1    red       COLOR_RED       1,0,0
#     2    green     COLOR_GREEN     0,1,0
#     3    yellow    COLOR_YELLOW    1,1,0
#     4    blue      COLOR_BLUE      0,0,1
#     5    magenta   COLOR_MAGENTA   1,0,1
#     6    cyan      COLOR_CYAN      0,1,1
#     7    white     COLOR_WHITE     1,1,1
    text=$1
    color=$2
    echo "$(tput setaf $color)$text $(tput sgr 0)"
}

# Print jefe guard version
version() {
    echo 0.1
}

dbdump_env_vars() {
    dbuser=wordpress
    dbpass=password
    port=22
    dump_dir=dbdump
    user=user
    host=host
    remote_backup_path='~/backups'
}

dbdump() {
    dbdump_env_vars
    # get all data base of mysql
    databases=$(echo "show databases;" | mysql -u$dbuser -p$dbpass)
    # remove defaults databases
    databases=$(echo $databases | sed -e "s/Database \|information_schema \|mysql \|performance_schema \|phpmyadmin //g")
    date=`date +%Y%m%d`
    for database in $databases
    do
        dump_path="$dump_dir/bdd$database/"
        mkdir -p $dump_path
        mysqldump -u$dbuser -p$dbpass $database > "${dump_path}${date}-${database}.sql"
        deletes_old_dbdump $dump_path
    done
    #     rsync -az --force --delete --progress -e "ssh -p$port" "$dump_path/." "${user}@${host}:$remote_backup_path"
}

deletes_old_dbdump() {
    dump_path=$1
    latest_dumps=$(ls -t $dump_path | head 3)
    all_dumps=$(ls -t $dump_path)
    old_dumps=$(echo $all_dumps | sed -e "s/$latest_dumps//g")
    rm -rf $old_dumps
}

# call arguments verbatim:
$@

