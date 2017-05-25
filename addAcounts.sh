#!/bin/sh

export Path=/sbin:/usr/sbin:/bin:/usr/bin

if [ "$1" == "" ]; then 
    echo "Usage: $0 [FileName]"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "The file of accounts doesn't exist, please cheate the file of account, ecah line for single user name."
    exit 1
fi

usernames=$(cat $1)

for username in $usernames
do
    echo $username
    useradd $username
    echo "$username:$username" | chpasswd
    chage -d 0 $username
done
