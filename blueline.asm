; thin blue line by Kai Hewat
; based on
; thin red line by Kirk Israel
;Explantions from http://e-tradition.net/bytes/6502/6502_instruction_set.html

;	Signify that program is 
;	written for 6502:
	processor 6502

;	File containing key info
;	for writing atari games
	include vcs.h

;	Identify the location to place all following code
;	$F000 is standard for atari programs
	org $F000
	
Start

;	Disable all interrupts 
;	(Set Interrupt Disable)
	SEI

;	CLear BCD math bit
;	(Clear decimal)
	CLD

;	put X on top
;	(load X #$FF)
	LDX #$FF

;	Use X to reset stack pointer
;	(Transfer X to stack pointer)
	TXS

;	Put 0 into A
;	(Load Accumulator with Memory)
	LDA #0

ClearMem 

;	store A + 0 in X
;	(store Accumulator) 
	STA 0,X

;	Decrement X
	DEX

;	If DEX doesn't result in 0
;	goto clearmem
;	(Branch on not equal to zero)
	BNE ClearMem

;	Load A with a colour
;	In this case not dark orange
	LDA #$22

;	Store Colour in background colour register
	STA COLUBK

;	Load A with colour blue
	LDA #$99

;	Store colour in missle0 register
	STA COLUP0

MainLoop

;	To sync with the TV VSYNC needs to be 0010
;	The bit second from the right needs to be set to 1
;	This is achieved here by loading A with the number 2
;	Then passing VSYNC the value from there
;	This is maintained for 3 scanlines
	LDA  #2
	STA  VSYNC
	STA  WSYNC
	STA  WSYNC
	STA  WSYNC

;	Load A with 43
	LDA  #43

;	TIM64T is a timer that counts down every 64 clock cycles
;	using the three scan lines above, we give ourselves approx
;	43 X 64 cycles
;	this ensures loop operations don't overrun the time 
;	taken to scan
	STA  TIM64T

;	zero out VSYNC when the time runs out
;	if operations are not all complete everything will break
	LDA #0
	STA  VSYNC

WaitForVblankEnd
;	Load timer 
	LDA INTIM

;	Kill time if the timer has not yet reached 0
	BNE WaitForVblankEnd

;	Y is being used to store how many lines we have to do
	LDY #191 

;	End vblank period with 0 
;	Use the 0 we stored in it earlier
	STA WSYNC
	STA VBLANK

;	Load A with -1 in the left nibble, ignore right
	LDA #$F0

;	HMM0 is horizontal movement register for Missle 0

;	Put our -1 in the left nibble
	STA HMM0

;	then start our movemnt of -1
	STA HMOVE

ScanLoop 

;	wait for previous line to finish
	STA WSYNC

;	Activating second bit from the right again
;	This time in ENAM0, this could be left on 
;	for this program. Doing it every loop is to better understand
;	this is where loop logic goes
	LDA #2
	STA ENAM0

;	Decrement 1 from Y which is being used as a line counter
	DEY

;Repeat if not finished with all scanlines
	BNE ScanLoop

;	Load the 2 from earlier 
;	Finish the final scanline
	STA WSYNC
	STA VBLANK

;	Store 30 in X
	LDX #30

OverScanWait
	STA WSYNC
	DEX
	BNE OverScanWait
	JMP  MainLoop ; Infinite loop
 
	org $FFFC
	.word Start
	.word Start
