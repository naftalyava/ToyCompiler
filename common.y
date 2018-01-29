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

%precedence H_THEN
%precedence H_ELSE



%%
PROGRAM: FDEFS 
{

}


FDEFS:	FDEFS FUNC_API BLK 
			{ 
				header.addImplemented($2.value);
				fManager[$2.value].isImplemented(true);
			}
       | FDEFS FUNC_API H_SEMI 
			{
				header.addUnimplemented($2.value);
				fManager[$2.value].isImplemented(false);
			}
       |    {}	



FUNC_API:	TYPE H_ID H_OPR FUNC_ARGS H_CPR        	
			{
				Function f;
				f.returnType = $1.value;	
				f.name = $2.value;
				f.implemented = false;
				f.startLine = buffer.nextQuad();
				fManager.insert($2.value);
			}


FUNC_ARGS : 	FUNC_ARGLIST
				{

				}
		|		{}


FUNC_ARGLIST :	FUNC_ARGLIST H_COMMA DCL 		
				{
					if ($3.type == INVALID || $3.type == VOID){
						cerr << "Semantic error: Function arguments can be INT8, INT16 or INT32.";
						cerr << " in line number " << to_string(yylineno) << endl;
                        rs = 1;						
						exit(EXIT_SEMANTIC_FAILURE);
					}
					$1.dclNodes.splice($1.dclNodes.end(), $3.dclNodes);
					$$.dclNodes = $1.dclNodes;
				}
		| DCL	{
					if ($1.type == INVALID || $1.type == VOID){
						cerr << "Semantic error: Function arguments can be INT8, INT16 or INT32.";
						cerr << " in line number " << to_string(yylineno) << endl;
                        rs = 1;						
						exit(EXIT_SEMANTIC_FAILURE);
					}
					$$.dclNodes = $1.dclNodes;
				}
	

BLK : H_OPM STLIST H_CPM
				{
					buffer.backpatch($3.nextList , $4.quad);
					sTable.endScope()
					buffer.emit()


					int real_sum;
					int int_sum;
					symbolTable.top().endScope(&real_sum, &int_sum);

					buffer.emit("SUBTI I2 I2 " + to_string(int_sum));
					buffer.emit("SUBTI I4 I4 " + to_string(real_sum));
					
					mem.endBLK();

				}
												


DCL : H_ID H_COLON TYPE
		{
			DCLNode dcl;
			dcl.name = $1.value;
			dcl.type = $3.type;
			$$.dclNodes.push_back(std::make_pair(to_string(yylineno),dcl));

			if ($3.type == INT8 || $3.type == INT16 || $3.type == INT32 || $3.type == VOID)
				$$.type = $3.type;
			else
				$$.type = INVALID;
		}
		
	| H_ID H_COMMA DCL
		{
			DCLNode dcl;
			dcl.name = $1.value;
			dcl.type = $3.type;

			$$.dclNodes.push_back(std::make_pair(to_string(yylineno),dcl));
			$$.dclNodes.splice($$.dclNodes.end(), $3.dclNodes);
			$$.type = $3.type;
		}

TYPE : H_INT8  									{$$.type = INT8;}
       | H_INT16								{$$.type = INT16;}
       | H_INT32								{$$.type = INT32;;}
       | H_VOID								    {$$.type = VOID;}


STLIST : STLIST STMT 							{$$.nodeptr = concatList(makeNode("STLIST", NULL, $1.nodeptr),
												makeNode("STMT", NULL, $2.nodeptr));}
		|										{$$.nodeptr = makeNode("EPSILON", NULL, NULL);}

STMT :  DCL H_SEMI                             {$$.nodeptr = concatList(makeNode("DCL", NULL, $1.nodeptr), makeNode(";", NULL, NULL));}
        | ASSN									{$$.nodeptr = makeNode("ASSN", NULL, $1.nodeptr);}
		| EXP H_SEMI                           {$$.nodeptr = concatList(makeNode("EXP", NULL, $1.nodeptr), makeNode( ";", NULL, NULL));}
        | CNTRL									{$$.nodeptr = makeNode("CNTRL", NULL, $1.nodeptr);}
		| READ									{$$.nodeptr = makeNode("READ", NULL, $1.nodeptr);}		
		| WRITE									{$$.nodeptr = makeNode("WRITE", NULL, $1.nodeptr);}		
		| RETURN							    {$$.nodeptr = makeNode("RETURN", NULL, $1.nodeptr);}
		| BLK									{$$.nodeptr = makeNode("BLK", NULL, $1.nodeptr);}

RETURN : H_RETURN EXP H_SEMI	                {$$.nodeptr = concatList(makeNode("return", NULL, NULL),
												(concatList(makeNode("EXP", NULL, $2.nodeptr),
												makeNode(";", NULL, NULL))));}
        | H_RETURN H_SEMI						{$$.nodeptr = concatList(makeNode("return", NULL, NULL),
												makeNode(";", NULL, NULL));}



WRITE : H_WRITE H_OPR EXP H_CPR H_SEMI			{$$.nodeptr = concatList(makeNode("write",NULL, NULL),
												(concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("EXP", NULL, $3.nodeptr),
												(concatList(makeNode(")", NULL, NULL),
												makeNode(";", NULL, NULL))))))));}
		
		| H_WRITE H_OPR H_STR H_CPR H_SEMI		{$$.nodeptr = concatList(makeNode("write",NULL, NULL),
												(concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("str",$3.value ,NULL),
												(concatList(makeNode(")", NULL, NULL),
												makeNode(";", NULL, NULL))))))));free($3.value);}


READ : H_READ H_OPR LVAL H_CPR H_SEMI			{$$.nodeptr = concatList(makeNode("read", NULL, NULL),
												(concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("LVAL", NULL, $3.nodeptr),
												(concatList(makeNode(")", NULL, NULL),
												makeNode(";", NULL, NULL))))))));}
		


ASSN : LVAL H_ASSIGN EXP H_SEMI					{$$.nodeptr = concatList(makeNode("LVAL", NULL, $1.nodeptr),
												concatList(makeNode("assign","=",NULL),
												concatList(makeNode("EXP", NULL, $3.nodeptr),
												makeNode(";", NULL, NULL))));}
		
LVAL : H_ID 									{$$.nodeptr = makeNode("id",$1.value, NULL); free($1.value);}

CNTRL : H_IF BEXP H_THEN STMT H_ELSE STMT		{$$.nodeptr = concatList(makeNode("if", NULL ,NULL),
												(concatList(makeNode("BEXP", NULL, $2.nodeptr),
												(concatList(makeNode("then", NULL, NULL),
												(concatList(makeNode("STMT", NULL, $4.nodeptr),
												(concatList(makeNode("else", NULL, NULL),
												makeNode("STMT", NULL, $6.nodeptr))))))))));}
																					
		| H_IF BEXP H_THEN STMT					{$$.nodeptr = concatList(makeNode("if",NULL, NULL),
												(concatList(makeNode("BEXP", NULL, $2.nodeptr),
												(concatList(makeNode("then", NULL, NULL),
												makeNode("STMT", NULL, $4.nodeptr))))));}

		| H_WHILE BEXP H_DO STMT				{$$.nodeptr = concatList(makeNode("while", NULL, NULL),
												(concatList(makeNode("BEXP", NULL, $2.nodeptr),
												(concatList(makeNode("do",NULL, NULL),
												makeNode("STMT", NULL, $4.nodeptr))))));}

BEXP : BEXP H_OR BEXP							{$$.nodeptr = concatList(makeNode("BEXP", NULL, $1.nodeptr),
												concatList(makeNode("or", "||",NULL),
												makeNode("BEXP", NULL, $3.nodeptr)));}

		| BEXP H_AND BEXP						{$$.nodeptr = concatList(makeNode("BEXP", NULL, $1.nodeptr),
												concatList(makeNode("and", "&&", NULL),
												makeNode("BEXP", NULL, $3.nodeptr)));}	
																								  
		| H_NOT BEXP							{$$.nodeptr = concatList(makeNode("not", "!", NULL),
												makeNode("BEXP", NULL, $2.nodeptr));}
																								  
		| EXP H_RELOP EXP						{$$.nodeptr = concatList(makeNode("EXP", NULL, $1.nodeptr),
												concatList(makeNode("relop",$2.value,NULL),
												makeNode("EXP", NULL, $3.nodeptr))); free($2.value);}

		| H_OPR BEXP H_CPR						{$$.nodeptr = concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("BEXP", NULL, $2.nodeptr),
												(makeNode(")", NULL, NULL)))));}
																				
																					
EXP : EXP H_ADDOP EXP 							{$$.nodeptr = concatList(makeNode("EXP", NULL, $1.nodeptr),
												concatList(makeNode("addop",$2.value,NULL),
												makeNode("EXP", NULL, $3.nodeptr))); free($2.value);}

		| EXP H_MULOP EXP 						{$$.nodeptr = concatList(makeNode("EXP", NULL, $1.nodeptr),
												concatList(makeNode("mulop",$2.value,NULL),
												makeNode("EXP", NULL, $3.nodeptr))); free($2.value);}

		| H_OPR EXP H_CPR						{$$.nodeptr = concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("EXP", NULL, $2.nodeptr),
												(makeNode(")", NULL, NULL)))));}

        | H_OPR TYPE H_CPR EXP					{$$.nodeptr = concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("TYPE", NULL, $2.nodeptr),
												concatList(makeNode(")", NULL, NULL), makeNode("EXP", NULL, $4.nodeptr)))));}

		| H_ID 									{$$.nodeptr = makeNode("id",$1.value,NULL); free($1.value);}

		| H_NUM									{$$.nodeptr = makeNode("num",$1.value,NULL); free($1.value);}
		
		| CALL									{$$.nodeptr = makeNode("CALL", NULL, $1.nodeptr);}
		

CALL : H_ID H_OPR CALL_ARGS H_CPR				{$$.nodeptr = concatList(makeNode("id",$1.value ,NULL),
												(concatList(makeNode("(", NULL, NULL),
												(concatList(makeNode("CALL_ARGS", NULL, $3.nodeptr),
												makeNode(")", NULL, NULL)))))); free($1.value);}


CALL_ARGS : CALL_ARGLIST 						{$$.nodeptr = makeNode("CALL_ARGLIST", NULL, $1.nodeptr);}
					| 							{$$.nodeptr = makeNode("EPSILON", NULL, NULL);}


CALL_ARGLIST : CALL_ARGLIST H_COMMA EXP			{$$.nodeptr = concatList(makeNode("CALL_ARGLIST", NULL, $1.nodeptr),
												concatList(makeNode(",", NULL, NULL),
												makeNode("EXP", NULL, $3.nodeptr)));}
            | EXP 								{$$.nodeptr = makeNode("EXP", NULL, $1.nodeptr);}			
			

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
