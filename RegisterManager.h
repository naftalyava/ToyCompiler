#ifndef REGISTERS_MANAGER_H_
#define REGISTERS_MANAGER_H_


class RegisterManager {
int counter;

public:
	RegisterManager();
	virtual ~RegisterManager();
	int getRegister(); //get next available register
	int getRegistersCount();
	void setRegistersCount(int toSet);
};

#endif // REGISTERS_MANAGER_H_