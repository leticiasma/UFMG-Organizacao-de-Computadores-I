
.data
source: .word 10, 13, 1, 6, 24, 5, 7, -1
dest: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text
main:
    mv x5,x0		#x5 armazena k
    mv x6,x0 		#x6 armazena sum
    jal x1,for		#O loop do "for" é chamado
    add x10,x6,x0	#Retornará o valor de sum
    beq x0,x0,exit	#Fim da execução

for:
    la x28,source	#x28 contém o endereço de source[0]
    slli x20,x5,2
    add x29,x20,x28	#x29 conterá o endereço do elemento source[k]
    lw x7,0(x29)	#x7 receberá o valor do elemento em source[k]
    bge x7,x0,if 	#Condição source[k]>=0 para chamar "if" se for verdadeira
    jalr x0,0(x1) 	#Volta para main
    
if:
    addi x31,x0,2	#x31 recebe o valor 2 para ser usado na conta de resto
    rem x30,x5,x31	#x30 recebe o resto da divisão de k por 2
    beq x30,x0,kPlusOne #Checa se k é par. Apenas incrementa k para a próxima iteração do "if" através da função "kPlusOne".
    addi sp,sp,-4 	#Para não entrar em conflito com o futuro retorno para a main
    sw x1,0(sp)
    jal x1,squarePlusOne
    lw x1,0(sp) 	#Recupera o retorno para a main de volta em x1
    addi sp,sp,4 	#Volta SP para posição original
    la x18,dest		#x18 guarda o endereço de dest[0]
    add x19,x5,x18	#x19 recebe o endereco do elemento dest[k]
    sw x11,0(x19) 	#dest[k] recebe squarePlusOne(source[k])
    add x6,x6,x11	#Atualiza o valor de sum
    beq x0,x0,kPlusOne	
    
    
kPlusOne:
    addi x5,x5,1	#Incremenda o valor de k
    beq x0,x0,for	#Entra novamente na função for

	#Apenas retorna para onde a função havia sido chamada (isto é para o próximo passo a ser executado)
returnTo:
    jalr x0,0(x1)
    
squarePlusOne:
    rem x30,x7,x31	#x30 recebe o resto da divisão de source[k] por 2
    mv x11,x7		#x11 recebe source[k]
    beq x30,x0,returnTo	#Se o resto da divisão for zero, é chamada a função "returnTo" e o valor retornado é source[k]
    	#Atualização do valor de retorno
    addi x11,x11,1
    mul x11,x11,x7
    beq x0,x0,returnTo	#Chamada a função "returnTo"
    
exit: