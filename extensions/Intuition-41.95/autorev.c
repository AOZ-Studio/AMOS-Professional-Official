#include <stdio.h>
#include <string.h>
#include <time.h>
#include <dos/dos.h>

main(int ac, char **av) {
    char s[256];
    FILE *f, *g;
    int v;
    static struct tm tm;
    static struct FileInfoBlock fib;
    BPTR l;

    if (ac < 2) exit(20);
    sprintf(s, "copy %s %s.bak clone", av[1], av[1]);
    if ((v = system(s)) > 5)
	exit(v);
    sprintf(s, "%s.bak", av[1]);
    if (!(f = fopen(s, "r"))) exit(20);
    if (!(g = fopen(av[1], "w"))) exit(20);
    do {
	fgets(s, 256, f); fprintf(g, "%s", s);
    } while (strncmp(s, "VERSION", 7));
    fgets(s, 256, f);
    strcpy(s, strchr(s, '\"')+1);
    *strchr(s, '\"') = 0;
    *strchr(s, '.') = 0;
    v = strtol(s, NULL, 10);
    strcpy(s, s+strlen(s)+1);
    fprintf(g, "\tdc.b \"%d.%d\"\n", v, 1 + strtol(s, NULL, 10));
    do {
	fgets(s, 256, f); fputs(s, g);
    } while (strncmp(s, "DATE", 4));
    fgets(s, 256, f);
    tm = *localtime(NULL);
    fprintf(g, "\tdc.b \"%02d/%02d/%02d\"\n", tm.tm_year % 100,
						tm.tm_mon + 1, tm.tm_mday);
    for (;;) {
	fgets(s, 256, f);
	if (feof(f)) break;
	fprintf(g, "%s", s);
    }
    fclose(f); fclose(g);
    sprintf(s, "%s.bak", av[1]);
    /* Try to reset file date */
    if (!(l = Lock(s, SHARED_LOCK))) exit(5);
    Examine(l, &fib);
    SetFileDate(av[1], &fib.fib_Date);
    UnLock(l);
    exit(0);
}
