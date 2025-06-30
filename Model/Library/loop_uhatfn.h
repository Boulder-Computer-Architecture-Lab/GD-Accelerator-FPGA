#include <math.h>

typedef double real;

void loop_uhat(const real tol,const real *trmult_reduced,const real *L,const real L_exp,
    real *uhat_i,const real *R,const real R_exp);