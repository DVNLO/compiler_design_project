#! /bin/bash
cat $1 | ./a.out | diff -y --suppress-common-lines $2 - ;
