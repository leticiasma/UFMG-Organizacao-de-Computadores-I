#ifndef BLOCO_H
#define BLOCO_H

#include "Palavra.hpp"

namespace Computador{

	class Bloco{
		public:
			Bloco();

			bool getBitValido();
			Palavra[] getBloco();
			void setBitValido(bool bitValido);
			void setBloco(Palavra[4] bloco);

		private:
			bool bitValido;
			Palavra[4] bloco;
	};

}

#endif

