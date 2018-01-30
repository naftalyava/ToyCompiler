#ifndef _BUFFER_H_
#define _BUFFER_H_

#include <vector>
#include <list>
#include <string>
#include "Function.h"

using namespace std;

class Buffer {
    private:
        string header;
        vector<string> code;
        unsigned int nextLine;
        vector<Function> implemented;
        vector<Function> unimplemented;

	public:
	Buffer();
    ~Buffer();
    void emit(string &instruction);
    void backPatch(list<unsigned int> &lines, string &address);
    unsigned int nextQuad();
    void bufferToRiski(string filename);
    void writeHeader();
    void addFunction(Function func);
	
};

#endif
