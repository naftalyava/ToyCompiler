#include "SymbolTable.h"





Symbol::Symbol(string name, unsigned int size, unsigned int offset) : m_name(name), m_size(size), m_offset(offset) {}

Symbol::~Symbol() {}

bool Symbol::operator==(const Symbol &symbol) 
{
	return (this->m_name == symbol.m_name);
}

string Symbol::getName() const 
{
	return m_name;
}

unsigned int Symbol::getSize() const 
{
	return m_size;
}

unsigned int Symbol::getOffset() const 
{
	return m_offset;
}

void Symbol::setName(string name) 
{
	m_name = name;
}

void Symbol::setSize(unsigned int size) 
{
	m_size = size;
}

void Symbol::setOffset(unsigned int offset) 
{
	m_offset = offset;
}



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
	symbols[level-1].push_back(Symbol(name, size, offset));
	//fix offset
	if (size == 1)
		offset += 2;
	else
		offset += size;
}

Symbol& SymbolTable::findSymbol(string name) const 
{
	for(unsigned int i = level - 1; i >= 0; i--){
		vector<Symbol>::iterator it = std::find(symbols[i].begin(), symbols[i].end(), Symbol(name, 0, 0));
		if (it != symbols[i].end())
			return *it;
	}
	throw SymbolNotFound();
} 
