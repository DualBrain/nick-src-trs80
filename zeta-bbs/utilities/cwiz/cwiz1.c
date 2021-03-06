/* cwiz ... Written by Rosko, substantially modified by Nick */

#include <stdio.h>
FILE    *in,*out;
#define  MAX    100
char    string[MAX];

main()
{
    int c, count;
    int  rba;  /* file position (should be long) */
    char str[6];

    if ((in=fopen("wisdom.txt","r"))==NULL) {
        fputs("Cannot open wisdom.txt\n",stderr);
        exit(1);
    }

    if ((out=fopen("wisdom.inx","w"))==NULL) {
        fputs("Cannot open wisdom.inx\n",stderr);
        exit(1);
    }

    putint(0);    /* first int = count of wisdoms */

    count = 0;
    while (1) {
        do {
            string[0]=0;
            rba = ftell(in);
            if (fgets(string,MAX,in)==NULL) break;
        } while (string[0] == ' ' || string[0]=='\t');
        if (string[0]==0) break;
        putint(rba);
        ++count;
    }
/*  rewind(out);
    putint(count);
*/

    fputs("There are ",stdout);
    itoa(count,str);
    fputs(str,stdout);
    fputs(" wisdoms.\n",stdout);
}

putint(n)
int     n;
{
    fputc(n & 0xff,out);
    fputc((n>>8) & 0xff,out);
}

