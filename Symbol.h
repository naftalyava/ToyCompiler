#ifndef _SYMBOL_H_
#define _SYMBOL_H_

#include <string>

using namespace std;

class Symbol {
	private:
		string m_name;
		unsigned int m_size;
		unsigned int m_offset;
	public:
        Symbol(string name, unsigned int size, unsigned int offset = 0);
        ~Symbol();
        bool operator==(const Symbol &symbol);
        string getName() const;
        unsigned int getSize() const;
        unsigned int getOffset() const;
        void setName(string name);
        void setSize(unsigned int size);
        void setOffset(unsigned int offset);
};


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


#endif
