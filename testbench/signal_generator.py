from fxpmath import Fxp
import numpy as np
from numpy.random import uniform
from numpy import ndarray

import scipy
from scipy import signal

from control import db2mag, mag2db


class FIR():
  pass


class SigGen():
  def __init__(self,N,Q,type="random",Fs=None,) -> None:
    self.N = N
    self.Q = Q
    self.__DATA = Fxp(None, True, self.N, self.Q)
    pass

  def randomGen(self) -> ndarray(shape=(1,2)):
    collect = Fxp(uniform(low=-(self.N-self.Q+1), high=(self.N-self.Q+1), size=(1,2))).like(self.__DATA)
    return collect

  def __synthFIR(self) -> ndarray:
    taps = 32
    bands = np.array([0., .22, .28, .5])
    coeff = signal.remez(taps+1, bands, [1,0], [1,1])
    return coeff

  def __generateSignal(self) -> ndarray:
    pass

  