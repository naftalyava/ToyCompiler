#ifndef _BUFFER_H_
#define _BUFFER_H_

#include <vector>
#include <list>
#include <string>
#include <fstream>
#include "Function.h"
#include <set>

using namespace std;

class Buffer {
    private:
        string header;
        vector<string> code;
        unsigned int quad;
        vector<Function> implemented;
        vector<Function> unimplemented;

	public:
        Buffer();
        ~Buffer();
        void emit(string instruction);
        void backPatch(set<unsigned int> &lines, unsigned int &address);
        unsigned int nextQuad();
        unsigned int getQuad();
        void bufferToRiski(string filename);
        //void writeHeader(vector<Function> implemented, vector<Function> unimplemented);
        void addFunction(Function func);
        Function& findFunction(string name);
	
};

#endif
