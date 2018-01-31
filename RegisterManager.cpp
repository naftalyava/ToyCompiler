#include "RegisterManager.h"

RegisterManager::RegisterManager() {
	counter = 3;
}

RegisterManager::~RegisterManager() {}

int RegisterManager::getRegister(){ //get next register

if(counter == 1023 ){
	//operational error!
}

return counter++;
}


int RegisterManager::getRegistersCount(){
	return counter;
}


void RegisterManager::setRegistersCount(int toSet){
	counter = toSet;
}
