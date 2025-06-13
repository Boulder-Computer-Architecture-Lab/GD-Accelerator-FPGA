#include "xparameters.h"
#include "xaxidma.h"
#include "xil_printf.h"
#include "xil_cache.h"

#define TX_BUFFER_BASE     (XPAR_PS7_DDR_0_BASEADDRESS + 0x01000000)
#define RX_BUFFER_BASE     (XPAR_PS7_DDR_0_BASEADDRESS + 0x02000000)
#define BUFFER_SIZE        32  // 16 words (64 bytes total)

int main() {
    XAxiDma dma;

    xil_printf("Initializing AXI DMA...\r\n");

    XAxiDma_Config dma_cfg = {
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

    int status = XAxiDma_CfgInitialize(&dma, &dma_cfg);
    if (status != XST_SUCCESS) {
        xil_printf("DMA initialization failed!\r\n");
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(&dma)) {
        xil_printf("Scatter-gather mode not supported.\r\n");
        return XST_FAILURE;
    }

    u32 *tx_buf = (u32 *)TX_BUFFER_BASE;
    u32 *rx_buf = (u32 *)RX_BUFFER_BASE;

    for (int i = 0; i < BUFFER_SIZE; i++) {
        tx_buf[i] = i;  // Input: 0, 1, 2, ..., 15
    }

    Xil_DCacheFlushRange((UINTPTR)tx_buf, BUFFER_SIZE * sizeof(u32));      // Clear old (garbage) tx_buf data
    Xil_DCacheInvalidateRange((UINTPTR)rx_buf, BUFFER_SIZE * sizeof(u32)); // Bypass cache when reading output

    xil_printf("Starting DMA transfers...\r\n");

    XAxiDma_SimpleTransfer(&dma, (UINTPTR)rx_buf, BUFFER_SIZE * sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_SimpleTransfer(&dma, (UINTPTR)tx_buf, BUFFER_SIZE * sizeof(u32), XAXIDMA_DMA_TO_DEVICE);

    while (XAxiDma_Busy(&dma, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&dma, XAXIDMA_DEVICE_TO_DMA));

    xil_printf("DMA transfer complete. Received data:\r\n");

    for (int i = 0; i < BUFFER_SIZE; i++) {
        xil_printf("rx_buf[%d] = %d\r\n", i, rx_buf[i]);
    }

    return 0;
}
