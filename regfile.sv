module regfile #(parameter AW=2,			     // address width; 2^AW is number of regs
                      DW=8)(             // data width; default data path width = 8
  input                  clk,             // clock
  input						 WritePrepReg,
  input						 ReadPrepReg,
  input						 WriteEnabled,
  input        [AW-1:0]  ReadReg1,
  input        [AW-1:0]  ReadReg2,
  input		   [AW-1:0]  WriteReg,
  input		   [DW-1:0]  WriteData,
  output logic [DW-1:0]  ReadData1,
  output logic [DW-1:0]  ReadData2
);	  	

  logic [DW-1:0] regs [2**AW]; 	     	 // create array of 2**AW elements (current: 4)
  logic [DW-1:0] prep;

  // READ LOGIC
  always_comb begin							 // reads are immediate/combinational
    if (ReadPrepReg) begin
		ReadData1 = prep;
	 end else begin
	   ReadData1 = regs[ReadReg1];
	 end
    
	 ReadData2 = regs[ReadReg2];
  end

  // WRITE LOGIC
  always_ff @ (posedge clk)	             // writes are clocked / sequential
    if (WriteEnabled) begin
	   if (WritePrepReg) begin
		  prep <= WriteData;
		end else begin
		  regs[WriteReg] <= WriteData;
		end
    end

endmodule
