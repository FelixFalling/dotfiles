#include <stdio.h>

int main(void) {
    /* ANSI colors: bold, yellow, cyan, gray, reset */
    const char *B = "\033[1m";
    const char *Y = "\033[33m";
    const char *C = "\033[36m";
    const char *G = "\033[90m";
    const char *R = "\033[0m";

    printf("%sBash Readline%s\n", B, R);
    printf("%sMOVE%s  %sCtrl-A%s start  %sCtrl-E%s end\n", Y, R, C, R, C, R);
    printf("      %sCtrl-B%s back   %sCtrl-F%s fwd\n", C, R, C, R);
    printf("      %sAlt-B %s word<-  %sAlt-F %s word->\n", C, R, C, R);
    printf("%sERASE%s %sCtrl-U%s <-line  %sCtrl-K%s line->\n", Y, R, C, R, C, R);
    printf("      %sCtrl-W%s <-word  %sAlt-D %s word->\n", C, R, C, R);
    printf("%sEX%s    $ cp monfichier dir/\n", G, R);
    return 0;
}
