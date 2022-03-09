#include <xc.inc>

extrn	GLCD_setup, GLCD_enable, GLCD_on, GLCD_off

psect	code, abs

org	    100h

setup:
    call    GLCD_setup
    call    GLCD_on

    end