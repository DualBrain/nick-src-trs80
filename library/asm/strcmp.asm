	COM	'<small c compiler output>'
*MOD
_STRCPY:
	DEBUG	'strcpy'
$?2:
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
	LD	A,H
	OR	L
	JP	Z,$?3
	JP	$?2
$?3:
	RET
_STRCMP:
	DEBUG	'strcmp'
$?5:
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	CALL	CCEQ
	LD	A,H
	OR	L
	JP	Z,$?6
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	LD	A,H
	OR	L
	JP	NZ,$?7
	LD	HL,0
	RET
$?7:
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	LD	HL,2
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
$?8:
	JP	$?5
$?6:
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	CALL	CCSUB
	RET
_STRCAT:
	DEBUG	'strcat'
$?10:
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	LD	A,H
	OR	L
	JP	Z,$?11
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	JP	$?10
$?11:
$?12:
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
	LD	A,H
	OR	L
	JP	Z,$?13
	JP	$?12
$?13:
	RET
	END
