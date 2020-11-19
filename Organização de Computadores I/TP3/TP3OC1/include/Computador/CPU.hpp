#ifndef CPU_H
#define CPU_H
#include <string>
#include <fstream> 
#include <iostream>
//#include "MemCache.hpp"
namespace Computador{
	class CPU{
	public:
		void lerCache(unsigned int posicao);
		void escreverCache(unsigned int posicao, std::string dado);
		void escreverArqFinal();
		~CPU();
		CPU();
	private:
		void escreverArqTemp(std::string linha);
		//Computador::MemCache* memCache;
		unsigned int leituras;
		unsigned int escritas;
		unsigned int misses;
		unsigned int hits;	
		bool flag;
	};
}

#endif