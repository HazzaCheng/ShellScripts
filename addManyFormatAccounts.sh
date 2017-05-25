#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

accountFile="user.passwd"

echo ""
echo "For example, our school student's student number is from 1527403001 to 1527403099"
echo "Account start code(perhaps a grade)                : 15"
echo "Account level code(perhas a colleage and major)    : 274030 "
echo "Range of number(01-99)                             : 3"
echo "The number of accounts                             : 99"
echo ""

read -p "Input account start code, ex> std ==============> " username_start
read -p "Input account level code, ex> 1 or enter =============> " username_level
read -p "Input number of digital ex> 3 =================> " nu_nu
read -p "Input start number, ex> 520 ===============> " nu_start
read -p "Input the amount of users, ex> 99 ==============> " nu_amount
read -p "Password standard 1) same as username 2) random numbers =========> " pwm

if [ "$username_start" == "" ]; then
    echo "Have no account start code, can not create users! "
fi

testing0=$(echo $nu_nu | grep '[^0-9]')
testing1=$(echo $nu_start | grep '[^0-9]')
testing2=$(echo $nu_amount | grep '[^0-9]')

if [ "$testing0" != "" -o "$testing1" != "" -o "$testing2" != "" ]; then
    echo "The number you input must be numberic!"
    echo "Fail to create users!"
    exit 1
fi
if [ "$pwm" != "1" ]; then
    pwm="2"
fi

[ -f $accountFile ] && mv $accountFile "$accountFile"$(date +%Y%m%d)
nu_end=$(($nu_start + $nu_amount - 1))
for ((i=$nu_start; i<=$nu_end; ++i))
do
    nu_len=${#i}
    if [ $nu_nu -lt $nu_len ]; then
        echo "The digits of the number($i->$nu_len) is bigger than the number of digital you set($nu_nu)"
        echo "Fail to continue!"
        exit 1
    fi

    nu_diff=$(($nu_nu - $nu_len))
    if [ "$nu_diff" != "0" ]; then
        nu_nn=0000000000000000000000
        nu_nn=${nu_nn:1:$nu_diff}
    fi

    account=${username_start}${username_level}${nu_nn}${i}
    if [ "$pwm" == "1" ];then
        password=$account
    else
        password=$(openssl rand -base64 6)
    fi
    echo "$account:$password" | tee -a "$accountFile"
done 

cat "$accountFile" | cut -d ":" -f 1 | xargs -n 1 useradd -m 
chpasswd < "$accountFile"
pwconv
cat "$accountFile" | cut -d ":" -f 1 | xargs -n 1 chage -d 0
echo "Ok, create successfully!"



