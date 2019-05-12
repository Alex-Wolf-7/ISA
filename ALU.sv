module ALU #(parameter AW=2, DW=8)(
  input  [2:0]    operation,
  input  [DW-1:0] input1,
  input  [DW-1:0] input2,
  output [DW-1:0] Output,
  output 			Zero
);	  	

assign Zero = (Output == 0);

always_comb begin
  case (operation)
    000: begin  // increment
	   Output = input1 + 1;
	 end
	 
	 001: begin  // decrement
	   Output = input1 - 1;
	 end
	 
	 010: begin  // xor bitwise (if result is 0, set "Zero" to 1)
	   Output = input1 ^ input2;
	 end
	 
	 011: begin  // xor reducing
	   Output = ^input1;
	 end
	 
	 100: begin  // shift left
	   Output = input1 << input2;
	 end
	 
	 101: begin  // shift right
	   Output = input1 >> input2;
	 end
	 
	 110: begin  // and
	   Output = input1 & input2;
	 end
	 
	 111: begin  // unused
	   $display("Unused ALU operation, 111!");
		Output = input1;
	 end
	 
	 default: begin
	   $display("Unused ALU operation, default!");
		Output = input1;
	 end
  endcase
end

endmodule
