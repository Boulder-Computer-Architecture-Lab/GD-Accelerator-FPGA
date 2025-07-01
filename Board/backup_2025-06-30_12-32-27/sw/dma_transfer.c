#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

#define DMA_MAP_SIZE 0x10000

// Register offsets
#define MM2S_DMACR   0x00
#define MM2S_DMASR   0x04
#define MM2S_SRC     0x18
#define MM2S_LEN     0x28

#define S2MM_DMACR   0x30
#define S2MM_DMASR   0x34
#define S2MM_DEST    0x48
#define S2MM_LEN     0x58

void usage(const char *prog) {
    printf("Usage:\n");
    printf("  %s mm2s <src_phys_addr> <length> <dma_base>\n", prog);
    printf("  %s s2mm <dest_phys_addr> <length> <dma_base>\n", prog);
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        usage(argv[0]);
        return 1;
    }

    const char *mode = argv[1];
    uint32_t addr = strtoul(argv[2], NULL, 0);
    uint32_t len  = strtoul(argv[3], NULL, 0);
    uint32_t dma_base = strtoul(argv[4], NULL, 0);

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    volatile uint32_t *dma = mmap(NULL, DMA_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, dma_base);
    if (dma == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return 1;
    }

    if (strcmp(mode, "mm2s") == 0) {
        printf("Starting MM2S: addr=0x%08X, len=%u, dma_base=0x%08X\n", addr, len, dma_base);

        dma[MM2S_DMACR / 4] = 0x4; // Reset
        usleep(1000);
        dma[MM2S_DMACR / 4] = 0x1; // Run
        dma[MM2S_DMASR / 4] = 0xFFFFFFFF; // Clear status
        dma[MM2S_SRC   / 4] = addr;
        dma[MM2S_LEN   / 4] = len;

        while (!(dma[MM2S_DMASR / 4] & (1 << 12))) usleep(100);
        printf("MM2S transfer complete.\n");

    } else if (strcmp(mode, "s2mm") == 0) {
        printf("Starting S2MM: addr=0x%08X, len=%u, dma_base=0x%08X\n", addr, len, dma_base);

        dma[S2MM_DMACR / 4] = 0x4; // Reset
        usleep(1000);
        dma[S2MM_DMACR / 4] = 0x1; // Run
        dma[S2MM_DMASR / 4] = 0xFFFFFFFF; // Clear status
        dma[S2MM_DEST  / 4] = addr;
        dma[S2MM_LEN   / 4] = len;

        while (!(dma[S2MM_DMASR / 4] & (1 << 12))) usleep(100);
        printf("S2MM transfer complete.\n");

    } else {
        fprintf(stderr, "Invalid mode '%s'. Use 'mm2s' or 's2mm'.\n", mode);
        usage(argv[0]);
    }

    munmap((void *)dma, DMA_MAP_SIZE);
    close(fd);
    return 0;
}

