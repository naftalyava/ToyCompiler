#ifndef _SYMBOLTABLE_H_
#define _SYMBOLTABLE_H_

#include "Symbol.h"
#include <string>
#include <vector>
#include <algorithm>
#include  <iostream>

class SymbolNotFound: public exception {};
class SymbolAlreadyExists: public exception {};

using namespace std;

class SymbolTable {
    private:
	vector< vector<Symbol> > symbols;
	unsigned int level;
	int offset;
        int backwards_offset;
    public:
        SymbolTable();
        ~SymbolTable();
        void startBlock();
        void endBlock();
        int addSymbol(string name, unsigned int size);
        void addArgumentSymbol(string name, unsigned int size);
        Symbol& findSymbol(string name);
        int getOffset() const {
                return offset;
        }
}; 

#endif