#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define NPOSLAND 17048
#define IPOSLAND(i, j) ((i)*NPOSLAND + (j))

#define MATRIX_PATH "trmult_reduced.bin"

typedef double real;

int main() {

    // Open matrix file
    const char* filename = MATRIX_PATH;
    FILE* file = fopen(filename, "rb");
    if (!file) {
        perror("Failed to open file.");
        return 1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    rewind(file);

    if (file_size % sizeof(double) != 0) {
        fprintf(stderr, "Invalid file size: not a multiple of sizeof(double)\n");
        fclose(file);
        return 1;
    }

    // Allocate memory for matrix
    size_t num_elements = file_size / sizeof(double);
    double* trmult_reduced = malloc(file_size);
    if (!trmult_reduced) {
        perror("trmult malloc failed");
        fclose(file);
        return 1;
    }

    // Read data into matrix array
    size_t elements_read = fread(trmult_reduced, sizeof(double), num_elements, file);
    if (elements_read != num_elements || elements_read != NPOSLAND*NPOSLAND) {
        fprintf(stderr, "Failed to read all elements\n");
        free(trmult_reduced);
        fclose(file);
        return 1;
    }
    fclose(file);

    // Allocate and initialize dummy `b` vector
    size_t N = NPOSLAND;
    double* b = malloc(N * sizeof(double));
    if (!b) {
        perror("b malloc failed");
        free(trmult_reduced);
        return 1;
    }
    for (int i = 0; i < N; i++) {
        b[i] = (double)((i+1)/1000.0);
    }
    
    // Allocate result buffer
    double* rslt = malloc(N * sizeof(double));
    if (!rslt) {
        perror("rslt malloc failed");
        free(trmult_reduced);
        free(b);
        return 1;
    }

    printf("Initialization complete.\n");

    // Perform MVM computation
    clock_t start = clock();
    for (int i = 0; i < NPOSLAND; i++){
        for (int j = 0; j < NPOSLAND; j++){
            rslt[i] += trmult_reduced[IPOSLAND(i, j)] * b[j];
        }
    }
    clock_t end = clock();

    // Print results
    printf("Compute time: %f\n", ((double)(end - start)) / CLOCKS_PER_SEC);
    for (size_t i = 0; i < 5; i++) {
        printf("rslt[%zu] = %.16f\n", i, rslt[i]);
    }
    printf("...\n");

    // Cleanup
    free(trmult_reduced);
    free(b);

    return 0;
}
