#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

echo "Now, I will detect your Linux server's services.'"
echo -e "The www, ftp, ssh, mysql and mail will be detected! \n"

testing=$(netstat -tuln 1| grep ":80")
if [ "$testing" != "" ]; then
    echo "WWW is running in your system!"
else 
    echo "WWW isn't' running in your system!"
fi

testing=$(netstat -tuln | grep ":22")
if [ "$testing" != "" ]; then
    echo "SSH is running in your system!"
else 
    echo "SSH isn't' running in your system!"
fi

testing=$(netstat -tuln | grep ":21")
if [ "$testing" != "" ]; then
    echo "FTP is running in your system!"
else 
    echo "FTP isn't' running in your system!"
fi

testing=$(netstat -tuln | grep ":25")
if [ "$testing" != "" ]; then
    echo "MAIL is running in your system!"
else 
    echo "MAIL isn't' running in your system!"
fi


testing=$(netstat -tuln 1| grep ":3306")
if [ "$testing" != "" ]; then
    echo "MYSQL is running in your system!"
else 
    echo "MYSQL isn't' running in your system!"
fi
