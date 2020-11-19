#ifndef MEMDADOS_H
#define MEMDADOS_H

#include "Palavra.hpp"

namespace Computador{

	class MemDados{
		public:
			MemDados();

			Bloco getMemDados();
			void setBloco(Palavra[4] bloco);

		private:
			bool bitValido;
			Palavra[4] bloco;
	};

}

#endif

