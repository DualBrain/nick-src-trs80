;credit: Assemble a CREDIT, compiled C, for Zeta
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info
;
	COM	'<credit 1.0  14-Aug-87>'
	ORG	BASE+100H
START
START1	DEC	HL
	LD	A,(HL)
	CP	' '
	JR	NC,START1
	INC	HL		;Pseudo start of cmd line
	LD	SP,START	;There is plenty of stack
	LD	(CMDLINE),HL	;Save cmd line pointer
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	LD	A,0
	JP	Z,TERMINATE
;
*GET	CINIT
*GET	CALL
;
DEBUG	MACRO	#$S
	ENDM
;
*GET	CREDIT1
*GET	CREDIT2
;
*GET	ROUTINES
*GET	LIBC
*GET	ATOI
*GET	CTYPE
;
HIGHEST	DEFW	$+2
;
THIS_PROG_END	EQU	$
	END	START
