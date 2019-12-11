# PIC
Assembly programs for the PIC microcontrollers family.

* Programs compiled in the MPLab IDE X.

## bcd_display

A sensor sends, every 2 seconds, information composed of a value between 0 and 255 (in binary), read on port B. This system then    presents this value in the form of three BCD digits, shown alternately on port A (5ms each ).

## c_bcd_display

Same as above, but programmed in C and compiled with XC8.
