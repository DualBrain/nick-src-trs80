;Shell: Version 2 Zeta Shell.....
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
;
	COM	'<Shell 2.2j 23-Dec-87>'
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load information.
;
	ORG	BASE+100H
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	Z,COMMAND
;Execute from file instead.
	LD	A,1
	LD	(FILE_LEVEL),A
	LD	(FROM_FILE),A
;
	PUSH	HL
	LD	HL,ABORT_ADDR
	LD	(ABORT),HL
	POP	HL
;
	LD	DE,FCB_IN
	CALL	EXTRACT
	JP	NZ,FILE_NOT_FND
	LD	HL,SH_EXT
	CALL	DOS_EXTEND		;lazy!
	LD	HL,BUFF_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	Z,FILE_OPEN
FILE_NOT_FND
	JP	ERROR
;
FILE_BADC
	LD	HL,M_BADC
MESS_EXIT
	LD	DE,$2
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
FILE_IFEOF
	CP	1CH
	JP	NZ,ERROR
	JP	FILE_FINI
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	TERMINATE
;
FILE_OPEN
	LD	HL,M_FILE_OPEN
	LD	DE,$2
	CALL	MESS_0
;
COMMAND:
	LD	SP,START	;just to make sure.
;
;Output command prompt
	LD	A,(FILE_LEVEL)
	OR	A
	JR	NZ,NO_PROMPT
	LD	HL,(CMD_NUMB)
	INC	HL
	LD	(CMD_NUMB),HL
;
	CALL	PRINT_PROMPT
;
NO_PROMPT
;
	LD	A,(FILE_LEVEL)
	OR	A
	JR	NZ,RD_FILE
;
;Ask for command line input
	LD	HL,INPUT_LINE
	LD	B,62
	CALL	40H
	JR	C,COMMAND	;if break hit
	CALL	TERMINATE_S
	LD	HL,INPUT_LINE
	JR	CMD_1
;
RD_FILE
	LD	HL,INPUT_LINE
RF_1	LD	DE,FCB_IN
	CALL	$GET
	JP	NZ,FILE_IFEOF
	CP	1AH
	JP	Z,FILE_FINI
	CP	0AH
	JR	Z,RF_1
	OR	A
	JP	Z,FILE_FINI
	CP	80H
	JP	NC,FILE_BADC
	CP	CR
	JR	Z,RF_2
	CP	' '
	JP	C,FILE_BADC
RF_2	LD	(HL),A
	INC	HL
	CP	CR
	JR	Z,RF_3
	LD	A,(LENGTH)
	INC	A
	LD	(LENGTH),A
	CP	80
	JR	C,RF_1
	JP	FILE_BADC
RF_3
	LD	A,0
	LD	(LENGTH),A
	LD	DE,($STDOUT)
	LD	HL,INPUT_LINE
RF_4	LD	A,(HL)
;;	CALL	$PUT		;No verbose.
	LD	A,(HL)
	CP	CR
	JR	Z,RF_5
	INC	HL
	JR	RF_4
RF_5
	LD	(HL),0		;Terminate string no CR
	LD	HL,INPUT_LINE
CMD_1	CALL	BYP_SP
	LD	A,(HL)
	OR	A
	JP	Z,COMMAND	;Loop if no command.
	LD	(START_LINE),HL
;
	LD	A,(SYS_STAT)
	BIT	6,A
	JR	NZ,STC_1
	LD	DE,WORD
	CALL	ADD_CR
	LD	HL,WORD
	CALL	LOG_MSG
;
STC_1
	LD	HL,(START_LINE)
	LD	A,(HL)
	OR	A
	JP	Z,COMMAND
	LD	DE,CMD_EXIT
	CALL	STR_CMP_WORD
	JP	Z,EXIT_CMD
	LD	HL,(START_LINE)
	LD	DE,CMD_IFZERO
	CALL	STR_CMP_WORD
	JP	Z,IFZERO_CMD
	LD	DE,CMD_SOURCE
	LD	HL,(START_LINE)
	CALL	STR_CMP_WORD
	JP	Z,SOURCE_CMD
	LD	HL,(START_LINE)
	LD	DE,CMD_IFNZERO
	CALL	STR_CMP_WORD
	JP	Z,IFNZERO_CMD
	LD	DE,CMD_PROMPT
	LD	HL,(START_LINE)
	CALL	STR_CMP_WORD
	JP	Z,PROMPT_CMD
;
	CALL	REROUTE
	CALL	SET_DEV
;
	LD	HL,FINAL_LINE	;Execute command
	CALL	CALL_PROG
	PUSH	AF
	CALL	RESET_DEV
	POP	AF
	JP	Z,TEST_RETURN
	CP	3
	JP	Z,BAD_CMD
	CP	2
	JR	Z,OUT_RAM
	LD	HL,M_SYSERR	;System error.
	LD	DE,$2
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
OUT_RAM
	LD	HL,M_OUTRAM
	LD	DE,$2
	CALL	MESS_0
	LD	A,(FILE_LEVEL)	;if not from file
	OR	A		;then ask for cmd again
	JP	Z,COMMAND
	LD	A,129		;?
	JP	TERM_ABORT	;else abort this shell.
;
TEST_RETURN			;test return code.
	OR	A
	JP	Z,COMMAND
	CP	80H
	JP	NC,COMMAND
;
;This is a cop-out until I write an 'sprintf' type
;routine (ie: into a string rather than into a device
	JP	COMMAND
;
;	PUSH	AF
;	LD	DE,$DO
;	LD	A,'{'
;	CALL	$PUT
;	POP	AF
;	LD	L,A
;	LD	H,0
;	CALL	PRINT_NUMB_DEV
;	LD	A,' '
;	CALL	$PUT
;	LD	HL,(START_LINE)
;	CALL	MESS_NCR
;	LD	A,'}'
;	CALL	$PUT
;	LD	A,CR
;	CALL	$PUT
;	JP	COMMAND
;
;Set standard devices for next program.
REROUTE
	XOR	A
	LD	(LESS_THAN),A
	LD	(GRTR_THAN),A
	LD	(EXTEND_FLAG),A
	LD	HL,(START_LINE)
	LD	(IN_PTR),HL
	LD	DE,FINAL_LINE
	LD	(OUT_PTR),DE
	CALL	GET_WORD		;Command name.
	CALL	COPY_WORD
;
ONE_WORD
	CALL	GET_WORD
	JR	NZ,END_OF_CMD
	LD	HL,WORD
;;	LD	A,(HL)
;;	CP	'@'
;;	JR	NZ,NOT_REDIR
;;	INC	HL
	LD	A,(HL)
	CP	'<'
	JR	Z,FROM
	CP	'>'
	JR	Z,TO
NOT_REDIR
	CALL	COPY_WORD
	JR	ONE_WORD
END_OF_CMD
	LD	HL,(OUT_PTR)
	LD	(HL),0
	RET
;
FROM
	LD	A,(LESS_THAN)
	OR	A
	JR	NZ,NOT_REDIR
;
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,TEMP_IN
	OR	A
	JR	NZ,NOT_TEMP_IN
TEMP_IN
	LD	HL,TEMPFILE
NOT_TEMP_IN
	LD	DE,INPUT_FILE
	CALL	FILENAME_COPY
	JR	NZ,BAD_REDIR
;
	LD	DE,INPUT_FILE
	LD	HL,0		;Dummy buffer
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,BAD_REDIR
	LD	A,1
	LD	(LESS_THAN),A
	JR	ONE_WORD
;
TO
	LD	A,(GRTR_THAN)
	OR	A
	JR	NZ,NOT_REDIR
;
	INC	HL
	LD	A,(HL)
	CP	'>'
	JR	NZ,NOT_EXTEND
	LD	A,1
	LD	(EXTEND_FLAG),A
	INC	HL
NOT_EXTEND
	LD	A,(HL)
	CP	' '
	JR	Z,TEMP_OUT
	OR	A
	JR	Z,TEMP_OUT
	LD	A,(PRIV_1)
	BIT	7,A
	JR	NZ,NOT_TEMP_OUT
TEMP_OUT
	LD	HL,TEMPFILE
NOT_TEMP_OUT
	LD	DE,OUTPUT_FILE
	CALL	FILENAME_COPY
	JR	NZ,BAD_REDIR
;
	LD	DE,OUTPUT_FILE
	LD	HL,0		;Dummy buffer
	LD	B,0
	CALL	DOS_OPEN_NEW
	JR	NZ,BAD_REDIR
;
	LD	A,(EXTEND_FLAG)
	OR	A
	CALL	NZ,DOS_POS_EOF
	JR	NZ,BAD_REDIR
	LD	A,1
	LD	(GRTR_THAN),A
	JP	ONE_WORD
;
BAD_REDIR
	LD	HL,M_BADREDIR
	CALL	PUTS
	LD	A,(FILE_LEVEL)
	OR	A
	JP	Z,COMMAND
	LD	A,130		;redirect error.
	JP	TERM_ABORT
;
GET_WORD
	LD	HL,(IN_PTR)
	LD	A,(HL)
	OR	A
	JR	Z,GW_4
	LD	DE,WORD
GW_1	LD	A,(HL)
	CP	' '
	JR	Z,GW_2
	OR	A
	JR	Z,GW_3
	LD	(DE),A
	INC	HL
	INC	DE
	JR	GW_1
GW_2	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	CP	' '
	JR	Z,GW_2
GW_3	LD	(IN_PTR),HL
	XOR	A
	LD	(DE),A
	CP	A
	RET
GW_4	CP	1
	RET
;
COPY_WORD
	LD	HL,WORD
	LD	DE,(OUT_PTR)
CW_1	LD	A,(HL)
	OR	A
	JR	Z,CW_2
	LD	(DE),A
	INC	HL
	INC	DE
	JR	CW_1
CW_2	LD	(OUT_PTR),DE
	RET
;
STR_CMP_WORD
	LD	A,(HL)
	CP	' '
	JR	Z,SCW_1
	OR	A
	JR	Z,SCW_1
	CALL	CI_CMP
	RET	NZ
	INC	HL
	INC	DE
	JR	STR_CMP_WORD
SCW_1	LD	A,(DE)
	CP	' '
	RET	Z
	OR	A
	RET		;Z or NZ.
;
BYP_SP	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SP
;
BYP_WORD
	LD	A,(HL)
	CP	' '
	JR	Z,BYP_SP	;Space at end of word.
	CP	CR
	RET	Z
	OR	A
	RET	Z
	INC	HL
	JR	BYP_WORD
;
FILENAME_COPY
	CALL	EXTRACT
	RET
;
FILE_FINI
	LD	A,(FILE_LEVEL)
	DEC	A
	LD	(FILE_LEVEL),A
	JR	Z,ALL_FILE_FINI
;**** Undefined code as yet ****
	JP	COMMAND
;
ALL_FILE_FINI
	LD	A,(FROM_FILE)
	OR	A
	JP	Z,COMMAND
	XOR	A
	JP	TERMINATE
;
PRINT_PROMPT
	LD	HL,M_PROMPT
	LD	A,(PRIV_2)
	BIT	IS_VISITOR,A
	JR	Z,PP_1
	LD	HL,M_PROMPT_VIS
PP_1
	LD	DE,$2
	CALL	MESS_0
;;	LD	HL,(CMD_NUMB)
;;	LD	DE,($STDOUT_DEF)
;;	CALL	PRINT_NUMB_DEV
	LD	HL,M_PROMPT2
	CALL	MESS_0
	RET
;
EXIT_CMD
	XOR	A		;Exit this shell
	JP	TERMINATE
;
SOURCE_CMD
	LD	A,(PRIV_1)
	BIT	7,A
	JP	Z,COMMAND	;Only the sysop as yet.
	JP	COMMAND
;
PROMPT_CMD
	JP	COMMAND
;
BAD_CMD
	LD	HL,(START_LINE)
	LD	DE,$2
BC_1	LD	A,(HL)
	CP	' '
	JR	Z,BC_2
	CP	CR
	JR	Z,BC_2
	OR	A
	JR	Z,BC_2
	CALL	$PUT
	INC	HL
	JR	BC_1
BC_2
	LD	HL,M_BAD_CMD
	CALL	MESS_0
	LD	A,(FILE_LEVEL)
	OR	A
	JP	Z,COMMAND
	LD	A,129
	JP	TERMINATE
;
ABORT_ADDR
	CALL	RESET_DEV
	JP	TERM_ABORT
;
SET_DEV
	LD	A,(LESS_THAN)
	OR	A
	JR	Z,SD_1
;
	CALL	SAVE_STDIN
	LD	DE,INPUT_FILE
	CALL	SET_STDIN
SD_1	LD	A,(GRTR_THAN)
	OR	A
	RET	Z
	CALL	SAVE_STDOUT
	LD	DE,OUTPUT_FILE
	CALL	SET_STDOUT
	RET
;
RESET_DEV
	LD	A,(LESS_THAN)
	OR	A
	JR	Z,RDEV_1
	CALL	REST_STDIN
	XOR	A
	LD	(LESS_THAN),A
RDEV_1	LD	A,(GRTR_THAN)
	OR	A
	RET	Z
	CALL	REST_STDOUT
	XOR	A
	LD	(GRTR_THAN),A
	RET
;
IFZERO_CMD
	LD	A,(LASTCC)	;Test if Zero
	OR	A
	JP	NZ,COMMAND	;If non zero.
;Else endeavour to execute the command.
	LD	HL,(START_LINE)
	CALL	BYP_WORD
	LD	(START_LINE),HL
	JP	STC_1		;Something to run!
;
IFNZERO_CMD
	LD	A,(LASTCC)	;Test if non zero
	OR	A
	JP	Z,COMMAND	;If zero.
;Else endeavour to execute the command.
	LD	HL,(START_LINE)
	CALL	BYP_WORD
	LD	(START_LINE),HL
	JP	STC_1		;Something to run!
;
ADD_CR	LD	A,(HL)
	OR	A
	JR	Z,ADDCR_1
	LD	(DE),A
	INC	HL
	INC	DE
	JR	ADD_CR
ADDCR_1	EX	DE,HL
	LD	(HL),CR
	INC	HL
	LD	(HL),0
	RET
;
*GET	ROUTINES
*GET	STDDEV.HDR
;
FILE_LEVEL	DEFB	0
FROM_FILE	DEFB	0
FCB_IN	DEFS	32
BUFF_IN	DEFS	256
SH_EXT	DEFM	'shl',ETX
LENGTH	DEFB	0
CMD_EXIT	DEFM	'exit',0
CMD_IFZERO	DEFM	'ifzero',0
CMD_SOURCE	DEFM	'source',0
CMD_IFNZERO	DEFM	'ifnzero',0
CMD_PROMPT	DEFM	'prompt',0
CMD_NUMB	DEFW	0
;
M_BAD_CMD
	DEFM	': Command not found.',CR
	DEFM	'Try "cmds" or "help".',CR,0
M_SYSERR
	DEFM	'Shell: System error. Sorry.',CR,0
;
M_OUTRAM
	DEFM	'Out of memory. Better "exit" this shell.',CR,0
;
M_PROMPT
	DEFM	CR
	DEFM	'Shell ',0
M_PROMPT_VIS
	DEFM	CR
	DEFM	'shell ',0
M_PROMPT2
	DEFM	'> ',0
;
M_FILE_OPEN
	DEFM	'<< Command file execution >>',CR,0
;
M_BADC	DEFM	CR,'Shell file contains invalid chars or line too long.',CR,0
M_NOT_FND
	DEFM	CR,'Shell file not found.',CR,0
M_BADREDIR
	DEFM	CR,'Bad I-O redirection attempted.',CR,0
;
START_LINE
	DEFW	0
INPUT_LINE
	DEFS	256
FINAL_LINE
	DEFS	256
WORD	DEFS	80
PROMPT	DEFM	'{!] Zeta: ',0
	DEFM	'Input_file>'
INPUT_FILE
	DEFS	32
;
OUTPUT_FILE
	DEFS	32
LESS_THAN
	DEFB	0
GRTR_THAN
	DEFB	0
EXTEND_FLAG
	DEFB	0
IN_PTR	DEFW	0
OUT_PTR	DEFW	0
TEMPFILE
	DEFM	'TEMPFILE',0
;
	DEFM	'<endshell>'
THIS_PROG_END	EQU	$
;
	END	START