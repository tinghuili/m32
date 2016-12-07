`timescale 1ns / 1ps
/*
 * File         : DM.v
 ** Data Memory Interface
    input  [31:0] DataMem_In,
    input  DataMem_Ready,
    output DataMem_Read,
    output [3:0]  DataMem_Write,        // 4-bit Write, one for each byte in word.
    output [29:0] DataMem_Address,      // Addresses are words, not bytes.
    output [31:0] DataMem_Out,
 */
module DM(
    input  clock,
	input reset,
    input DataMem_Read,
    input [3:0]  DataMem_Write,        // 4-bit Write, one for each byte in word.
    input [29:0] DataMem_Address,      // Addresses are words, not bytes.
    input [31:0] DataMem_In,
	output  [31:0] DataMem_Out,
    output reg DataMem_Ready
    );
	integer i;
	parameter NMEM = 512; //128
	
	reg [31:0] mem [0:NMEM-1];  // 32-bit memory with 128 entries
	reg [31:0] n_mem [0:NMEM-1];
	
	always @(posedge clock or posedge reset)begin
		if(reset)begin
			for(i=0; i<=NMEM-1; i=i+1) begin
				mem[i]<=32'd0;
			end
		end
		else begin
			for(i=0; i<=NMEM-1; i=i+1) begin
				mem[i]<=n_mem[i];
			end
		end
	end
	// ACK
	always @(posedge clock) begin
		if(reset)begin
			DataMem_Ready <= 1'b0;
		end
		else begin
			if (DataMem_Read==1'b1 && DataMem_Write==4'd0) begin
				DataMem_Ready <= 1'b1;
			end
			else if (DataMem_Read==1'b0 && DataMem_Write!=4'd0) begin
				DataMem_Ready <= 1'b1;
			end
			else begin
				DataMem_Ready <= 1'b0;
			end
		end
	end
	// Write
	always @(*)begin
		if (DataMem_Write[3]==1'b1)begin
			n_mem[DataMem_Address[8:0]][31:24] = DataMem_In[31:24]; //#1 [6:0]
		end
		else begin
			n_mem[DataMem_Address[8:0]][31:24] = mem[DataMem_Address[8:0]][31:24];
		end
		
		if (DataMem_Write[2]==1'b1)begin
			n_mem[DataMem_Address[8:0]][23:16] = DataMem_In[23:16];
		end
		else begin
			n_mem[DataMem_Address[8:0]][23:16] = mem[DataMem_Address[8:0]][23:16];
		end
		
		if (DataMem_Write[1]==1'b1)begin
			n_mem[DataMem_Address[8:0]][15:8] = DataMem_In[15:8];
		end
		else begin
			n_mem[DataMem_Address[8:0]][15:8] = mem[DataMem_Address[8:0]][15:8];
		end
		
		if (DataMem_Write[0]==1'b1)begin
			n_mem[DataMem_Address[8:0]][7:0] = DataMem_In[7:0];
		end		
		else begin
			n_mem[DataMem_Address[8:0]][7:0] = mem[DataMem_Address[8:0]][7:0];
		end
	end
	
	// Read
	assign DataMem_Out = (DataMem_Write != 4'd0) ? DataMem_In : mem[DataMem_Address[8:0]][31:0];
	//assign #(1) rdata = wr ? wdata : mem[addr][31:0];
endmodule