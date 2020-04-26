/* Info about extension labels (i.e. size,pos) */

#include <stdio.h>

int main(int ac, char **av)
{
    FILE *f;
    short x, rc = 0;
    long cnt, y, i, pos;

    while (--ac) {
	++av;
	if (!(f = fopen(*av, "r"))) {
	    perror(*av); rc = 10; continue;
	}
	fseek(f, 0x20, SEEK_SET);
	fread(&y, 4, 1, f);
	fread(&pos, 4, 1, f);
	i = cnt = y>>1;
	fseek(f, 0x32, SEEK_SET);
	while (i--) {
	    fread(&x, 2, 1, f); x <<= 1;
	    printf("%4d: %04x/%d\n", cnt-i-1, pos, x);
	    pos += x;
	}
    }
}
