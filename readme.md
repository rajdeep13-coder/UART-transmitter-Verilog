# UART-Tx (Verilog UART TX/RX)

[![Domain](https://img.shields.io/badge/Domain-VLSI-blueviolet.svg)](#)
[![HDL](https://img.shields.io/badge/HDL-Verilog-blue.svg)](#)
[![Simulation CI](https://github.com/<owner>/<repo>/actions/workflows/sim-ci.yml/badge.svg)](https://github.com/<owner>/<repo>/actions/workflows/sim-ci.yml)

Compact UART transmitter/receiver RTL with parity support, loopback simulation, and FPGA project scaffolding for Vivado/Quartus flows.

## Project Summary

This project implements a reusable UART (Universal Asynchronous Receiver/Transmitter) communication core in Verilog, including both transmit (TX) and receive (RX) paths. It converts parallel bytes to serial UART frames and reconstructs received serial frames back into bytes, with optional parity checking and framing/parity error reporting.

It is useful for:

- Learning digital communication protocol design in RTL
- Integrating serial debug/command interfaces in FPGA projects
- Serving as a clean reference design for UART timing, framing, and verification flow

Core functions provided:

- UART byte transmission with configurable baud and oversampling
- UART byte reception with start-bit validation and error flags
- Loopback testbench and script-based simulation workflow for quick validation

## Features

- Configurable `CLK_FREQ_HZ`, `BAUD_RATE`, and `OVERSAMPLE` (default `16`)
- TX frame: `start(0)` + `8 data bits (LSB first)` + `optional parity` + `stop(1)`
- RX start-bit validation and mid-bit sampling using oversample ticks
- RX status outputs: `rx_valid`, `parity_error`, `framing_error`
- Ready-to-run simulation flow for Windows PowerShell and Linux/macOS shell

## Repository Layout

```
UART-Tx/
├── src/                 # RTL: uart_tx, uart_rx, uart_top
├── test/                # Testbenches
├── sim/                 # Icarus + GTKWave scripts/Makefile
├── constraints/         # Basys3 / Arty A7 XDC templates
├── fpga/                # Placeholder project directories
├── docs/                # Diagrams and report assets
├── .gitignore
├── LICENSE
└── readme.md
```

## Prerequisites

- Icarus Verilog (`iverilog`, `vvp`)
- GTKWave (optional, for waveform viewing)

### Windows install (Chocolatey)

```powershell
choco install iverilog gtkwave -y
```

### Icarus install troubleshooting (Windows)

If `iverilog` is still not found after install:

1. Open PowerShell **as Administrator**.
2. Clear possible Chocolatey lock files:

```powershell
Remove-Item "C:\ProgramData\chocolatey\lib\*.lock" -Force -ErrorAction SilentlyContinue
```

3. Re-run install:

```powershell
choco install iverilog -y
```

4. Open a **new** terminal and verify:

```powershell
iverilog -V
vvp -V
```

If local install remains blocked, push the repo and use GitHub Actions CI (included in this project) to validate simulation in the cloud.

## Quick Start

### Option A: PowerShell (Windows)

```powershell
Set-Location sim
.\run_sim.ps1 -Target main
```

Run RX-only test:

```powershell
Set-Location sim
.\run_sim.ps1 -Target rx
```

Run with waveform viewer:

```powershell
Set-Location sim
.\run_sim.ps1 -Target main -Wave
```

### Option B: Make (Linux/macOS)

```bash
cd sim
make run
```

Open waveform:

```bash
cd sim
make wave
```

## UART Timing Notes

- `OVERSAMPLE=16` means one UART bit spans 16 oversample ticks.
- TX advances to the next bit every 16 ticks.
- RX validates start at `OVERSAMPLE/2`, then samples each bit every 16 ticks.

## FPGA Bring-Up Notes

- Update the placeholders in `constraints/basys3.xdc` or `constraints/arty_a7.xdc`.
- Match `clk` constraint period to your board clock source.
- Keep top-level UART I/O names aligned with `uart_top.v` or your board wrapper.

## Development Notes

- RTL and testbenches are written in Verilog-2001 style and compile with `iverilog -g2012`.
- Generated simulation artifacts (`*.vvp`, `*.vcd`) are ignored by Git.
- See `CONTRIBUTING.md` for recommended contribution workflow.

## License

This project is licensed under the MIT License. See `LICENSE`.
