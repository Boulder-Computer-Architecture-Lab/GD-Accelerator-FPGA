#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

#define ADD_ONE_BASE XPAR_ADD_ONE_0_BASEADDR

int main() {
    int input = 42;
    xil_printf("Input: %d\r\n", input);
    Xil_Out32(ADD_ONE_BASE + 0x00, input);      // Write input to offset 0x00
    u32 result = Xil_In32(ADD_ONE_BASE + 0x04); // Read result from offset 0x04
    xil_printf("Output: %d\r\n", result);
    return 0;
}
