;spool: setup routines to spool printer to disk file.
;
	COM	'<SPOOL 1.0 29-Mar-85>'
*GET	DOSCALLS
;
	ORG	5200H
START	LD	HL,(HIMEM)
	LD	DE,EN_CODE-ST_CODE
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL
	INC	HL
	LD	DE,ST_CODE
	OR	A
	SBC	HL,DE
	EX	DE,HL
	LD	HL,(R_1+1)
	ADD	HL,DE
	LD	(R_1+1),HL
	LD	HL,(R_2+1)
	ADD	HL,DE
	LD	(R_2+1),HL
	LD	HL,(R_3+1)
	ADD	HL,DE
	LD	(R_3+1),HL
	LD	HL,(R_4+1)
	ADD	HL,DE
	LD	(R_4+1),HL
	LD	HL,(R_5+1)
	ADD	HL,DE
	LD	(R_5+1),HL
	LD	HL,(R_6+1)
	ADD	HL,DE
	LD	(R_6+1),HL
	LD	HL,(R_7+1)
	ADD	HL,DE
	LD	(R_7+1),HL
;
	LD	HL,(HIMEM)
	INC	HL
	EX	DE,HL
	LD	HL,ST_CODE
	LD	BC,EN_CODE-ST_CODE
	LDIR
;
	LD	HL,(HIMEM)
	INC	HL
	EX	DE,HL
	LD	HL,_OPEN-ST_CODE
	ADD	HL,DE
	PUSH	DE
	CALL	4461H	;*name enqueue
	POP	DE
	JP	NZ,DOS_ERROR
	LD	HL,_CLOSE-ST_CODE
	ADD	HL,DE
	CALL	4461H
	JP	NZ,DOS_ERROR
	JP	DOS
;
ST_CODE
;
_OPEN	DC	4,0
	DEFM	'OPEN    '
;open a file for printer use.
;if pre-existing, set to append.
R_1	LD	DE,FCB
	CALL	DOS_EXTRACT
	JP	NZ,DOS_ERROR
R_2	LD	HL,BUFFER
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
	CALL	4448H
	JP	NZ,DOS_ERROR
;file is open for append. Change printer addr.
	LD	HL,(4026H)
R_3	LD	(STORE),HL
R_4	LD	HL,NEW_DVR
	LD	(4026H),HL
;finished.
	JP	402DH
NEW_DVR
	LD	A,C
R_5	LD	DE,FCB
	CALL	001BH
	RET	Z
	PUSH	AF
	CALL	DOS_CLOSE
	POP	AF
	JP	DOS_ERROR
;
_CLOSE	DC	4,0
	DEFM	'CLOSE   '
;
R_6	LD	DE,FCB
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
R_7	LD	HL,(STORE)
	LD	(4026H),HL
	JP	402DH
;
FCB	DEFS	32
BUFFER	DEFS	256
STORE	DEFW	0
EN_CODE	NOP
;
	END	START
