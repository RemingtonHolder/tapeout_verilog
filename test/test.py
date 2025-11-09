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
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    # dut.ui_in.value = 15
    dut.ui_in.value = 1

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # Set the input values you want to test
    # dut.ui_in.value = 14
    dut.ui_in.value = 0

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uio_out.value == 55

    # await ClockCycles(dut.clk, 1)

    # # Set the input values you want to test
    # dut.ui_in.value = 15

    # # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)

    # # Set the input values you want to test
    # dut.ui_in.value = 14

    # # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)

    # # The following assersion is just an example of how to check the output values.
    # # Change it to match the actual expected output of your module:
    # assert dut.uio_out.value == 55

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
