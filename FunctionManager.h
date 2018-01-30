#ifndef _FUNCTIONMANAGER_H_
#define _FUNCTIONMANAGER_H_

class FunctionManager{
    private:
        vector<Function> implemented;
        vector<Function> unimplemented;
    public:
    FunctionManager() {}
    ~FunctionManager() {}
    void addFunction(Function function) {}
    void generateHeader() {}
};

#endif