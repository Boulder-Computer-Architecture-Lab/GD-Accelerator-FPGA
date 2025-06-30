#include "loop_uhatfn.h"
#include <math.h>

#define NPOSLAND 17048 // Number of cells with positive land
#define IPOSLAND(i, j) ((i) * NPOSLAND + (j)) // location i-location j cost: col_idx * NROWS + row_idx

void loop_uhat(const real tol, const real *trmult_reduced, const real *L, const real L_exp,
               real *uhat_i, const real *R, const real R_exp)
/*
input:
- tol: level of tolerance, scalar, real
- trmult_reduced: 17048x17048, real
- L, R: 17048x1, real
- L_exp, R_exp: scalar
output:
- uhat_i: 17048x1, real
*/
{
    // HLS Interface Configuration for Memory Mapping
    #pragma HLS INTERFACE m_axi port=trmult_reduced 	offset=slave	bundle=gmem0	depth=17048*17048
    #pragma HLS INTERFACE m_axi port=L 					offset=slave 	bundle=gmem1	depth=17048
    #pragma HLS INTERFACE m_axi port=uhat_i 			offset=slave 	bundle=gmem2	depth=17048
    #pragma HLS INTERFACE m_axi port=R 					offset=slave 	bundle=gmem3	depth=17048

    // Control Interface Configuration
    #pragma HLS INTERFACE s_axilite port=tol bundle=control
    #pragma HLS INTERFACE s_axilite port=L_exp bundle=control
    #pragma HLS INTERFACE s_axilite port=R_exp bundle=control
    #pragma HLS INTERFACE s_axilite port=return bundle=control

    real integral[NPOSLAND];  // Stores intermediate computed values
    real uhat_local[NPOSLAND]; // Local buffer to avoid memory clobbering issues

    // Copy input uhat_i values to a local buffer to avoid direct memory accesses
    for (int i = 0; i < NPOSLAND; i++) {
        #pragma HLS PIPELINE
        uhat_local[i] = uhat_i[i];
    }

    real error = tol + 1.; // Initialize error larger than tolerance
    int iter = 0;

    while (error >= tol) { // Iterative process until convergence
        // Compute accuracy and update the guess
        for (int i = 0; i < NPOSLAND; i++) {
            #pragma HLS PIPELINE
            integral[i] = R[i] * pow(uhat_local[i], R_exp); // Compute integral term
        }

        error = 0; // Reset error for each iteration

        for (int i = 0; i < NPOSLAND; i++) {
            real rhs = 0;

            // Compute the right-hand side summation term
            for (int j = 0; j < NPOSLAND; j++) {
                #pragma HLS PIPELINE
                rhs += trmult_reduced[IPOSLAND(i, j)] * integral[j];
            }

            // Compute the updated estimate
            real uhat_f = L[i] * pow(rhs, L_exp);
            real deviation = (uhat_local[i] - uhat_f);
            error += deviation * deviation; // Compute squared error

            // Store updated values in local buffer
            uhat_local[i] = uhat_f;
        }

        iter++; // Increment iteration counter

        #ifdef DEBUG_MODE_ERROR_UHAT
        printf("iter %d error_uhat: %.16lf\n", iter, error);
        #endif
    } // end while

    // Copy computed results back to uhat_i
    for (int i = 0; i < NPOSLAND; i++) {
        #pragma HLS PIPELINE
        uhat_i[i] = uhat_local[i];
    }

    #ifdef DEBUG_MODE_ERROR_UHAT
    printf("Final error_uhat: %.16lf\n", error);
    #endif
}
