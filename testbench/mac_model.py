from typing import overload
import fxpmath
from fxpmath import Fxp

import random
import bitarray
from bitarray import bitarray as bits


# def get_sample(self, n, f):
#   num = Fxp(val=(-1)**(random.randint(0, 1))*(random.random()), signed=1, n_word=n, n_frac=f)
#   snum = num.base_repr(2)
#   inum = int(snum, 2)
#   return inum


class MACModel():
  def __init__(self, N, Q) -> None:
    self.N = N
    self.Q = Q
    self.__DATA = Fxp(None, True, self.N, self.Q)
    self.__MULT = Fxp(None, True, 2*self.N, 2*self.Q)
    # self.__ACCUM = Fxp(None, True, 2*self.N, 2*self.Q)
    self.a, self.b = Fxp().like(self.__DATA), Fxp().like(self.__DATA)
    self.c = Fxp().like(self.__MULT)
    self.ac = Fxp(0.0).like(self.__MULT)
    
  def acc(self, a_val, b_val) -> None:
    self.a = Fxp(a_val).like(self.__DATA)
    self.b = Fxp(b_val).like(self.__DATA)
    self.c.equal(self.a * self.b)
    self.ac.equal(self.ac + self.c)

  def get_result(self) -> Fxp:
    magic_round = Fxp(1/(2**(self.Q)) - 1/(2**(self.__MULT.n_frac))).like(self.__MULT)
    temp_result = Fxp().like(self.__MULT)
    # print(self.ac.bin(frac_dot=True))
    temp_result.equal(self.ac)
    temp_result.equal(temp_result >> self.Q)
    temp_result.equal(temp_result + 1/(2**(self.Q+1)))
    # print(temp_result.bin(frac_dot=True))
    # print(self.__get_vector().bin(frac_dot=True))
    # self.ac.equal(self.ac & self.__get_vector())
    # print(self.ac.bin(frac_dot=True))
    self.ac.equal(self.ac & magic_round)
    # print(self.ac.bin(frac_dot=True))
    # print(magic_round.bin(frac_dot=True))
    result = Fxp().like(self.__DATA)
    result.equal(temp_result)
    # print(result.bin(frac_dot=True))
    return result
    


def class_random_test():
  N = int(input("Word length: "))
  Q = int(input("Fractional part length: "))
  if N < Q:
    print(
      "Incorrect Fractional part length\n"
      "\tFractional part length should not be grater than word length\n\n"
      "Exit...."
    )
    exit()
  length = int(input("Pipeline length: "))
  unit = MACModel(N, Q)
  for i in range(length):
    a, b = random.uniform(-(N-Q), (N-Q)), random.uniform(-(N-Q), (N-Q))
    unit.acc(a, b)
  result = unit.get_result().get_val()
  print(result)

if __name__ == '__main__':
  class_random_test()
