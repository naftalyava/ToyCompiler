
#include "Buffer.h"
#include <iostream>

Buffer::Buffer() : code(0) {}

Buffer::~Buffer(){}

void Buffer::emit(string instruction)
{
    code.push_back(instruction);
    quad + 4;
}

void Buffer::backPatch(set<unsigned int> &lines, unsigned int &address)
{

}

unsigned int Buffer::nextQuad()
{
    return (code.size() + 2);
}

unsigned int Buffer::getQuad()
{
    
    return (code.size() + 1);
}

void Buffer::bufferToRiski(string filename)
{
    ofstream riskFile;
    riskFile.open(filename.c_str());

    riskFile << "<header>" <<endl;
    riskFile << "<unimplemented>";
    for (auto func : this->unimplemented){
        riskFile << " " << func.getName();
        for (auto line : func.getCallLine()){
            riskFile << "," << to_string(line);
        }
    }
    riskFile << endl;
    riskFile << "<implemented>";
    for (auto func : this->implemented){
        riskFile << " " << func.getName() << "," << func.getLine();
    }
    riskFile << endl;
    riskFile << "</header>" << endl;



    for (auto line : this->code) 
    {
        riskFile << line << endl;
    }
    riskFile.close();
}


void Buffer::addFunction(Function func)
{
    if (func.getIsImplemented())
        implemented.push_back(func);
    else
        unimplemented.push_back(func);
}










/*
void Buffer::writeHeader(vector<Function> implemented, vector<Function> unimplemented)
{
    header += "<header>\n";

    header += "<unimplemented>";
    for(std::vector<Function>::iterator it = unimplemented.begin(); it != unimplemented.end(); ++it)
    {
        header += *it.getName();
        for (std::vector<int>::iterator it2 = it.getCallLine().begin(); it2 != it.getCallLine().end(); ++it2)
        {
            header += "," + to_string(it2);
        }
    }
    header += "\n";

        header += "<implemented>";
    for(std::vector<Function>::iterator it = implemented.begin(); it != implemented.end(); ++it)
    {
        header += *it.getName();
        for (std::vector<int>::iterator it2 = it.getCallLine().begin(); it2 != it.getCallLine().end(); ++it2)
        {
            header += "," + to_string(it2);
        }
    }
    header += "\n";

    header += "</header>\n";
}

*/


Function& Buffer::findFunction(string name)
{
    cout << "look in implemented" << endl;
    for (int i=0; i < implemented.size(); i++){
        if (implemented[i].getName() == name){
            cout << "function: " << name << " is found" << endl;
            return implemented[i];
        }
    }

    cout << "look in unimplemented" << endl;
    for (int i=0; i < unimplemented.size(); i++){
        if (unimplemented[i].getName() == name){
            cout << "function: " << name << " is found" << endl;
            return unimplemented[i];
        }
    }

}