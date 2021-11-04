import os
import random

import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import RisingEdge, FallingEdge

import pytest
from cocotb_test.simulator import run


from fxpmath import Fxp

# @pytest.fixture
# def dut():
#   return []

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))

class TB(object):
  def __init__(self, dut) -> None:
    self.dut = dut
    self.dut.arst_n.value = 1
    self.dut.ce.value     = 0
    self.dut.sload.value  = 1
    self.dut.A.value      = 0
    self.dut.B.value      = 0
    cocotb.fork(Clock(self.dut.clk, 10, units="ns").start())

  def __get_sample(self, n, f) -> int:
    num = Fxp(val=(-1)**(random.randint(0, 1))*(random.random()), signed=1, n_word=n, n_frac=f)
    snum = num.base_repr(2)
    inum = int(snum, 2)
    return inum

  async def generate_stream(self, iter, n_word, n_frac) -> None:
    await FallingEdge(self.dut.clk)
    self.dut.ce.value = 1
    self.dut.sload.value = 0
    for i in range(iter):
      self.dut.A.value = self.__get_sample(n_word, n_frac)
      self.dut.B.value = self.__get_sample(n_word, n_frac)
      await FallingEdge(self.dut.clk)
    # self.dut.ce.value = 0
    self.dut.A.value = self.dut.B.value = 0
    self.dut.sload.value = 1
    await FallingEdge(self.dut.clk)

  async def reset(self) -> None:
    self.dut.arst_n.setimmediatevalue(1)
    await Timer(3, units='ns')
    self.dut.arst_n.value = 0
    await Timer(6, units='ns')
    self.dut.arst_n.value = 1

@cocotb.test()
async def mac_test(dut):
#   cocotb.fork(Clock(dut.clk, 5, units='ns').start())
  tb = TB(dut)
  # N = int(os.environ.get("N", "8"))
  N = len(dut.A)

  await tb.reset()

  await tb.generate_stream(iter=5, n_word=N, n_frac=N-1)
  await tb.generate_stream(iter=5, n_word=N, n_frac=N-1)

  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

# factory = TestFactory(test_mac)
# factory.generate_tests()



@pytest.mark.parametrize(
  "n_width", ["8", "16", "32", "64"]
)
def test_start(n_width):
  verilog_sources=[os.path.join(rtl_dir, "mac.v")]
  module = "test_mac"
  toplevel = "mac"
  parameters = {}
  # global N
  # N = int(n_width)
  parameters['N'] = n_width
  sim_build = os.path.join(tests_dir, "sim_build") + "_" + "_".join(("{}={}".format(*i) for i in parameters.items()))
  run(
    compile_args = ["-g2005"],
    plus_args = ["-fst"],
    verilog_sources=verilog_sources,
    toplevel=toplevel,
    module=module,
    parameters=parameters,
    sim_build=sim_build
  )

if __name__ == '__main__':
  test_start()