;mkdir: Make a directory
;
	ORG	5300H
*GET	FILSYS
;
START	LD	SP,5300H
	CALL	FS_INIT
	JP	NZ,FS_DOS_ERROR
	CALL	FS_TERMINATE
	CALL	FS_MKDIR
	JP	NZ,FS_DOS_ERROR
	CALL	FS_EXIT
	JP	NZ,FS_DOS_ERROR
	JP	FS_DOS
;
	END	START
