#ifndef _FUNCTION_H_
#define _FUNCTION_H_

#include <string>
#include <vector>

using namespace std;

class Function{
    private:
        string m_name;
        bool m_isImplemented;
        bool m_isMain;
        bool m_hasReturn;
        unsigned int m_line;
        unsigned int m_returnType; // 0 - void, 1 - int8, 2 - int16, 4 - int32 
        vector<unsigned int> m_args;
    public:
    Function(string name) : m_name(name), 
                            m_isImplemented(false), 
                            m_isMain(false), 
                            m_hasReturn(false), 
                            m_line(0),
                            m_returnType(0),
                            m_args()
    {}

    void setIsImplemented(bool isImplemented) {m_isImplemented = isImplemented;}
    void setIsMain(bool isMain) {m_isMain = isMain;}
    void setHasReturn(bool hasReturn) {m_hasReturn = hasReturn;}
    void setLine(unsigned int line) {m_line = line;}
    bool getIsImplemented() const {return m_isImplemented;}
    bool getIsMain() const {return m_isMain;}
    bool getHasReturn() const {return m_hasReturn;}
    unsigned int getLine() const {return m_line;}
    void addArgument(unsigned int arg) {m_args.push_back(arg);}
    bool operator==(Function &other){
        if ( (this->m_name != other.m_name) || 
             (this->m_returnType != other.m_returnType) || 
             (this->m_args.size() != other.m_args.size()) ) 
            return false;
        else 
        {
            for (int i=0; i < m_args.size(); i++){
                if (this->m_args[i] != other.m_args[i]) return false;
            }
        }
        return true;
    }
};

#endif
