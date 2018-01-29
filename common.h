#ifndef _COMMON_H_
#define _COMMON_H_

#include <string>
#include <stdio.h>


/*
	Definitions of data structure to share data between lex and bison
*/

typedef enum {INT8, INT16, INT32, VOID, INVALID} TokenType;

typedef struct{
	TokenType type;
	std::string value;
	int registerNum;
	int addr;

	int quad;
	std::set<int> nextList;
	std::set<int> trueList;
	std::set<int> falseList;
} yystype;

#define YYSTYPE yystype

#endif
