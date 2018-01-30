
#include "Buffer.h"

Buffer::Buffer(){};

Buffer::~Buffer(){};

void Buffer::emit(string &instruction)
{
    code.push_back(instruction);
}

void Buffer::backPatch(list<unsigned int> &lines, string &address);
{

}

unsigned int Buffer::nextQuad();
{
    code.push_back(command);
}

void Buffer::bufferToRiski(string filename);
{
    ofstream riskFile;
    riskFile.open(filename.c_str());
    for (auto line : this->bufferLines) 
    {
        riskFile << line << endl;
    }
    riskFile.close();
}

void Buffer::writeHeader(vector<Function> implemented, vector<Function> unimplemented)
{
    header += "<header>\n";

    header += "<unimplemented>";
    for(std::vector<Function>::iterator it = unimplemented.begin(); it != unimplemented.end(); ++it)
    {
        header += it.getName();
        for (std::vector<int>::iterator it2 = it.getCallLine().begin(); it2 != it.getCallLine().end(); ++it2)
        {
            header += "," + to_string(it2);
        }
    }
    header += "\n";

        header += "<implemented>";
    for(std::vector<Function>::iterator it = implemented.begin(); it != implemented.end(); ++it)
    {
        header += it.getName();
        for (std::vector<int>::iterator it2 = it.getCallLine().begin(); it2 != it.getCallLine().end(); ++it2)
        {
            header += "," + to_string(it2);
        }
    }
    header += "\n";

    header += "</header>\n";
}

	