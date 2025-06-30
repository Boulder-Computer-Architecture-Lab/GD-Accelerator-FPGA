#include "loop_uhatfn_Row.h"
#include <math.h>

#define NPOSLAND 17048 // Number of cells with positive land

void loop_uhatfn_Row(const int row_idx, const real tol, real *trmult_reduced, const real *L, const real L_exp,
                   real *uhat_i, const real *R, const real R_exp, real *row_error)
/*
input:
- row_idx: index of the row to process
- tol: level of tolerance, scalar, real
- trmult_reduced: 17048 elements, real
- L, R: 17048x1, real
- L_exp, R_exp: scalar
output:
- uhat_i: 17048x1, real
- row_error: scalar, real (error contribution per row)
*/
{
    // m_axi ports for large arrays
    #pragma HLS INTERFACE m_axi port=trmult_reduced offset=slave bundle=gmem0 depth=17048
    #pragma HLS INTERFACE m_axi port=L offset=slave bundle=gmem1 depth=17048
    #pragma HLS INTERFACE m_axi port=uhat_i offset=slave bundle=gmem2 depth=17048
    #pragma HLS INTERFACE m_axi port=R offset=slave bundle=gmem3 depth=17048

    // s_axilite ports for scalars and SoC control
    #pragma HLS INTERFACE s_axilite port=row_idx bundle=control
    #pragma HLS INTERFACE s_axilite port=tol bundle=control
    #pragma HLS INTERFACE s_axilite port=L_exp bundle=control
    #pragma HLS INTERFACE s_axilite port=R_exp bundle=control
    #pragma HLS INTERFACE s_axilite port=row_error bundle=control
	#pragma HLS INTERFACE s_axilite port=return bundle=control

    real integral[NPOSLAND];
    real rhs = 0;
    real deviation = 0;
    *row_error = 0;

    // Compute integral[] inside FPGA
    for (int j = 0; j < NPOSLAND; j++) {
        #pragma HLS PIPELINE
        integral[j] = R[j] * pow(uhat_i[j], R_exp); // Compute integral
    }

    // Compute row-wise sum
    for (int j = 0; j < NPOSLAND; j++) {
        #pragma HLS PIPELINE
        rhs += trmult_reduced[j] * integral[j];
    }

    // Compute the updated estimate
    real uhat_f = L[row_idx] * pow(rhs, L_exp);
    deviation = (uhat_i[row_idx] - uhat_f);
    
    // Store updated value in output buffer
    uhat_i[row_idx] = uhat_f;

    // Computer row squared error
    *row_error = deviation * deviation;

    //printf("Row Error: %f\n", *row_error);
}
