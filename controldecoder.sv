module controldecoder (
  input        clk,
  input		   reset,
  input [2:0]  opcode,
  input			lastBit,
  
  output		   WritePrepReg,
  output		   ReadPrepReg,
  output		   WriteEnabled,
  output		   DataWrite,
  output		   DataRead,
  output [2:0] ALUOp,
  output       controlBranch,
  output       aluRegSource,
  output       aluConstantOrOne,
  output       saveAluToReg,
  output       prepCommand
);

logic prepEnabled;
logic enablePrep;
logic disablePrep;

always_comb begin
  if (!prepEnabled) begin
    case (opcode)
	   000: begin  // PREP
		  WritePrepReg = 1;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 1;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add, not used
		end
		
		001: begin  // INC
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
		end
		
		010: begin  // XOR
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b010;  // bitwise xor
		end
		
		011: begin  // XORR
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b011;  // reducing xor
		end
		
		100: begin  // SLL
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b100;  // left shift
		end
		
		101: begin  // SRL
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b101;  // right shift
		end
		
		110: begin
		  $display("Unused opcode, 110 (no prep)!");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		end
		
		111: begin
		  $display("Unused opcode, 111! (no prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
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
		end
		
    endcase
  end else begin
    case (opcode)
	   000: begin  // ANDI
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b110;  // and
		end
		
		001: begin  // BEQ
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b010;  // xor
		end
		
		010: begin  // LW
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 1;
		  ALUOp = 3'b000;  // add
		end
		
		011: begin  // SW
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 1;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add
		end
		
		100: begin  // SAVE
		  WritePrepReg = 0;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 1;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;  // add
		end
		
		101: begin  // PSFT
		  WritePrepReg = 1;
		  ReadPrepReg = 1;
		  WriteEnabled = 1;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b100;  // left shift
		end
		
		110: begin
		  $display("Unused opcode, 110! (with prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
		end
		
		111: begin
		  $display("Unused opcode, 111! (with prep)");
		  WritePrepReg = 0;
		  ReadPrepReg = 0;
		  WriteEnabled = 0;
		  enablePrep = 0;
		  disablePrep = 0;
		  DataWrite = 0;
		  DataRead = 0;
		  ALUOp = 3'b000;
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
		end
    endcase
  end
end

always @(posedge clk) begin
  if(reset) begin
    prepEnabled <= 0;
  end else if (enablePrep) begin
    prepEnabled <= 1;
  end else if (disablePrep) begin
    prepEnabled <= 0;
  end
end

endmodule
