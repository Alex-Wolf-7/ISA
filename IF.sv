// Design Name:    basic_proc
// Module Name:    IF 
// Project Name:   CSE141L
// Description:    instruction fetch (pgm ctr) for processor
//
// Revision:  2019.01.27
//
module IF(
  input Branch_rel,		  // jump to Target + PC
  input ALU_zero,			  // flag from ALU
  input [15:0] Target,		  // jump ... "how high?"
  input Init,				  // reset, start, etc. 
  input Halt,				  // 1: freeze PC; 0: run PC
  input clk,				  // PC can change on pos. edges only
  input req,
  output logic[15:0] PC		  // program counter
  );
  
  logic halted = 1'b1;
	 
  always_ff @(posedge clk)	  // or just always; always_ff is a linting construct
	 if(Init) begin
	   PC <= 0;				  // for first program; want different value for 2nd or 3rd
		halted <= 1'b1;
	 end else if (req) begin
	   PC <= PC+1;
		halted <= 1'b0;
	 end else if(halted || Halt) begin
	   PC <= PC;
		halted <= 1'b1;
	 end else if(Branch_rel && ALU_zero) // conditional relative jump
	   PC <= Target + PC;
	 else
	   PC <= PC+1;		      // default increment (no need for ARM/MIPS +4 -- why?)

endmodule
