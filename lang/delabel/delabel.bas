00010   : REM ' Delabel/bas: Takes labels from Edtasm source code.
00020   CLEAR 5000: CLS
00030   LINE INPUT "NAME OF EDTASM SOURCE FILE: ";A$
00040   LINE INPUT "DESTINATION FILESPEC: ";B$
00045   : REM ' Firstly work out number of labels to change.
00050   OPEN "I",1,A$
00060   IF EOF(1) OR LEFT$(C$,1) = CHR$(26) THEN GOTO 120
00070   LINE INPUT #1,C$
00075   IF LEFT$(C$,1) = CHR$(26) THEN 60
00080   IF LEN(C$) <> 19 AND LEN(C$) <> 20 THEN 60
00090   IF MID$(C$,10,5) =(CHR$(9) + "EQU" + CHR$(9)) THEN NL = NL + 1
00110   GOTO 60
00120   CLOSE : DIM LT$(NL),LV$(NL)
00122   C$ = ""
00125   PRINT "FOUND";NL;"EQUATES"
00130   OPEN "I",1,A$
00140   IF EOF(1) OR LEFT$(C$,1) = CHR$(26) THEN 220
00150   LINE INPUT #1,C$
00153   IF LEFT$(C$,1) = CHR$(26) THEN 140
00155   IF LEN(C$) <> 19 AND LEN(C$) <> 20 THEN 140
00160   IF MID$(C$,10,5) =(CHR$(9) + "EQU" + CHR$(9)) THEN ND = ND + 1: GOTO 180
00170   GOTO 140
00180   LT$(ND) = MID$(C$,7,3)
00190   FOR KL = 15 TO LEN(C$) - 2: IF MID$(C$,KL,1) = "0" THEN NEXT KL
00200   LV$(ND) = MID$(C$,KL, LEN(C$) + 1 - KL)
00202   IF ASC(LV$(ND))> 64 THEN LV$(ND) = "0" + LV$(ND)
00205   PRINT LT$(ND);"   EQU   ";LV$(ND)
00210   GOTO 140
00220   CLOSE : IF ND <> NL THEN PRINT "Error - number of labels differs": END
00225   C$ = ""
00230   OPEN "I",1,A$: OPEN "O",2,B$
00240   IF EOF(1) OR LEFT$(C$,1) = CHR$(26) THEN PRINT #2, CHR$(26): CLOSE : PRINT "DONE": END
00250   LINE INPUT #1,C$
00255   IF LEFT$(C$,1) = CHR$(26) THEN 240
00260   IF (LEN(C$) = 19 OR LEN(C$) = 20) AND MID$(C$,10,5) =(CHR$(9) + "EQU" + CHR$(9)) THEN GOTO 240
00270   K = INSTR(C$, CHR$(9)): IF K = 0 THEN 350
00280   K2 = INSTR(K + 1,C$, CHR$(9)): IF K2 = 0 THEN 350
00285   IF LEN(C$) - K2 < 3 THEN 350
00290   FOR CH = 1 TO NL
00300   PL = INSTR(K2,C$,LT$(CH))
00310   IF PL = 0 THEN 340
00320   C$ = LEFT$(C$,PL - 1) + LV$(CH) + RIGHT$(C$, LEN(C$) - PL - 2)
00330   GOTO 350
00340   NEXT CH
00350   PRINT #2,C$: GOTO 240