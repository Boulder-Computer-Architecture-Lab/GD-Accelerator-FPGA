#include <stdlib.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xaxidma.h"
#include "ff.h"

#define FILE_NAME       "trmult.bin"
#define NPOSLAND        17048

#define ROW_SIZE        NPOSLAND
#define NUM_ROWS        NPOSLAND
#define NUM_DOUBLES     ROW_SIZE * NUM_ROWS // Number of elements
#define MATRIX_SIZE     ((size_t)(NUM_DOUBLES * 8)) // Size in bytes

#define CHUNK_SIZE      1024 // bytes
#define CHUNK_DOUBLES   (CHUNK_SIZE / sizeof(double))

// Statically allocated buffers (not on heap)
__attribute__((aligned(64))) volatile double input_buffer[CHUNK_DOUBLES];
__attribute__((aligned(64))) volatile double output_buffer[CHUNK_DOUBLES];

int main() {

    // -------------------------- Vars -------------------------- //

    FIL file;
    FATFS fatfs;
    UINT bytesRead;
    XAxiDma AxiDma;
    XAxiDma_Config cfg = {
        .BaseAddr        = XPAR_AXI_DMA_0_BASEADDR,
        .HasStsCntrlStrm = XPAR_AXI_DMA_0_SG_INCLUDE_STSCNTRL_STRM,
        .HasMm2S         = XPAR_AXI_DMA_0_INCLUDE_MM2S,
        .HasMm2SDRE      = XPAR_AXI_DMA_0_INCLUDE_MM2S_DRE,
        .Mm2SDataWidth   = XPAR_AXI_DMA_0_MM2S_DATA_WIDTH,
        .HasS2Mm         = XPAR_AXI_DMA_0_INCLUDE_S2MM,
        .HasS2MmDRE      = XPAR_AXI_DMA_0_INCLUDE_S2MM_DRE,
        .S2MmDataWidth   = XPAR_AXI_DMA_0_S2MM_DATA_WIDTH,
        .HasSg           = XPAR_AXI_DMA_0_INCLUDE_SG,
        .Mm2sNumChannels = XPAR_AXI_DMA_0_NUM_MM2S_CHANNELS,
        .S2MmNumChannels = XPAR_AXI_DMA_0_NUM_S2MM_CHANNELS,
        .Mm2SBurstSize   = XPAR_AXI_DMA_0_MM2S_BURST_SIZE,
        .S2MmBurstSize   = XPAR_AXI_DMA_0_S2MM_BURST_SIZE,
        .MicroDmaMode    = XPAR_AXI_DMA_0_MICRO_DMA,
        .AddrWidth       = XPAR_AXI_DMA_0_ADDRWIDTH,
        .SgLengthWidth   = XPAR_AXI_DMA_0_SG_LENGTH_WIDTH
    };

    // ------------------------ Init/Cfg ------------------------ //

    xil_printf("Initializing DMA...\n\r");
    if (XAxiDma_CfgInitialize(&AxiDma, &cfg) != XST_SUCCESS) {
        xil_printf("DMA init failed\n\r");
        return XST_FAILURE;
    }

    xil_printf("Resetting DMA...\n\r");
    XAxiDma_Reset(&AxiDma);
    while (!XAxiDma_ResetIsDone(&AxiDma)) {
        xil_printf("Waiting for DMA reset...\n\r");
    }

    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("Error: DMA is in SG mode\n\r");
        return XST_FAILURE;
    }

    xil_printf("Mounting SD card...\n\r");
    FRESULT res = f_mount(&fatfs, "0:/", 1);
    if (res != FR_OK) {
        xil_printf("SD mount failed: %d\n\r", res);
        return XST_FAILURE;
    }

    xil_printf("Opening file: %s\n\r", FILE_NAME);
    res = f_open(&file, FILE_NAME, FA_READ);
    if (res != FR_OK) {
        xil_printf("File open failed: %d\n\r", res);
        return XST_FAILURE;
    }

    // ------------------------ Transmit ------------------------ //

    xil_printf("Starting DMA transfer...\n\r");
    xil_printf("Input buffer addr: 0x%08lx\n\r", (UINTPTR)input_buffer);
    xil_printf("Transfer size: %lu\n\r", MATRIX_SIZE);

    for (size_t offset = 0; offset < MATRIX_SIZE; offset += CHUNK_SIZE) {

        size_t chunk = (MATRIX_SIZE - offset) < CHUNK_SIZE ? (MATRIX_SIZE - offset) : CHUNK_SIZE;
        
        res = f_read(&file, (void *) input_buffer, chunk, &bytesRead);
        if (res != FR_OK || bytesRead != chunk) {
            xil_printf("Chunk read failed at offset %lu (read %u)\n\r", offset, bytesRead);
            return XST_FAILURE;
        }

        xil_printf("Transferring chunk of size %lu at offset %lu\n\r", chunk, offset);

        Xil_DCacheFlushRange((UINTPTR)input_buffer, chunk); // Flush input
        Xil_DCacheInvalidateRange((UINTPTR)output_buffer, chunk); // Invalidate output

        // Start S2MM
        int status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)output_buffer, chunk, XAXIDMA_DEVICE_TO_DMA);
        if (status != XST_SUCCESS) {
            xil_printf("S2MM transfer failed: %d\n\r", status);
            return XST_FAILURE;
        }

        // Start MM2S
        status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)input_buffer, chunk, XAXIDMA_DMA_TO_DEVICE);
        if (status != XST_SUCCESS) {
            xil_printf("MM2S transfer failed: %d\n\r", status);
            return XST_FAILURE;
        }

        // Wait
        while (XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE));
        while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA));

        // Check DMA status
        u32 mm2s_status = XAxiDma_ReadReg(XPAR_AXI_DMA_0_BASEADDR, XAXIDMA_SR_OFFSET);
        u32 s2mm_status = XAxiDma_ReadReg(XPAR_AXI_DMA_0_BASEADDR, XAXIDMA_RX_OFFSET + XAXIDMA_SR_OFFSET);
        if (mm2s_status & 0x1000 || s2mm_status & 0x1000) {
            xil_printf("DMA error detected, resetting...\n\r");
            XAxiDma_Reset(&AxiDma);
            while (!XAxiDma_ResetIsDone(&AxiDma));
        }
    }

    xil_printf("DMA transfer complete!\n\r");

    // ---------------------------------------------------------- //

    f_close(&file);
    return 0;
}
