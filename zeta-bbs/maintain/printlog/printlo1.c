/*
** Printlog: Zeta logfile printer program
** Ver 1.1  on 25-Sep-87
**/

#include <stdio.h>

#define  LOG1     "log.zms"
#define  LOG2     "xferlog.zms"

FILE  *fpin,*fpout;
char  logx=0,logp=1,flagd=0;
char  *fout,*fin;
int   lpp,lines,nlines,nsaved=0,i=0,c;
char  line1[80],line2[80];
char  *linen[132],buffer[5280];

main(argc,argv)
int  argc;
char *argv[];
{
   fout=":l";        /* Line printer       */
   lpp=58;           /* 60 lines/page - 2  */

   for (i=0;i<66;++i) linen[i] = buffer + 80*i;
   i=0;

   while (--argc) {
      if (**(++argv) == '-')
         switch(argv[0][1]) {
            case 'X' : /* print off xferlog instead */
                       logx=1;
                       break;

            case 'F' : /* output to a file */
                       fout= *(++argv); argc--; logp=0;
                       break;

            case 'P' : /* set lines per page */
                       lpp=atoi(*(++argv))-2; argc--;
                       break;
 
           case 'D' : /* delete non-event lines */
                       flagd=1;
                       break;
         }
   }

   if (logx) fin = LOG2; else fin = LOG1;
   if ((fpin=fopen(fin,"r"))==NULL) {
      fputs("printlog: Can't open input\n",stderr);
      exit(1);
   }
   if (fgets(line1,80,fpin)==NULL) {
      fputs("printlog: input is empty\n",stderr);
      exit(2);
   }
   if (fgets(line2,80,fpin)==NULL) {
      fputs("printlog: input is empty\n",stderr);
      exit(2);
   }

   lines = 0;
   while ((c=getc(fpin))!=EOF)
      if (c=='\n') ++lines;
   fputs("printlog: Phase 2 commencing.\n",stderr);

   if (lines<lpp) {
      fputs("printlog: No output - file too short\n",stderr);
      exit(0);
   }

   if ((fpout=fopen(fout,"w"))==NULL) {
      fputs("printlog: Can't open output\n",stderr);
      exit(2);
   }

   fputs(line1,stdout);
   fputs(line2,stderr);

   nlines= lpp*(lines/lpp);
   fclose(fpin);

   if ((fpin=fopen(fin,"r"))==NULL) {
      fputs("printlog: Can't re-open input\n",stderr);
      exit(1);
   }

   while(getc(fpin)!='\n'); /* bypass title 1 */
   while(getc(fpin)!='\n'); /* bypass title 2 */

   for(i=0;i<nlines;++i) {
      if (i%lpp == 0) {
         fputs(line1,fpout);
         fputs(line2,fpout);
      }
      while (putc(getc(fpin),fpout)!='\n');
   }

   /* finished output - save rest of file in memory */
   nsaved = 0;
   while (fgets(linen[nsaved++],80,fpin)!=NULL);
   fclose(fpout);
   fclose(fpin);

   /* rewrite log file with titles and unprinted data */
   if ((fpin=fopen(fin,"w"))==NULL) {
      printf("printlog: Can't re-re-open %s\n",fin);
      exit(1);
   }

   fputs("Rewriting\n",stdout);

   fputs(line1,fpin);
   fputs(line2,fpin);
   for (i=0;i<nsaved;i++) fputs(linen[i],fpin);
   fclose(fpin);

   fputs("printlog: finished\n",stderr);
   exit(0);
}

