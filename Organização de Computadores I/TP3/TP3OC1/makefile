CC=g++ # compilador, troque para gcc se preferir utilizar C
CFLAGS=-Wall -g #-Wextra # compiler flags, troque o que quiser, exceto bibliotecas externas
EXEC=./tp3 # nome do executavel que sera gerado, nao troque
BUILD=./build/
SRC=./src/
INCLUDE=./include/
COMP=Computador/

$(EXEC):	$(BUILD)main.o $(BUILD)$(COMP)CPU.o 
	$(CC) $(CFLAGS) -o $(EXEC) $(BUILD)main.o $(BUILD)$(COMP)*.o 

$(BUILD)main.o:	$(SRC)main.cpp $(BUILD)$(COMP)CPU.o  
	$(CC) $(CFLAGS) -I $(INCLUDE)$(COMP) -c $(SRC)main.cpp -o $(BUILD)main.o

$(BUILD)$(COMP)CPU.o: $(SRC)$(COMP)CPU.cpp $(INCLUDE)$(COMP)CPU.hpp #$(BUILD)$(COMP)MemCache.o
	$(CC) $(CFLAGS) -I $(INCLUDE)$(COMP) -c $(SRC)$(COMP)CPU.cpp -o $(BUILD)$(COMP)CPU.o

#$(BUILD)$(COMP)MemCache.o: $(SRC)$(COMP)Diamante.cpp $(INCLUDE)$(JOGODIM)Diamante.hpp 
#	$(CC) $(CFLAGS) -I $(INCLUDE)$(JOGODIM) -c $(SRC)$(JOGODIM)Diamante.cpp -o $(BUILD)$(JOGODIM)Diamante.o

clean:
	rm -f $(BUILD)*/*.o

mem:
	valgrind --leak-check=full --show-leak-kinds=all $(EXEC) ./testcases/EX1