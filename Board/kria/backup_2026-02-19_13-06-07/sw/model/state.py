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

        # downcast to fp16 for DMA
        x = np.asarray(x, dtype=np.float32)
        x16 = x.astype(np.float16, copy=False)

        # vector padding
        if self.Npad is not None:
            buf = self.kernel.get_inbuf(self.Npad)  # returns CMA buffer (float16)
            buf[:] = 0
            buf[:x16.shape[0]] = x16
            y = self.kernel.matvec(buf)
            return y[:x16.shape[0]]
        else:
            return self.kernel.matvec(x16)

