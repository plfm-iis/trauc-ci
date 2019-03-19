# Str-solver CI scripts

## Installation
Run `scripts/setup.sh` to build docker for Z3Prover/Z3, CVC4 and Trau.

## Usage
For **CVC4**, **z3seq**, **z3str**, and **trau**,
we won't rebuild them unless specified.   
Use `scripts/run_as_cron.sh` to run benchmarks.

For others that requires rebuild everytime, 
use `scripts/run_z3_branch_as_cron.sh`
