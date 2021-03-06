#include "common.h"
#include <stack>
#include <iostream>

/*
    Globals                                      
*/


Buffer *buffer = new Buffer();
SymbolTable *symbol_table = new SymbolTable();
Function *current_function = new Function(); 
RegisterManager *register_manager = new RegisterManager();


extern int yyparse ();
extern void yylex_destroy();
extern	FILE *yyin;
extern 	int yylex();
extern int yydebug;
/*
    parser
*/

int main(int argc, char* argv[])
{
	if(argc != 2)
	{
		std::cerr << "Operational error: ";
		std::cerr << "Invalid number of arguments!" << endl;
	    exit(0);
	}
    string inputCodeName = argv[1];

    yyin = fopen(argv[1],"r");
    if(yyin==NULL)
    {
    	  cerr << "Operational error: ";
    	  cerr << "Invalid argument!" << endl;
    	  exit(0);
    }
    if(inputCodeName.substr(inputCodeName.find_last_of("."),4) != ".cmm")
    {
    	  cerr << "Operational error: ";
    	  cerr << "Invalid argument!" << endl;
    	  exit(0);
    }


    

    yyparse();

    string tmp = inputCodeName.substr(0, inputCodeName.find("."));
    buffer->bufferToRiski(tmp + ".rsk");

    fclose(yyin);
    yylex_destroy();

return 0;
}