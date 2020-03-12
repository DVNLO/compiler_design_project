#! /bin/bash

no_input_min_files=(./tests/no_input/min/*)
no_input_num_files="$(($(ls -1q ./tests/no_input/min/* | wc -l)-1))"
no_input_mil_file_path="./tests/no_input/mil/"

need_input_min_files=(./tests/need_input/min/*)
need_input_num_files="$(($(ls -1q ./tests/need_input/min/* | wc -l)-1))"
need_input_mil_file_path="./tests/need_input/mil/"


echo "#######################################################################"
echo "################## Generating No_Input Programs #######################"
for i in $(seq 0 $no_input_num_files)
do
	echo "#######################################################################"
	echo "${no_input_min_files[$i]}"
	./run.sh "${no_input_min_files[$i]}" > "${no_input_mil_file_path}$(basename ${no_input_min_files[$i]}).mil"
done ;
echo "#######################################################################"
echo ""

echo "#######################################################################"
echo "################## Generating Need_Input Programs #####################"
for i in $(seq 0 $need_input_num_files)
do
	echo "#######################################################################"
	echo "${need_input_min_files[$i]}"
	./run.sh "${need_input_min_files[$i]}" > "${need_input_mil_file_path}$(basename ${need_input_min_files[$i]}).mil"
done ;
echo "#######################################################################"
echo ""
