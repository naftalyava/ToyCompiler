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
	current_function->clearArgs();


	// if there is no return to the current function (add return)
	// Set current function as NULL
	register_manager->startScope();

	cout << "adding function arguments to symbol_table" << endl;

	for (int i = 0; i < $2.dcl_list.size(); i++){
		cout << "adding: " << $2.dcl_list[i].name << " size: " << $2.dcl_list[i].type << endl; 
		symbol_table->addArgumentSymbol($2.dcl_list[i].name, $2.dcl_list[i].type);
	}
	

} BLK {
	buffer->emit("RETRN");
	//close scope
	delete symbol_table;
	register_manager->endScope();
	
	cout << "Re-Allocate new ST" << endl;
	symbol_table = new SymbolTable();

}

| FDEFS FUNC_API H_SEMI 
{
	cout << "FDEFS : FDEFS FUNC_API H_SEMI" << endl;
	// Set function as unimplemented
	current_function->setIsImplemented(false);

	


	/* */

	buffer->addFunction(*current_function);
	current_function->clearArgs();
	// Set current function as NULL
}
|
{}	


FUNC_API:	TYPE H_ID H_OPR FUNC_ARGS H_CPR        	
{
	cout << "FUNC_API:	TYPE H_ID H_OPR FUNC_ARGS H_CPR" << endl;
	$$.dcl_list = $4.dcl_list;
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

	for (int i = 0 ; i < $4.dcl_list.size(); i++)	{
		current_function->addArgument($4.dcl_list[i].type);
	}

	cout <<  "currentFunc name: " << $2.value << endl;
	cout << "currentFunc args count: " << current_function->getArguments().size() << endl;
	
}


FUNC_ARGS : FUNC_ARGLIST
{
	$$.dcl_list = $1.dcl_list;
}
|
{
	//function recieve no arguments?
}


FUNC_ARGLIST :	FUNC_ARGLIST H_COMMA DCL 		
{
	cout << "FUNC_ARGLIST :	FUNC_ARGLIST H_COMMA DCL " << endl;
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]: " <<  $$.dcl_list[i].name << endl;
	}
	cout << "----------------------" << endl;
	$$.dcl_list.insert($$.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]: " <<  $$.dcl_list[i].name << endl;
	}

	/*
	cout << "About to add symbols" << endl;
	for (unsigned int i = 0; i < $3.dcl_list.size(); i++){
		symbol_table->addSymbol($3.dcl_list[i].name, $3.dcl_list[i].type);
		cout << "symbol name: " << $3.dcl_list[i].name << endl;
		cout << "symbol size: " << $3.dcl_list[i].type << endl;
	}
	*/

	// DON'T ENABLE THIS LINE <------- BUG -------->
	//$$.dcl_list.insert($$.dcl_list.end(), $1.dcl_list.begin(), $1.dcl_list.end());
	cout << "Symbols were added" << endl;

	// check semantic error of $3 (No Void)

	// concat $3 to the end of $1.

	// Update the $$ dclList

}

| DCL
{
	// check semantic error (No Void)
	cout << "FUNC_ARGLIST :	DCL " << endl;
	// update the $$ dclList according to $1
	cout << "$1.dcl_list size: " <<  $1.dcl_list.size() << endl;
	for (int i = 0; i < $1.dcl_list.size(); i++)
	{
		cout << "$1.dcl_list[i]: " <<  $1.dcl_list[i].name << endl;
	}

	cout << "$$.dcl_list size: " <<  $$.dcl_list.size() << endl;
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]: " <<  $$.dcl_list[i].name << endl;
	}

	cout << "About to add symbols" << endl;
	for (unsigned int i = 0; i < $1.dcl_list.size(); i++){
		symbol_table->addSymbol($1.dcl_list[i].name, $1.dcl_list[i].type);
		cout << "symbol name: " << $1.dcl_list[i].name << endl;
		cout << "symbol size: " << $1.dcl_list[i].type << endl;
	}

	cout << "Symbols were added" << endl;
	
}
	

BLK : H_OPM 
{
	$$.quad = buffer->getQuad();
	symbol_table->startBlock();
	// if current function has arguments and ST is empty ( we are in the bigger block) 

	// add the current function dclList to the ST.

	
} STLIST M H_CPM {
	cout << "BLK: } STLIST M H_CPM {" << endl;

	buffer->backPatch($3.next_list , $4.quad);
	//add $2 dclList to the ST and check for sematic errors
	symbol_table->endBlock();
}								


DCL : H_ID H_COLON TYPE
{
	cout << "DCL : H_ID H_COLON TYPE" << endl;
	// update the $$ dclList with the given id:type
	DCL_Node node = {$1.value, $3.type, yylineno};
	$$.dcl_list.push_back(node);
	cout << "$1.value: " << $1.value << endl;
	// Update $$ type according to $3 type / value.
	$$.type = $3.type;
	cout << "$$.dcl_list size: " <<  $$.dcl_list.size() << endl;
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]: " <<  $$.dcl_list[i].name << endl;
	}
	
	
}
		
| H_ID H_COMMA DCL
{
	cout << "DCL : H_ID H_COMMA DCL" << endl;
	// add id to the $$ dclList
	DCL_Node node = {$1.value, $3.type, yylineno};
	$$.dcl_list.push_back(node);
	$$.dcl_list.insert($$.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());
	cout << "$1.value: " << $1.value << endl;
	// Set the $$ according to the $3 type.
	$$.type = $3.type;
	cout << "$$.dcl_list size: " <<  $$.dcl_list.size() << endl;
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]: " <<  $$.dcl_list[i].name << endl;
	}
	// concat the $3 dclList to the $$ dclList
	//$$.dcl_list.insert($$.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());

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


STLIST : STLIST M STMT
{
	cout << "STLIST : STLIST M STMT" << endl;
	
	$$.next_list = $3.next_list;
	for (auto element : $$.next_list)
		cout << "$$next_list[i]" << element << endl;
	$3.next_list.clear(); //will be taken care by backPatching the LIST in the next derevation

	
	for (auto element : $$.next_list)
		cout << "$$next_list[i]" << element << endl;

	buffer->backPatch($1.next_list, $2.quad);
}

|
{}


STMT :  DCL H_SEMI
{
	for (int i= 0; i<$1.dcl_list.size(); i++){
		
		if ($1.dcl_list[i].type == 1){
			symbol_table->addSymbol($1.dcl_list[i].name, 1);
			buffer->emit("ADD2I I2 I2 " + to_string(2));
		} else {
			symbol_table->addSymbol($1.dcl_list[i].name, $1.dcl_list[i].type);
			buffer->emit("ADD2I I2 I2 " + to_string($1.dcl_list[i].type));
		}
		
		//symbol_table->addSymbol($1.dcl_list[i].name, $1.dcl_list[i].type);
		//buffer->emit("ADD2I I2 I2 " + to_string($1.dcl_list[i].type));
	}
}

| ASSN{}

| EXP H_SEMI{}
| CNTRL
{
	cout << "STMT: CNTRL" << endl;
	$$.next_list = $1.next_list;

	for (auto element : $$.next_list)
		cout << "$$next_list[i] " << element << endl;
}
| READ{}		
| WRITE{}		
| RETURN{}
| BLK{}


RETURN : H_RETURN EXP H_SEMI
{
	buffer->emit("STI32 I" + to_string($2.reg) +" I1 -4");
	buffer->emit("RETRN");
}

| H_RETURN H_SEMI
{
	buffer->emit("RETRN");
}


WRITE : H_WRITE H_OPR EXP H_CPR H_SEMI
{
	if ($3.type != 4) {
		int tmp = register_manager->getRegister();
		buffer->emit("SLAI I" + to_string(tmp) + " I" 
							 + to_string($3.reg) + " "+ to_string(32 - 8 * $3.type));
		buffer->emit("SRAI I" + to_string(tmp) + " I" 
		                     + to_string(tmp) + " " + to_string(32 - 8 * $3.type));
		buffer->emit("PRNTI I" + to_string(tmp));
	} else {
		buffer->emit("PRNTI I" + to_string($3.reg));
	}
	
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
	cout << "READ : H_READ H_OPR LVAL H_CPR H_SEMI" << endl;
	if ($3.type == 0)
	{
		cout << "Semantic error: <Read target type void> in line number <" << yylineno << ">" << endl;
		exit(3);	
	}
	int readReg = register_manager->getRegister();

	buffer->emit("READI I" + to_string(readReg));

	buffer->emit("STI" + to_string($3.type*8) + " I" + to_string(readReg) + " I" + to_string($3.reg) + " 0");


}
		


ASSN : LVAL H_ASSIGN EXP H_SEMI
{
	cout << "ASSN : LVAL H_ASSIGN EXP H_SEMI" << endl;
	cout << "$1.type: " << $1.type << " $3.type: " << $3.type << endl;
	cout << "$1.reg: " << $1.reg << " $3.reg: " << $3.reg << endl;
	if ($1.type != $3.type)
	{
		cout << "Semantic error: <Assignment type mismatch> in line number <" << yylineno << ">" << endl;
		exit(3);
	}

	$$.type = $1.type;
	$$.reg = $1.reg;
	buffer->emit("STI" + to_string($$.type * 8) + " I"  + to_string($3.reg) + " I" + to_string($1.reg) + " 0");
}
		
LVAL : H_ID
{
	cout << "LVAL : H_ID start" << endl; 
	DCL_Node dcl_node;
	try{
		Symbol &symbol = symbol_table->findSymbol($1.value);
		cout << "symbol is found: " << $1.value << endl; 
		cout << "symbol is size: " << symbol.getSize() << endl; 
	
		dcl_node.type = symbol.getSize();
		dcl_node.name = $1.value;
		dcl_node.node_offset = symbol.getOffset();
	}
	catch (...)
	{
		cout << "Semantic error: <Symbol Not Found> in line number <" << yylineno << ">" << endl;
		exit(3);
	}	

	try {
		$$.reg = dcl_node.node_reg = register_manager->getRegister();
		cout << "LVAL : H_ID dcl_node.node_reg : " << dcl_node.node_reg << endl;
		buffer->emit("ADD2I I" + to_string(dcl_node.node_reg) 
						 + " I1 " 
						 +  to_string(symbol_table->findSymbol($1.value).getOffset()));
		$$.type = symbol_table->findSymbol($1.value).getSize();
	} catch (...) {
		cout << "Semantic error: <Symbol Not Found> in line number <" << yylineno << ">" << endl;
		exit(3);
	}
	$$.dcl_list.push_back(dcl_node);
	cout << "LVAL : H_ID end" << endl;
}


CNTRL : H_IF BEXP H_THEN M STMT H_ELSE N M STMT
{
	set<int> merged;
	cout << "CNTRL : H_IF BEXP H_THEN M STMT H_ELSE N M STMT" << endl;
	buffer->backPatch($2.true_list, $4.quad);
	buffer->backPatch($2.false_list, $8.quad);
	
	MERGE_LISTS(merged, $5.next_list, $7.next_list);
	MERGE_LISTS($$.next_list, merged, $9.next_list);

	for (auto element : $$.next_list)
		cout << "$$next_list[i]" << element << endl;
}
																					
| H_IF BEXP H_THEN M STMT
{
	buffer->backPatch($2.true_list , $4.quad);
	MERGE_LISTS($$.next_list, $2.false_list, $5.next_list);
}

| H_WHILE M BEXP H_DO M STMT
{
	buffer->backPatch($6.next_list , $2.quad);
	buffer->backPatch($3.true_list , $5.quad);
	$$.next_list = $3.false_list;
	buffer->emit("UJUMP " + to_string($2.quad));
}


BEXP : BEXP H_OR M BEXP
{
	// Update BEXP false list and update the true list
	buffer->backPatch($1.false_list , $3.quad);
	MERGE_LISTS($$.true_list, $1.true_list , $4.true_list);
	$$.false_list = $4.false_list;
}

| BEXP H_AND M BEXP
{
	// Update BEXP false list and update the true list
	buffer->backPatch($1.true_list , $3.quad);
	$$.true_list = $4.true_list;
	MERGE_LISTS($$.false_list, $1.false_list , $4.false_list);
}	
																								  
| H_NOT BEXP
{
	// Swap the ture/false lists.
	$$.true_list = $2.false_list;
	$$.false_list = $2.true_list;
}
																								  
| EXP H_RELOP EXP
{
	cout << "BEXP: EXP H_RELOP EXP" << endl;
	cout << "RELOP: " << $2.value << endl;
	if ($1.type != $3.type)
	{
		cout << "Sssssssssssssssssssss" << endl;
		exit(3);
	}

	$$.reg = register_manager->getRegister();
	string relop;
	string branch;

	//update the variables of the string with proper command
	//"=="|"<>"|"<"|"<="|">"|">="
	if (strcmp($2.value, "==") == 0)
	{
		relop.assign("SEQUI");
		branch.assign("BREQZ");
	}

	if (strcmp($2.value, "<>") == 0)
	{
		relop.assign("SNEQI");
		branch.assign("BREQZ");
	}

	if (strcmp($2.value, "<") == 0)
	{
		relop.assign("SLETI");
		branch.assign("BREQZ");
	}

	if (strcmp($2.value, "<=") == 0)
	{
		relop.assign("SGRTI");
		branch.assign("BNEQZ");
	}

	if (strcmp($2.value, ">") == 0)
	{
		relop.assign("SGRTI");
		branch.assign("BREQZ");
	}

	if (strcmp($2.value, ">=") == 0)
	{
		relop.assign("SLETI");
		branch.assign("BNEQZ");
	}


	buffer->emit(relop + " I"+ to_string($$.reg) + " I" +to_string($1.reg) + " I" +to_string($3.reg));
	$$.false_list.insert(buffer->nextQuad());
	buffer->emit(branch + " I" + to_string($$.reg) + " ");
	$$.true_list.insert(buffer->nextQuad());
	buffer->emit("UJUMP ");

}

| H_OPR BEXP H_CPR
{
	$$.true_list = $2.true_list;
	$$.false_list = $2.false_list;
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
	$$.is_exp = true;
	
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
	$$.is_exp = true;
}

| H_OPR EXP H_CPR						
{
	$$ = $2;
	$$.is_exp = $2.is_exp;
}

| H_OPR TYPE H_CPR EXP
{
	cout << "EXP : H_OPR TYPE H_CPR EXP" << endl;
	cout << "$2.type: " << $2.type << endl;
	cout << "$4.type: " << $4.type << endl;
	cout << "to_string(32 - 8 * $4.type): " << to_string(32 - 8 * $4.type) << endl;

	$$.type = $2.type;

	//cast from big to small


	if ($4.type > $2.type) {
		$$.reg = register_manager->getRegister();
		if (!$4.is_const){
			
			buffer->emit("SLAI I" + to_string($$.reg) + " I" 
							 + to_string($4.reg) + " "+ to_string(32 - 8 * $2.type));
			buffer->emit("SRAI I" + to_string($$.reg) + " I" 
		                     + to_string($$.reg) + " " + to_string(32 - 8 * $2.type));
			buffer->emit("ANDI I" + to_string($$.reg) + " I" + to_string($$.reg) + " " + to_string(-1+(int)pow(2, 8 * $2.type)));
		} else {
			buffer->emit("ANDI I" + to_string($$.reg) + " I" + to_string($4.reg) + " " + to_string(-1+(int)pow(2, 8 * $2.type)));
		}
			
	}
	else if ($4.type < $2.type)	{
		$$.reg = register_manager->getRegister();
		if (!$4.is_const){
			buffer->emit("SLAI I" + to_string($$.reg) + " I" 
							 + to_string($4.reg) + " "+ to_string(32 - 8 * $4.type));
			buffer->emit("SRAI I" + to_string($$.reg) + " I" 
		                     + to_string($$.reg) + " " + to_string(32 - 8 * $4.type));
			if($2.type != 4){
				buffer->emit("ANDI I" + to_string($$.reg) + " I" + to_string($$.reg) + " " + to_string(-1+ (int)pow(2, 8 * $2.type)));
				}
		} else {
			if($2.type != 4){
				buffer->emit("ANDI I" + to_string($$.reg) + " I" + to_string($4.reg) + " " + to_string(-1+ (int)pow(2, 8 * $2.type)));
			}
			
		}
			
	}
	else {
		$$.reg = $4.reg;
	}
	$$.is_exp = true;//$4.is_exp;
		
}

| H_ID
{
	cout << "EXP: H_ID start" << endl; 
	DCL_Node dcl_node;
	try{
		Symbol &symbol = symbol_table->findSymbol($1.value);
		cout << "symbol is found: " << $1.value << endl; 
		cout << "symbol size: " << symbol.getSize() << endl; 
		cout << "symbol offset: " << symbol.getOffset() << endl;
	
		dcl_node.type = symbol.getSize();
		dcl_node.name = $1.value;
	}
	catch (...)
	{
		cout << "Semantic error: <Symbol Not Found> in line number <" << yylineno << ">" << endl;
		exit(3);
	}
	
	

	try {
		$$.type = symbol_table->findSymbol($1.value).getSize();
		$$.reg = dcl_node.node_reg = register_manager->getRegister();
		cout << "EXP: H_ID dcl_node.node_reg : " << dcl_node.node_reg << endl;
		buffer->emit("LDI" + to_string($$.type * 8)+ " I" + to_string(dcl_node.node_reg) 
						 + " I1 " 
						 +  to_string(symbol_table->findSymbol($1.value).getOffset()));
		
	} catch (...) {
		cout << "Semantic error: <Symbol Not Found> in line number <" << yylineno << ">" << endl;
		exit(3);
	}
	$$.dcl_list.push_back(dcl_node);
	$$.is_exp = false;
	cout << "EXP: H_ID end" << endl;
}

| H_NUM
{
	$$.is_const = true;
	$$.type = 4;
	$$.reg = register_manager->getRegister();
	buffer->emit("COPYI I" + to_string($$.reg) 
						   + " " + $1.value);
	$$.is_exp = false;
}
		
| CALL
{
	$$.type = $1.type;
	$$.reg = $1.reg;
	$$.is_exp = $1.is_exp;
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
	$$.type = func.getReturnType();

	cout << "$3.dcl_list.size(): " << $3.dcl_list.size() << endl;
	cout << "args.size(): " << args.size() << endl;
	if ($3.dcl_list.size() != args.size()){
		cout << "Semantic error: <Argument Number Mismatch> in line number <" << yylineno << ">" << endl;
				exit(3);
	} else {
		cout << "CHECK FUNCTION SIGNATURE" << endl;
		for (int i=0; i < args.size(); i++){
			if (args[i] != $3.dcl_list[i].type){
				cout << "args[i]: " << args[i] << endl;
				cout << "$3.dcl_list[i].type: " << $3.dcl_list[i].type << endl;

				cout << "Semantic error: <Argument Type Mismatch> in line number <" << yylineno << ">" << endl;
				exit(3);
			}
		}

		if (!func.getIsImplemented()){
			func.addCallLine(buffer->getQuad());
			cout << "call lines was updated for:" << endl;
			cout << "func name: " << func.getName() << " line: " << buffer->getQuad() << endl;
		}

	
	}
 

	// Push registers in usage to the stack
	int stack_counter = 0;
	cout << "Push registers in usage to the stack , RegNum:" << register_manager->getRegistersCount() << endl;
	for (int i = 0 ; i < register_manager->getRegistersCount(); i++)
	{
		buffer->emit("STI32 I" + to_string(i) + " I2 " + to_string(i*4));
		stack_counter += 4;
	}

	int tmp = 0;
	for (int i = $3.dcl_list.size()-1 ; i >= 0; i--)
	{	
		if ((int)$3.dcl_list[i].type == 1)
			tmp += 2;
		else
			tmp += (int)$3.dcl_list[i].type;
	}

	//Make room for Return value And Arguments
	stack_counter += 4;
	buffer->emit("ADD2I I2 I2 " + to_string(stack_counter + tmp));
	

	//Move FP
	buffer->emit("COPYI I1 I2");

	// Push call arguments
	cout << "Push call arguments to the stack" << endl;
	int rev_counter = -4;
	cout << "STACK COUNTER [BEFORE]: " << stack_counter << endl;
	for (int i = 0 ; i < $3.dcl_list.size(); i++)
	{
		if ($3.dcl_list[i].type == 1){
			rev_counter -= 1;
		}
		else if ($3.dcl_list[i].type == 2){
			rev_counter -= 2;
			if (rev_counter % 2 == 0){
			} else {
				rev_counter -= 1;
			}	
		} else {
			rev_counter -= 4;
			if (rev_counter % 4 == 0){}
			else
				rev_counter -= (4 - (rev_counter % 4)); 
		}
		cout << "************** $3.dcl_list.size: " << $3.dcl_list.size() << endl;
		cout << "************** $3.dcl_list[i].name: " << $3.dcl_list[i].name << endl;
		cout << "************** $3.dcl_list[i].node_reg: " << $3.dcl_list[i].node_reg << endl;
		buffer->emit("STI" + to_string(8 * $3.dcl_list[i].type) + " I" + to_string($3.dcl_list[i].node_reg) + " I1 " + to_string(rev_counter)); // Don't know why -8!!!!!


	}
	cout << "STACK COUNTER [AFTER]: " << stack_counter << endl;



	//JLink
	if (!func.getIsImplemented()){
		buffer->emit("JLINK -1");
	}
	else{
		buffer->emit("JLINK " + to_string(func.getLine()));
	}

	//Move FP back
	buffer->emit("COPYI I2 I1");
	
	//Load return value (always size == 4) --> Maybe we need to cast according to Func return type
	$$.reg = register_manager->getRegister();
	buffer->emit("LDI32 I" + to_string($$.reg) + " I1 -4");
	
	// Sub the extra jump we did for I2 <--------------
	buffer->emit("SUBTI I2 I2 " + to_string(stack_counter + tmp));

	// Load registers back
	cout << "Load registers from the stack" << endl;
	for (int i = 0 ; i < register_manager->getRegistersCount() - 1 ; i++)
	{										/* -1 for the register we used for the return value */
		if (i == 2)
			continue;

		buffer->emit("LDI32 I" + to_string(i) + " I2 " + to_string(i*4));
	}


}


CALL_ARGS : CALL_ARGLIST				
{
	cout << "CALL_ARGS : CALL_ARGLIST" << endl;
	$$.dcl_list = $1.dcl_list;
	for (int i = 0 ; i < $$.dcl_list.size(); i++){
		cout << "name:type " << $$.dcl_list[i].name << " : " << $$.dcl_list[i].type << endl;
	}
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
	cout << "$3.reg: " << $3.reg << endl;
	for (int i = 0 ; i < $3.dcl_list.size(); i++){
		cout << "name:type " << $3.dcl_list[i].name << " : " << $3.dcl_list[i].type << endl;
		cout << "&&&&&& $3.dcl_list[i].node_reg: " << $3.dcl_list[i].node_reg << endl;
		if ($3.is_exp && $3.reg != $3.dcl_list[i].node_reg)
		{
			$3.dcl_list[i].node_reg = $3.reg;
		}
		cout << "%%%%%% $3.dcl_list[i].node_reg: " << $3.dcl_list[i].node_reg << endl;
	}
	cout << "#######################" << endl;
	$$.dcl_list.insert($$.dcl_list.end(), $3.dcl_list.begin(), $3.dcl_list.end());
	for (auto element: $$.dcl_list)
		cout << "name:type " << element.name << " : " << element.type << endl;
}
| EXP						
{
	cout << "CALL_ARGLIST : EXP" << endl;
	cout << "$$.dcl_list size: " <<  $$.dcl_list.size() << endl;
	for (int i = 0; i < $$.dcl_list.size(); i++)
	{
		cout << "$$.dcl_list[i]-name:reg " <<  $$.dcl_list[i].name << ":" << $$.dcl_list[i].node_reg << endl;
	}
}

M : 
{
	cout << "M - Marker" << endl;
	$$.quad = buffer->nextQuad();
	cout << "$$.quad" << $$.quad << endl;
	
}

N :
{
	cout << "N - Marker" << endl;
	// update next_list
	$$.next_list.insert(buffer->nextQuad());
	cout << "buffer->nextQuad()" << buffer->nextQuad() << endl;

	// prepare space for jump
	buffer->emit("UJUMP ");
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
