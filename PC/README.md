# Program Counter (`PC`)

## Overview
The Program Counter stores the 32-bit address of the instruction currently being fetched. On a rising clock edge, it updates to `next_pc` (typically `pc + 4` for sequential instructions or a branch/jump target address), and resets to `RESET_ADDR` (`32'h0000_0000`) when reset is asserted.

## Ports & Parameters
| Direction | Signal / Param | Width / Type | Description |
| :--- | :--- | :--- | :--- |
| `parameter` | `WIDTH` | `int = 32` | Address bus width in bits |
| `parameter` | `RESET_ADDR` | `logic [31:0] = '0` | Reset entry address |
| `input` | `clk` | `logic` | System clock |
| `input` | `rst_n` | `logic` | Active-low reset (`0` resets `pc` to `RESET_ADDR`) |
| `input` | `pc_en` | `logic` | Write enable (`1` updates `pc`; tie to `1'b1` for single-cycle) |
| `input` | `next_pc` | `logic [31:0]` | Next instruction address from `IF_Stage` / branch/jump mux |
| `output` | `pc` | `logic [31:0]` | Current program counter value |

## Behavior & Edge Cases
* **Reset:** When `rst_n == 0`, `pc` returns to `RESET_ADDR` (`0x00000000`).
* **Hold vs. Advance:** When `pc_en == 0`, `pc` holds its current value; when `pc_en == 1`, `pc <= next_pc` on `posedge clk`.

## CI (`rnr-stage.yaml`) Integration
* Add `pc` under `modules:` pointing to `PC/rtl.sv`.
* Also list `pc` under `modules:` for any parent stage or top module (`IF_Stage` / `Single_Cycle_RISCV`) that instantiates it.
