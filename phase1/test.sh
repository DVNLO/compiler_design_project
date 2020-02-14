#! /bin/bash
cat $1 | ./a.out 2>&1 | diff -s $2 - ;
