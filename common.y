%{

#include <string.h>
#include <iostream>
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
extern Buffer *buffer;
extern SymbolTable *symbol_table;
extern Function *current_function; 

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


FDEFS:	FDEFS FUNC_API  
{
	//initiate ST 
	// Set function as implemented
	current_function->setIsImplemented(true);
	current_function->setLine(buffer->getQuad());
	// Set function line
	

	// Add function to function manager
	buffer->addFunction(*current_function);


	// if there is no return to the current function (add return)
	// Set current function as NULL
} BLK {
	
	

}

| FDEFS FUNC_API H_SEMI 
{
	// Set function as unimplemented
	current_function->setIsImplemented(false);
	buffer->addFunction(*current_function);
	// Set current function as NULL
}
|
{}	


FUNC_API:	TYPE H_ID H_OPR FUNC_ARGS H_CPR        	
{
	//check if func name already exist in the symbol table pf the functions.

	// if Yes, then check if the arguments match.

	// if every thing is ok (doesn't exist in ST and Args OK) then update current function.
	current_function->setName($2.value);
	current_function->setReturnType($1.type);
	
	if ($1.type == VOID){
		current_function->setReturnType(0);
	} 
	else if($1.type == INT8){
		current_function->setReturnType(1);
	}
	else if($1.type == INT16){
		current_function->setReturnType(2);
	}
	else if($1.type == INT32){
		current_function->setReturnType(4);
	}	


	
}


FUNC_ARGS : FUNC_ARGLIST
{
	//update $$ dclList = $1 dclList
}
|
{
	//function recieve no arguments?
}


FUNC_ARGLIST :	FUNC_ARGLIST H_COMMA DCL 		
{
	// check semantic error of $3 (No Void)

	// concat $3 to the end of $1.

	// Update the $$ dclList

}

| DCL
{
	// check semantic error (No Void)

	// update the $$ dclList according to $1
	$$.dcl_list = $1.dcl_list;
}
	

BLK : H_OPM 
{
	$$.quad = buffer->getQuad();
	// if current function has arguments and ST is empty ( we are in the bigger block) 

	// add the current function dclList to the ST.

	
} STLIST H_CPM {
	//add $2 dclList to the ST and check for sematic errors
}								


DCL : H_ID H_COLON TYPE
{
	// update the $$ dclList with the given id:type
	DCL_Node node = {$1.value, $3.type, yylineno};
	$$.dcl_list.push_back(node);

	// Update $$ type according to $3 type / value.
	$$.type = $3.type;
}
		
| H_ID H_COMMA DCL
{
	// add id to the $$ dclList
	DCL_Node node = {$1.value, $3.type, yylineno};
	$$.dcl_list.push_back(node);

	// Set the $$ according to the $3 type.
	$$.type = $3.type;

	// concat the $3 dclList to the $$ dclList
	$$.dcl_list.insert($$.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());
}

TYPE : H_INT8
{
	$$.type = 1;
}

| H_INT16
{
	$$.type = 2;
}
| H_INT32
{
	$$.type = 4;
}
| H_VOID
{
	$$.type = 0;
}


STLIST : STLIST STMT
{
	
}

|
{}


STMT :  DCL H_SEMI
{
	for (int i= 0; i<$1.dcl_list.size(); i++){
		if ($1.dcl_list[i].type == 1){
			buffer->emit("ADD2I I2 I2 " + to_string(2));
		} else {
			buffer->emit("ADD2I I2 I2 " + to_string($1.dcl_list[i].type));
		}
	}
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
	Symbol &symbol = symbol_table->findSymbol($1.value);
	DCL_Node dcl_node;
	dcl_node.type = symbol.getSize();
	dcl_node.name = $1.value;
	$$.dcl_list.push_back(dcl_node);
}

| H_NUM
{
	
}
		
| CALL
{

}


CALL : H_ID H_OPR CALL_ARGS H_CPR
{
	//Construct function


	cout << "called: " << $1.value << endl;
	Function &func = buffer->findFunction($1.value);
	cout << "function: " << func.getName() << "is found" << endl;
	cout << "is implemented: " << func.getIsImplemented() << endl;

	vector<unsigned int> args = func.getArguments();
	cout << "get arguments done" << endl;
	

	cout << "$3.dcl_list.size(): " << $3.dcl_list.size() << endl;
	cout << "args.size(): " << args.size() << endl;
	if ($3.dcl_list.size() != args.size()){

	} else {
		for (int i=0; i < args.size(); i++){
			if (args[i] != $3.dcl_list.size()){

			} else {

			}
		}

		if (!func.getIsImplemented()){
			func.addCallLine(buffer->getQuad());
			cout << "call lines was updated for:" << endl;
			cout << "func name: " << func.getName() << " line: " << buffer->getQuad() << endl;
		}
			
	}
 

}


CALL_ARGS : CALL_ARGLIST				
{
	cout << "CALL_ARGS : CALL_ARGLIST" << endl;
	$$.dcl_list = $1.dcl_list;
}
|
{	
	$$.dcl_list.empty();
	cout << "$$.dcl_list.size(): " << $$.dcl_list.size() << endl;
}


CALL_ARGLIST : CALL_ARGLIST H_COMMA EXP			
{
	cout << "CALL_ARGLIST : CALL_ARGLIST H_COMMA EXP" << endl;
	cout << "before insert $$.dcl_list.size(): " << $$.dcl_list.size() << endl;
	cout << "$1.dcl_list.size(): " << $1.dcl_list.size() << endl;
	cout << "$3.dcl_list.size(): " << $3.dcl_list.size() << endl;
	$$.dcl_list.insert($1.dcl_list.end(), $1.dcl_list.begin(), $1.dcl_list.end());
	$$.dcl_list.insert($1.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());
	cout << "after insert $$.dcl_list.size(): " << $$.dcl_list.size() << endl;
}
| EXP						
{
	cout << "CALL_ARGLIST : EXP" << endl;
	$$.dcl_list.insert($$.dcl_list.end(), $1.dcl_list.begin(), $1.dcl_list.end());
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
