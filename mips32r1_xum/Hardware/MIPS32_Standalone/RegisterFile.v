`timescale 1ns / 1ps
/*
 * File         : RegisterFile.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   7-Jun-2011   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A Register File for a MIPS processor. Contains 32 general-purpose
 *   32-bit wide registers and two read ports. Register 0 always reads
 *   as zero.
 */
 
`ifndef DEBUG_CPU_REG
`define DEBUG_CPU_REG 0
`endif
 
module RegisterFile(
    input  clock,
    input  reset,
    input  [4:0]  ReadReg1, ReadReg2, WriteReg,
    input  [31:0] WriteData,
    input  RegWrite,
    output [31:0] ReadData1, ReadData2
    );

    // Register file of 32 32-bit registers. Register 0 is hardwired to 0s
    reg [31:0] registers [1:31];
	////TH
	initial begin
		if (`DEBUG_CPU_REG) begin
			$display("Time     $v0,      $v1,      $t0,      $t1,      $t2,      $t3,      $t4,      $t5,      $t6,      $t7");
			$monitor("%d ns, %x, %x, %x, %x, %x, %x, %x, %x, %x, %x",$time,
					registers[2][31:0],	/* $v0 */
					registers[3][31:0],	/* $v1 */
					registers[8][31:0],	/* $t0 */
					registers[9][31:0],	/* $t1 */
					registers[10][31:0],	/* $t2 */
					registers[11][31:0],	/* $t3 */
					registers[12][31:0],	/* $t4 */
					registers[13][31:0],	/* $t5 */
					registers[14][31:0],	/* $t6 */
					registers[15][31:0],	/* $t7 */
				);
		end
	end
	////TH
    // Initialize all to zero
    integer i;
    initial begin
        for (i=1; i<32; i=i+1) begin
            registers[i] <= 0;
        end
    end

    // Sequential (clocked) write.
    // 'WriteReg' is the register index to write. 'RegWrite' is the command.
    always @(posedge clock) begin
        if (reset) begin
            for (i=1; i<32; i=i+1) begin
                registers[i] <= 0;
            end
        end
        else begin
            if (WriteReg != 0)
                registers[WriteReg] <= (RegWrite) ? WriteData : registers[WriteReg];
        end
    end

    // Combinatorial Read. Register 0 is all 0s.
    assign ReadData1 = (ReadReg1 == 0) ? 32'h00000000 : registers[ReadReg1];
    assign ReadData2 = (ReadReg2 == 0) ? 32'h00000000 : registers[ReadReg2];

endmodule

