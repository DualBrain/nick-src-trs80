	COM	'<small c compiler output>'
*MOD
_ISALPHA:
	DEBUG	'isalpha'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,97
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?3
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,122
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?3
	LD	HL,1
	JP	$?4
$?3:
	LD	HL,0
$?4:
	LD	A,H
	OR	L
	JP	NZ,$?5
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,65
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?6
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,90
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?6
	LD	HL,1
	JP	$?7
$?6:
	LD	HL,0
$?7:
	LD	A,H
	OR	L
	JP	NZ,$?5
	LD	HL,0
	JP	$?8
$?5:
	LD	HL,1
$?8:
	LD	A,H
	OR	L
	JP	Z,$?2
	LD	HL,1
	RET
$?2:
	LD	HL,0
	RET
$?9:
	RET
_ISUPPER:
	DEBUG	'isupper'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,65
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?12
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,90
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?12
	LD	HL,1
	JP	$?13
$?12:
	LD	HL,0
$?13:
	LD	A,H
	OR	L
	JP	Z,$?11
	LD	HL,1
	RET
$?11:
	LD	HL,0
	RET
$?14:
	RET
_ISLOWER:
	DEBUG	'islower'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,97
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?17
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,122
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?17
	LD	HL,1
	JP	$?18
$?17:
	LD	HL,0
$?18:
	LD	A,H
	OR	L
	JP	Z,$?16
	LD	HL,1
	RET
$?16:
	LD	HL,0
	RET
$?19:
	RET
_ISDIGIT:
	DEBUG	'isdigit'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,48
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?22
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,57
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?22
	LD	HL,1
	JP	$?23
$?22:
	LD	HL,0
$?23:
	LD	A,H
	OR	L
	JP	Z,$?21
	LD	HL,1
	RET
$?21:
	LD	HL,0
	RET
$?24:
	RET
_ISSPACE:
	DEBUG	'isspace'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,32
	POP	DE
	CALL	CCEQ
	LD	A,H
	OR	L
	JP	NZ,$?27
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,9
	POP	DE
	CALL	CCEQ
	LD	A,H
	OR	L
	JP	NZ,$?27
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,13
	POP	DE
	CALL	CCEQ
	LD	A,H
	OR	L
	JP	NZ,$?27
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,13
	POP	DE
	CALL	CCEQ
	LD	A,H
	OR	L
	JP	NZ,$?27
	LD	HL,0
	JP	$?28
$?27:
	LD	HL,1
$?28:
	LD	A,H
	OR	L
	JP	Z,$?26
	LD	HL,1
	RET
$?26:
	LD	HL,0
	RET
$?29:
	RET
_TOUPPER:
	DEBUG	'toupper'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,97
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?32
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,122
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?32
	LD	HL,1
	JP	$?33
$?32:
	LD	HL,0
$?33:
	LD	A,H
	OR	L
	JP	Z,$?31
	LD	HL,2
	ADD	HL,SP
	PUSH	HL
	CALL	CCGINT
	PUSH	HL
	LD	HL,32
	POP	DE
	CALL	CCSUB
	POP	DE
	CALL	CCPINT
$?31:
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	RET
_TOLOWER:
	DEBUG	'tolower'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,65
	POP	DE
	CALL	CCGE
	LD	A,H
	OR	L
	JP	Z,$?36
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,90
	POP	DE
	CALL	CCLE
	LD	A,H
	OR	L
	JP	Z,$?36
	LD	HL,1
	JP	$?37
$?36:
	LD	HL,0
$?37:
	LD	A,H
	OR	L
	JP	Z,$?35
	LD	HL,2
	ADD	HL,SP
	PUSH	HL
	CALL	CCGINT
	LD	DE,32
	ADD	HL,DE
	POP	DE
	CALL	CCPINT
$?35:
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	RET
	END