#! /bin/bash

min_files=(./min/*)
token_files=(./tokens/*)
num_files="$(($(ls -1q ./min/* | wc -l)-1))"


for i in $(seq 0 $num_files)
do
	echo "###############################################"
	echo "${min_files[$i]}" "${token_files[$i]}"  
	./test.sh "${min_files[$i]}" "${token_files[$i]}"  
done ;
