;readidx/asm: Read the index record;
;setup:
;	i_date, i_group, i_article,
;	h_date, h_from, h_to, h_subj.
;Return 0 if EOF, 1 if OK, 2 if error?
;
_READIDX
	LD	B,13		;Length of header
	LD	DE,IDX_BUF
RI_1	PUSH	BC
	PUSH	DE
	LD	HL,(_NEWSIDX)
	PUSH	HL
	CALL	_FGETC
	POP	IY
	POP	DE
	POP	BC
	LD	A,H
	OR	A
	JR	NZ,RI_EOF
	LD	A,L
	LD	(DE),A
	INC	DE
	DJNZ	RI_1
;
;Have read the header, now fix it.
	LD	HL,(IDX_BUF+1)	;Article #
	LD	(_I_ARTICL),HL
;
	LD	HL,IDX_BUF+3
	LD	DE,_I_DATE
	LD	BC,6
	LDIR
;
	LD	A,(IDX_BUF)	;Group # or 0 if deleted
	LD	L,A
	LD	H,0
	LD	(_I_GROUP),HL
;
	LD	HL,(IDX_BUF+9)
	LD	(NEXTSECT),HL
;
	LD	HL,(IDX_BUF+11)
	LD	(_I_LINES),HL
;
	LD	A,(IDX_BUF)
	OR	A
	RET	Z		;No text if deleted.
;
	CALL	POS_TXT
;
	LD	HL,_H_FROM
	CALL	GET_FIELD
;
	LD	HL,_H_TO
	CALL	GET_FIELD
;
	LD	HL,_H_DATE
	CALL	GET_FIELD
;
	LD	HL,_H_SUBJ
	CALL	GET_FIELD
;
	LD	HL,1
	RET
;
RI_EOF
	LD	HL,0
	RET
;
POS_TXT
	;Decide which file we want
	LD	DE,(NEXTSECT)
	LD	HL,2047
	OR	A
	SBC	HL,DE
	LD	HL,(_NEWSTXT0)	;0-2047
	JR	NC,PT_1
	LD	HL,-2048
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(_NEWSTXT1)
PT_1
	PUSH	DE
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(FCB),DE
;
	;Position the file.
	POP	BC
	CALL	DOS_POS_RBA
	RET	NZ
	CALL	DOS_READ_SECT
	RET	Z
;
	LD	HL,3
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	(BUF),HL
;
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(NEXTSECT),DE
	INC	HL
	LD	(BYTEPOS),HL
	RET
;
FCB	DEFW	0
IDX_BUF	DEFS	13
NEXTSECT	DEFW	0
;
GET_TXT
	LD	HL,(BYTEPOS)
	PUSH	HL
	LD	DE,(BUF)
	XOR	A
	SBC	HL,DE
	OR	H
	POP	HL
	CALL	NZ,POS_TXT
	LD	HL,(BYTEPOS)
	LD	A,(HL)
	INC	HL
	LD	(BYTEPOS),HL
	RET
;
GET_FIELD
	LD	B,79
GF_1	PUSH	BC
	PUSH	HL
	CALL	GET_TXT
	POP	HL
	POP	BC
	LD	(HL),A
	INC	HL
	OR	A
	RET	Z
	DJNZ	GF_1
;
BUF	DEFW	0
BYTEPOS	DEFW	0
