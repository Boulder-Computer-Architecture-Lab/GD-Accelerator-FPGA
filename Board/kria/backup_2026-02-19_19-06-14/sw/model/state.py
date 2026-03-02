from dataclasses import dataclass
import numpy as np
from typing import Any, Optional

@dataclass
class ModelState:
    H0: Any
    a: np.ndarray
    a_norm: Any
    m2: np.ndarray
    C_vect: np.ndarray
    tau0: np.ndarray
    pop0: np.ndarray
    pop5: np.ndarray
    pop5_fertadj: np.ndarray
    popminus5: np.ndarray
    popminus10: np.ndarray
    ubar: np.ndarray
    trmult_reduced: Any
    n: int
    earth_indices: np.ndarray
    indicator_sea: Any
    subs: np.ndarray
    subs_vect: Any
    beta: float
    tail_bands: float
    ind_islands: Any
    alpha: float
    theta: float
    Omega: float
    kernel: Optional[Any] = None
    Npad: Optional[int] = None

    def mvm(self, x: np.ndarray) -> np.ndarray:
        if self.kernel is None:
            return self.trmult_reduced @ x

        # downcast to fp32 for DMA
        x32 = np.asarray(x, dtype=np.float32)

        N = x32.shape[0]
        Npad = self.Npad

        # Pack x into partitioned CMA buffer (shape (P, EPP))
        vbuf = self.kernel.vector 
        flat = vbuf.reshape(-1)

        flat.fill(np.float32(0))
        flat[:N] = x32

        print(vbuf)

        # Program BRAM vector partitions via CDMA
        self.kernel.send_vector(vbuf)

        # Run matrix stream DMAs and get output (kernel returns padded length)
        y = self.kernel.matvec()
        y = y.reshape(-1)

        return y[:N].astype(np.float32, copy=True)

