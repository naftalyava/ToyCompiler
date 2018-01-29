#include "Symbol.h"

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