#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

read -p "Pleas input the directory: " dir

if [ "$dir" == "" -o ! -d "$dir" ]; then
    echo "$dir is not exist!"
    exit 1
fi

files=$(ls $dir)
for file in $files
do
    perm=""
    test -r "$dir/$file" && perm="$perm readable"
    test -w "$dir/$file" && perm="$perm writable"
    test -x "$dir/$file" && perm="$perm executable"
    echo "The file $file's  permission is $perm' "
done
