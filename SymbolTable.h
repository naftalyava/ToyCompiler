#ifndef _SYMBOLTABLE_H_
#define _SYMBOLTABLE_H_

#include "Symbol.h"
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

class SymbolNotFound: public exception {};

class SymbolTable {
    private:
		vector< vector<Symbol> > symbols;
		unsigned int level;
		unsigned int offset;
	public:
        SymbolTable();
        ~SymbolTable();
        void startBlock();
        void endBlock();
        void addSymbol(string name, unsigned int size);
        Symbol& findSymbol(string name) const;
}; 

#endif