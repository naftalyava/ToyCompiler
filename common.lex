%{
#include <stdio.h>
#include <string.h>

#include "common.h"
#include "common.tab.h"


%}

%option yylineno noyywrap

digit       ([0-9])
digits		{digit}+
letter      ([a-zA-Z])
whitespace  ([\t\n (\n\r)])
relop		"=="|"<>"|"<"|"<="|">"|">="
addop		"+"|"-"	
mulop		"*"|"/"
assign		"="
and			"&&"
or			"||"
not			(!)
reserved	"int8"|"int16"|"int32"|"void"|"write"|"read"|"while"|"do"|"if"|"then"|"else"|"return"
comment 	#.*[^\n\r]
symbol 		"("|")"|"{"|"}"|","|";"|":"

num			{digits}+
str 		\"(?:[^"\\]|\\.)*\"
id          {letter}(_|{letter}|{digit})*

%%

"int8" 	    {yylval.type = 1; return H_INT8;}
"int16" 	{yylval.type = 2; return H_INT16;}
"int32" 	{yylval.type = 4; return H_INT32;}
"void" 	    {yylval.type = 0; return H_VOID;}
"write" 	{return H_WRITE;}
"read" 		{return H_READ;}
"while" 	{return H_WHILE;}
"do" 		{return H_DO;}
"if" 		{return H_IF;}
"then" 		{return H_THEN;}
"else" 		{return H_ELSE;}
"return" 	{return H_RETURN;}
"(" 		{return H_OPR;} 
")" 		{return H_CPR;} 
"{" 		{return H_OPM;} 
"}" 		{return H_CPM;} 
"," 		{return H_COMMA;} 
";" 		{return H_SEMI;} 
":" 		{return H_COLON;}
{assign} 	{return H_ASSIGN;}
{and} 		{return H_AND;}
{or} 		{return H_OR;}
{not} 		{return H_NOT;}
{num} 		{yylval.value = strdup(yytext);	return H_NUM;}
{id} 		{yylval.value = strdup(yytext);	return H_ID;}
{str} 		{yylval.value = strdup(yytext+1); yylval.value[strlen(yytext)-2]='\0'; return H_STR;}
{relop} 	{yylval.value = strdup(yytext);	return H_RELOP;}
{addop} 	{yylval.value = strdup(yytext);	return H_ADDOP;	}
{mulop} 	{yylval.value = strdup(yytext);	return H_MULOP;	}
{comment}					;
{whitespace}				;
.                           {printf("Lexical error: '%s' in line number %d\n", yytext, yylineno); exit(1);}
%%