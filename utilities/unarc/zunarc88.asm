;unarc.zas: Zeta version of Unarc
;Unarc ... by Bob Freed ... Modified for Trs-80 by
;Nick Andrew, 29-Nov-86.
;	      31-Dec-86
;	      29-Jan-86
; Zeta version: 11-May-87
;		14-Jan-88
;               29-Apr-89
;
*GET	DOSCALLS
*GET	UNARCEXT
;
SEP	EQU	'.'
TBASE	EQU	BASE
; system equates
MEMTOP	EQU	4049H		; himem for model 1
;
	COM	'<Unarc-Zeta, 06-May-89>'
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	ORG	BASE+100H
START	LD	SP,START
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	Z,_EXIT
	JP	BEGIN
;
_EXIT
	XOR	A
	JP	TERMINATE
;
_ERROR
	JP	TERMINATE
;
;SHOWC	EQU	1
;SHOWD	EQU	1
;SHOWE	EQU	1
;SHOWF	EQU	1
;
*GET	FILEA
*GET	FILEB
*GET	FILEC
*GET	FILED
*GET	FILEE
*GET	FILEF
*GET	FILEG
*GET	FILEH
*GET	FILEI
*GET	FILEJ
*GET	FILEK
;
THIS_PROG_END	EQU	$
	END	START