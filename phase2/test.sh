#! /bin/bash
cat $1 | ./mini_l 2>&1 | diff -s $2 - ;
