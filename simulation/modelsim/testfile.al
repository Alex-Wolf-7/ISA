PREP 010101
SAVE $r0
PREP 000011
SAVE $r1
PREP 111111	# 000111111
PSFT 000010
PXOR $r1
SW   $r0

PREP 000011
SAVE $r1
PREP 111111	# 000111111
PSFT 000010
PXOR $r1
LW   $r3
END		# 111111111