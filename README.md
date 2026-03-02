## Overview

This project provides RTL and software implementations for a PYNQ SoC FPGA matrix–vector multiplication (MVM) accelerator used in a Spatial Integrated Assessment Model (S-IAM).

## Requirements

- Software: Vivado 2023.2, Python 3.10.12
- Hardware: Kria KV260 Vision AI Starter Kit

## Quick Start

### Build Project

Open Vivado and execute the following into the Tcl Console:

```bash
source Vivado/kria/scripts/build.tcl
build_project 1
```

Alternatively, from outside Vivado: 

```
vivado -mode batch -source Vivado/kria/scripts/build.tcl -tclargs impl
```

This usually takes about 2 hours.

### Program the Board

- Update the paths in``Scripts/send_hw_to_board.sh`` and run it (from outside of Vivado) to transfer the relevant hardware files to the Kria board.

- Run ``./send_matrix_to_board.sh 4 4272 17088 "fp16"`` to provide an example input.

- ``ssh`` into the board and run the cells in ``sw/test.ipynb``.

## Repository Structure

- ``Scripts/``: Contains utility scripts, including:
    - ``send_hw_to_board.sh``: sends the .bit/.hwh files to the board.
    - ``send_matrix_to_board.sh``: sends a randomly generated input matrix with specified dimensions.
    - ``backup_to_host.sh``: retrieves snapshots of relevant on-board files.
    - ``restore_from_backup.sh``: overwrites the corresponding on-board directories with most recent backup.

_Note: verify and update the target directory and IP address in these scripts as needed._

- ``Board/``: Contains the two most recent snapshots of on-board files, including the exported .bit/.hwh files and the .ipynb/.py scripts used to test the hardware.
- ``Model/``: Contains two naive C implementations of an MVM (fp64 and fp16) for CPU benchmarking, as well as a full C++ implementation of the original S-IAM.
- ``Vivado/``:
    - ``lib/``: Alex Forencich's Verilog-AXI and Verilog-AXIS libraries.
    - ``kria/``:
        - ``bd/``: Tcl script to regenerate the block diagram.
        - ``build/``: Vivado project and all generated outputs.
        - ``hdl/``: All .v/.sv sources used in the block diagram.
        - ``ip/``: .xci files for all instantiated IP cores.
        - ``scripts/``: Build script and Python utilities for updating header files when changing the number of input channels (default = 4).
        - ``sim/``: SystemVerilog testbench for mvm_accelerator.v.

## Build Instructions

Execute the following from the Tcl Console in Vivado:

```bash
source Vivado/kria/scripts/build.tcl
```

This should create the Vivado project, add sources, generate output products for the IPs, and build the block diagram. The design should then be ready for implementation. 

After making changes to the block diagram, execute the following command from the Tcl Console while in the root directory of the repository:

```bash
write_bd_tcl -force -include_layout Vivado/kria/bd/design_1.tcl
``` 

Equivalently, use **Tools > Export Block Design** and save the Tcl file as:

```
Vivado/kria/bd/design_1.tcl
```

This ensures the changes will be reflected in subsequent builds. 

## Acknowledgments

This project incorporates modules from Alex Forencich’s Verilog-AXI/Verilog-AXIS libraries:
- https://github.com/alexforencich/verilog-axi
- https://github.com/alexforencich/verilog-axis

The model implementation is based on the following paper:
- https://www.journals.uchicago.edu/doi/full/10.1086/697084
