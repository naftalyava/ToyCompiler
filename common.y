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
extern RegisterManager *register_manager;

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
	//symbol_table->startScope();

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
	cout << "About to add symbols" << endl;
	for (unsigned int i = 0; i < $$.dcl_list.size(); i++){
		symbol_table->addSymbol($$.dcl_list[i].name, $$.dcl_list[i].type);
	}
	cout << "Symbols were added" << endl;
	
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
	cout << "DCL : H_ID H_COLON TYPE" << endl;
	
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

	cout << "DCL : H_ID H_COMMA DCL" << endl;
	//symbol_table->addSymbol($1.value, $3.type);
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
			symbol_table->addSymbol($1.dcl_list[i].name, 2);
			buffer->emit("ADD2I I2 I2 " + to_string(2));
		} else {
			symbol_table->addSymbol($1.dcl_list[i].name, $1.dcl_list[i].type);
			buffer->emit("ADD2I I2 I2 " + to_string($1.dcl_list[i].type));
		}
	}
}

| ASSN
{
	cout << "STMT : ASSN" << endl;
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
	buffer->emit("PRNTI I" + to_string($3.reg));
}
		
| H_WRITE H_OPR H_STR H_CPR H_SEMI
{
	unsigned tmp;
	cout << "H_STR: " << $3.value << endl;
	for (int i=0; i < strlen($3.value); i++){
		if ($3.value[i] == '\\' && $3.value[i+1] == 'n'){
			tmp = '\n';
			i++;
		} 
		else if ($3.value[i] == '\\' && $3.value[i+1] == 't') {
			tmp = '\t';
			i++;
		}
		else {
			tmp = $3.value[i];
		}
		
		buffer->emit("PRNTC " + to_string(tmp));
	}
}


READ : H_READ H_OPR LVAL H_CPR H_SEMI
{
	
}
		


ASSN : LVAL H_ASSIGN EXP H_SEMI
{
cout << "ASSN : LVAL H_ASSIGN EXP H_SEMIN" << endl;
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
	cout << "EXP : EXP H_ADDOP EXP" << endl;
	cout << "$2.value: " << $2.value << endl;
	//Handle error
	cout << "$1.type: " << $1.type << endl;
	cout << "$3.type: " << $3.type << endl;

	if ($1.type != $3.type){
		cout << "Semantic error: <type mismatch> in line number <" << yylineno << ">" << endl;
		exit(3);
	}


	if (strcmp($2.value, "+") == 0){
		$$.reg = register_manager->getRegister();
		buffer->emit("ADD2I I" + to_string($$.reg) 
	                       + " I" + to_string($1.reg)
						   + " I" + to_string($3.reg) 
						   );
	} 
	else if (strcmp($2.value, "-") == 0){
		$$.reg = register_manager->getRegister();
		buffer->emit("SUBTI I" + to_string($$.reg) 
	                       + " I" + to_string($1.reg)
						   + " I" + to_string($3.reg) 
						   );
	} else {
		cout << "ERROR" << endl;
	}
	$$.type = $1.type;
	
}

| EXP H_MULOP EXP
{
	if ($1.type != $3.type){
		cout << "Semantic error: <type mismatch> in line number <" << yylineno << ">" << endl;
		exit(3);
	}

	if (strcmp($2.value, "*") == 0){
		$$.reg = register_manager->getRegister();
		buffer->emit("MULTI I" + to_string($$.reg) 
	                       + " I" + to_string($1.reg)
						   + " I" + to_string($3.reg) 
						   );
	} 
	else if (strcmp($2.value, "/") == 0){
		$$.reg = register_manager->getRegister();
		buffer->emit("DIVDI I" + to_string($$.reg) 
	                       + " I" + to_string($1.reg)
						   + " I" + to_string($3.reg) 
						   );
		
	} else {
		cout << "ERROR" << endl;
	}
	$$.type = $1.type;
}

| H_OPR EXP H_CPR						
{
	$$ = $2;
}

| H_OPR TYPE H_CPR EXP
{

}

| H_ID
{
	cout << "EXP: H_ID start" << endl; 
	Symbol &symbol = symbol_table->findSymbol($1.value);
	cout << "symbol is found" << endl; 
	
	DCL_Node dcl_node;
	dcl_node.type = symbol.getSize();
	dcl_node.name = $1.value;
	$$.dcl_list.push_back(dcl_node);

	try {
		$$.reg = register_manager->getRegister();
		buffer->emit("LDI32 I" + to_string($$.reg) 
						 + " I1 " 
						 +  to_string(symbol_table->findSymbol($1.value).getOffset()));
		$$.type = symbol_table->findSymbol($1.value).getSize();
	} catch (...) {

	}
	cout << "EXP: H_ID end" << endl;
}

| H_NUM
{
	$$.reg = register_manager->getRegister();
	buffer->emit("COPYI I" + to_string($$.reg) 
						   + " " + $1.value);
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
		cout << "Mismatch number of arguments" << endl;
	} else {
		for (int i=0; i < args.size(); i++){
			if (args[i] != $3.dcl_list[i].type){
				//Need to do casting? if Not, error
			}
			switch(args[i])
			{
				case 1:
					buffer->emit("");
					break;
				case 2:
					buffer->emit("");
					break;
				case 4:
					buffer->emit("");
					break;
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
	cout << "CALL_ARGLIST : EPSILON - 1" << endl;
	$$.dcl_list.clear();
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
