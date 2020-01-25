#! /bin/bash

min_files=(./min/*)
token_files=(./tokens/*)

for i in {0..3}
do
	echo "###############################################"
	echo "${min_files[$i]}" "${token_files[$i]}"  
	./test.sh "${min_files[$i]}" "${token_files[$i]}"  
done ;
