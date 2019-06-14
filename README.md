CSE 141L Final Project
Alexander Wolf
A12600211

HOW TO ASSEMBLE:
Change directory into `./simulation/modelsim/`
Compile the assembler by typing `javac Assembler.java`
Assemble your Assembly code by typing `java Assembler FILENAME`. The file to assemble must be a `.al` file. This file will be `prog1.al`.
Assembling will produce a file named `machine_code.alex`
There should already be an assembled `prog1.al` in place when this assignment is submitted.

HOW TO RUN:
Open the full project folder in ModelSim
Compile all `.sv` files:
	ALU.sv
	controldecoder.sv
	dm.sv
	IF.sv
	InstROM.sv
	proc.sv
	prog123_tb.sv
	regfile.sv
	TopLevel.sv
Run a simulation, using `prog123_tb.sv` as the testbench. The program itself finishes in 16855 ns.
The testbench will try to run all three programs, however only the first one works. Scrolling up on the transcript shows the correct output for prog1.

Warning: for Quartus compilation, the assembled `machine_code.alex` will have to be copied to the main folder. It should already be there, but if Quartus cannot find it please make sure it is in place.
