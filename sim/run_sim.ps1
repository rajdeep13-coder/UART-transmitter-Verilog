param(
    [ValidateSet("main", "rx")]
    [string]$Target = "main",
    [switch]$Wave
)

$ErrorActionPreference = "Stop"

function Assert-Tool([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required tool '$Name' not found on PATH."
    }
}

Assert-Tool "iverilog"
Assert-Tool "vvp"

Push-Location $PSScriptRoot
try {
    if ($Target -eq "main") {
        & iverilog -g2012 -o uart_tb.vvp ../src/uart_tx.v ../src/uart_rx.v ../src/uart_top.v ../test/uart_tb.v
        if ($LASTEXITCODE -ne 0) { throw "iverilog compile failed (main)." }

        & vvp uart_tb.vvp
        if ($LASTEXITCODE -ne 0) { throw "vvp run failed (main)." }

        if ($Wave) {
            $gtkw = Get-Command gtkwave -ErrorAction SilentlyContinue
            if ($gtkw) {
                & gtkwave uart_tb.vcd -S gtkwave.tcl
            } else {
                Write-Warning "GTKWave not found on PATH. Install GTKWave to open waveform GUI."
            }
        }
    }
    else {
        & iverilog -g2012 -o uart_rx_only_tb.vvp ../src/uart_rx.v ../test/uart_rx_only_tb.v
        if ($LASTEXITCODE -ne 0) { throw "iverilog compile failed (rx)." }

        & vvp uart_rx_only_tb.vvp
        if ($LASTEXITCODE -ne 0) { throw "vvp run failed (rx)." }
    }

    Write-Host "Simulation completed successfully." -ForegroundColor Green
}
finally {
    Pop-Location
}
