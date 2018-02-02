#ifndef _SYMBOL_H_
#define _SYMBOL_H_

#include <string>

using namespace std;

class Symbol {
	private:
		string m_name;
		unsigned int m_size;
		int m_offset;
	public:
        Symbol(string name, unsigned int size, int offset = 0);
        ~Symbol();
        bool operator==(const Symbol &symbol);
        string getName() const;
        unsigned int getSize() const;
        int getOffset() const;
        void setName(string name);
        void setSize(unsigned int size);
        void setOffset(int offset);
};

#endif
