#!/bin/ksh

rm f1 f2 f3
i=10

while (( i > 0 ))
do
	print $(date "+%s")  dev.cli.file1 $RANDOM >>f1
	print dev.cli.file2 $(date "+%s")  $RANDOM >>f2
	print dev.cli.file3 $RANDOM >>f3
	(( i = i - 1 ))
	sleep 1
done
