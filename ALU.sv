module ALU #(parameter AW=2, DW=8)(
  input  [2:0]    operation,
  input  [DW-1:0] input1,
  input  [DW-1:0] input2,
  
  output logic [DW-1:0] Output,
  output logic          Zero
);	  	

assign Zero = (Output == 0);

always_comb begin
  case (operation)
    3'b000: begin  // increment
	   Output = input1 + 1;
	 end
	 
	 3'b001: begin  // decrement
	   Output = input1 - 1;
	 end
	 
	 3'b010: begin  // xor bitwise (if result is 0, set "Zero" to 1)
	   Output = input1 ^ input2;
	 end
	 
	 3'b011: begin  // xor reducing
	   Output = ^input1;
	 end
	 
	 3'b100: begin  // shift left
	   Output = input1 << input2;
	 end
	 
	 3'b101: begin  // shift right
	   Output = input1 >> input2;
	 end
	 
	 3'b110: begin  // and
	   Output = input1 & input2;
	 end
	 
	 3'b111: begin  // input2 is 0
		Output = input2 ^ 8'b00000000;
	 end
	 
	 default: begin
	   $display("Unused ALU operation, default!");
		Output = input1;
	 end
  endcase
end

endmodule
