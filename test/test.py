# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


# @cocotb.test()
@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 1 ms
    # clock = Clock(dut.clk, 1, units="ms") // USED FOR RTL
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    dut._log.info("TESTING PROJECT BEHAVIOR")

    # Enter TEST MODE so counter uses tile clk: ui_in[7]=1
    # bits: [7]=test_mode, [3:1]=tap, [0]=enable
    dut.ui_in.value = 0b0001_0000  # test_mode=1, tap=0, enable=0
    # await ClockCycles(dut.clk, 1)

    # # Start counting (enable=1)
    # dut.ui_in.value = 0b0001_0001
    # await ClockCycles(dut.clk, 10)

    # # Stop counting
    # dut.ui_in.value = 0b0001_0000
    # await ClockCycles(dut.clk, 1)

    # uo_out[7:1] exposes count[6:0] when enable=0
    observed = (int(dut.uo_out.value) >> 1) & 0x7F
    assert observed == 0, f"expected 0, got {observed}"
