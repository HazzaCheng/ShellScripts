#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

usernames=$(cat user.passwd | cut -d ":" -f 1)
for username in $usernames 
do
    echo "userdel -r $username"
    userdel -r $username
done
