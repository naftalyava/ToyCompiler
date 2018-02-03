#include "SymbolTable.h"


SymbolTable::SymbolTable() : level(1), offset(0), backwards_offset(-4)
{
	symbols.resize(level);
}

SymbolTable::~SymbolTable()
{

}

void SymbolTable::startBlock() 
{
	level++;
	cout << "startBlock - level: " << level << endl;
	symbols.resize(level);
}

void SymbolTable::endBlock() 
{
	level--;
	cout << "endBlock - level: " << level << endl;
	symbols.pop_back();
}

void SymbolTable::addArgumentSymbol(string name, unsigned int size)
{
	cout << "Symbol: " << name << " size: " << size << " offset: " << backwards_offset << " added" << endl;
		/* START */
	if (size == 1){
		backwards_offset -=1;
	}
	else if (size == 2){
		backwards_offset -=2;
		if (backwards_offset % 2 == 0){
		} else {
			backwards_offset -= 1;
		}	
	} else {
		backwards_offset -=4;
		if (backwards_offset % 4 == 0){}
		else
			backwards_offset -= (4 - (backwards_offset % 4)); 
	}

	/* END */
	symbols[level-1].push_back(Symbol(name, size, backwards_offset));
		
}

int SymbolTable::addSymbol(string name, unsigned int size) 
{
	cout << "Symbol: " << name << " size: " << size << " offset: " << offset << endl;
	
	/* START */
	int tmp = 0;
	if (size == 1){
	}
	else if (size == 2){
		if (offset % 2 == 0){
		} else {
			tmp = 1;
			offset += 1;
		}	
	} else {
		if (offset % 4 == 0){}
		else{
			tmp = (4 - (offset % 4));
			offset += (4 - (offset % 4));
		}
			 
	}

	/* END */
	symbols[level-1].push_back(Symbol(name, size, offset));
	offset += size;
	return tmp + size;
}

Symbol& SymbolTable::findSymbol(string name) 
{
	cout << "Try to find symbol: " << name << endl;

	cout << "level" << level << endl;
	for(int i = level - 1; i >= 0; i--){
		cout << "symbols[i].size: " << symbols[i].size() << endl;
		auto r = std::find(symbols[i].begin(), symbols[i].end(), Symbol(name, 0, 0));
		if (r != end(symbols[i]))
			return *r;
	}
	throw SymbolNotFound();
} 