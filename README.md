2-Way In-Order MIPS Superscalar Processor

This project implements a 2-way in-order MIPS superscalar processor using Verilog, deployed on an Altera MAX-10 FPGA for the Jordan National Semiconductors Competition, where it secured a top 10 position in the finals. The design emphasizes hardware simplicity, offloading complex tasks like instruction scheduling, assembly, and exception handling to software, with a file-based input/output system to manage the toolchain.

Project Overview

The processor is based on the MIPS (Microprocessor without Interlocked Pipeline Stages) architecture, a RISC design known for its simplicity and efficiency. The 2-way superscalar design allows two instructions to be executed per cycle by exploiting Instruction-Level Parallelism (ILP), provided no data or control hazards exist. The hardware is kept minimal to optimize area and power on the Altera MAX-10 FPGA, while software handles scheduling, assembling, and exception management.

Key Features

2-Way Superscalar Execution: Executes up to two instructions per cycle using duplicated datapath components (e.g., ALUs, register ports).

In-Order Execution: Instructions are issued and completed in program order, simplifying hazard detection and resolution.

Hardware Simplicity: Minimal hardware design with a single-cycle MIPS core extended for superscalarity.

Software-Driven Complexity: Instruction scheduling, assembly, and exception handling are managed by external software, interfaced via file I/O.

Altera MAX-10 FPGA: Deployed on a low-cost, low-power FPGA with integrated flash, ideal for competition and educational purposes.

Top 10 in Jordan National Semiconductors Competition: Demonstrates a competitive balance of performance, functionality, and efficiency.

