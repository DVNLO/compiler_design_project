#! /bin/bash

no_input_min_files=(./tests/require_no_input/min/*)
no_input_num_files="$(($(ls -1q ./tests/require_no_input/min/* | wc -l)-1))"

need_input_min_files=(./tests/require_input/min/*)
need_input_num_files="$(($(ls -1q ./tests/require_input/min/* | wc -l)-1))"


echo "#######################################################################"
echo "####################### No Input Programs #############################"
for i in $(seq 0 $no_input_num_files)
do
	echo "#######################################################################"
	echo "${no_input_min_files[$i]}"
	./run.sh "${no_input_min_files[$i]}"
done ;
echo "#######################################################################"
echo ""

echo "#######################################################################"
echo "###################### Need Input Programs ############################"
for i in $(seq 0 $need_input_num_files)
do
	echo "#######################################################################"
	echo "${need_input_min_files[$i]}"
	./run.sh "${need_input_min_files[$i]}"
done ;
echo "#######################################################################"
echo ""
