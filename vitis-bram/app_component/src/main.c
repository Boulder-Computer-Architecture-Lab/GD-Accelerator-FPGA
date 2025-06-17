#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"

#define BRAM_BASE 0x40000000

int main() {
    volatile u32 *bram = (u32 *) BRAM_BASE;
    sleep(10);

    for (int i = 0; i < 16; i++) {
        xil_printf("BRAM[%d] = 0x%08X\n", i, bram[i]);
    }

    return 0;
}