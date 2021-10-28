import logging
import os
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

import pytest
import cocotb_test
from cocotb_test.simulator import run


from fxpmath import Fxp

# @pytest.fixture
# def dut():
#   return []

class TB(object):
  def __init__(self, dut) -> None:
    self.dut = dut
    self.dut.arst_n.value = 1
    self.dut.ce.value     = 0
    self.dut.sload.value  = 0
    self.dut.A.value      = 0
    self.dut.B.value      = 0
    self.log = logging.getLogger("cocotb.tb")
    self.log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk, 10, units="ns").start())

  def __get_sample(n_word=32, n_frac=31) -> int:
    num = Fxp(val=(-1)**(random.randint(0, 1))*(random.random()), signed=1, n_word=n_word, n_frac=n_frac)
    snum = num.base_repr(2)
    inum = int(snum, 2)
    return inum

  async def generate_stream(self, iter, n_word, n_frac) -> None:
    self.dut.ce <= 1
    for i in range(iter):
      self.dut.A = self.__get_sample(n_word=n_word, n_frac=n_frac)
      self.dut.B = self.__get_sample(n_word=n_word, n_frac=n_frac)
      await RisingEdge(self.dut.clk)
    self.dut.ce <= 0

  async def reset(self) -> None:
    self.dut.arst_n.setimmediatevalue(1)
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)
    self.dut.arst_n <= 0
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)
    self.dut.arst_n <= 1
    await RisingEdge(self.dut.clk)
    await RisingEdge(self.dut.clk)


@cocotb.test()
async def test_mac(dut):
  tb = TB(dut)

  await tb.reset()

  for i in range(10):
    await tb.generate_stream()

  await RisingEdge(dut.clk)
  await RisingEdge(dut.clk)

# factory = TestFactory(test_mac)
# factory.generate_tests()


tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))

@pytest.mark.parametrize("n_frac", [8, 16, 32])
def start_test(n_frac):
  dut = "mac"
  module = os.path.splitext(os.path.basename(__file__))[0]
  toplevel = dut
  verilog_sources = [
      os.path.join(rtl_dir, f"{dut}.v"),
  ]
  parameters = {}
  parameters['N'] = n_frac
  sim_build = os.path.join(tests_dir, "sim_build")
  run(
    python_search=[tests_dir],
    verilog_sources=verilog_sources,
    toplevel=toplevel,
    module=module,
    parameters=parameters,
    sim_build=sim_build
  )

  