#! /bin/bash

no_input_mil_files=(./tests/no_input/mil/*)
no_input_num_files="$(($(ls -1q ./tests/no_input/mil/* | wc -l)-1))"

need_input_mil_files=(./tests/need_input/mil/*)
input_files=(./tests/need_input/input/*)
need_input_num_files="$(($(ls -1q ./tests/need_input/mil/* | wc -l)-1))"


echo "#######################################################################"
echo "####################### No_Input Programs #############################"
for i in $(seq 0 $no_input_num_files)
do
	echo "#######################################################################"
	echo "${no_input_mil_files[$i]}"
	mil_run "${no_input_mil_files[$i]}"
done ;
echo "#######################################################################"
echo ""

echo "#######################################################################"
echo "###################### Need_Input Programs ############################"
for i in $(seq 0 $need_input_num_files)
do
	echo "#######################################################################"
	echo "${need_input_mil_files[$i]}"
	mil_run "${need_input_mil_files[$i]}" < "${input_files[$i]}"
done ;
echo "#######################################################################"
echo ""
