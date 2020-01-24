#! /bin/bash
cat $1 | ./a.out | diff -s $2 - ;
