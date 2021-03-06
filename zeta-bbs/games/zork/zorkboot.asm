;zorkboot: Zork 1 boot sector.
;last changed 15-Feb-86
H41FE	EQU	$-2
;
;Entry point for zork1:......
H4200	LD	SP,H4200
;
;if Zeta... check if person is allowed to play.
	IF	ZETA
	CALL	MAY_I_PLAY
	ENDIF
;
	LD	A,2
	LD	(H42EF),A
	XOR	A	;But I made it DI.
	LD	(H42EE),A
	JP	H42F6	;was call h42d7
;
	CALL	H42BD
	LD	HL,4300H	;no label!!
	LD	(H42F0),HL
	LD	B,16H
H421A	DEC	B
	JP	M,H42F6
	PUSH	BC
	CALL	H4256
	POP	BC
	LD	HL,H42F1
	INC	(HL)
	CALL	H422D
	JP	H421A
;
H422D	LD	A,(H42EE)
	CP	2
	JP	NC,H424C
	LD	HL,H42EF
	INC	(HL)
	LD	A,(HL)
	CP	0AH
	RET	C
	LD	(HL),0
	LD	A,(H42EE)
	CP	1
	JP	NC,H4251
H4247	LD	HL,H42EE
	INC	(HL)
	RET
H424C	LD	HL,H42EF
	DEC	(HL)
	RET	P
H4251	LD	(HL),9
	JP	H4247
;
H4256	LD	A,0FFH
	LD	(H42F2),A
H425B	CALL	H4293
	JP	NZ,H42CD
	RET
H4262	LD	A,(37ECH)
	OR	A
	CALL	M,H42D7
	LD	A,(H42ED)
	LD	(37E0H),A
	LD	A,(H42EF)
	LD	(37EEH),A
	LD	A,(H42EE)
	LD	DE,37EFH
	LD	(DE),A
	LD	A,1BH
	LD	HL,37ECH
	LD	(HL),A
	PUSH	BC
	POP	BC
	PUSH	BC
	POP	BC
H4286	LD	A,(HL)
	RRCA
	JP	C,H4286
	PUSH	HL
	LD	HL,(H42F0)
	LD	B,H
	LD	C,L
	POP	HL
	RET
;
H4293	CALL	H4262
	LD	(HL),88H
H4298	LD	A,(HL)
	AND	2
	JP	Z,H42A7
	LD	A,(HL)
	JP	H4298
H42A2	LD	A,(HL)
	RRCA
	JP	NC,H42B3
H42A7	LD	A,(HL)
	AND	2
	JP	Z,H42A2
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	JP	H42A7
H42B3	LD	A,(HL)
	AND	1CH
	RET	NZ
	LD	A,(HL)
	AND	60H
	CP	40H
	RET
H42BD	LD	A,0BH
	LD	HL,37ECH
	LD	(HL),A
	PUSH	BC
	POP	BC
	PUSH	BC
	POP	BC
H42C7	LD	A,(HL)
	RRCA
	JP	C,H42C7
	RET
H42CD	LD	HL,H42F2
	INC	(HL)
	CALL	NZ,H42BD
	JP	H425B
H42D7	LD	A,(H42ED)
	LD	(37E0H),A
	LD	HL,0
H42E0	DEC	HL
	LD	A,H
	OR	L
	JP	NZ,H42E0
	LD	A,(H42ED)
	LD	(37E0H),A
	RET
;
H42ED	DEFB	1
H42EE	DEFB	0
H42EF	DEFB	0
H42F0	DEFB	0
H42F1	DEFB	0
H42F2	DEFB	0
H42F3	DEFB	0
H42F4	DEFB	0
H42F5	DEFB	0F7H
H42F6	LD	HL,H5977
	LD	(H42F0),HL
	LD	A,1
	LD	(H42EF),A
;
