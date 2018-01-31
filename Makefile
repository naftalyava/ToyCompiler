all:
	bison -d common.y
	flex common.lex
	g++ lex.yy.c common.tab.c Symbol.cpp SymbolTable.cpp Buffer.cpp common.cpp Function.h RegisterManager.cpp -o part3 

clean:
	rm -f part3 lex.yy.c common.tab.c common.tab.h
