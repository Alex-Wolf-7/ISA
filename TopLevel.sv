// dummy processor -- substitute your top level design
// CSE141L   Spring 2019
module TopLevel #(parameter AW = 8, DW = 8, A = 16, W = 9)
 (input        clk,
               reset,	       // master reset from bench: "start over"
		         req,		       // from test bench: "do next program"
  output logic ack);	       // to test bench: "done with that program"

logic[15:0] ct;                // dummy cycle counter

logic [AW-1:0] DmMemAdr;	     // memory address pointer, shared for read and write
logic          DmReadEn;   // can tie high in most designs
logic          DmWriteEn;   // normally low, but high for STORE
logic [DW-1:0] DmDatIn;		     // data path in, for STORE operations
wire  [DW-1:0] DmDatOut;

logic [2:0]    AluOperation;
logic [DW-1:0] AluInput1;
logic [DW-1:0] AluInput2;
wire  [DW-1:0] AluOutput;
wire 		   	AluZero;

logic				regfileWritePrepReg;
logic		      regfileReadPrepReg;
logic          regfileWriteEnabled;
logic [1:0]    regfileReadReg1;
logic [1:0]    regfileReadReg2;
logic [1:0]    regfileWriteReg;
logic [DW-1:0] regfileWriteData;
wire  [DW-1:0] regfileReadData1;
wire  [DW-1:0] regfileReadData2;

logic [2:0]    controlOpcode;
logic			   controlLastBit;
wire		      controlWritePrepReg;
wire		      controlReadPrepReg;
wire		      controlWriteEnabled;
wire		      controlDataWrite;
wire		      controlDataRead;
wire  [2:0]    controlALUOp;
wire           controlBranch;
wire           controlAluRegSource;
wire           controlAluConstantOrOne;
wire           controlSaveAluToReg;
wire  		   controlPrepCommand;

logic          IfBranch_rel;
logic          IfALU_zero;
logic [15:0]   IfTarget;
logic          IfInit;
logic          IfHalt;
wire  [15:0]   IfPC;

logic [A-1:0]  InstAddress;
wire  [W-1:0]  InstOut;
		   // data path out, for LOAD operations 
dm #(.DW(DW),.AW(AW)) dm(
  clk,
  DmMemAdr,
  DmReadEn,
  DmWriteEn,
  DmDatIn,
  DmDatOut
); // instantiate data memory
assign DmMemAdr = AluOutput;
assign DmReadEn = controlDataRead;
assign DmWriteEn = controlDataWrite;
assign DmDatIn = regfileReadData2;


regfile regfile(
  clk,
  regfileWritePrepReg,
  regfileReadPrepReg,
  regfileWriteEnabled,
  regfileReadReg1,
  regfileReadReg2,
  regfileWriteReg,
  regfileWriteData,
  reset,
  regfileReadData1,
  regfileReadData2
);
assign regfileWritePrepReg = controlWritePrepReg;
assign regfileReadPrepReg = controlReadPrepReg;
assign regfileWriteEnabled = controlWriteEnabled;
assign regfileReadReg1 = InstOut[3:2];
assign regfileReadReg2 = InstOut[1:0];
assign regfileWriteReg = InstOut[5:4];
always_comb begin
  if (controlDataRead) begin
    regfileWriteData         = DmDatOut;
  end else if (controlSaveAluToReg) begin
    regfileWriteData         = AluOutput;
  end else if (controlPrepCommand) begin
    regfileWriteData[DW-1:6] = 2'b00;
	 regfileWriteData[5:0]    = InstOut[5:0];
  end else begin
    regfileWriteData         = regfileReadData1;
  end
end


controldecoder controldecoder(
  clk,
  reset,
  controlOpcode,
  controlLastBit,
  controlWritePrepReg,
  controlReadPrepReg,
  controlWriteEnabled,
  controlDataWrite,
  controlDataRead,
  controlALUOp,
  controlBranch,
  controlAluRegSource,
  controlAluConstantOrOne,
  controlSaveAluToReg,
  controlPrepCommand
);
assign controlOpcode = InstOut[8:6];
assign controlLastBit = InstOut[0];


ALU ALU(
  AluOperation,
  AluInput1,
  AluInput2,
  AluOutput,
  AluZero
);
assign AluOperation = controlALUOp;
assign AluInput1 = regfileReadData1;
always_comb begin
  if (controlAluRegSource == 1'b1) begin
    AluInput2 = regfileReadData2;
  end else if (controlAluConstantOrOne == 1'b0) begin
    AluInput2[DW-1:2] = 6'b00_0000;
	 AluInput2[1:0] = InstOut[1:0];
  end else begin
    AluInput2 = 8'b0000_0001;
  end
end


IF IF(
  IfBranch_rel,
  IfALU_zero,
  IfTarget,
  IfInit,
  IfHalt,
  clk,
  req,
  IfPC
);
assign IfBranch_rel = controlBranch;
assign IfALU_zero = AluZero;
assign IfTarget = regfileReadData1;
assign IfInit = reset;
assign IfHalt = ack;


InstROM #(.A(A),.W(W)) InstROM(.*);
assign InstAddress = IfPC;

assign ack = (IfPC == 9'b111_11_11_11);
// optional data width and address width parametric overrides

// the following sequence makes sure the test bench
//  stops; in practice, you will want to tie your ack
//  flags to the completion of each program
always_ff @(posedge clk) begin
  if(reset) begin
    ct  <= 0;
  end
  else if(req) begin
	ct  <= 0;
  end
  else begin
    ct <= ct+1;
  end
end


endmodule