/*
 * PPK Ass #1 - Nick Andrew
 * Student # 8425464
 * 03-Sep-85
 * 11-Nov-85: Modified for Alcor 'C'
 */

#define SORTIN "temp1/f"             
#define SORTOUT "temp2/f"
#define MAXFLDS (100)           /* Maximum No. of fields */

#include <stdio.h>              /* Get standard routines */

FILE *config, *src, *dest, *temp1, *temp2;
char *heading,*today,*usecr;

int sortdat[MAXFLDS],printdat[MAXFLDS],mwidth[MAXFLDS];
int numflds,numsort,numprint,lines,sortlen,page;
int sumwidth,columns,spacing,linpage;

struct       {
               char *tname,*dataptr,*display;
               int  flength;
               char needed,prneed,srneed,delim,numer;
             } fieldat[MAXFLDS];


main(argc,argv)
int argc; char *argv[];
{

   intro();                              
   getconf(argv[1],(argc>1));            
   copy();                               
   dosort();                             
   dorprt();                             
   printf("PPK1: Normal Termination\n");
}

intro()
{
   printf("PPK Assignment 1 - Nick Andrew\n");
}

/* Get input file configuration and output format data
 * off either standard input (keyboard) or from a file.
 */
getconf(confil,flag)
char *confil;
int  flag;
{
   extern FILE *openup();
   int num,i;
   char string[64],c,*calloc(),*getstring();

   /* Use either an opened file or standard input */
   config=(flag ? openup(confil,"r") : stdin);
   prompt(flag,"Please enter source filename: ");
   if (!fscanf(config,"%s",string))
      error("PPK1: Config file empty!\n");
   src=openup(string,"r");
   prompt(flag,"Please enter output filename: ");
   fscanf(config,"%s",string);
   dest=openup(string,"w");
   /* check for correct config file */
   if (flag && (fscanf(config," %c",&c),c!='*'))
      printf("PPK1: Error in config file!\n");
   prompt(flag,"Enter a heading for this report: ");
   heading=getstring(config);       /* get heading string */
   printf("Heading is %s\n",heading);
   prompt(flag,"Use how many columns? (80/132): ");
   fscanf(config,"%d",&columns);
   prompt(flag,"How many lines per page (66): ");
   fscanf(config,"%d",&linpage);
   prompt(flag,"CRs in source file? Y/N: ");
   fscanf(config," %c",&c);
   c=toupper(c);
   if ((c!='Y')&&(c!='N')) error("PPK1: Invalid CR info!\n");
   usecr=(c=='Y');   /* Set flag depending on value of c */
   prompt(flag,"<S>ingle or <D>ouble or <T>riple spaced? ");
   fscanf(config," %c",&c);
   c=toupper(c);
   spacing=(1*(c=='S')+2*(c=='D')+3*(c=='T'));  /* S=1, D=2, T=3 */
                        /* Expect format info from this point */
   numflds=0;
   while (!feof(config))
      {
      /* loop for each field name to build dict */
      prompt(flag,"Enter source file field name, '*' to finish: ");
      fscanf(config,"%s",string);
      if (string[0]=='*') break; /* break out of the loop */

      fieldat[++numflds].tname=calloc(strlen(string)+1,sizeof(char));
      strcpy(fieldat[numflds].tname,string);
      fieldat[numflds].needed=0;
                     /* read the integer field length */
      prompt(flag,"Enter maximum field length: ");
      fscanf(config,"%d",&fieldat[numflds].flength);
      prompt(flag,"Enter <A> Ascii or <N> Numeric field: ");
      fscanf(config," %c",&c);
      c=toupper(c);
      fieldat[numflds].numer=(c=='N');
      prompt(flag,"Enter delimiter char or CR if none: ");
      if (!flag) do c=getc(config); while (c!='\n');
                            /* bypass white space */
      do c=getc(config); while (c==' ');
      if (c=='\n') c=0;     /* no delimiter */
      if (c==0x5c)          /* read an octal number */
         { int oct;
           fscanf(config,"%3o",&oct);
           c=(char) oct;
         }
      fieldat[numflds].delim=c;
      }

   numsort=numprint=0;
   while (!feof(config))
      {
      /* Get list of SORT fields required */
      prompt(flag,"Enter SORT field name or '*' to end: ");
      fscanf(config,"%s",string);
      if (string[0]=='*') break;
      i=1;
      while (strcmp(string,fieldat[i].tname) && (i<=numflds)) i++;
      if (i>numflds)
         {
         printf("PPK1: Sort field unknown: %s\n",string);
         continue;
         }
      sortdat[++numsort]=i;
      fieldat[i].needed=1;
      }
                             /* Read in desired output fields */
   while (!feof(config))
      {
      /* Get list of PRINT fields required */
      prompt(flag,"Enter print field name or '*' to end: ");
      fscanf(config,"%s",string);
      if (string[0]=='*') break;
      i=1;
      while (strcmp(string,fieldat[i].tname) && (i<=numflds)) i++;
      if (i>numflds)
         {
         printf("PPK1: Print field unknown: %s\n",string);
         continue;              /* without using it */
         }
      printdat[++numprint]=i;
      fieldat[i].needed=fieldat[i].prneed=1;
      prompt(flag,"Enter a display heading for this field: ");
      fieldat[i].display=getstring(config);
      }
   /* print out each sort field and each print field */
   printf("Sort fields defined:\n");
   for (i=1;i<=numsort;i++)
      printf("%s, ",fieldat[sortdat[i]].tname);
   printf("\nPrint fields defined:\n");
   for (i=1;i<=numprint;i++)
      printf("%s, ",fieldat[printdat[i]].tname);
   printf("\n");
   }

dosort()         /* Use UNIX sort program to accomplish sort */
{
/* copy temp file 1 to temp file 2 */
}

/* Copy variable length input file fields to fixed format
 * sort input file.
 */
copy()
{
   int field,i,j,records=0;
   char c,del,*ptr;
                               /* Open temp file */
   temp1=openup(SORTIN,"w");
                               /* Read source until EOF */
   while (c=getc(src),!feof(src))
      {
      ungetc(c,src);
      for (field=1;field<=numflds;field++)
         {
         ptr=calloc(fieldat[field].flength+1,sizeof(char));
         del=fieldat[field].delim;
         /* Depending on the value of DEL get either
          * a fixed or a variable length field.
          */
         if (!del) getfix(src,ptr,fieldat[field].flength);
              else getvar(src,ptr,fieldat[field].flength,del);
         if (fieldat[field].numer)
            { /* fix numeric value - right justify */
            int integer;
            sscanf(ptr,"%d",&integer);
            sprintf(ptr,"%*d",fieldat[field].flength,integer);
            }
         if (fieldat[field].needed) fieldat[field].dataptr=ptr;
            else                    cfree(ptr);
         }
                       /* Output all the sort fields first */
      for (field=1;field<=numsort;field++)
         fprintf(temp1,"%s",fieldat[sortdat[field]].dataptr);
                       /* Followed by all the print fields */
      for (field=1;field<=numsort;field++)
         fprintf(temp1,"%s",fieldat[printdat[field]].dataptr);
      if (usecr) c=getc(src); /* if CR at end of record discard it */
      putc('\n',temp1);       /* Put CR at end of sort line */
      records=records+1;      /* Count input becords */
                              /* Free all space used to store
                               *     fields now           */

      for (i=1;i<=numflds;i++)
         if (fieldat[i].needed) cfree(fieldat[i].dataptr);
      }
   fclose(temp1);;
   if (!records) error("PPK1: Source file empty!\n");
   printf("%d records read off source file\n",records);
}

/* Error-checking function to open a file.
 * will print 'error' if any error and exit with error status
 */
FILE *openup(file,perms)
char *file,*perms;
{
   FILE *fp;
   if ((fp=fopen(file,perms))==NULL)
      error("PPK1: Can't open %s\n",file);
   return(fp);
}

/* Print an error and exit with error status */
error(str,nam)
char *str,*nam;
{
   printf(str,nam);
   printf("PPK1: Abnormal termination.\n");
   exit(-1);
}

getfix(file,ptr,en)     /* get a fixed length field */
char *ptr;
int en;
FILE *file;
{
   int i=0;
   while (i<en) ptr[i++]=getc(file);  /* read each char */
   ptr[i]=0;
   if (feof(file)) error("PPK1: EOF unexpected!\n");
}

getvar(file,ptr,en,delim)   /* Get a variable length field */
char *ptr,delim;
int en;
FILE *file;
{
   int i=0;
   char c;
   while (i<en)    /* read chars to a maximum number */
      {
      if ((c=getc(file))==delim) break;
      ptr[i++]=c;
      }
   while (i<en) ptr[i++]=' ';  /* blank pad resultant field */
   ptr[i]=0;
                             /* ignore field width overflow */
   while (c!=delim && !feof(file)) c=getc(file);
   if (feof(file)) error("PPK1: EOF unexpected!\n");
}

dorprt()
{
   char c;
   int i,j;
   page=lines=sortlen=sumwidth=0;
   for (i=1;i<=numflds;i++)
      if (fieldat[i].prneed)
         /* Preallocate required storage */
         fieldat[i].dataptr=calloc(fieldat[i].flength+1,sizeof(char));
   /* Calculate length of sort fields prepended */
   for (i=1;i<=numsort;i++)
       sortlen += fieldat[sortdat[i]].flength;
   for (i=1;i<=numprint;i++)
      {
      j=printdat[i];
      mwidth[i]=max(fieldat[j].flength,strlen(fieldat[j].display));
      sumwidth+=mwidth[i];
      }
   temp2=openup(SORTOUT,"r");
   while (c=getc(temp2),!feof(temp2))   /* Check for EOF */
      {
      ungetc(c,temp2);     /* Undo illogical UNIX EOF check */
      if (!lines) ffeed(); /* Formfeed output if lines=0    */
      getfields();         /* Get all input fields          */
      writrecd();          /* write formatted output        */
      if (lines>(linpage-14)) lines=0;
      }
   fclose(temp2);                       /* close files  */
   fclose(dest);
}

prompt(flag,string)
int flag;
char *string;
{
   if (!flag) printf(string);
}

/* Get all print fields off the
 * sorted temporary file.
 */
getfields()
{
   int i,j,field,records=0;
   char *ptr;
   /* disregard sort fields */
   for (i=0;i<sortlen;i++) getc(temp2);
   /* read a field at a time */
   for (i=1;i<=numprint;i++)
      {
      j=printdat[i];   /* Note now fields are FIXED length */
      getfix(temp2,fieldat[j].dataptr,fieldat[j].flength);
      }
   getc(temp2);    /*discard newline character */
}

/* Write a formatted detail line
 * to the destination file.
 */
writrecd()
{
   int i;
   char c;
   for (i=1;i<=numprint;i++)
      {
      /* Print centered field within heading or vice versa */
      center(0,fieldat[printdat[i]].dataptr,mwidth[i]);
      calcspc(i);
      }
   /* Single, double or triple spaced output */
   for (i=1;i<=spacing;i++) putc('\n',dest);
   lines+=spacing;
}

/* formfeed the output file and print headings */
ffeed()
{
   int stdspc,i;
   putc('\f',dest);
   /* stdspc is spaces from start to heading for centering */
   stdspc=((columns-strlen(heading))/2);
   fprintf(dest,"Page %3d",++page);  /* page number */
   spaces(dest,stdspc-8);
   fprintf(dest,"%s",heading);       /* heading string */
   spaces(dest,stdspc-24);
   fprintf(dest,"%s","Sat 11 Nov 1985 15:25\n");
   center(1,heading,columns);
   fprintf(dest,"\n\n\n");
   for (i=1;i<=numprint;i++)
      {
      center(0,fieldat[printdat[i]].display,mwidth[i]);
      calcspc(i);
      }
   fprintf(dest,"\n");
   for (i=1;i<=numprint;i++)
      {
      center(1,fieldat[printdat[i]].display,mwidth[i]);
      calcspc(i);
      }
   fprintf(dest,"\n\n\n");
}

/* Get a string which may include spaces from std input.
 */
char *getstring(file)
FILE *file;
{
   char *ptr,c;
   int i=0;
   ptr=calloc(130,sizeof(char));
   while (c=getc(file),(c==' ' || c=='\n'));
   while (c!='\n' && !feof(file))
      {
      ptr[i++]=c;
      c=getc(file);
      }
   ptr[i]=0;
   return(ptr);
}

/* Output 'spaces' number of spaces to file 'file'. */
spaces(file,num)
FILE *file;   int num;
{
   int i=0;
   while (i++ < num) putc(' ',file);
}

/* Calculate how many spaces are required to exactly fit
 * 'numflds' fields into a field of width 'columns' when
 * the data takes up 'sumwidth' columns.
 * This function will always get the spacing exact!
 */
calcspc(field)
int field;
{
   int x1,x2;
   if (field==numprint) return;
   x1=(columns-sumwidth)/(numprint-1);
   x2=(columns-sumwidth)%(numprint-1);
   if (field<x2) x1++;
   spaces(dest,x1);
}

/* Center a string 'string' into a field of width 'width'.
 * If 'flag' is set, then print dashes instead of 'string'.
 */
center(flag,string,width)
char *string;
int width,flag;
{
   int len,spc1,spc2,i;
   len=strlen(string);
   spc1=(width-len)/2;
   spc2=(width-len-spc1);
   spaces(dest,spc1);
   for (i=0;i<len;i++) putc(flag ? '-' : string[i],dest);
   spaces(dest,spc2);
}

/* Quick function to find the maximum of two integers */
max(a,b)  int a,b;
{ return( a>b ? a : b); }

