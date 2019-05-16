// Create Date:    15:50:22 10/02/2016 
// Design Name: 
// Module Name:    InstROM 
// Project Name:   CSE141L
// Tool versions: 
// Description: Verilog module -- instruction ROM template	
//	 preprogrammed with instruction values (see case statement)
//
// Revision: 
//
module InstROM #(parameter A=16, W=9) (
  input       [A-1:0] InstAddress,
  output logic[W-1:0] InstOut);

  always_comb begin  
	  case (InstAddress)
		 12'b000000000000: begin
		   InstOut = 9'b000_11_11_11;  // PREP #111111
		 end
		 12'b000000000001: begin
		   InstOut = 9'b100_00_00_00;  // SAVE $r0
		 end
		 12'b000000000010: begin
		   InstOut = 9'b001_01_00_01;  // INC $r1 $r0 up
		 end
		 12'b000000000011: begin
		   InstOut = 9'b001_10_00_00;  // INC $r2 $r0 down
		 end
		 12'b000000000100: begin
		   InstOut = 9'b010_11_01_10;  // XOR $r3 $r1 $r2
		 end
		 12'b000000000101: begin
		   InstOut = 9'b000_00_11_00;  // PREP #001100
		 end
		 12'b000000000110: begin
		   InstOut = 9'b000_10_00_10;  // ANDI $r2 $r2
		 end
		 12'b000000000111: begin
		   InstOut = 9'b011_00_10_00;  // XORR $r2 $r0
		 end
		 default: begin
			InstOut = 9'b111_11_11_11;  // END PROGRAM
		 end
	  endcase
  end
	 
// Instruction format: {4bit opcode, 3bit rs or rt, 3bit rt, immediate, or branch target}
	 
//  always_comb 
//	case (InstAddress)
// opcode = 0 lhw, rs = 0, rt = 1
//	  0 : InstOut = 'b0000000001;  // load from address at reg 0 to reg 1  
// opcode = 1 addi, rs/rt = 1, immediate = 1
     
//	  1 : InstOut = 'b0001001001;  // addi reg 1 and 1
		
// opcode = 2 shw, rs = 0, rt = 1
//	  2 : InstOut = 'b0010000001;  // sw reg 1 to address in reg 0
		
// opcode = 3 beqz, rs = 1, target = 1
//      3 : InstOut = 'b0011001001;  // beqz reg1 to absolute address 1
		
// opcode = 15 halt
//	  4 : InstOut = '1;  // equiv to 10'b1111111111 or 'b1111111111    halt
//	  default : InstOut = 'b0000000000;
//    endcase

// alternative expression
//   need $readmemh or $readmemb to initialize all of the elements
  
  
/* CURRENTLY DISABLED BECAUSE WE HAVEN'T BEEN TOLD TO USE YET AND IS JUST PLACEHOLDER  
  logic[W-1:0] inst_rom[2**(A)];
  always_comb InstOut = inst_rom[InstAddress];
 
  initial begin		                  // load from external text file
  	$readmemb("machine_code.txt",inst_rom);
  end 
*/  
  
  
endmodule
