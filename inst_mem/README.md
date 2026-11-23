# Instruction Memory (`instruct_mem`)

## Overview
Instruction Memory provides combinational read access to 32-bit RISC-V instructions using word-aligned addressing. Because RISC-V instructions are 32 bits (4 bytes) wide and aligned to 4-byte boundaries, the lower two address bits (`addr[1:0]`) are ignored when indexing words.

## Ports & Parameters
| Direction | Signal / Param | Width / Type | Description |
| :--- | :--- | :--- | :--- |
| `parameter` | `DEPTH` | `int = 256` | Number of 32-bit instruction words |
| `parameter` | `MEM_FILE` | `string = ""` | Optional hex file loaded via `$readmemh` |
| `input` | `addr` | `logic [31:0]` | Byte address from the Program Counter (`pc`) |
| `output` | `instr` | `logic [31:0]` | Fetched 32-bit RISC-V instruction |

## Behavior & Edge Cases
* **Default NOP Fill:** Unused memory locations are initialized to `32'h0000_0013` (`addi x0, x0, 0`), preventing `X` propagation if execution runs past loaded instructions.
* **Hex Program Loading:** If `MEM_FILE` is non-empty, instructions are loaded at simulation start using `$readmemh`.
* **Word Indexing:** Uses `addr[ADDR_BITS+1:2]` so byte addresses `0x00, 0x04, 0x08, ...` map to word indices `0, 1, 2, ...`.

## CI (`rnr-stage.yaml`) Integration
* Add `instruct_mem` (or `instruction_memory`) under `modules:` pointing to its `.sv` file.
* Also list it under `modules:` for any parent stage or top module (`IF_Stage` / `Single_Cycle_RISCV`) that instantiates it.
