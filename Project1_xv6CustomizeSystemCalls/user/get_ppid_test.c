#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
    int ppid = get_ppid();
    printf("Parent Process ID: %d\n", ppid);
    exit(0);
}
