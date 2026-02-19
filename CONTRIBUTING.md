# Contributing

Thanks for contributing to UART-Tx.

## Development Workflow

1. Fork and create a feature branch.
2. Keep changes focused and small.
3. Run simulation before opening a PR.
4. Update docs when behavior or interfaces change.

## Local Validation

### PowerShell (Windows)

```powershell
Set-Location sim
.\run_sim.ps1 -Target main
.\run_sim.ps1 -Target rx
```

### Linux/macOS

```bash
cd sim
./run_sim.sh --target main
./run_sim.sh --target rx
```

## Coding Guidelines

- Keep module interfaces explicit and stable.
- Prefer parameterized values over hardcoded timing constants.
- Avoid unrelated refactors in functional fix PRs.
- Preserve existing naming conventions where possible.

## Commit & PR Notes

- Use clear commit messages (e.g. `fix(rx): correct parity sampling in stop state`).
- Include a short test summary in PR description.
- Attach waveform screenshots only when they add debugging context.
