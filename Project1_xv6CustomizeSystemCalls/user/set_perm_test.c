#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc != 3) {
        printf("Usage: set_perm <pid> <perm_flags>\n");
        exit(1);
    }

    int pid = atoi(argv[1]);
    int perm_flags = atoi(argv[2]);

    if (set_perm(pid, perm_flags) < 0) {
        printf("Error: Unable to set permissions for process %d\n", pid);
    } else {
        printf("Permissions set for process %d to %d\n", pid, perm_flags);
    }

    exit(0);
}
