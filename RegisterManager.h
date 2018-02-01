#ifndef REGISTERS_MANAGER_H_
#define REGISTERS_MANAGER_H_

#include <vector>

using namespace std;

class RegisterManager {
private:
	unsigned int counter;
	vector<unsigned int> scope;

public:
	RegisterManager();
	virtual ~RegisterManager();
	int getRegister(); //get next available register
	int getRegistersCount();
	void setRegistersCount(int toSet);
	void startScope();
	void endScope();
};

#endif // REGISTERS_MANAGER_H_