module controldecoder (
  input        clk,
  input		   reset,
  input  [2:0] opcode,
  input			lastBit,
  
  output logic       WritePrepReg,
  output	logic       ReadPrepReg,
  output	logic	      WriteEnabled,
  output	logic	      DataWrite,
  output	logic	      DataRead,
  output logic [2:0] ALUOp,
  output logic       controlBranch,     // if we are branching
  output logic       aluRegSource,      // if 1, input 2 to ALU is regfileReadData2
  output logic       aluConstantOrOne,  // if true, ALU input is 1, otherwise is constant
  output logic       saveAluToReg,      // data written to regfile is output of ALU
  output logic       prepCommand        // is prep command, data written to regfile is constant
);

logic prepEnabled;
logic enablePrep;
logic disablePrep;
logic [2:0] lastOp;

always_comb begin
  if (!prepEnabled) begin
    case (opcode)
	   3'b000: begin  // PREP
		  WritePrepReg = 1'b1;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 1;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add, not used
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 1;
		end
		
		3'b001: begin  // INC
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  if (lastBit == 1'b1) begin
		    ALUOp = 3'b000;  // increment (add?)
		  end else begin
			 ALUOp = 3'b001;  // decrement (sub?)
		  end
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 1;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b010: begin  // XOR
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b010;  // bitwise xor
		  controlBranch = 0;
		  aluRegSource = 1;
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b011: begin  // XORR
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b011;  // reducing xor
		  controlBranch = 0;
		  aluRegSource = 0; 
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b100: begin  // SLL
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b100;  // left shift
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b101: begin  // SRL
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b101;  // right shift
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b110: begin
		  $display("Unused opcode, 110 (no prep)!");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b111: begin
		  $display("Halting program, 111 reached! (no prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		default: begin
		  $display("Default hit controldecoder! (no prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
    endcase
  end else begin
    case (opcode)
	   3'b000: begin  // ANDI
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b110;  // and
		  controlBranch = 0;
		  aluRegSource = 1;
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b001: begin  // BEQ
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b010;  // xor
		  controlBranch = 1;
		  aluRegSource = 1;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b010: begin  // LW
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 1;
		  ALUOp = 3'b000;  // add
		  controlBranch = 0;
		  aluRegSource = 1;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b011: begin  // SW
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 1;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add
		  controlBranch = 0;
		  aluRegSource = 1;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b100: begin  // SAVE
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b101: begin  // PSFT
		  WritePrepReg = 1;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b100;  // left shift
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 1;
		  prepCommand = 0;
		end
		
		3'b110: begin
		  $display("Unused opcode, 110! (with prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		3'b111: begin
		  $display("Unused opcode, 111! (with prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
		
		default: begin
		  $display("Default hit controldecoder! (with prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		  controlBranch = 0;
		  aluRegSource = 0;
		  aluConstantOrOne = 0;
		  saveAluToReg = 0;
		  prepCommand = 0;
		end
    endcase
  end
end

always @(negedge clk) begin
  lastOp <= opcode;
end

always @(posedge clk) begin
  if(reset) begin
    prepEnabled <= 0;
	 
  end else if (prepEnabled == 0) begin
    if (lastOp == 3'b000) begin
	   prepEnabled <= 1;
	 end
	 
  end else begin
    if (lastOp == 3'b000 || lastOp == 3'b001 || lastOp == 3'b010 || lastOp == 3'b011 || lastOp == 3'b100) begin
	   prepEnabled <= 0;
	 end
  end
end

endmodule
