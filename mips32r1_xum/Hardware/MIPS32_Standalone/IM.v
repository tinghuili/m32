`timescale 1ns / 1ps
/*
 * File         : IM.v
 ** Instruction Memory Interface
    input  [31:0] InstMem_In,
    output [29:0] InstMem_Address,      // Addresses are words, not bytes.
    input  InstMem_Ready,
    output InstMem_Read,
    output [7:0] IP                     // Pending interrupts (diagnostic)
 */
module IM(
    input  clock,
    output  [31:0] InstMem_Out,
    input [29:0] InstMem_Address,      // Addresses are words, not bytes.
    output reg InstMem_Ready,
    input InstMem_Read
    //input [7:0] IP                     // Pending interrupts (diagnostic)
    );

	parameter NMEM = 512;   // Number of memory entries,
							// not the same as the memory size
	parameter IM_DATA = "im_data.txt";  // file to read data from

	reg [31:0] mem [0:511];  // 32-bit memory with 128 entries

	initial begin
		$readmemh(IM_DATA, mem, 0, NMEM-1);
	end
	
	// ACK
	always @(posedge clock) begin
		if (InstMem_Read) begin
			InstMem_Ready <= 1'b1;
		end
		else begin
			InstMem_Ready <= 1'b0;
		end
	end

	assign InstMem_Out = mem[InstMem_Address[8:0]]; //#(1) 
	//assign InstMem_Out = mem[InstMem_Address]; //#(1) 
	//assign data = mem[addr[8:2]][31:0];
endmodule