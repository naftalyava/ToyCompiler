%{

#include <string.h>
#include "common.h"


#define YYERROR_VERBOSE 1
#define YYDEBUG 1


/*******************************************
* pre-declarations for functions and variables 
* that we will use in the code later.
*******************************************/
extern int yylineno;
extern char* yytext;
extern int yylex();
void yyerror(const char*);

/*******************************************
* Globals
*******************************************/
Buffer *buffer = new Buffer();
SymbolTable *symbol_table = new SymbolTable();
Function *current_function = new Function(); 
//RegistersManager registers_manager = new RegistersManager();
%}

/*******************************************
* In this section we are defining the tokens 
* which will be used between the lex and the bison parts.
* the tokens are separated into two groups, 
* regular token and priority/assosiavity tokens.
* we are using template "H_$" which $ will be replaced
* with the token world.
*******************************************/
%token H_IF H_ID H_STR H_NUM H_VOID H_INT8 H_INT16 H_INT32 H_WRITE H_WHILE  H_DO H_RETURN
%token H_READ H_FOR H_SEMI H_COLON
%right H_THEN
%right H_ELSE
%right H_ASSIGN
%left H_COMMA
%left H_OR
%left H_AND
%left H_RELOP
%left H_ADDOP
%left H_MULOP
%right H_NOT
%right H_OPR  // (
%left H_CPR   // )
%right H_OPS  // [
%left H_CPS   // ]
%right H_OPM  // {
%left H_CPM   // }




%%
PROGRAM: FDEFS 
{

}


FDEFS:	FDEFS FUNC_API BLK 
{

}

| FDEFS FUNC_API H_SEMI 
{

}
|
{}	


FUNC_API:	TYPE H_ID H_OPR FUNC_ARGS H_CPR        	
{
	//check if func name already exist in the symbol table pf the functions.

	// if Yes, then check if the arguments match.

	// if every thing is ok (doesn't exist in ST and Args OK) then update current function.
}


FUNC_ARGS : FUNC_ARGLIST
{

}
|
{}


FUNC_ARGLIST :	FUNC_ARGLIST H_COMMA DCL 		
{

}

| DCL
{

}
	

BLK : H_OPM STLIST H_CPM
{

}										


DCL : H_ID H_COLON TYPE
{
	// update the $$ dclList with the given id:type
	// Update $$ type according to $3 type / value.
}
		
| H_ID H_COMMA DCL
{
	// add id to the $$ dclList
	// Set the $$ according to the $3 type.
	// concat the $3 dclList to the $$ dclList
}

TYPE : H_INT8
{
	$$.type = INT8;
}

| H_INT16
{
	$$.type = INT16;
}
| H_INT32
{
	$$.type = INT32;
}
| H_VOID
{
	$$.type = VOID;
}


STLIST : STLIST STMT
{
	
}

|
{}


STMT :  DCL H_SEMI
{
	
}

| ASSN
{
	
}

| EXP H_SEMI
{
	
}
| CNTRL
{}
| READ
{
	
}		
| WRITE
{
	
}		
| RETURN
{
	
}
| BLK
{
	
}


RETURN : H_RETURN EXP H_SEMI
{
	
}

| H_RETURN H_SEMI
{
	
}


WRITE : H_WRITE H_OPR EXP H_CPR H_SEMI
{
	
}
		
| H_WRITE H_OPR H_STR H_CPR H_SEMI
{
	
}


READ : H_READ H_OPR LVAL H_CPR H_SEMI
{
	
}
		


ASSN : LVAL H_ASSIGN EXP H_SEMI
{

}
		
LVAL : H_ID
{

}


CNTRL : H_IF BEXP H_THEN STMT H_ELSE STMT
{
	
}
																					
| H_IF BEXP H_THEN STMT
{

}

| H_WHILE BEXP H_DO STMT
{
	
}


BEXP : BEXP H_OR BEXP
{
	
}

| BEXP H_AND BEXP
{
	
}	
																								  
| H_NOT BEXP
{
	
}
																								  
| EXP H_RELOP EXP
{
	
}

| H_OPR BEXP H_CPR
{
	
}
																				
																					
EXP : EXP H_ADDOP EXP
{
	
}

| EXP H_MULOP EXP
{

}

| H_OPR EXP H_CPR						
{

}

| H_OPR TYPE H_CPR EXP
{

}

| H_ID
{
	
}

| H_NUM
{
	
}
		
| CALL
{

}


CALL : H_ID H_OPR CALL_ARGS H_CPR
{

}


CALL_ARGS : CALL_ARGLIST				
{
	
}
|
{}


CALL_ARGLIST : CALL_ARGLIST H_COMMA EXP			
{

}
| EXP						
{

}			
			

%%

/******************************************************
* The yyerror() function is overriden with our implementaion 
* in order to meet the homework requirments in case of error.
*******************************************************/
void yyerror(const char* token) 
{
	printf("Syntax error: '%s' in line number %d\n", yytext, yylineno);
	exit(0);
}
