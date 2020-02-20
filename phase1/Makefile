CC=gcc
CFLAGS= -lfl 
EXEC= a.out

cc: flex
	$(CC) lex.yy.c $(CFLAGS)
run: cc
	./$(EXEC)
flex:
	flex mini_l.lex
clean:
	rm $(EXEC) lex.yy.c
