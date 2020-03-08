#Makefile
OBJS	= bison.o lex.o main.o errors.o instructions.o semantics.o

CC	= g++
# https://stackoverflow.com/questions/925179/selectively-remove-warning-message-gcc
CFLAGS	= -std=c++11 -ggdb -Wno-write-strings -Wall -pedantic

mini_l:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o mini_l -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o
 
lex.c:		mini_l.lex 
		flex mini_l.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	mini_l.y
		bison -d -v mini_l.y
		cp mini_l.tab.c bison.c
		cmp -s mini_l.tab.h tok.h || cp mini_l.tab.h tok.h

errors.o:	errors.cpp
		$(CC) $(CFLAGS) -c errors.cpp -o errors.o

instructions.o:	instructions.cpp
		$(CC) $(CFLAGS) -c instructions.cpp -o instructions.o

semantics.o:	semantics.cpp
		$(CC) $(CFLAGS) -c semantics.cpp -o semantics.o

main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o

lex.o yac.o main.o	: 
lex.o main.o		: tok.h
errors.o		: errors.h
instructions.o		: instructions.h
semantics.o		: semantics.h instructions.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h mini_l.tab.c mini_l.tab.h mini_l.output mini_l
