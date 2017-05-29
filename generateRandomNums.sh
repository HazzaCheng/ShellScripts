#!/bin/sh

export Path=/sbin:/usr/sbin:/bin:/usr/bin

function getNum(){
	c=1
	while [[ $c -le 20000 ]]
	do
		echo $(($RANDOM%100000))
		((c++))
	done
}

for i in $(seq 1 20)
do
	getNum &> ${i}.txt 
done

echo "---------------Done---------------"
cat [0-9]*.txt > nums.txt
rm -f [0-9]*.txt
		
