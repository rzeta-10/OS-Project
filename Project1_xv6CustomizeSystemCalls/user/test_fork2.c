#include "../kernel/types.h"
#include "user.h"
#include "printf.h"

int main() {
    int pid = fork2(10); // Create a child process with priority 10

    if (pid < 0) {
        printf("fork2 failed\n");
        exit(1);
    }

    if (pid == 0) {
        // This is the child process
        printf("Child process with priority 10\n");
        exit(0);
    } else {
        // Parent waits for the child to finish
        wait(0); // Wait for the child process to complete
        printf("Parent process created child with PID: %d\n", pid);
    }

    exit(0);
}
