#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

users=$(cut -d ':' -f1 /etc/passwd)
for username in $users
do
    id $username
done
