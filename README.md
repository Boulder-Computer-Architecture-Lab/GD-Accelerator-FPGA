## Overview

This project provides the RTL and software implementations for a PYNQ SoC FPGA matrix-vector multiplication accelerator for the application of a Spatial Integrated Assessment Model (S-IAM).

## Requirements

- Software: Vivado 2023.2, Python 3.10.12
- Hardware: Kria KV260 Vision AI Starter Kit

## Repository Structure

- ``Scripts``: Contains scripts for sending .bit/.hwh (``send_hw_to_board.sh``) and a random input matrix with specified dimensions (``send_matrix_to_board.sh``) to the board. Can also acquire a snapshot of the board relevant files from the board using ``backup_to_host.sh``. Note: the on-board target directory and IP need to be changed if using a different Kria KV260.
- ``Board``: Contains the two most recent snapshots of on-board files including the .bit/.hwh exported from Vivado, and the .ipynb/.py files used to test the hardware design.
- ``Model``: Contains two naive implementations of a MVM in C as a CPU benchmark (one for fp64 and one for fp16). Also contains and full C++ implementation of the original S-IAM.
- ``Vivado``: 
    - ``lib``: Contains Alex Forencich's Verilog-AXI and Verilog-AXIS open-source libraries.
    - ``kria``: 
        - ``bd``: Contains the exported tcl script to generate the block diagram.
        - ``build``: Contains the Vivado project including all generated outputs.
        - ``hdl``: Contains all .v/.sv sources used in the block diagram.
        - ``ip``: Contains .xci files for all IPs instantiated in ``../hdl``.
        - ``scripts``: Contains build script and a Python script for updating the header files when changing the number of input channels (default=4).
        - ``sim``: Contains a .sv testbench for ``mvm_accelerator.v``.

## Build Instructions

From the Tcl Console in Vivado, navigate to the repository's root directory and execute:

```bash
source Vivado/kria/scripts/build.tcl
```

This should create the Vivado project, add sources, generate output products for the IPs, and build the block diagram. The design should then be ready for implementation. 

After making changes to the block diagram, execute the folliwng command from the Tcl Console (while in the root directory of the repository):

```bash
write_bd_tcl -force -include_layout Vivado/kria/bd/design_1.tcl
``` 

Equivalently, use ``Tools > Export Block Design`` and save the Tcl file as ``Vivado/kria/bd/design_1.tcl``. This ensures the changes will be reflected in subsequent builds. 

## Acknowledgments

This project incorporates modules from Alex Forencich’s Verilog-AXI/Verilog-AXIS libraries:
- https://github.com/alexforencich/verilog-axi
- https://github.com/alexforencich/verilog-axis

