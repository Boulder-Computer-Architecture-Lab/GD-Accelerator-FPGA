from dataclasses import dataclass
import numpy as np
from typing import Any

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

