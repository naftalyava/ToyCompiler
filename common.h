#ifndef _COMMON_H_
#define _COMMON_H_

#include <string>
#include <stdio.h>
#include <vector>
#include <set>
#include <math.h>

#include "SymbolTable.h"
#include "Function.h"
#include "Buffer.h"
#include "RegisterManager.h"


/*
	Definitions of data structure to share data between lex and bison
*/
#define MERGE_LISTS(Father, son1,son2) do{ \
Father.insert(son1.begin(),son1.end()); \
Father.insert(son2.begin(),son2.end()); \
}	while(0)

typedef enum {INT8, INT16, INT32, VOID, INVALID} TokenType;

typedef struct {
    string name;
    unsigned int type;
    unsigned int quad;
    unsigned int node_reg;
    int node_offset;
} DCL_Node;


typedef struct{
    char*	value;
    unsigned int type;
    bool is_const;
    bool is_exp;
    int offset;
    unsigned int quad;
    unsigned int reg;
    vector<DCL_Node> dcl_list;
    set<unsigned int> true_list;
    set<unsigned int> false_list;
    set<unsigned int> next_list;
} yystype;

#define YYSTYPE yystype

#endif
