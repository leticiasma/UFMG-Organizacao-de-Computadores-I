#include "CPU.hpp"

namespace Computador{

	CPU::CPU(){
		this->leituras=0;
		this->escritas=0;
		this->misses=0;
		this->hits=0;
		this->flag = true;
		//this->memCache = new Computador::MemCache();
	}

	CPU::~CPU(){
		//deleta a memória cache
		//delete this->memCache;
	}

	//Operação de leitura da Cache
	void CPU::lerCache(unsigned int posicao){
		this->leituras++;
		bool hit=false;
		//Se deu hit
		/*
		if(this->memCache->buscarMemDados(posicao)){
			this->hit++;
			hit = true;
		}else{
			this->misses++;
		}
		*/
		if(this->flag){
			this->hits++;
			hit=true;
			this->flag=false;
		}else{
			this->misses++;
		}
		
		//Escreve no arqTemp
		//posicao 0 hit ? H : M
		std::string linha = std::to_string(posicao);
		linha.append(" 0 ");
		if(hit){
			linha.append("H");
		}else{
			linha.append("M");
		}
		escreverArqTemp(linha);
	}

	//Operação de escrita na cache
	void CPU::escreverCache(unsigned int posicao, std::string dado){
		this->escritas++;
		//this->memCache->salvarMemDados(posicao,dado);

		//Escreve no arqTemp
		//posicao 1 dado W
		std::string linha = std::to_string(posicao);
		linha.append(" 1 ");
		linha.append(dado);
		linha.append(" W");
		escreverArqTemp(linha);
	}

	//Escreve o arquivo temporário
	void CPU::escreverArqTemp(std::string linha){
		std::fstream saida;
		saida.open("resultTemp.txt", std::ofstream::app);
		if(saida.is_open()){
			saida<<linha<<std::endl;
			saida.close();
		}else{
			std::cout<<"Não deu pra abrir o arqTemp"<<std::endl;
		}
		
	}

	//Escreve o arquivo final de saída
	void CPU::escreverArqFinal(){
		std::fstream saida, arqTemp;
		saida.open("result.txt", std::ofstream::out);
		double hitRate = (int)this->hits/(int)this->leituras;
		double missRate = (int)this->misses/(int)this->leituras;
		if(saida.is_open()){
			saida<<"READS: "<<std::to_string(this->leituras)<<std::endl;
			saida<<"WRITES: "<<std::to_string(this->escritas)<<std::endl;
			saida<<"HITS: "<<std::to_string(this->hits)<<std::endl;
			saida<<"MISSES: "<<std::to_string(this->misses)<<std::endl;
			saida<<"HIT RATE: "<<std::to_string(hitRate)<<std::endl;
			saida<<"MISS RATE: "<<std::to_string(missRate)<<std::endl;
			saida<<std::endl;

			arqTemp.open("resultTemp.txt", std::ofstream::in);
			if(arqTemp.is_open()){
				std::string linha;
				while (std::getline(arqTemp, linha)) {
				saida<<linha<<std::endl;
				}

				arqTemp.close();
			}else{
				std::cout<<"Não deu pra abrir o arqTemp"<<std::endl;
			}
			
			saida.close();
		}else{
			std::cout<<"Não deu pra abrir o arqFinal"<<std::endl;
		}
		
	}
}