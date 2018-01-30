all:
	bison -d common.y
	flex common.lex
	g++ lex.yy.c common.tab.c -o part3

clean:
	rm -f part3 lex.yy.c common.tab.c common.tab.h