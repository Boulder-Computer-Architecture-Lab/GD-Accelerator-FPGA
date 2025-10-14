#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define NPOSLAND 17048
#define IPOSLAND(i, j) ((i)*NPOSLAND + (j))

#define MATRIX_PATH "trmult_reduced16.bin"

typedef __fp16 real;

int main() {

    // Open matrix file (assumed FP16 on disk)
    const char* filename = MATRIX_PATH;
    FILE* file = fopen(filename, "rb");
    if (!file) {
        perror("Failed to open file.");
        return 1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    rewind(file);

    if (file_size % sizeof(real) != 0) {
        fprintf(stderr, "Invalid file size: not a multiple of sizeof(_Float16)\n");
        fclose(file);
        return 1;
    }

    // Allocate memory for matrix
    size_t num_elements = file_size / sizeof(real);
    real* trmult_reduced = (real*)malloc(num_elements * sizeof(real));
    if (!trmult_reduced) {
        perror("trmult malloc failed");
        fclose(file);
        return 1;
    }

    // Read data into matrix array
    size_t elements_read = fread(trmult_reduced, sizeof(real), num_elements, file);
    if (elements_read != num_elements || elements_read != (size_t)NPOSLAND * (size_t)NPOSLAND) {
        fprintf(stderr, "Failed to read all elements\n");
        free(trmult_reduced);
        fclose(file);
        return 1;
    }
    fclose(file);

    // Allocate and initialize dummy `b` vector (FP16)
    size_t N = NPOSLAND;
    real* b = (real*)malloc(N * sizeof(real));
    if (!b) {
        perror("b malloc failed");
        free(trmult_reduced);
        return 1;
    }
    for (size_t i = 0; i < N; i++) {
        b[i] = (real)((double)(i + 1) / 1000.0);
    }

    // Allocate result buffer (FP16)
    real* rslt = (real*)malloc(N * sizeof(real));
    if (!rslt) {
        perror("rslt malloc failed");
        free(trmult_reduced);
        free(b);
        return 1;
    }

    printf("Initialization complete.\n");

    // Perform MVM computation (FP16 accumulate)
    clock_t start = clock();
    for (size_t i = 0; i < NPOSLAND; i++){
        rslt[i] = (real)0.0;  // make sure we start from zero
        for (size_t j = 0; j < NPOSLAND; j++){
            // Force FP16 rounding at each step by casting the mul and the sum
            real prod = (real)((real)trmult_reduced[IPOSLAND(i, j)] * (real)b[j]);
            rslt[i] = (real)(rslt[i] + prod);
        }
    }
    clock_t end = clock();

    // Print results
    printf("Compute time: %f\n", ((double)(end - start)) / CLOCKS_PER_SEC);
    for (size_t i = 0; i < 5; i++) {
        printf("rslt[%zu] = %.16f\n", i, (double)rslt[i]);
    }
    printf("...\n");

    // Cleanup
    free(trmult_reduced);
    free(b);
    free(rslt);

    return 0;
}
