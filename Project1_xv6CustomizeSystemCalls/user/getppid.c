#include "user.h"
#include "stdio.h"

int main() {
    int ppid = getppid();
    printf("Parent PID: %d\n", ppid);
    exit(0);
}
