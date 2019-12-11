/*
 * File:   program.c
 * Authors: Douglas A. C.Canevarollo & Gabriel A. P. Nunes
 *
 * Created on 10 de Dezembro de 2019, 22:47
 */

/* Configura��es iniciais. */
#pragma config FOSC = HS
#pragma config WDTE = OFF
#pragma config PWRTE = OFF
#pragma config BOREN = OFF
#pragma config LVP = ON
#pragma config CPD = OFF
#pragma config WRT = OFF
#pragma config CP = OFF


#define true 1
#define false 0

#define _XTAL_FREQ 4000000  // Clock de 4MHz.


#include <xc.h>
#include <stdlib.h>
#include <stdio.h>


/**
 * Exibe um valor na porta A e aguarda 5 ms.
 * 
 * @param value : valor que ser� exibido na porta A.
 */
void showPortA(unsigned char value) {
    PORTA = value;
    __delay_ms(5);  // Fun��o nativa do XC8.
    
    return;
}

/**
 * Exibe o resultado na porta A durante 2 segundos, ou seja, se cada chamada de
 * fun��o dura 5 ms e, em um la�o, essa fun��o � chamada 3 vezes, temos 15 ms
 * por la�o. Logo, ao repetirmos 133 vezes, temos que 15ms * 133 = 1.995 s, que
 * � aproximadamente 2 s.
 * 
 * @param hundred   : valor da centena a ser exibido.
 * @param ten       : valor da dezena a ser exibido.
 * @param unit      : valor da unidade a ser exibido.
 */
void showOutput(unsigned char hundred, unsigned char ten, unsigned char unit) {
    int i;
    
    for (i = 0; i < 133; i++) {
        showPortA(hundred);
        showPortA(ten);
        showPortA(unit);
    }
    
    return;
}

/**
 * Fun��o principal.
 */
void main(void) {
    unsigned char input, hundred, ten, unit;
    
    /* Configura��es do banco 1. */
    ADCON1 = 0x6;
    TRISA = 0x00;  // Porta A como sa�da.
    TRISB = 0xFF;  // Porta B como entrada.
    
    while (true) {
        /* Armazena o valor de entrada. */
        input = PORTB;
        
        /* Utilizaremos resto de divis�es para separarmos os d�gitos em BCD. */
        hundred = input / 100;
        
        input = input % 100;
                
        ten = input / 10;
        
        unit = input % 10;
        
        /* Por fim, exibimos o resultado. */
        showOutput(hundred, ten, unit);
    }
    
    return;
}
