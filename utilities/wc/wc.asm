;wc.asm: Assemble WC, compiled C
;
*GET	DOSCALLS
;
	ORG	5200H
START
	LD	HL,(HIMEM)
	LD	SP,HL
;
*GET	CINIT
*GET	CALL
*GET	DEBUG
;
*GET	WC1
;
*GET	ATOI
*GET	STRCMP
*GET	CTYPE
*GET	LIBC
;
HIGHEST	DEFW	$+2
;
	END	START
