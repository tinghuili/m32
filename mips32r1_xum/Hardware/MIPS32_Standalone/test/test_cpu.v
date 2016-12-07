`timescale 1ns/10ps
`define CYCLE	100
`define SDFFILE    "Processor_syn.sdf" //
`include "gscl45nm.v" //

`include "Processor_syn.v"
//`include "Processor.v"
//`include "DM.v" //delete
`include "IM.v"

module test_cpu;

	integer i = 0;

	reg  clock;
    reg  reset;
    reg  [4:0] Interrupts;            // 5 general-purpose hardware interrupts
    reg  NMI;                         // Non-maskable interrupt
    // Data Memory Interface
    wire  [31:0] DataMem_In; //
    wire  DataMem_Ready;//
    wire DataMem_Read;
    wire [3:0]  DataMem_Write;       // 4-bit Write, one for each byte in word.
    wire [29:0] DataMem_Address;      // Addresses are words, not bytes.
    wire [31:0] DataMem_Out;
    // Instruction Memory Interface
    wire  [31:0] InstMem_In; //
    wire [29:0] InstMem_Address;      // Addresses are words, not bytes.
    wire  InstMem_Ready; //
    wire InstMem_Read;
    wire [7:0] IP;
	
	Processor mips32(.clock(clock), .reset(reset), .Interrupts(Interrupts), .NMI(NMI), .DataMem_In(DataMem_In), 
				.DataMem_Ready(DataMem_Ready), .DataMem_Read(DataMem_Read), .DataMem_Write(DataMem_Write), 
				.DataMem_Address(DataMem_Address), .DataMem_Out(DataMem_Out), .InstMem_In(InstMem_In), 
				.InstMem_Address(InstMem_Address), .InstMem_Ready(InstMem_Ready), .InstMem_Read(InstMem_Read), .IP(IP));
	IM #(.NMEM(`NUM_IM_DATA), .IM_DATA(`IM_DATA_FILE))
			instruction_memory (.clock(clock), .InstMem_Out(InstMem_In), .InstMem_Address(InstMem_Address), 
			.InstMem_Ready(InstMem_Ready), .InstMem_Read(InstMem_Read));
	//DM data_memory (.clock(clock), .reset(reset), .DataMem_Read(DataMem_Read), .DataMem_Write(DataMem_Write), 
	//	.DataMem_Address(DataMem_Address), .DataMem_In(DataMem_Out), .DataMem_Out(DataMem_In), .DataMem_Ready(DataMem_Ready));
	
	//`ifdef SDF //
	initial $sdf_annotate(`SDFFILE, mips32);//
	//`endif// 
	
	always begin
		#(`CYCLE/2) clock = ~clock;
	end
	
	initial begin
		#0;	
		clock = 1'b0;
		reset = 1'b0;
	end
	
	initial begin
		@(negedge clock)  reset = 1'b1;
		#`CYCLE	reset = 1'b0;
	end
	
	initial begin
		$dumpfile(`DUMP_FILE);
		$dumpvars(0, test_cpu);
		/* cpu will $display output when `DEBUG_CPU_STAGES is on */

		// Run all the lines, plus 5 extra to finish off the pipeline.
		for (i = 0; i < `NUM_IM_DATA*4 + 100; i = i + 1) begin
			@(posedge clock);
		end

		$finish;
	end
endmodule