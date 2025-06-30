#include <math.h>
#include <assert.h>
#include <stdio.h>

typedef double real;

#ifdef __cplusplus
extern "C" {
#endif

void loop_uhatfn_Row(const int row_idx, const real tol, real *trmult_reduced, const real *L, const real L_exp,
    real *uhat_i, const real *R, const real R_exp, real *row_error);

#ifdef __cplusplus
}
#endif
