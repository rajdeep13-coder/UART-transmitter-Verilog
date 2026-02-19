#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

TARGET="main"
WAVE=0

while [[ $# -gt 0 ]]; do
	case "$1" in
		--target)
			TARGET="$2"
			shift 2
			;;
		--wave)
			WAVE=1
			shift
			;;
		*)
			echo "Unknown option: $1"
			echo "Usage: ./run_sim.sh [--target main|rx] [--wave]"
			exit 1
			;;
	esac
done

case "$TARGET" in
	main)
		make clean
		make run
		if [[ $WAVE -eq 1 ]]; then
			if command -v gtkwave >/dev/null 2>&1; then
				gtkwave uart_tb.vcd -S gtkwave.tcl
			else
				echo "GTKWave not found on PATH; skipping waveform viewer."
			fi
		fi
		;;
	rx)
		make clean
		make run-rx
		;;
	*)
		echo "Invalid target: $TARGET"
		echo "Valid targets: main, rx"
		exit 1
		;;
esac

echo "Simulation completed successfully."
