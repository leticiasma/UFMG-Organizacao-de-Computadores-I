#x12 armazenará "a" e x13 armazenará "b", ambos registradores de argumento de funções

main:
    beq x0,x0,exponencial	#Chama a função exponencial
    
exponencial:
    mv x10,x12          #x10 é o registrador de valor de retorno
    addi x5,x0,1	#x5 guarda o valor de i no loop, isto é a iteração
    beq x0,x0,loop	#Entra no loop
    
loop:
    bge x5,x13,exit	#Condição para sair do loop se i >= b
    mul x10,x10,x12	#Sucessivas multiplicações do loop em cada iteração i
    addi x5,x5,1	#Incremendo de i
    beq x0,x0,loop	#Nova iteração	

exit: