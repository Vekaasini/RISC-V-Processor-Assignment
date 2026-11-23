# Data Memory (`data_mem`)

## Overview
Data Memory handles data reads and writes for load and store instructions. Writes occur synchronously on `posedge clk` when `mem_write` is asserted, while reads are combinational when `mem_read` is asserted, supporting byte (`8-bit`), half-word (`16-bit`), and word (`32-bit`) accesses selected by `funct3` and `addr[1:0]`.

## Ports & Parameters
| Direction | Signal / Param | Width / Type | Description |
| :--- | :--- | :--- | :--- |
| `parameter` | `DEPTH` | `int = 256` | Number of 32-bit memory words |
| `input` | `clk` | `logic` | System clock |
| `input` | `mem_write` | `logic` | Enables synchronous write on rising clock edge |
| `input` | `mem_read` | `logic` | Enables read output (`0` outputs `32'b0`) |
| `input` | `funct3` | `logic [2:0]` | Access width and sign mode (see table below) |
| `input` | `addr` | `logic [31:0]` | Byte address (typically ALU result) |
| `input` | `write_data` | `logic [31:0]` | Store data (typically `rs2` value) |
| `output` | `read_data` | `logic [31:0]` | Loaded data (sign- or zero-extended as required) |

## Supported `funct3` Encodings
| `funct3` | Load Instruction | Store Instruction | Width & Extension |
| :--- | :--- | :--- | :--- |
| `3'b000` | `LB` | `SB` | 8-bit byte (sign-extended on load) |
| `3'b001` | `LH` | `SH` | 16-bit half-word (sign-extended on load) |
| `3'b010` | `LW` | `SW` | 32-bit word |
| `3'b100` | `LBU` | — | 8-bit byte (zero-extended) |
| `3'b101` | `LHU` | — | 16-bit half-word (zero-extended) |

## Behavior & Edge Cases
* **Byte & Half-Word Alignment:** `addr[1:0]` selects the byte lane (`0..3`) for `SB`/`LB`/`LBU` and lower/upper half-word (`addr[1] == 0` vs. `1`) for `SH`/`LH`/`LHU`.
* **Read Gating:** When `mem_read == 0`, `read_data` drives `32'b0` to avoid stale/unintended values downstream in `WB_Stage`.

## CI (`rnr-stage.yaml`) Integration
* Add `data_mem` (or `data_memory`) under `modules:` pointing to its `.sv` file.
* Also list it under `modules:` for any parent stage or top module (`EX_Stage` / `WB_Stage` / `Single_Cycle_RISCV`) that instantiates it.
