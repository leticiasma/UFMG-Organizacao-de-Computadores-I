#include "Bloco.hpp"

namespace Computador{

	Bloco::Bloco(){

		this->bitValido = false;

		for(int i=0; i<4; i++){
			Palavra palavra;

			this->bloco[i] = palavra;
		}

	}

	bool Bloco::getBitValido(){
		return this->bitValido;
	}

	Palavra[4] Bloco::getBloco(){
		return this->bloco;
	}

	void Bloco::setBitValido(bool bitValido){
		this->bitValido = bitValido;
	}

	void Bloco::setBloco(Palavra[4] bloco){
		this->bloco = bloco;
	}

}