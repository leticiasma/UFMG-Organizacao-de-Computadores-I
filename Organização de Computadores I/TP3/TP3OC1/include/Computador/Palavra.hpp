#ifndef PALAVRA_H
#define PALAVRA_H

#include <string>

namespace Computador{

	class Palavra{
		public:
			Palavra();

			std::string getPalavra();
			void setPalavra(std::string palavra);
		private:
			std::string palavra;
	};

}

#endif

