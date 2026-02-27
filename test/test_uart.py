import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

async def reset_dut(dut):
    """Reset the DUT."""
    dut.rst_n.value = 0
    dut.rx_serial.value = 1 # Idle state for UART
    dut.tx_start.value = 0
    dut.tx_data.value = 0
    dut.parity_en.value = 0
    dut.parity_odd.value = 0
    
    for _ in range(5):
        await RisingEdge(dut.clk)
        
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

@cocotb.test()
async def test_uart_loopback(dut):
    """Test UART TX to RX loopback with random data."""
    
    # Start a 50MHz clock (20ns period)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_dut(dut)
    
    # Connect TX to RX for loopback testing
    # We'll use a background coroutine to continuously forward tx_serial to rx_serial
    async def loopback():
        while True:
            await RisingEdge(dut.clk)
            dut.rx_serial.value = dut.tx_serial.value
            
    cocotb.start_soon(loopback())
    
    # Test parameters
    num_tests = 20
    
    for i in range(num_tests):
        # Generate random byte
        test_byte = random.randint(0, 255)
        
        # Wait until TX is not busy
        while dut.tx_busy.value == 1:
            await RisingEdge(dut.clk)
            
        # Start transmission
        dut.tx_data.value = test_byte
        dut.tx_start.value = 1
        await RisingEdge(dut.clk)
        dut.tx_start.value = 0
        
        dut._log.info(f"Sending byte: {hex(test_byte)}")
        
        # Wait for RX valid
        timeout_cycles = 0
        max_timeout = 50000 # Prevent infinite loop
        
        while dut.rx_valid.value == 0:
            await RisingEdge(dut.clk)
            timeout_cycles += 1
            if timeout_cycles > max_timeout:
                assert False, "Timeout waiting for rx_valid"
                
        # Check received data
        received_byte = int(dut.rx_data.value)
        dut._log.info(f"Received byte: {hex(received_byte)}")
        
        assert received_byte == test_byte, f"Data mismatch! Sent: {hex(test_byte)}, Received: {hex(received_byte)}"
        assert dut.framing_error.value == 0, "Framing error detected!"
        assert dut.parity_error.value == 0, "Parity error detected!"
        
        # Wait a bit before next transmission
        for _ in range(100):
            await RisingEdge(dut.clk)

    dut._log.info("Loopback test completed successfully!")

@cocotb.test()
async def test_uart_parity(dut):
    """Test UART with parity enabled."""
    
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_dut(dut)
    
    # Enable parity (Even parity)
    dut.parity_en.value = 1
    dut.parity_odd.value = 0
    
    async def loopback():
        while True:
            await RisingEdge(dut.clk)
            dut.rx_serial.value = dut.tx_serial.value
            
    cocotb.start_soon(loopback())
    
    test_byte = 0x55 # 01010101 (4 ones -> even parity bit should be 0)
    
    dut.tx_data.value = test_byte
    dut.tx_start.value = 1
    await RisingEdge(dut.clk)
    dut.tx_start.value = 0
    
    while dut.rx_valid.value == 0:
        await RisingEdge(dut.clk)
        
    assert int(dut.rx_data.value) == test_byte
    assert dut.parity_error.value == 0, "Unexpected parity error!"
    
    dut._log.info("Parity test completed successfully!")
