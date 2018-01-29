#include <string>
#include <vector>
#include <algorithm>


using namespace std;


class Symbol{
	private:
		string m_name;
		unsigned int m_size;
		unsigned int m_offset;
	public:
		Symbol(string name, unsigned int size, unsigned int offset = 0) : m_name(name), m_size(size), m_offset(offset) {}
		~Symbol() = default;
		bool operator==(const Symbol &symbol){ return (this->m_name == symbol.m_name);}
		string getName() const {return m_name;}
		unsigned int getSize() const {return m_size;}
		unsigned int getOffset() const {return m_offset;}
		void setName(string name) {m_name = name;}
		void setSize(unsigned int size) {m_size = size;}
		void setOffset(unsigned int offset) {m_offset = offset;}
};


class SymbolTable{

	private:
		vector< vector<Symbol> > symbols;
		unsigned int level;
		unsigned int offset;

	public:
		SymbolTable() : level(1), offset(0) {
			symbols.resize(level);
		}
		~SymbolTable(){}
		void startBlock() {
			level++;
			symbols.resize(level);
		}
		void endBlock() {
			symbols.pop_back();
		}
		void addSymbol(string name, unsigned int size) {
			symbols[level-1].push_back(Symbol(name, size, offset));
			//fix offset
			if (size == 1)
				offset += 2;
			else
				offset += size;
		}
		Symbol& findSymbol(int string) {
			
			for(unsigned int i = level - 1; i >= 0; i--){
				//std::find_if(symbols[i].begin(), symbols[i].end(),);
			}
		} 



};


/*
class FunctionManager{
public:
	FunctionManager(){}
	~FunctionManager(){}

	void addFunction( std::pair < std::string, std::list<TokenType> > signature, int line, bool isImplemented) {}
	
};
*/


int main ()
{
	SymbolTable st;

}