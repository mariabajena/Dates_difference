.data 
Fraseyres: .asciiz "\nHan transcurrido: A?os Ordinarios: "
Fraseyleap: .asciiz " A?os Bisiestos: "
Frasedays: .asciiz " Días: "
FrasediffSec: .asciiz " Segundos: "
FrasediffMin: .asciiz " Minutos: "
FrasediffHour: .asciiz " Horas: "

Fecha1: .space 21
Fecha2: .space 21
NúmeroFinal: .space 4
Frase: .asciiz "\nIntroduce una fecha válida con formato o dd/mm/aaaa hh:mm:ss "
Frase2: .asciiz "\nIntroduce una fecha válida con formato o dd/mm/aaaa hh:mm:ss posterior a la introducida anteriormente "
Frase3: .asciiz "\nLa segunda fecha introducida es anterior a la primera, por favor, introduzca la segunda posterior"
Frase4: .asciiz "\nFormato de fecha incorrecto, por favor, introduzca las fechas con el formato dd/mm/aaaa hh:mm:ss"
Frase5: .asciiz "\nFecha inválida/ no existente. Porfavor, introduzca de nuevo"
Frase6: .asciiz "\nUna de las horas introducidas es incorrecta. Porfavor, introduzca de nuevo"
FraseFin: .asciiz "\nQuiere volver a introducir fechas? Para sí, pulsar 1, para finalizar, pulsar 0 "
Resultado: .space 32
.text

main:
	la $a0, Frase
	li $v0, 4
	syscall
	la $a0, Fecha1			#se introduce la primera fecha por pantalla
	li $a1, 20
	li $v0, 8
	syscall
	
	jal convertirfecha		#se convierte el string a int, deovlviendo los dias
	bne $v1, 47, formatoincorrecto	#se comprueba que el caracter de separación introducido sea una barra (/) tal como exige el formato
	bne $t8, 2, formatoincorrecto	#se comprueba que el número introducido es de dos dígitos
	move $s5, $v0    # dia1
	jal convertirfecha		#se convierte el string a int, deovlviendo los meses
	bne $t8, 2, formatoincorrecto	#se comprueba que el caracter de separación introducido sea una barra (/) tal como exige el formato
	bne $v1, 47, formatoincorrecto	#se comprueba que el número introducido es de dos dígitos
	move $s3, $v0    #mes1
	jal convertirfecha		#se convierte el string a int, deovlviendo el a?o
	bne $v1, 32, formatoincorrecto	#se comprueba que el caracter de separación introducido sea una barra (/) tal como exige el formato
	bne $t8, 4, formatoincorrecto	#se comprueba que el número introducido es de cuatro dígitos
	move $s1, $v0    #a?o1
	li $t8, 0			#contador de dígitos $t8 utilizado en convertirfecha a 0
	
	move $a0, $s1			#$a0<---y1
	move $a1, $s3			#$a1<---m1
	move $a2, $s5			#$a3<---d1
	jal comprobarbisiesto		#se comprueba que la fecha introducida es correcta, sino, salta un aviso y se vuelven a pedir los números
	move $a3, $v0			#si bisiesto===> $v0==1
	jal comprobarfecha
	beq $t0, 0, fechanoexistente	#si comprobarfecha == 0 ====> formato incorrecto
	li $t0, 0
	
	la $a0, Frase2			#"\nIntroduce una fecha válida con formato o dd/mm/aaaa hh:mm:ss posterior a la introducida anteriormente "
	li $v0, 4
	syscall
	la $a0, Fecha2			#se introduce la segunda fecha por pantalla
	li $a1, 20
	li $v0, 8
	syscall
	
	jal convertirfecha		#se realizan las mismas operaciones que para la fecha uno
	bne $v1, 47, formatoincorrecto 
	bne $t8, 2, formatoincorrecto
	move $s6, $v0    # dia2
	jal convertirfecha
	bne $v1, 47, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s4, $v0    #mes2
	jal convertirfecha
	bne $v1, 32, formatoincorrecto
	bne $t8, 4, formatoincorrecto
	move $s2, $v0    #a?o2
	
	move $a0, $s2
	move $a1, $s4
	move $a2, $s6
	jal comprobarbisiesto		#se comprueba que la fecha introducida es correcta, sino, salta un aviso y se vuelven a pedir los números
	move $a3, $v0
	jal comprobarfecha
	move $t0, $v0
	beq $t0, 0, fechanoexistente
	
	li $t0, 0
	
	blt $s2, $s1, volverapedir	#si el a?o segundo es menor que el primero, se vuelven a pedir los números
	beq $s2, $s1, comprobarmes	#si el a?o es el mismo, se comprueban los meses
	
	j calculos

volverapedir:
	la $a0, Frase3			#"\nLa segunda fecha introducida es anterior a la primera, por favor, introduzca la segunda posterior"
	li $v0, 4			#se vuelve al main, pidiendo ambas fechas de nuevo, debido a que la fecha segunda es menor que la primera
	syscall
	j main
comprobarmes:
	blt $s4, $s3, volverapedir	#si siendo el mismo a?o el mes segundo es menor que el primero, se vuelven a pedir ambos números
	beq $s4, $s3, comprobardia	#si son el mismo mes y el mismo a?o, se comprueba el dia
	j calculos
comprobardia:
	blt $s6, $s5, volverapedir	#si el dia segundo es menor que el primero, siendo el mes y el a?o los mismos, se vuelven a pedir
	j calculos
formatoincorrecto:
	la $a0, Frase4
	li $v0, 4			#el formato introducido es incorrecto, por lo que se vuelven a pedir los números
	syscall
	j main
fechanoexistente:
	la $a0, Frase5			#la fecha introducida es errónea, no existe
	li $v0, 4
	syscall
	j main
horarionoexistente:
	la $a0, Frase6			#una de las horas introducidas es errónea, no existe
	li $v0, 4
	syscall
	j main
	
#----DETERMINE days, months, lapYearsBetween---------

#-----REGISTERS-------------------------------------------------#	
#		y1 -- $s1
#		y2 -- $s2
#		m1 -- $s3
#		m2 -- $s4
#		d1 -- $s5
#		d2 -- $s6
#  leapYarsBetween -- $s7
#---------------------------------------------------------------#

calculos:
	jal leapYearsBetween		#se llama a la funcion leapYearsBetween, que calcula los a?os bisiestos entre ambas fechas introducidas
	move $s7, $v0			#se mueve a $s7 los a?os bisiestos transcurridos
	
	jal calculateMonths		#se claculan los meses transcurridos entre ambas fechas
	move $s3, $v0
	move $s4, $v1
	
	ble $s3, 9, checkm2		#si m1 no es enero o febrero
	
	addi $s1, $s1, -1	#y1--
	addi $s0, $s0, 1	#yres++
	
checkm2:	
	ble $s4, 9, next	#si m1 no es enero o febrero
	
	addi $s2, $s2, -1	#y2--

next:	
	jal calculateDays	#calcula dias dependiendo de la formula #((m*306)+5)/10)+day-1)
	move $s5, $v0		#$s5<---day1
	move $s6, $v1		#$s6<---day2
	
	
#----CALCULATE result------------------------------
	jal calculateResultYear	#yres=y2-y1-leapYearsBetween
	move $s0, $v0		#$s0<---yres
	
	move $a0, $s2
	jal comprobarbisiesto	#y2 bisiesto?
	move $a0, $v0
	
	jal calculateResultDay	#d2-d1
	move $s1, $v0
	move $s0, $v1

	add $t0, $s0, $s7
	bnez $t0, imprimir
	
	li $s0, 0
	li $s7, 0

#-----REGISTERS-------------------------------------------------#	
#		A?os Ordinarios -- $s0
#		A?os Bisiestos -- $s7
#		Días -- $s1 (posteriormente se guardan en $s0)
#---------------------------------------------------------------#
	
imprimir:
	la $a0, Fraseyres   	 	#imprime frase por pantalla
	li $v0, 4
	syscall

	move $a0, $s0
	la $a1, Resultado
	addi $a1, $a1, 32		#se imprime el resultado de los a?os transcurridos
	jal convertiracadena		#se transforma antes el resultado a cadena mediante la funcion convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	
	la $a0, Fraseyleap  	 	#imprime frase por pantalla
	li $v0, 4
	syscall

	move $a0, $s7
	la $a1, Resultado
	addi $a1, $a1, 32		#se imprime el resultado de los a?os bisiestos transcurridos
	jal convertiracadena		#se transforma antes el resultado a cadena mediante la funcion convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	
calcularmismodia:
	beq $s0, $s7, mismodiaono	#se mira si las fechas introducidas corresponden al mismo dia
	j guardardias
mismodiaono:
	beq $s7, $s1, mismodia	
	j guardardias
mismodia:
	add $s7, $zero, -1		#si corresponden al mismo dia, se setea $s7 a -1, para posteriormente comprobar que si es el mismo dia la hora segunda no es menor que la primera
	
guardardias:
	move $s0, $s1			#se guardan los días en $s0 los dias resultantes, para posteriormente al calcular el tiempo realizar los cambios oportunos en dias, (si es que se tienen que realizar)
	j time				#se salta a la etiqueta time para calcular el tiempo (horas, minutos y segundos)
imprimirdias:
	la $a0, Frasedays   		#imprime frase por pantalla
	li $v0, 4
	syscall
	
	move $a0, $s0
	la $a1, Resultado		
	addi $a1, $a1, 32		#se imprime el resultado de dias por pantalla
	jal convertiracadena		#se transforma antes el resultado a cadena mediante la funcion convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	j imprimirTime			#se procede a imprimir el tiempo
	
################----------TIME------------##################

#-----REGISTERS-------------------------------------------------#	
#		hora1 -- $s1
#		hora2 -- $s2
#		min1 -- $s3
#		min2 -- $s4
#		seg1 -- $s5
#		seg2 -- $s6
#---------------------------------------------------------------#

time:
	la $a0, Fecha1
	addi $a0, $a0, 11		#se avanzan 11 posiciones en la cadena de la fecha, a partir de ahi comienzan las horas
	jal convertirfecha		#se llama a la funcion convertirfecha para convertir el string a int
	bne $v1, 58, formatoincorrecto	# si el caracter separatorio no es (:) , se llama a formatoincorrecto
	bne $t8, 2, formatoincorrecto	# si el numero introducido no es de 2 digitos, se llama a formatoincorrecto
	move $s2, $v0    # h1		#se guarda la hora 1 en $s2
	jal convertirfecha
	bne $v1, 58, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s4, $v0    #min1		#se realizan las mismas operaciones para los minutos
	jal convertirfecha
	bne $v1, 0, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s6, $v0    #sec1		#se realizan las mismas operaciones para los segundos

	move $a0, $s2
	move $a1, $s4
	move $a2, $s6
	jal comprobarhorario		#se comprueba que las horas, minutos y segundos están dentro de los límites establecidos
	move $t0, $v0
	beq $t0, 0, horarionoexistente	# si no es así, se salta a la etiqueta horarionoexistente y se vuelven a pedir los números por pantalla
	
	li $t0, 0
	
	la $a0, Fecha2 			# se realian las mismas operaciones que para la fecha 1
	addi $a0, $a0, 11
	jal convertirfecha
	bne $t1, 58, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s1, $v0    # h2
	jal convertirfecha
	bne $t1, 58, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s3, $v0    #min2
	jal convertirfecha
	bne $t1, 0, formatoincorrecto
	bne $t8, 2, formatoincorrecto
	move $s5, $v0    #sec2
	
	move $a0, $s1
	move $a1, $s3
	move $a2, $s5
	jal comprobarhorario		#se comprueba que las horas, minutos y segundos están dentro de los límites establecidos
	move $t0, $v0
	beq $t0, 0, horarionoexistente	#si no es así, se salta a la etiqueta horarionoexistente y se vuelven a pedir los números por pantalla
	
	li $t0, 0
	
	beq $s7, -1, mismodiahoras  	#si $s7 es -1, significa que las fechas introducidas corresponden al mismo dia, por lo tanto se pasa a comprobar que la segunda hora no es menor que la primera
	j calcresulttime 		# si no, se pasa directamente a los calculos de la parte horaria
	
mismodiahoras:
	blt $s1, $s2, volverapedir	#si la hora segunda es menor, se vuelven a pedir los números
	beq $s1, $s2, mismodiaminutos   #si las horas son iguales se pasa a comprobar los minutos
	j calcresulttime
mismodiaminutos:
	blt $s3, $s4, volverapedir 	#si siendo las horas las mismas, los minutos segundos son menores, se vuelven a pedir 
	beq $s3, $s4, mismodiasegundos  #si los minutos son iguales, se comprueban los segundos
	j calcresulttime
mismodiasegundos:
	blt $s5, $s6, volverapedir 	#si los segundos de la segunda fecha son menores, se vuelve a pedir por pantalla los numeros
	
calcresulttime:
	jal calculateResultSec		# se calcula la diferencia de segundos
	move $s6, $v0	#$s6<----diffSec
	
	jal calculateResultMin		#se calcula la diferencia de minutos
	move $t0, $s4
	move $s4, $v0	#$s4<----diffMin
	
	jal calculateResultHour		#se calcula la diferencia de horas
	move $t9, $s2
	move $s2, $v0	#$s2<----diffHour

	###Ajustes####
	
#-----REGISTERS-------------------------------------------------#	
#		Días -- $s0
#		Horas -- $s2
#		Minutos -- $s4
#		Segundos -- $s6
#		Hora segunda fecha menor? -- $t2
#		Minutos segunda fecha menores? -- $t8
#		Segundos segunda fecha menores? -- $t6
#---------------------------------------------------------------#
	
	beq $t2, 1, reducirdias		#si la se?al $t2 está a 1 se reducen los días (que $t2 esté a uno significa que las horas de la segunda fecha son inferiores a las de la primera)	
horas:
	beq $t8, 1, reducirhoras	#si la se?al $t8 está a 1 se reducen las horas (significa que los minutos de la segunda fecha son menores que los de la primera)
minutos:
	beq $t6, 1, reducirminutos	#si la se?al $t6 está a 1 se reducen los minutos (significa que los segundos de la segunda fecha son menores que los de la primera)
	j imprimirdias
	
reducirdias:
	addi $s0, $s0, -1		#se reducen los días en 1
	addi $t7, $zero, 24		#se pone $t7 a 24
	sub $s2, $t7, $s2		#se resta a 24 la diferencia horaria, quedando las nuevas horas resultante
	j horas
reducirhoras:
	sub $s2, $s2, 1			#se restan las horas en 1
	blt $s2, 0, reducirdias		#si las horas son negativas, se pasa a reducir dias 
	addi $t7, $zero, 60		#se pone $t7 a 60
	sub $s4, $t7, $s4 		#se resta a 60 la diferencia de minutos, quedando los nuevos minutos resultantes
	sub $s4, $s4, $t6		#se le resta $t6 (si está a 1, significa que hay que restarle para a?adirle a minutos)
	li $t0,99			#se pone $t0 a 99 como se?al
	j minutos
	
reducirminutos:
	beq $t0, 99, reducirminutos2	#si $t0 está a 99 (es decir, ha pasao por la etiqueta reducirhoras) se salta a reducirminutos2
	j quitarnormal
quitarnormal:
	sub $s4, $s4, 1			#se restan 1 a los minutos
reducirminutos2:
	blt $s4, 0, reducirhoras	#si los minutos están negativos, ir a reducirhoras
	addi $t7, $zero, 60		#se pone $t7 a 60
	sub $s6, $t7, $s6		#se restan a 60 la diferencia de segundos, para obtener los nuevos segundos resultantes
	j imprimirdias

imprimirTime:
	la $a0, FrasediffHour  		#imprime frase por pantalla
	li $v0, 4
	syscall

	move $a0, $s2			#imprime las horas
	la $a1, Resultado
	addi $a1, $a1, 32
	jal convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	
	la $a0, FrasediffMin   		#imprime frase por pantalla
	li $v0, 4
	syscall

	move $a0, $s4
	la $a1, Resultado		#imprime los minutos
	addi $a1, $a1, 32
	jal convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	
	la $a0, FrasediffSec  		#imprime frase por pantalla
	li $v0, 4
	syscall

	move $a0, $s6
	la $a1, Resultado		#se imprimen los segundos
	addi $a1, $a1, 32
	jal convertiracadena
	move $a0, $a1
	li $v0, 4
	syscall
	la $a0, FraseFin
	li $v0, 4 
	syscall
	la $a0, NúmeroFinal		#se pide al usuario si quiere continuar introduciendo números o si quiere acabar el programa
	li $a1, 4
	li $v0, 8
	syscall
	jal convertirfecha
	move $t0, $v0
	beq $t0, 1, main 		#si se mete un 1 se vuelve al main
	
exit:

	li $v0, 10 			#finaliza el programa si se introduce un 0
	syscall



########Funciones#######
###############################################################################
leapYearsBefore: #year--
            	 #return (year / 4) - (year / 100) + (year / 400)
            	 #Calcula todos los a?os bisiestos que han existido antes del a?o introducido
	addi $t0, $t0, -1
	li $t1, 4
	div $t0, $t1
	mflo $t2
	
	li $t1, 100
	div $t0, $t1
	mflo $t3
	
	li $t1, 400
	div $t0, $t1
	mflo $t4
	
	sub $t2, $t2, $t3
	add $t2, $t2, $t4
	
salirleapYearsBefore:
	move $v0, $t2
	jr $ra			#Se devuelve el control al programa principal
###############################################################################################
calculateResultSec: 		#calcula la diferencia de segundos entre las fechas
	move $t5, $s5		#$t5<---$d1
	move $t6, $s6		#$t6<---$d2
	
	blt $s5, $s6, CalculateResultSec2	#d1>d2?
	
	sub $t5, $t5, $t6	#$t5<---$t5-$t6
	addi $t6, $zero, 0	#si los segundos de la primera fecha son menores, se setea a 0 $t6
	j salircalculateResultSec
	
CalculateResultSec2:
	sub $t5, $t6, $t5
	addi $t6, $zero, 1	#si los segundos de la segunda fecha son menores, se setea a 1 $t6
salircalculateResultSec:
	move $v0, $t5		#$v0<---resSec
	jr $ra			#Se devuelve el control al programa principal
###############################################################################################
calculateResultMin: #se calcula la diferencia de minutos
	move $t3, $s3		 #$t3<----
	move $t4, $s4		
	
	blt $s3, $s4, calculateResultMin2
	
	sub $t3, $t3, $t4
	addi $t8, $zero, 0	#si los minutos de la primera fecha son menores, se setea a 0 $t8
	j salircalculateResultMin
	
calculateResultMin2:
	sub $t3, $t4, $t3
	addi $t8, $zero, 1	#si los minutos de la segunda fecha son menores, se setea a 1 $t8
	j salircalculateResultMin
salircalculateResultMin:
	move $v0, $t3
	jr $ra			#Se devuelve el control al programa principal
###############################################################################################
calculateResultHour: 		#se calcula la diferencia de segundos 
	move $t1, $s1		
	move $t2, $s2		
	
	blt $s1, $s2, calculateResultHour2	
	
	sub $t1, $t1, $t2
	addi $t2, $zero, 0	#si las horas de la primera fecha son menores, se setea a 0 $t2
	j salircalculateResultHour
calculateResultHour2:
	sub $t1, $t2, $t1	
	addi $t2, $zero, 1	#si las horas de la segunda fecha son menores, se setea a 1 $t2
	j salircalculateResultHour
salircalculateResultHour:
	move $v0, $t1		#$v0<---$hres
	jr $ra			#Se devuelve el control al programa principal
###############################################################################################
calculateResultDay: #d2-d1
	move $t1, $s5	#t1<---d1
	move $t2, $s6	#t2<---d2
	move $t3, $s0	#t3<---yres
	
	sub $t2, $t2, $t1	#t2<---d2-d1
	
	bgez $t2, salircalculateResultDay	#if(d2-d1>=0)
	
	addi $t2, $t2, 365
	addi $t3, $t3, -1
#########################################################	
	move $t5, $a0	#$t5<-----ist5leap
	
	sub $t6, $s2, $s1	#$t2<--y2-y1 
	li $t4, 4
	div $t6, $t4
	mfhi $t4
	
	bne $t4, 1, salircalculateResultDay	#(y2-y1)%4=1? 
	beq $t5, 0, salircalculateResultDay	#y2bisiesto?
	addi $t2, $t2, 1	#dres++

######################################################
salircalculateResultDay:
	move $v0, $t2	#$v0<---dres
	move $v1, $t3	#v1<---yres
	
	jr $ra			#Se devuelve el control al programa principal
####################################################################################
calculateResultYear: #yres=y2-y1-leapYearsBetween
	move $t1, $s1	#$t1<---y1
	move $t2, $s2	#$t2<---y2
	move $t3, $s7	#$t3<---leapyearsBetween
	
	sub $t2, $t2, $t1	#y2-y1
	sub $t2, $t2, $t3 	#yres=y2-y1-leapYearsBetween

salircalculateResultYear:
	move $v0, $t2	#$v0<---yres
	jr $ra			#Se devuelve el control al programa principal
####################################################################################
calculateDays: #((m*306)+5)/10)+day-1)
	li $t0, 306
	li $t1, 5
	li $t2, 10
	
	move $t3, $s3		#$t3<---m1
	mul $t4, $t3, $t0	#$t4<---m1*306
	add $t4, $t4, $t1	#(m1*306)+5)
	div $t4, $t2		#((m1*306)+5)/10)
	mflo $t7		
	add $t7, $t7, $s5	#((m1*306)+5)/10)+day1
	addi $t7, $t7, -1	#(m1*306)+5)/10)+day1-1)
	
	move $t3, $s4		#$t3<---m2
	mul $t0, $t3, $t0	#$t4<---m2*306
	add $t0, $t0, $t1	#(m2*306)+5)
	div $t0, $t2		#((m2*306)+5)/10)
	mflo $t6
	add $t6, $t6, $s6	#((m2*306)+5)/10)+day2
	addi $t6, $t6, -1	#(m1*306)+5)/10)+day2-1)

salircalculateDays:
	move $v0, $t7		#$t7<---day1
	move $v1, $t6		#$t6<---day2

	jr $ra			#Se devuelve el control al programa principal
####################################################################################
calculateMonths: #m=(m+9)%12
	move $t0, $s3	#$t0<---m1
	li $t1, 12
	addi $t0, $t0, 9	#m1=(m1+9)
	div $t0, $t1		#m1=(m1+9)%12
	mfhi $t0
	
	move $t3, $s4		#$t3<---m2
	addi $t3, $t3, 9	#m2=(m1+9)
	div $t3, $t1		#m2=(m1+9)%12
	mfhi $t3
	
salircalculateMonths:
	move $v0, $t0		#$v0<---m1
	move $v1, $t3		#v1<---m2
	
	jr $ra			#Se devuelve el control al programa principal
######################################################################################
leapYearsBetween: 		#LeapYearsBefore(endy) - LeapYearsBefore(starty + 1);
		  		#se calcula ls a?os bisiestos que existen entre los dos a?os introducidos
	addi $sp, $sp, -4	#Se mueve una posición hacia atrás la dirección de retorno (sp) para cargarla en ra
	sw $ra, 0($sp)		#Se carga en ra la dirección de retorno (sp)
	
	move $t0, $s1
	jal leapYearsBefore	# se calculan los a?os bisiestos anteriores a la primera fecha introducida
	move $t7, $v0
	
	move $t0, $s2
	jal leapYearsBefore	# se calculan los a?os bisiestos anteriores a la segunda fecha introducida
	move $t6, $v0
	
	sub $t3, $t6, $t7	#se restan ambos cálculos

salirleapYearsBetween:
	move $v0, $t3
	lw $ra, 0($sp)		#Se lee la dirección de retorno 
	addi $sp, $sp, 4	#Se libera la pila
	jr $ra			#Se devuelve el control al programa principal
#######################################
convertirfecha:			#Función que va conviertiendo la cadena introducida en int's, 
				#correspondientes a los dias, meses, a?os, horas, minutos y segundos, uno a uno.
	li $t8, 1		#carga 1 a t8
	lb $t0, ($a0)		#carga string del lugar de $a0
	addi $t0, $t0, -48	#como siempre son cifras, resta 48 (differencia en ASCII)
convertirfecha2:
	addiu $a0, $a0, 1	#va a proximo caracter del string
	lb $t1, ($a0)		#carga ese caracter en $t0
	ble $t1, 47, salir	#cifras corectas solo son los mientras 48-57 + if "/" o ":" sale de convertir
	bge $t1, 58, salir	#cifras corectas solo son los mientras 48-57
	addi $t1, $t1, -48	#como siempre son cifras, resta 48 (differencia en ASCII)
	mul $t0, $t0, 10	#para convertir en decimal multiplica cifra 1 por 10
	add $t0, $t0, $t1	#anade cifra2 (jednoœci)
	add $t8, $t8, 1		#anade 1 a $t8
	j convertirfecha2	#proxima cifra
salir:
	addiu $a0, $a0, 1	#pone puntero de $a0 a proxima cifra
	move $v0, $t0		#mueve $t0 (lo que ha calculado) en $v0
	move $v1, $t1		#mueve $t1 en $v1 ( para ver si el ultimo caracter era barra )
	jr $ra
############################################
convertiracadena:		#función que convierte un número (en int) a cadena. Hace la función inversa a convertirfecha
	addi $sp, $sp, -4	
	sw $ra, 0($sp)		
	addi $t0, $zero, 10
	move $t1, $a0
	j dividir
convertir2:
	mflo $t1
 dividir:
        div $t1, $t0
        mfhi $t2		#hi to remainder
        addi $t2, $t2, 48
        sb $t2, ($a1)
        addiu $a1, $a1, -1
        mflo $t1		#lo to quotient
        beq $t1,0,salir2
        j convertir2
	jr $ra			#Se devuelve el control al programa principal
salir2:
	addi $t1,$t1, 48
	sb $t1, ($a1)
	move $v0, $a1
	jr $ra			#Se devuelve el control al programa principal
######################################################################
comprobarbisiesto:	#se comprueba si el a?o introducido es bisiesto o no, si es divisible entre 4. 
			#Si es divisible entre 100, además hay que comprobar si es divisible entre 400.
	li $t0, 4
	div $a0, $t0
	mfhi $t0
	bne $t0, 0, nobisiesto
	li $t0, 100
	div $a0, $t0
	mfhi $t0
	beq $t0, 0, comprobar400
	li $t0, 1
	j salircomprobarbisiesto
comprobar400:
	li $t0, 400
	div $a0, $t0
	mfhi $t0
	bne $t0, 0, nobisiesto
	li $t0, 1
	j salircomprobarbisiesto
nobisiesto:
	li $t0, 0
salircomprobarbisiesto:
	move $v0, $t0
	jr $ra
#############################################################
comprobarfecha:				#se comprueba que la fecha introducida está dentro de los valores permitidos
	li $t0, 1
	blt $a2, 1, fechaincorrecta	#si el día es 0 o negativo
	bgt $a2, 31, fechaincorrecta	#si tiene más de 31 días
	blt $a1, 1, fechaincorrecta	# si el mes es 0 o negativo
	bgt $a1, 12, fechaincorrecta	# si el mes es más de 12
	
	beq $a1, 4, mes30		# comprobaciones según el mes que se haya introducido
	beq $a1, 6, mes30
	beq $a1, 9, mes30
	beq $a1, 11, mes30
	
	beq $a3, 1, febrerobisiesto	#comprobación de febrero de a?o  bisiesto (29 días)
	beq $a3, 0, febreronobisiesto	#comprobación de febrero de a?o  bisiesto (28 días)
	j salircomprobarfecha
febrerobisiesto:
	bne $a1, 2, fechacorrecta	#si no es febrero, por las operaciones anteriores sabemos, que tiene 31 dias, asi que es correcto
	bgt $a2, 29, fechaincorrecta	#pero si es febrero 31 dias no esta bien
	j salircomprobarfecha
mes30:
	bgt $a2, 30, fechaincorrecta
	j salircomprobarfecha
febreronobisiesto:
	bne $a1, 2, fechacorrecta	#si no es febrero, por las operaciones anteriores sabemos, que tiene 31 dias, asi que es correcto
	bgt $a2, 28, fechaincorrecta	#pero si es febrero 31 dias no esta bien
	j salircomprobarfecha
fechaincorrecta:
	li $t0, 0			# fecha incorrecta ----------------- $t0 a 0
	j salircomprobarfecha
fechacorrecta:
	li $t0, 1			# fecha correcta ----------------- $t0 a 1
salircomprobarfecha:
	move $v0, $t0			#$v0<---$t0
	jr $ra
###################################################
comprobarhorario:			#comprueba que el horario introducido está dentro de los límites permitidos
	blt $a0, 0, horarioincorrecto	#comprobar horas
	bgt $a0, 23, horarioincorrecto	#comprobar horas
	blt $a1, 0, horarioincorrecto	#comprobar minutos
	bgt $a1, 59, horarioincorrecto	#comprobar minutos
	blt $a2, 0, horarioincorrecto	#comprobar segundos
	bgt $a2, 59, horarioincorrecto	#comprobar segundos
	li $t0, 1			#poner $t0 a 1 si el horario es correcto
	j salircomprobarhorario
horarioincorrecto:
	li $t0, 0			#poner $t0 a 0 si el horario es incorrecto
salircomprobarhorario:
	move $v0, $t0
	jr $ra