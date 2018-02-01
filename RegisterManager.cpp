#include "RegisterManager.h"

RegisterManager::RegisterManager() {
	scope.push_back(3);
}

RegisterManager::~RegisterManager() {}

int RegisterManager::getRegister(){ //get next register

	if (scope.size() >= 1023){
		//ERROR
	}

	return scope[scope.size()]++;
}


int RegisterManager::getRegistersCount(){
	return scope[scope.size()];
}


void RegisterManager::setRegistersCount(int toSet){
	scope[scope.size()] = toSet;
}


void RegisterManager::startScope()
{
	scope.push_back(3);
}


void RegisterManager::endScope()
{
	if (scope.size() == 0){
		//ERROR
	}
	else {
		scope.pop_back();
	}
}