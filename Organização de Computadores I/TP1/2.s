#x12 armazena o valor n, isto é, qual é o termo da Fibonacci pretendido 

main: 
    beq x0,x0,fib	#Chama a função Fibonacci

fib:
    addi x5,x0,3
    addi x10,x0,1	#x10 armazena o valor de retorno, isto é, o valor na posição n da sequência de Fibonacci
    blt x12,x5,exit	#Verifica se n é 1 ou 2, isto é, se são os casos base, nos quais os termos são iguais a 1
    	#Sendo que X10 armazena o valor atual da sequência, x6 e x7 são, respectivamente, o valor nas posições do atual-2 e do atual-1
    addi x6,x0,1
    addi x7,x0,1
    addi x28,x0,3	#x28 armazena o valor de i, isto é, da iteração, que começa com 3
    beq x0,x0,loop	#Chama o loop

loop:
    blt x12,x28,exit	#Verifica a condição para sair do loop n < i
    	#Troca dos novos valores: retorno, atual-2 e atual-1
    add x10,x6,x7 
    mv x6,x7
    mv x7,x10
    addi x28,x28,1	#Incremento de i
    beq x0,x0,loop	#Nova iteração do loop
    
exit: