; @(#) bb2.asm - BB code file #2, on 30 Jul 89
;
; ------------------------------
;
KILL_CMD
	CALL	GET_CHAR
	CP	CR
	RET	NZ
	LD	HL,M_KILL
	LD	(FUNCNM),HL
	LD	HL,KILLMESSAGE
	LD	(FUNCTION),HL
	CALL	DO_SCAN_1
;Fixup counts of messages here...
	CALL	INFO_SETUP
	RET
;
; ------------------------------
;
KILLMESSAGE
	LD	A,(MSG_FOUND)
	OR	A
	JR	NZ,KMSG_1
	XOR	A
	LD	(KILL_QUERY),A
	LD	HL,M_KLQRY
	CALL	YES_NO
	CP	'N'
	JR	Z,KMSG_1
	CP	'Q'
	JR	Z,KMSG_Q
	LD	A,1
	LD	(KILL_QUERY),A
KMSG_1
	CALL	GET_$2
	CP	1
	JR	Z,KMSG_Q
;make sure message is TO me or FROM me or SYSOP.
	CALL	IF_SYSOP
	JR	NZ,KMSG_2
	LD	DE,(USR_NUMBER)
	LD	HL,(HDR_SNDR)
	OR	A
	SBC	HL,DE
	JR	Z,KMSG_2
	LD	HL,(HDR_RCVR)
	OR	A
	SBC	HL,DE
	JR	Z,KMSG_2
	LD	HL,M_MSG2
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	LD	HL,M_NTFRYO
	CALL	MESS
	RET
;
KMSG_2
	CALL	TEXT_POSN
	CALL	HDR_PRNT
	LD	A,(KILL_QUERY)
	OR	A
	JR	Z,KMSG_3
	LD	HL,M_KILLIT
	CALL	YES_NO
	CP	'Y'
	JR	Z,KMSG_3
	CP	'N'
	RET	Z
KMSG_Q	LD	A,1
	LD	(SCAN_ABORT),A
	RET
KMSG_3
	LD	HL,M_KILLING
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	CALL	PUTCR
;allow chance to abort.
	CALL	GET_$2
	CP	1
	JR	Z,KMSG_Q
;
	CALL	TEXT_POSN
;Set killed bit in header
	LD	A,(HDR_FLAG)
	SET	FM_KILLED,A
	LD	(HDR_FLAG),A
;Free all blocks used by the message
	CALL	KILL_FREE
;Change message topic to 1
	LD	A,255		;In header
	LD	(HDR_TOPIC),A
;
	LD	DE,MSG_TOPIC	;In memory
	LD	HL,(A_MSG_POSN)
	ADD	HL,DE
	LD	A,255
	LD	(HL),A
;
	LD	HL,(A_MSG_POSN)	;In msgtop
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,16
	ADD	HL,DE
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	A,255
	CALL	$PUT
	JP	NZ,ERROR
;
	LD	HL,(A_MSG_POSN)	;Rewrite header
	PUSH	HL
	POP	BC
	LD	DE,HDR_FCB
	CALL	DOS_POSIT
	JP	NZ,ERROR
	LD	HL,THIS_MSG_HDR
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
;
;update number of killed messages.
	LD	HL,(N_KLD_MSG)
	INC	HL
	LD	(N_KLD_MSG),HL
;
	LD	DE,TOP_FCB
	CALL	DOS_REWIND
	JP	NZ,ERROR
	LD	HL,TOPIC
	LD	B,16
KMSG_4	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	KMSG_4
;
	LD	HL,M_MSGKLD	;Done.
	CALL	MESS
	RET
;
; ------------------------------
;
TXT_GET_PUT_NCR
	CALL	BGETC
	CP	CR
	RET	Z
	CALL	PUT
	JR	TXT_GET_PUT_NCR
;
; ------------------------------
;
CREATE_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
	CALL	IF_VISITOR
	JP	NZ,NO_PERMS
;check for a place to put the new topic.
CC_2
CC_3
CC_4	LD	C,0
	LD	B,200
CC_5	PUSH	BC
	LD	A,C
	LD	(TEMP_TOPIC),A
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	Z,EMP_TOP_FND
	POP	BC
	INC	C
	DJNZ	CC_5
;all subtopics used.
	LD	HL,M_SUBUSED
	CALL	MESS
	JP	MAIN
;
EMP_TOP_FND
	POP	BC
;
	CALL	IF_CHAR
	JR	Z,CC_7
;
CC_6	LD	HL,M_GETTPC
	CALL	GET_STRING
;
CC_7	LD	HL,FTN_NAME
	LD	DE,FTN_NAME+1
	LD	(HL),0
	LD	BC,15
	LDIR
	LD	HL,FTN_NAME
	LD	B,0
CC_8
	LD	A,B
	CP	16
	JR	Z,CC_TPCLNG	;Name too long
;
	PUSH	HL
	CALL	GET_CHAR
	POP	HL
	LD	(HL),A
	INC	HL
	INC	B
	CP	CR
	JR	NZ,CC_8
;
	LD	HL,FTN_NAME
	LD	A,(HL)
	CP	CR
	JP	Z,MAIN		;If empty return to main
	JR	CC_LGOK
;
CC_TPCLNG
	LD	HL,M_TPCLNG
	CALL	MESS
	JP	MAIN
;
CC_LGOK
;now check name against each other topic
	LD	B,200
CC_9	LD	C,0
CC_10	PUSH	BC
	LD	A,C
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	Z,CC_11
	LD	DE,FTN_NAME
	CALL	STRCMP_CI
	JR	Z,CC_12
CC_11	POP	BC
	INC	C
	DJNZ	CC_10
;is OK to put in. None equal.
	JR	CC_13
;
CC_12	LD	HL,M_ALRDYTOP
	CALL	MESS
	JP	MAIN
;
;Create the topic in memory
CC_13
	LD	A,(TEMP_TOPIC)
	CALL	TOP_ADDR
	EX	DE,HL
	LD	HL,FTN_NAME	;CR terminated
	LD	BC,16
	LDIR
	EX	DE,HL
;Following code is bullshit. It is an expiry interval in days.
	LD	(HL),0		;bits to check, priv_2
	INC	HL
	LD	(HL),0		;Expected value of priv
	INC	HL
;Calculate (2nd xor priv2) and 1st. If result is zero
;then topic is visible.
	LD	(HL),0FFH
	INC	HL
	LD	(HL),0
;
	LD	A,(TEMP_TOPIC)	;Save to file
	CALL	MUL_20
	LD	DE,16
	ADD	HL,DE
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
;
	LD	A,(TEMP_TOPIC)
	CALL	TOP_ADDR
	LD	DE,TOP_FCB
	LD	B,20
CC_14	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	CC_14
	LD	HL,M_TPCMDE
	CALL	MESS
	JP	MAIN
;
; ------------------------------
;
FIX_MFD
	LD	A,0
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	RET	NZ
;dear me. MFD is bad. Probably a new file.
;fix it, sam...
	LD	DE,MFD_DATA
	LD	BC,20
	EX	DE,HL
	LDIR
	LD	C,16
	LD	HL,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
;
	XOR	A
	CALL	TOP_ADDR
	LD	DE,TOP_FCB
	LD	B,20
FMFD_1	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	FMFD_1
	RET
;
; ------------------------------
;
STATS_MSG
	LD	HL,M_SYSGOT
	CALL	MESS
	LD	HL,(N_MSG)
	CALL	PRINT_NUMB
	LD	HL,M_MESGS
	CALL	MESS
	LD	HL,M_NKLD
	CALL	MESS
	LD	HL,(N_KLD_MSG)
	CALL	PRINT_NUMB
	LD	HL,M_MESGS
	CALL	MESS
	RET
;
; ------------------------------
;
MOVE2_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
M2_GETL
;
	LD	HL,M_MOVEWHR
	CALL	GET_STRING
;
M2_3
	CALL	IF_CHAR
	CP	'?'
	JR	Z,M2_LIST
	CP	CR
	JR	Z,M2_EXIT
	CALL	IF_NUM
	JR	NZ,M2_EXIT
	CALL	GET_CHAR
	CALL	GET_NUM
	JR	M2_MOVE
;
M2_EXIT
	CALL	GET_CHAR
	CP	CR
	JR	NZ,M2_EXIT
	JP	MAIN
;
M2_LIST
	CALL	GET_CHAR	;'?'
	CP	CR
	JR	NZ,M2_LIST
M2_0
	XOR	A
	LD	(SUB_CNT),A
	LD	(TEMP_TOPIC),A
;
M2_1	LD	A,(TEMP_TOPIC)
	CP	200		;MAX_TOPICS
	JR	Z,M2_2X
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	Z,M2_2Y
;
;print number
	LD	A,'<'
	CALL	PUT
	LD	A,(SUB_CNT)
	LD	L,A
	LD	H,0
	CALL	PRINT_NUMB
	LD	A,'>'
	CALL	PUT
	LD	A,' '
	CALL	PUT
	LD	A,' '
	CALL	PUT
;
	LD	A,(TEMP_TOPIC)
	CALL	TOPIC_PRINT
	CALL	PUTCR
;
	LD	A,(SUB_CNT)
	INC	A
	LD	(SUB_CNT),A
;
M2_2Y
	LD	A,(TEMP_TOPIC)
	INC	A
	LD	(TEMP_TOPIC),A
;
	JR	M2_1
;
M2_2X
M2_2
	CALL	PUTCR
	JP	M2_GETL
;
M2_MOVE
	PUSH	HL
	CALL	GET_CHAR
	POP	HL
;
	LD	A,H
	OR	A
	JP	NZ,MAIN
;
	LD	A,L
	LD	(SUB_CNT),A
;
;try to go along underneath until SUB_CNT exhausted.
	XOR	A
	LD	(TEMP_TOPIC),A
;
M2_7	LD	A,(TEMP_TOPIC)
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	Z,M2_UNUSED
;
	LD	A,(SUB_CNT)
	OR	A
	JR	Z,M2_FOUND
	DEC	A
	LD	(SUB_CNT),A
;
M2_UNUSED
	LD	A,(TEMP_TOPIC)
	INC	A
	LD	(TEMP_TOPIC),A
	CP	200		;MAX_TOPICS
	JR	NZ,M2_7
	LD	HL,M_NOTOPICN
	CALL	MESS
	JP	MAIN
;
M2_FOUND
	LD	HL,M_OK
	CALL	MESS
;
	LD	A,(TEMP_TOPIC)
	LD	(MY_TOPIC),A
	CALL	INFO_SETUP
	JP	MAIN
;
; ------------------------------
;
DELTOP_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
	CALL	IF_VISITOR
	JP	NZ,NO_PERMS
DC_1	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,DC_2
	LD	A,(MY_TOPIC)
	CALL	TOP_ADDR
	LD	DE,16
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,(USR_NUMBER)
	CALL	CPHLDE
	JR	Z,DC_2
	LD	HL,M_NOTCRTR
	CALL	MESS
	JP	MAIN
DC_2
	LD	HL,(N_MSG_TOP)
	LD	A,H
	OR	L
	JR	Z,DC_3
;
	LD	HL,M_TPNTMT
	CALL	MESS
	JP	MAIN
;
DC_3
DC_6
	LD	A,(MY_TOPIC)
	CALL	TOP_ADDR
	LD	B,20
DC_7	LD	(HL),0
	INC	HL
	DJNZ	DC_7
;
	LD	A,(MY_TOPIC)
	CALL	MUL_20
	LD	DE,16
	ADD	HL,DE
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	B,20
DC_8	XOR	A
	CALL	$PUT
	JP	NZ,ERROR
	DJNZ	DC_8
;written.
	XOR	A
	LD	(MY_TOPIC),A
;Bug fix....
	CALL	INFO_SETUP
	JP	MAIN
;
; ------------------------------
;
;Kill all free blocks used by the current message
KILL_FREE
	LD	HL,(TXT_RBA+1)	;First block
	LD	(_THISBLK),HL
KF_01
	CALL	_PUTFREE
	LD	HL,(_THISBLK)
	CALL	_SEEKTO
	CALL	_READBLK
	JR	NZ,KF_02	;Error
	LD	HL,0
	CALL	_GETINT
	LD	(_THISBLK),HL
	LD	A,H
	OR	L
	JR	NZ,KF_01
	RET
;
KF_02	LD	HL,M_KILLERR
	CALL	MESS
	RET
;
;End of bb2