;@(#) mail2.asm: mail code file #2, on 08 Apr 89
;
KILL_CMD
	CALL	GET_CHAR
	CP	CR
	JR	Z,KILL_1
	CP	' '
	JR	NZ,KILL_CMD
KILL_1
	LD	HL,M_KILL
	LD	(FUNCNM),HL
	LD	HL,KILLMESSAGE
	LD	(FUNCTION),HL
	CALL	DO_SCAN_1
	CALL	INFO_SETUP	;Fix counts of messages
	RET
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
;
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
;
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
	AND	5FH
	CP	'Q'
	JR	Z,KMSG_Q
;
	CALL	TEXT_POSN
;Set killed bit in header
	LD	A,(HDR_FLAG)
	SET	FM_DELETED,A
	LD	(HDR_FLAG),A
;Free all blocks used by the message
	CALL	KILL_FREE
;Change message topic to 1
	LD	A,1		;In header
	LD	(HDR_TOPIC),A
;
	LD	DE,MSG_TOPIC	;In memory
	LD	HL,(A_MSG_POSN)
	ADD	HL,DE
	LD	A,1
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
	LD	A,1
	CALL	$PUT
	JP	NZ,ERROR
;
	CALL	WRITE_MSGHDR
;
;update number of killed messages.
	LD	HL,(N_KLD_MSG)
	INC	HL
	LD	(N_KLD_MSG),HL
;
	LD	HL,M_MSGKLD	;Done.
	CALL	MESS
	RET
;
;Print the header of a message
HDR_PRNT
	LD	HL,M_MSG2
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
;
	CALL	BGETC		;bypass dummy byte
	CALL	BGETC		;bypass # of lines
;
	LD	HL,M_SNDR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	LD	HL,M_RCVR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	LD	A,(HDR_FLAG)
	BIT	FM_NEW,A
	JR	Z,HPR_2		;if not sent
	LD	HL,M_NEW
	CALL	MESS
HPR_2
;
	LD	A,(HDR_FLAG)
	BIT	FM_PROCESSED,A
	JR	Z,HPR_3		;if not processed
	LD	HL,M_NETSENT
	CALL	MESS
HPR_3
;
	LD	HL,M_DATE
	CALL	MESS
	CALL	TXT_GET_PUT_NCR		;now date & time.
;
	LD	HL,M_SUBJ
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	CALL	PUTCR
	CALL	PUTCR
	RET
;
TXT_GET_PUT_NCR
	CALL	BGETC
	CP	CR
	RET	Z
	CALL	PUT
	JR	TXT_GET_PUT_NCR
;
CREATE_CMD
	JP	MAIN		;Kludge
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
	CALL	IF_VISITOR
	JP	NZ,NO_PERMS
	LD	A,(MY_LEVEL)
	CP	3
	JR	NZ,CC_1
	LD	HL,M_ATBOTM
	CALL	MESS
	JP	MAIN
CC_1	CP	0
	JR	NZ,CC_2
;check for a place to put the new topic.
CC_2
CC_3
	LD	B,7
	LD	A,(MY_LEVEL)
	CP	2
	JR	NZ,CC_4
	LD	B,3
CC_4	LD	C,1
CC_5	PUSH	BC
	LD	A,(MY_TOPIC)
	CALL	TOPIC_DOWN
	LD	(TEMP_TOPIC),A
	CALL	TOP_INT
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
CC_TPCLNG
	LD	HL,M_TPCLNG
	CALL	MESS
	JP	MAIN
;
CC_LGOK
;now check name against each other topic
	LD	B,7
	LD	A,(MY_LEVEL)
	CP	2
	JR	NZ,CC_9
	LD	B,3
CC_9	LD	C,1
CC_10	PUSH	BC
	LD	A,(MY_TOPIC)
	CALL	TOPIC_DOWN
	CALL	TOP_INT
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
CC_13
	LD	A,(TEMP_TOPIC)
	CALL	TOP_INT
	CALL	TOP_ADDR
	EX	DE,HL
	LD	HL,FTN_NAME	;CR terminated
	LD	BC,16
	LDIR
	EX	DE,HL
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
	CALL	TOP_INT
	CALL	MUL_20
	LD	DE,16
	ADD	HL,DE
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	A,(TEMP_TOPIC)
	CALL	TOP_INT
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
MOVE2_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
	CALL	IF_CHAR
	JP	Z,M2_3
;
;print upper if any.
M2_0
;print upwards.
	LD	HL,M_UPWRD
	CALL	MESS
	LD	A,(MY_LEVEL)
	OR	A
	JR	NZ,M2_001
	LD	HL,M_YOATUP
	CALL	MESS
	JR	M2_TOP
M2_001	LD	HL,M_UPTO
	CALL	MESS
	LD	A,(MY_TOPIC)
	CALL	TOPIC_UP
	CALL	TOPIC_PRINT
	CALL	PUTCR
	CALL	GET_$2
	OR	A
	JR	Z,M2_TOP
	LD	HL,MOVE_RND
	CALL	CHK_CHAR
	JP	Z,M2_4
M2_TOP
	LD	HL,M_DWNWRD
	CALL	MESS
	XOR	A
	LD	(SUB_CNT),A
	LD	A,(MY_TOPIC)
	CALL	SUB_LEVEL
	LD	A,(MY_TOPIC)
	PUSH	AF
M2_1	POP	AF
	CALL	SUB_NEXT
	JR	C,M2_2X
	PUSH	AF
	PUSH	DE
	CALL	SUB_NONEX
	POP	DE
	JR	Z,M2_1
;print number
	LD	A,'<'
	CALL	PUT
	LD	A,(SUB_CNT)
	INC	A
	LD	(SUB_CNT),A
	ADD	A,'0'
	CALL	PUT
	LD	A,'>'
	CALL	PUT
	LD	A,' '
	CALL	PUT
	LD	A,' '
	CALL	PUT
	POP	AF
	PUSH	AF
	PUSH	DE
	CALL	TOPIC_PRINT
	CALL	PUTCR
;
	CALL	GET_$2
	OR	A
	JR	Z,M2_NOK
	LD	HL,MOVE_RND
	CALL	CHK_CHAR
	JR	NZ,M2_NOK
	POP	DE
	POP	DE	;was AF
	JR	M2_4
M2_NOK
	POP	DE
	JR	M2_1
;
M2_2X	LD	A,(SUB_CNT)
	OR	A
	JR	NZ,M2_2
	LD	HL,M_NOBELO
	CALL	MESS
M2_2
	CALL	GET_$2
	LD	HL,MOVE_RND
	CALL	CHK_CHAR
	JR	Z,M2_4
	LD	HL,M_WHRTO
	CALL	GET_STRING
M2_3	CALL	GET_CHAR
M2_4	CP	CR
	JP	Z,MAIN
	CALL	IF_NUM
	JR	Z,M2_6
	AND	5FH
	CP	'U'
	JR	NZ,M2_2
	LD	A,(MY_LEVEL)
	OR	A
	JP	Z,M2_0
;
	CALL	GET_CHAR	;get the CR
	LD	A,(MY_TOPIC)	;move up then.
	CALL	TOPIC_UP
	LD	(MY_TOPIC),A
	LD	HL,MY_LEVEL
	DEC	(HL)
	LD	HL,M_MVGUP
	CALL	MESS
M2_5
	CALL	INFO_SETUP
	JP	MAIN
;
M2_6	CP	'8'
	JP	NC,M2_0
	SUB	'0'
	LD	(SUB_CNT),A
	JP	Z,M2_0
;try to go along underneath until SUB_CNT exhausted.
	CALL	GET_CHAR
	LD	A,(MY_TOPIC)
	CALL	SUB_LEVEL
	LD	A,(MY_TOPIC)
	PUSH	AF
M2_7	POP	AF
	CALL	SUB_NEXT
	JP	C,M2_0
	PUSH	AF
	PUSH	DE
	CALL	SUB_NONEX
	POP	DE
	JR	Z,M2_7		;ignore if unassigned.
;
	LD	A,(SUB_CNT)	;dec count
	DEC	A
	LD	(SUB_CNT),A
	JR	NZ,M2_7
;
	LD	HL,M_OK
	CALL	MESS
	POP	AF
	LD	(MY_TOPIC),A
	LD	HL,MY_LEVEL
	INC	(HL)
	JR	M2_5
;
DELTOP_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
	CALL	IF_VISITOR
	JP	NZ,NO_PERMS
	LD	A,(MY_LEVEL)
	OR	A
	JR	NZ,DC_1
	LD	HL,M_NODLTP
	CALL	MESS
	JP	MAIN
DC_1	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,DC_2
	LD	A,(MY_TOPIC)
	CALL	TOP_INT
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
	LD	A,(MY_TOPIC)
	CALL	SUB_LEVEL
	LD	A,(MY_TOPIC)
DC_4	CALL	SUB_NEXT
	JR	C,DC_6
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	TOP_INT
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	NZ,DC_5
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	JR	DC_4
DC_5	POP	HL
	POP	DE
	POP	BC
	POP	AF
	LD	HL,M_ACTSUB
	CALL	MESS
	JP	MAIN
DC_6
	LD	A,(MY_TOPIC)
	CALL	TOP_INT
	CALL	TOP_ADDR
	LD	B,20
DC_7	LD	(HL),0
	INC	HL
	DJNZ	DC_7
	LD	A,(MY_TOPIC)
	CALL	TOP_INT
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
DC_8	CALL	$PUT
	JP	NZ,ERROR
	DJNZ	DC_8
;written.
	LD	A,(MY_TOPIC)
	CALL	TOPIC_UP
	LD	(MY_TOPIC),A
	LD	A,(MY_LEVEL)
	DEC	A
	LD	(MY_LEVEL),A
;Bug fix....
	CALL	INFO_SETUP
	JP	MAIN
;
;Check_mail: Check for and give option to read mail.
CHECK_MAIL
	LD	HL,M_YHM	;You have mail
	LD	(ML_MSG),HL
	XOR	A
	LD	(ML_FOUND),A
;
	LD	HL,M_LOOKMAIL
	CALL	MESS
;
	LD	BC,(N_MSG)
	LD	HL,0
;
CKML_1	PUSH	BC		;Number of messages remaining
	PUSH	HL		;Relative message number
;
	LD	(A_MSG_POSN),HL
	CALL	READ_MSGHDR
;
	LD	HL,THIS_MSG_HDR
	BIT	FM_DELETED,(HL)
	JR	NZ,CKML_2
;
	LD	HL,(HDR_RCVR)
	LD	DE,(USR_NUMBER)
	OR	A
	SBC	HL,DE
	JR	NZ,CKML_2
;
	LD	A,(HDR_FLAG)
	BIT	FM_NEW,A
	JR	Z,CKML_1A
;
	LD	HL,M_YHNM
	LD	(ML_MSG),HL	;Found new mail to you
;
	LD	HL,ML_FOUND
	LD	A,2
	OR	(HL)
	LD	(HL),A
	JR	CKML_2
;
CKML_1A
	LD	HL,ML_FOUND
	LD	A,1
	OR	(HL)
	LD	(HL),A
;
CKML_2	POP	HL		;Relative message number
	POP	BC		;Number of messages remaining
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CKML_1	;Loop back
;
	LD	A,(ML_FOUND)
	OR	A
	JR	NZ,CKML_3
;
	LD	HL,M_NOMAIL	;no mail sorry
	CALL	MESS
	RET
;
CKML_3
	LD	HL,(ML_MSG)
	CALL	MESS
;
	LD	HL,M_READMAIL
	CALL	YES_NO
	CP	'Y'
	RET	NZ
;
	LD	HL,CMD_READMINE
	LD	A,(ML_FOUND)
	BIT	1,A
	JR	Z,CKML_4
	LD	HL,CMD_READNEW
CKML_4
;Move into command buffer
	LD	DE,IN_BUFF
	LD	BC,4
	LDIR
	LD	HL,IN_BUFF
	LD	(CHAR_POSN),HL
;now set to ALL topics.
	XOR	A
	LD	(MY_TOPIC),A
	LD	HL,OPTIONS
	SET	FO_LOWR,(HL)
	RES	FO_CURR,(HL)
	CALL	INFO_SETUP
;now READ..
	CALL	READ_CMD
;
	XOR	A		;Reset all options
	LD	(MY_TOPIC),A
	LD	HL,OPTIONS
	RES	FO_LOWR,(HL)
	SET	FO_CURR,(HL)
	CALL	INFO_SETUP
	RET
;
;Search the headers for New, Processed mail, and reset the New flag.
FIX_NEWMAIL
	LD	A,(ML_FOUND)
	AND	2
	RET	Z		;No new mail so return
;
	LD	BC,(N_MSG)
	LD	HL,0
;
FN_01
	PUSH	BC		;Number of messages remaining
	PUSH	HL		;Relative message number
;
	LD	(A_MSG_POSN),HL
	CALL	READ_MSGHDR
;
	LD	HL,THIS_MSG_HDR
	BIT	FM_DELETED,(HL)
	JR	NZ,FN_02
;
	LD	HL,(HDR_RCVR)
	LD	DE,(USR_NUMBER)
	OR	A
	SBC	HL,DE
	JR	NZ,FN_02
;
	LD	A,(HDR_FLAG)
	BIT	FM_NEW,A
	JR	Z,FN_02
	BIT	FM_PROCESSED,A
	JR	Z,FN_02
;
	RES	FM_NEW,A
	RES	FM_PROCESSED,A
	LD	(HDR_FLAG),A
	CALL	WRITE_MSGHDR
;
FN_02
	POP	HL		;Relative message number
	POP	BC		;Number of messages remaining
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,FN_01	;Loop back
FN_03
	CP	A
	RET
;
;Save relevant data into the topic file
SAVE_NEW_COUNT
	LD	DE,TOP_FCB
	CALL	DOS_REWIND
	JP	NZ,ERROR
	LD	HL,TOPIC
	LD	B,7
SNC_01	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	SNC_01
	RET
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
;End of Mail2
