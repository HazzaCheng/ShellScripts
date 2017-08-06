#!/bin/sh
#################################################################
# author: HazzaCheng(hazzacheng@gmail.com)
# date: 2017-7-26
# function: Check the important files whether they are modified by md5sum 
#################################################################

export Path=/sbin:/usr/sbin:/bin:/usr/bin

# 1. create the important file list
ls /etc/{passwd,shadow,group} > important.file
find /bin /sbin /usr /usr/sbin /usr/bin -perm /6000 >> important.file

# 2. create a new fingerprint code
for filename in $(cat important.file)
do
    md5sum $filename >> finger1.file
done

# 3. compare the fingerprint code
if [ "$1" == "new" ]; then
    for filename in $(cat important.file)
    do
        md5sum $filename >> finger1.file
    done
    echo "New file finger1.file is created"
    exit 0
fi

if [ ! -f finger1.file ]; then
    echo "file: finger1.file NOT exist"
    exit 1
fi

[ -f finger_new.file ] && rm finger_new.file
for filename in $(cat important.file)
do
    md5sum $filename >> finger_new.file
done

testing=$(diff finger1.file finger_new.file)
if [ "$testing" != "" ]; then
    diff finger1.file finger_new.file | echo |  mail -s 'Finger Trouble' root
fi

