#include "SymbolTable.h"


SymbolTable::SymbolTable() : level(1), offset(0) 
{
	symbols.resize(level);
}

SymbolTable::~SymbolTable()
{

}

void SymbolTable::startBlock() 
{
	level++;
	symbols.resize(level);
}

void SymbolTable::endBlock() 
{
	level--;
	symbols.pop_back();
}

void SymbolTable::addSymbol(string name, unsigned int size) 
{
	cout << "Symbol: " << name << " offset: " << offset << endl;
	symbols[level-1].push_back(Symbol(name, size, offset));
	//fix offset
	if (size == 1)
		offset += 2;
	else
		offset += size;
}

Symbol& SymbolTable::findSymbol(string name) 
{
	for(unsigned int i = level - 1; i >= 0; i--){
		auto r = std::find(symbols[i].begin(), symbols[i].end(), Symbol(name, 0, 0));
		if (r != end(symbols[i]))
			return *r;
	}
	throw SymbolNotFound();
} 