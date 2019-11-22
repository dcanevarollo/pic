; Autores: Douglas A. C. Canevarollo & Gabriel A. P. Nunes
;
; Um sensor envia, a cada 2 segundos, uma informa��o composta por um valor entre
; 0 e 255 (em bin�rio), lido na porta B. Esse sistema apresenta ent�o esse valor
; na forma de tr�s d�gitos BCD, mostrados alternadamente na porta A (5ms cada).
;
; Microcontrolador PIC18F873A, clock de 4MHz.
    
	list	    p=16F873A	    ; Informa ao compilador o microcontrolador 
				    ; utilizado.
    
;
    
	#include    <p16f873a.inc>  ; Inclui algumas configura��es padr�es do 
				    ; PIC18F873A.
    
; FUSE bits:
; Cristal oscilador de 4MHz, sem watchdog, com powerup e sem prot. de c�digo.
	__CONFIG    _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF
    
;
; Defini��o do vetor de reset.
	org	    H'0000'	; Origem do c�digo principal.
	goto	    start
	
; Defini��o de aliases.

	cblock	    H'20'
    
	TEMP			; Armazenar� o valor recebido pela porta B.
	HUNDRED			; Contador da centena.
	DOZEN			; Contador da dezena.
	UNITY			; Contador da unidade.
	DELCUT1MS		; Contador do timer de 1 ms.
	DELCUT1S		; Contador do timer de 1 s.
	
	endc

;
; Configura��es dos bancos e portas de E/S.
start:
	bsf	    STATUS, RP0	; Seleciona o banco 1.
	movlw	    B'0110'
	movwf	    ADCON1	; Utiliza sinais digitais de entrada.
	movlw	    B'11111111'
	movwf	    TRISB	; Todos os 8 bits da porta B ser�o usados como 
				; entrada.
	movlw	    B'00000000'
	movwf	    TRISA	; Todos os 5 bits da porta A ser�o usados como 
				; sa�da.
	bcf	    STATUS, RP0	; Seleciona o banco 0.
;
; Aplica��o principal inicia agora.
init:
	call	    delay2s	; Aguarda 2 segundos.
	movf	    PORTB, 0	; Armazena o valor de entrada no reg. W.
	movwf	    TEMP	; Esse n�mero � armazenado na porta B.
;
; Como n�o podemos utilizar D'-1', passamos o bin�rio 1111 aos contadores como
; inicializa��o. Ao receber um incremento os 4 primeiros bits ser�o zerados 
; (1111 + 0001 = 1 0000). Portanto, quando incrementarmos, zeramos o bit 4 de 
; cada um para evitar problemas.
	movlw	    B'1111'
	movwf	    HUNDRED
	movwf	    DOZEN
	movwf	    UNITY
;
; Ciclo de defini��o da centena.
; A cada ciclo, subtrai 100 do valor original e incrementa o contador at� que
; ocorra um carry no registrador STATUS, ou seja, a centena j� foi totalmente
; contada. Por exemplo, 255 entrar� no la�o 2 vezes e o contador ser� incremen-
; 2 vezes. Logo, o reg. da centena armazenar� o valor 2.
hund:
	incf	    HUNDRED, 1	; Incrementa o contador.
	bcf	    HUNDRED, 4	; Zera o bit onde o carry ocorreu.
	movlw	    D'100'	; W = 100.
	subwf	    TEMP, 1	; Temp = Temp - W = Temp - 100.
	btfsc	    STATUS, C	; Se o bit de carry estiver falso, pula o la�o.
	goto	    hund
	movlw	    D'100'
	addwf	    TEMP, 1	; Soma 100 ao valor obtido na �ltima subtra��o
				; para retornar ao valor antes do carry (< 0).
;
; Ciclo de defini��o da dezena.
; Segue a mesma l�gica da centena.
doz:
	incf	    DOZEN, 1
	bcf	    DOZEN, 4
	movlw	    D'10'
	subwf	    TEMP, 1
	btfsc	    STATUS, C
	goto	    doz
	movlw	    D'10'
	addwf	    TEMP, 1
;
; A unidade j� estar� definida no registrador TEMP.
	movf	    TEMP, 0
	movwf	    UNITY
;
; Exibi��o alternada dos d�gitos BCD na porta A.
	movf	    HUNDRED, 0	; W = centena.
	movwf	    PORTA	; Exibe o d�gito da centena na porta A.
	call	    delay5ms	; Espera 5 ms.
;
	movf	    DOZEN, 0	; W = dezena.
	movwf	    PORTA	; Exibe o d�gito da dezena na porta A.
	call	    delay5ms
;
	movf	    UNITY, 0	; W = unidade.
	movwf	    PORTA	; Exibe o d�gito da unidade na porta A.
	call	    delay5ms
;
	goto	    init	; Volta ao in�cio (espera de 2 s para o pr�ximo 
				; valor).
;
; Timer de 1 ms.
; 4MHz	-> 4.000.000 ciclos de software p/ segundo 
;	-> 2.000.000 ciclos de m�quina p/ segundo
;	-> 2.000 ciclos de m�quina p/ milisegundo.
;		
; 1 passada	-> 8 ciclos
; x passadas	-> 2.000 ciclos
;
; 2.000 ciclos = 8 passadas -> passadas = 2.000/8 -> 250 passadas necess�rias.
delay1ms:
	movlw	    D'250'
	movwf	    DELCUT1MS
; As seguintes instru��es gastam 8 ciclos de m�quina.
del1ms:
	nop
	nop
	nop
	nop
	nop
	decfsz	    DELCUT1MS, 1   ; Pula a instru��o goto caso o contador seja 
				   ; zerado.
	goto	    del1ms
	return
;
; Timer de 5 ms.
; Chama 5 vezes o delay de 1 ms.
delay5ms:
	call	    delay1ms
	call	    delay1ms
	call	    delay1ms
	call	    delay1ms
	call	    delay1ms
	return
;
; Timer de 1 s.
; Ao executar 2 vezes o timer de 5 ms, temos 10 ms. Executando 10 ms 100 vezes,
; temos 1 segundo (1.000 ms).
delay1s:
	movlw	    D'100'
	movwf	    DELCUT1S
del1s:
	call	    delay5ms
	call	    delay5ms
	decfsz	    DELCUT1S, 1
	goto	    del1s
	return
;
; Timer de 2 s.
; Chama 2 vezes o delay de 1 s.
delay2s:
	call	    delay1s
	call	    delay1s
	return
	
	end			    ; Fim de programa.