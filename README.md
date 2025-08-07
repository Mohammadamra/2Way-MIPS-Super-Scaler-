#  Two-Way Superscalar Processor in Verilog HDL

**A high-performance MIPS-compatible processor architecture** designed to execute **two instructions per clock cycle** using dual-issue superscalar techniques. This project reimagines the classic five-stage pipeline to achieve near-ideal throughput, advanced dependency handling, and real-world simulation support.

---

## ⚙️ Architecture Overview

This processor extends the traditional five-stage pipeline:

IF → ID → EX → MEM → WB

With major enhancements to support **dual-issue execution**, **hazard resolution**, and **parallelism**, including:

- 🔁 **Dual-Instruction Fetch**  
  Implemented using **dual-port instruction memory** for parallel instruction fetching.

- 🧠 **Advanced Issue Logic**  
  Determines which two instructions can be safely issued and executed together.

- 🧮 **Dual ALUs**  
  Parallel execution paths for arithmetic and logic operations.

- 🔄 **Forwarding & Branch Prediction Units**  
  Reducing stalls, handling control hazards, and maintaining pipeline efficiency.

- 🧷 **Multi-Ported Register File**  
  Supporting multiple read/write accesses per cycle.

---

## 📦 Ecosystem Components

This is not just a core — it’s a complete toolchain.

| Tool | Description |
|------|-------------|
| 🧾 **Custom Assembler** | MIPS-compatible assembler with **dual-issue instruction encoding** support |
| ⚠️ **Exception Handler** | Handles interrupts and faults with robust pipeline management |
| 🐍 **Python-Based Simulator** | A **cycle-accurate simulator** for functional verification and performance profiling |

---

## 📈 Performance Summary

- **CPI ≈ 0.5** in optimal cases
- **CPI ≈ 0.5–0.7** with occasional stalls
- **Benchmark Comparison**:

| Architecture | CPI |
|--------------|-----|
| Single-Cycle | 1.0 |
| 5-Stage Pipeline | 1.16 – 1.34 |
| **This Work** | **0.5 – 0.7** |

✅ Significant reduction in execution time and improved throughput over conventional designs.

---

## ✅ Functional Coverage

Comprehensive testbenches were developed for:

- Register File  
- Issue Logic  
- ALU  
- Pipeline Registers

> Achieved **high coverage**, validating corner cases and ensuring functional correctness across all units.

---
