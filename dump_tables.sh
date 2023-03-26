#!/bin/bash
Date=`date +%Y-%m-%d`
Directory=/home/backup/mydb/$Date
Pass="xxxxxxxxxxxxx"
Expire=5

if [ ! -d $Directory ];
then
        mkdir -p /home/backup/mydb/$Date
fi

tables=$(docker exec mydb mysql -h 192.168.1.100 -uroot -p$Pass database -e "show tables;"|grep -v Tables_in_)

delete=( "del_db"  "temp"  "zzzz_db" )

for del in ${delete[@]}
do
   tables=("${tables[@]/$del}") #Quotes when working with strings
done

for i in $tables;do
        docker exec mydb mysqldump -h 192.168.1.100 -u root -p$Pass --quick --lock-tables=false --single-transaction database $i > $Directory/$i.sql;
        echo "$i is complete" >> /home/devops/script/dump.log
        tar -czf $Directory/mydb-$i.tar.gz $Directory/$i.sql --remove-files
done

find $Directory/.. -type d -mtime +$Expire | xargs rm -rf
