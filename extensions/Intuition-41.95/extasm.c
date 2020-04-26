/* Assemble an AMOS extension.  Automatically calculates label offsets
 * and numbers.  Use "L_Name" as an ordinary label, and do ordinary
 * BSRs/BRAs/etc. to it.  (Note: do not use L_xxx for anything else!)
 * For AMOS internal routines, do "jsr L_xxx" or "jmp L_xxx".
 *
 * ExtAsm normally processes all "include" and "incdir" directives
 * itself.  If you want to disable this automatic processing for a
 * section of code, bracket it with these two lines:

;EXTASM: I
;... includes ...
;EXTASM: i

 * NOTE ON CONDITIONAL INCLUDES:
 * (This section only applies if processing of includes is active.)
 *
 *   If you conditinally include one or more files, those include
 * directives *MUST* be bracketed with EXTASM conditionals.  They take
 * this form:

      ifd SYMBOL
;EXTASM: DSYMBOL
	include "myfile.s"
;EXTASM: E
      else
;EXTASM: NSYMBOL
	include "myotherfile.s"
;EXTASM: E
      endc

 * The "EXTASM: X" (with X one of D [defined], N [not defined], or E
 * [end conditional]) must be in all caps.  Nesting is not allowed.
 * If you do not include these ExtAsm directives, bad things will
 * happen!
 * The symbols used in these tests must be given on the command line
 * using the "-s" option, as in "-sSYMBOL".  These are also passed to
 * the assembler, so it must support the "-s" option as well.
 * The ExtAsm tests must be used around INCDIR directives as well.
 *
 * NOTE ON L_xxx LABELS:
 *   The first label in your extension (the one that begins the startup
 * stuff) must be L_0.  Otherwise, ExtAsm will not recognise any of
 * your labels as valid labels.
 *
 * Copyright (C) 1994-95 Andrew Church.
 */

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <ctype.h>

char verstr[] = "$VER: extasm 1.4 (95/06/18)";

FILE *f = NULL, *f2 = NULL;
char linebuf[256], incdir[256], defincdir[256];
int ac;	/* global copy of argc */
char **av;    /* global copy of argv */

char *ASM = "as";
char *LINK = "dlink";


#define DEBUG

#ifdef DEBUG
/* Set a breakpoint here... */
void debug()
{
}
#endif


void error(char *s,...)
{
    va_list args;

    va_start(args, s);
    vfprintf(stderr, s, args);
    fprintf(stderr, "\n");
    exit(20);
}

FILE *sfopen(char *s, char *m)
{
    FILE *f = fopen(s,m);
    if (!f) error("Unable to open %s", s);
    return f;
}

char *stripblanks(char *s)
{
    char *t = s + strlen(s);

    while (*--t == ' ' || *t == '\t' || *t == '\n' && t >= s); *++t = 0;
    t = s; while (*t == ' ' || *t == '\t' || *t == '\n') t++;
    return strcpy(s, t);
}

char *getline(FILE *f)
{
    if (fgets(linebuf, 256, f)) {
	if (linebuf[strlen(linebuf)-1] == '\n')
	    linebuf[strlen(linebuf)-1] = 0;
    } else {
	*linebuf = 0;
    }
    return linebuf;
}

void include(char *fn, FILE *out)
{
    FILE *f;
    register char *s, *t;
    register char c;
    char line[256];
    register int ignore = 0;  /* set to 1 if an EXTASM conditional is true */
    register int i;
    register int ignore_incl;	/* Should we ignore include/incdir's? */
    f = fopen(fn, "r");
    if (!f) {
	strcat(strcpy(line, incdir), fn);
	f = fopen(line, "r");
	if (!f) {
	    strcat(strcpy(line, defincdir), fn);
	    f = fopen(line, "r");
	    if (!f) error("Couldn't find %s (incdir=\"%s\")", fn, incdir);
	}
    }
    s = getline(f);
    if (!strncmp(s, ";EXTASM: ", 9)) {
	c = s[9]; t = s+10;
	switch (c) {
	case 'D':
	    ignore = 1;
	    for (i = 2; i < ac; i++)
		if (!strnicmp(av[i], "-s", 2) &&
			!strcmp(av[i]+2, t)) {
		    ignore = 0;
		    break;
		}
	    break;
	case 'N':
	    ignore = 0;
	    for (i = 2; i < ac; i++)
		if (!strnicmp(av[i], "-s", 2) &&
			!strcmp(av[i]+2, t)) {
		    ignore = 1;
		    break;
		}
	    break;
	case 'E':
	    ignore = 0;
	    break;
	case 'I':
	    ignore_incl = 1; break;
	case 'i':
	    ignore_incl = 0; break;
	default:
	    error("Unknown EXTASM conditional, type %c", c);
	}
    }
    if (*s == '*') *s = 0;
    if (t = strchr(s, ';')) *t = 0;
    strcpy(line, s);
    stripblanks(s);
    while (!feof(f) && stricmp(s, "end")) {
	if (!ignore)
	    if (!strnicmp(s, "include", 7) && isspace(s[7]) &&
							!ignore_incl) {
		stripblanks(strcpy(s, s+7));
		t = s+1;
		while (*t != *s) t++; *t = 0;
		include(s+1, out);
	    } else if (!strnicmp(s, "incdir", 6) && isspace(s[6]) &&
							!ignore_incl) {
		stripblanks(strcpy(s, s+6));
		t = s+1;
		while (*t != *s) t++; *t = 0;
		strcpy(incdir, s+1);
		if (*(t = incdir + strlen(incdir)-1) != ':' &&
			*t != '/')
		    strcat(incdir, "/");
	    } else
		fprintf(out, "%s\n", line);
	s = getline(f);
	if (!strncmp(s, ";EXTASM: ", 9)) {
	    c = s[9]; t = s+10;
	    switch (c) {
	    case 'D':
		ignore = 1;
		for(i = 2; i < ac; i++)
		    if (!strncmp(av[i], "-S", 2) &&
			    !strcmp(av[i]+2, t)) {
			ignore = 0;
			break;
		    }
		break;
	    case 'N':
		ignore = 0;
		for(i = 2; i < ac; i++)
		    if (!strncmp(av[i], "-S", 2) &&
			    !strcmp(av[i]+2, t)) {
			ignore = 1;
			break;
		    }
		break;
	    case 'E':
		ignore = 0;
		break;
	    case 'I':
		ignore_incl = 1; break;
	    case 'i':
		ignore_incl = 0; break;
	    default:
		error("Unknown EXTASM conditional, type %c", c);
	    }
	}
	if (*s == '*') *s = 0;
	if (t = strchr(s, ';')) *t = 0;
	strcpy(line, s);
	stripblanks(s);
    }
#ifdef DEBUG
    debug();
#endif
    fclose(f);
}

void main(int argc, char **argv)
{
    static char in[64], out[64], lbl[32], inst[16], op[64], cmd[512],
		line[256], listout[64];
    register char *s, *t;
    int i, n, labelnum = 0, nlabels, codepos, codesize, objsize, curpos,
	codesize2;
    int gotfirstlabel = 0;    /* did we find the first label? */
    static int lpos[2048];
    short j, bad, listing = 0;
    char *buf;
    FILE *listf;

    for (i = 0; i < 2048; i++) lpos[i] = -1;
    *in = *out = *listout = 0;
    ac = argc; av = argv;
    for (i = 1; i < argc; i++) {
	if (*(s = argv[i]) == '-')
	    switch (s[1]) {
	    case 'o':	/* output filename */
		if (s[2] == 0) {
		    if (--argc == 0) {
			fprintf(stderr, "-o option needs a filename\n");
			exit(20);
		    }
		    s = argv[++i];
		} else
		    s += 2;
		strcpy(out, s);
		break;
	    case 'S':	/* define a symbol */
		break;	/* - handled by include() */
	    case 'l':	/* listing of symbols and Lnnn labels */
		listing = 1;
		if (s[2] == '=')
		    strcpy(listout, s+3);
		break;
	    case 'A':	/* assembler */
		if (s[2] == 0) {
		    if (--argc == 0) {
			fprintf(stderr, "-A option needs a filename\n");
			exit(20);
		    }
		    s = argv[++i];
		} else
		    s += 2;
		ASM = s; break;
	    case 'L':	/* linker */
		if (s[2] == 0) {
		    if (--argc == 0) {
			fprintf(stderr, "-L option needs a filename\n");
			exit(20);
		    }
		    s = argv[++i];
		} else
		    s += 2;
		LINK = s; break;
	    default:
		fprintf(stderr, "Unknown option %s\n", s);
		exit(20);
	    }
	else {
	    if (*in) {
		fprintf(stderr, "Input file already specified\n");
		exit(20);
	    }
	    strcpy(in, s);
	}
    }
    if (!*in) error("required argument missing");
    if (!*out) {
	strcpy(out, in);
	if (s = strrchr(out, '.')) *s = 0;
	strcat(out, ".lib");
    }
    if (listing) {
	if (!*listout) {
	    strcpy(listout, in);
	    if (s = strrchr(listout, '.')) *s = 0;
	    strcat(listout, ".lst");
	}
	listf = sfopen(listout, "w");
    }
    f2 = sfopen("T:___tmp___", "w");
    strcpy(incdir, in);
    if (s = strrchr(incdir, '/'))
	*++s = 0;
    else if (s = strrchr(incdir, ':'))
	*++s = 0;
    strcpy(defincdir, incdir);
    include(in, f2);
    fclose(f2);
    f = sfopen("T:___tmp___", "r");
    f2 = sfopen("T:extasm_tmp.a", "w");
    while (!feof(f)) {
	strcpy(line, s = getline(f));
	*lbl = *inst = *op = 0;
	if (*s != ' ' && *s != '\t' && *s != '\n' && *s) {
	    t = s; i = 0;
	    do
		lbl[i++] = *t++;
	    while (*t != ' ' && *t != '\t' && *t != '\n' &&
			    *t != ':' && *t);
	    lbl[i] = 0;
	    if (*t == ':') t++;
	    strcpy(s, t);
	    t = lbl+1;
	    while (t = strchr(t, '.')) {
		*t = '_';
		*(line + (t - lbl)) = '_';
	    }
	}
	t = stripblanks(s);
	if (!*s || *s == ';' || *s == '*')
	    if (!strncmp(lbl, "L_", 2)) {
		if (!gotfirstlabel)
		    gotfirstlabel = !strcmp(lbl+2, "0");
		if (gotfirstlabel) {
		    fprintf(f2, "%s\tequ %d\n\txdef\tL%d\nL%d\n",
					lbl, labelnum, labelnum, labelnum);
		    if (listing)
			fprintf(listf, "L%d\t%s\n", labelnum, lbl);
		    labelnum++;
		} else
		    fprintf(f2, "%s\n", line);
	    } else
		fprintf(f2, "%s\n", line);
	else {
	    i = 0;
	    while (*t != ' ' && *t != '\t' && *t != '\n' && *t)
		inst[i++] = *t++;
	    inst[i] = 0;
	    stripblanks(strcpy(op, t));
	    /* check for 'j' or 'b' (e.g. jsr/bsr) since we don't
	     * want "rdc.w L_xxx,-1" in the token table.
	     */
	    if (!strncmp(t = op, "L_", 2) &&
		((*inst == 'j' || *inst == 'J') ||
		 (*inst == 'b' || *inst == 'B'))) {
		while (t = strchr(t, '.'))
		    *t = '_';
		sprintf(line, "%s\tr%s\t%s", lbl, inst, op);
	    }
#ifdef FIX_RS
	    if (!strnicmp(inst, "rs.", 3)) {
		for (t = op; *t && *t != '\t' &&
			*t != ' ' && *t != ';'; t++);
		*t = 0;
		switch (inst[3]) {
		case 'w':
		    strcpy(op, strcat(strcat(
			    strcpy(s,"("), op
			    ), ")*2"));
		    break;
		case 'l':
		    strcpy(op, strcat(strcat(strcpy(s,"("), op), ")*4"));
		    break;
		}
		if (*lbl) fprintf(f2, "%s\tequ __RS\n", lbl);
		fprintf(f2,"__RS\tset __RS+%s\n", op);
	    } else if (!stricmp(op, "__RS")) {
		/* Sometimes __Rs is used instead */
		strcpy(op, "__RS");
		fprintf(f2, "%s\t%s %s\n", lbl, inst, op);
	    } else if (!stricmp(inst, "rsreset"))
		fprintf(f2,"__RS\tset 0\n");
	    else if (stricmp(inst, "rsset"))  /* ignore RsSet */
#endif
	    if (!strncmp(lbl, "L_", 2)) {
		if (!gotfirstlabel)
		    gotfirstlabel = !strcmp(lbl+2, "0");
		if (gotfirstlabel) {
		    fprintf(f2,
			    "%s\tequ %d\n\txdef\tL%d\nL%d\t%s%s%s\n",
			    lbl, labelnum, labelnum, labelnum,
			    inst, *op ? "\t" : "", op);
			    labelnum++;
		} else
		    fprintf(f2, "%s\n", line);
	    } else
		fprintf(f2, "%s\n", line);
	}
    }
    nlabels = labelnum;
    fclose(f);
    fclose(f2);
    if (listing) fclose(listf);
    remove("T:___tmp___");
    sprintf(cmd, "%s T:extasm_tmp.a -oT:eatmp.o", ASM);
    for (i = 1; i < argc; i++)
	if (!strncmp(argv[i], "-S", 2))
	    strcat(strcat(cmd, " "), argv[i]);
    i = system(cmd);
    remove("T:extasm_tmp.a");
    if (i >= 10) exit(i);
    f = sfopen("T:eatmp.o", "r");
    fread(&n, 4, 1, f);
    while (n != 0x3E9) {
	fread(&n, 4, 1, f); fseek(f, n*4, SEEK_CUR);
	fread(&n, 4, 1, f);
    }
    codepos = ftell(f);
    fread(&codesize, 4, 1, f); codesize *= 4;
    fseek(f, codesize, SEEK_CUR);
    fread(&n, 4, 1, f);
    while (n != 0x3EF) {
	fread(&n, 4, 1, f); fseek(f, n*4, SEEK_CUR);
	fread(&n, 4, 1, f);
    }
    fread(&n, 4, 1, f);
    while (n) {
	j = n >> 24; n &= 0xFFFFFF;
	switch (j) {
	case 0x01:    /* XDEF */
	    fread(lbl, 1, n*4, f);
	    fread(&n, 4, 1, f);
	    if (*lbl == 'L') {
		labelnum = strtol(lbl+1, NULL, 10);
		lpos[labelnum] = n;
	    }
	    break;
	default:    /* shouldn't be any others */
	    fprintf(stderr, "Weird HUNK_EXT entry 0x%02x%06x\n",
		    j, n);
	    exit(20);
	}
	fread(&n, 4, 1, f);
    }
    for (i = 0, bad = 0; i < nlabels; i++) {
	if (lpos[i] == -1) {
	    fprintf(stderr, "Label L%d not found\n", i);
	    bad = 1;
	}
    }
    if (bad) exit(20);
    fseek(f, 0, SEEK_END); objsize = ftell(f); fseek(f, 0, SEEK_SET);
    f2 = sfopen("T:extasm_tmp.o", "w");
    buf = malloc(objsize); if (!buf) error("Out of memory");
    fread(buf, 1, codepos, f); fwrite(buf, 1, codepos, f2);
    codesize2 = codesize + nlabels * 2 - 2;
    n = (codesize2 + 3) / 4; fwrite(&n, 4, 1, f2);
    fseek(f, 8, SEEK_CUR);
    n = nlabels * 2 - 2; fwrite(&n, 4, 1, f2);
    fread(buf, 1, 14, f); fwrite(buf, 1, 14, f2);
    curpos = lpos[0];
    for (labelnum = 1; labelnum < nlabels; labelnum++) {
	j = (lpos[labelnum] - curpos) / 2;
	fwrite(&j, 2, 1, f2);
	curpos = lpos[labelnum];
    }
    fwrite(buf, 1, i = fread(buf, 1 , codesize-18, f), f2);
    if (codesize2 & 3) {		/* longword align */
	j = 0; fwrite(&j, 2, 1, f2);
    }
    fwrite(buf, 1, fread(buf, 1, objsize, f), f2);    /* copy remainder */
    fclose(f); fclose(f2); remove("T:eatmp.o");
    sprintf(cmd, "%s T:extasm_tmp.o -o%s", LINK, out);
    i = system(cmd);
    remove("T:extasm_tmp.o");
    exit(i);
}
