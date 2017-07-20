filenames=$(ls [d-w]*)
for filename in $filenames
do
	echo "treating $filename"
	iconv -f big5 -t utf8 $filename -o ${filename}.utf8
	sleep 1s
	mv ${filename}.utf8 $filename
done
