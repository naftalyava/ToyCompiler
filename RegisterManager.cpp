#include "RegisterManager.h"

RegisterManager::RegisterManager() {
	scope.push_back(3);
}

RegisterManager::~RegisterManager() {}

int RegisterManager::getRegister(){ //get next register

	int reg = 0;
	if (scope.size() >= 1023){
		//ERROR
	}

	reg = scope[scope.size()-1];
	++scope[scope.size()-1];
	//cout << "reg: " << reg << endl;
	return reg;
}


int RegisterManager::getRegistersCount(){
	return scope[scope.size()-1];
}


void RegisterManager::setRegistersCount(int toSet){
	scope[scope.size()-1] = toSet;
}


void RegisterManager::startScope()
{
	//cout << "startScope" << endl;
	scope.push_back(3);
}


void RegisterManager::endScope()
{
	if (scope.size() == 0){
		//ERROR
	}
	else {
		//cout << "endScope" << endl;
		scope.pop_back();
	}
}