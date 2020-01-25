CC=gcc
CFLAGS= -lfl 
EXEC= a.out

cc: flex
	$(CC) lex.yy.c $(CFLAGS)
run: cc
	./$(EXEC)
flex:
	flex lexer_spec.lex
clean:
	rm $(EXEC) lex.yy.c
