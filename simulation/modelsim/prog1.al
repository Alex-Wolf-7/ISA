# Input is r1r0, with first 5 bits of r1 are 0s and don't count
PREP 000000
LW   $r0
PREP 000001
LW   $r1
PREP 000010
SAVE $r2
PREP 000000
SW   $r2
PREP 011110
SAVE $r2
PREP 000001
SW   $r2

PREP 000000
SAVE $r2
PREP 001101 		# 13 lines down, to start of "calculate p8"
BEQ  $r2

# Get the next words
PREP 000000
LW   $r2     		# grab our counter
PREP 000000
PXOR $r2
LW   $r0    		# get mem at our counter
INC  $r2, $r2		# inc our counter to get next
PREP 000000
PXOR $r2
LW   $r1		# grab mem at our counter
INC  $r2, $r2		# inc our counter to get next
PREP 000000
SW   $r2		# save our counter for next loop

# Calculate p8
XORR $r2, $r1           # reduce to single bit
PREP 111100
PSFT 000010
ANDI $r3, $r0           # grab bits 5, 6, 7, 8 from $r0
XORR $r3, $r3           # reduce those to single bit 
XOR  $r2, $r3, $r2      # combine single bits to parity
PREP 111100             # P8: store at 100000, 1 byte
SW   $r2

PREP 100000
PSFT 000010
ANDI $r2, $r0           # get 8th bit
XORR $r3, $r1
XOR  $r2, $r2, $r3      
PREP 001110
ANDI $r3, $r0           # get 4:2
XOR  $r3, $r3, $r2
XORR $r3, $r3
PREP 111101		
SW   $r3		# P4: store at 100001, 1 byte

PREP 000110
ANDI $r3, $r1
PREP 000001
SAVE $r2
PREP 011011
PSFT 000010
PXOR $r2
ANDI $r2, $r0
XOR  $r2, $r2, $r3
XORR $r2, $r2
PREP 111110
SW   $r2		# P2: store at 100010, 1 byte

PREP 000101
ANDI $r3, $r1
PREP 000011
SAVE $r2
PREP 010110
PSFT 000010
PXOR $r2
ANDI $r2, $r0
XOR  $r3, $r2, $r3
XORR $r3, $r3
PREP 111111
SW   $r3		# P1: store at 100011, 1 byte

# Get P8 in position
PREP 111100
LW   $r3
SLL  $r3, $r3, 3
SLL  $r3, $r3, 3
SLL  $r3, $r3, 1

# Add in d[4:2]
SLL  $r2, $r0, 3
PREP 111000
PSFT 000001
ANDI $r2, $r2
XOR  $r3, $r3, $r2

# Get P4 in position
PREP 111101
LW   $r2
SLL  $r2, $r2, 3
XOR  $r3, $r3, $r2

# Add in d[1]
PREP 000001
ANDI $r2, $r0
SLL  $r2, $r2, 2
XOR  $r3, $r2, $r3

# Get P2 in position
PREP 111110
LW   $r2
SLL  $r2, $r2, 1
XOR  $r3, $r3, $r2

# Get P1 in position
PREP 111111
LW   $r2
XOR  $r3, $r3, $r2

# Save o0
PREP 000001
LW   $r2
PREP 000000
PXOR $r2
SW   $r3
INC  $r3, $r2

# Get output 1
SLL  $r1, $r1, 3
SLL  $r1, $r1, 1
SRL  $r2, $r0, 3
SRL  $r2, $r2, 1
XOR  $r1, $r1, $r2 

# Store o1
PREP 000000
PXOR $r3
SW   $r1
INC  $r3, $r3

PREP 000001
SW   $r3

PREP 000000
LW   $r0
PREP 011110
SAVE $r1
XOR  $r0, $r1, $r0

PREP 000011
BEQ  $r0

# Branch to top. Needs to be double check
PREP 000000
SAVE $r3
PREP 000001
SAVE $r0
PREP 100100
PSFT 000010
PXOR $r0
BEQ  $r3

END
