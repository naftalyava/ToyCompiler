#ifndef _COMMON_H_
#define _COMMON_H_

#include <string>
#include <stdio.h>
#include <vector>
#include <set>

#include "SymbolTable.h"
#include "Function.h"
#include "Buffer.h"


/*
	Definitions of data structure to share data between lex and bison
*/

typedef enum {INT8, INT16, INT32, VOID, INVALID} TokenType;

typedef struct{
    char*	value;
} yystype;

#define YYSTYPE yystype

#endif
