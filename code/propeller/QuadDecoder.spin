{{

┌──────────────────────────────────────────┐
│ Quadrature Decoder                       │
│ Author: Luke Haywas                      │
│                                          │
│                                          │
│ Copyright (c) <2010> <Luke Haywas>       │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Description:
Uses one cog to continuously monitor a rotary quadrature encoder.
As the encoder is turned, each change of position is accumulated
to a variable in hub RAM. This variable then reflects how far
the encoder has been turned to the left or the right.

Wiring: Connect the encoder to two adjacent pins. Pass the number
of the first pin as the first parameter of the Start method.
Pass the ADDRESS of the variable to accumulate to as the second
parameter of the Start method.

}}

VAR
  byte  cog

PUB start(pin, varaddr)                                 ' Start a cog monitoring the encoder.
  stop 
  epin1 := pin
  result := cog := cognew(@quad, varaddr) + 1          

{{
  Parameters:
    pin                         first pin of the encoder input
    varaddr                     address of the hub variable to accumulate to

  Returns:
    1 + number of cog it got started in
    0 if no cogs available.

  Note: You can preset the value of the accumulation variable before calling start.
  
  Example usage:
    variable := 25
    quad.start(12, @variable)
}}

PUB stop                                                ' Stop monitoring the encoder.
  if cog
    cogstop(cog~ - 1)

DAT
                        ORG                        
quad                    rdlong  accum, par              ' get initial value of accumulator
                        mov     quadmask, #%11          ' initialize encoder mask
                        shl     quadmask, epin1         ' bitshift it to encoder pins
                                 
firstread               mov     oldstate, ina           ' read encoder for the first time
                        and     oldstate, quadmask      ' call this the "old state"
                        shr     oldstate, epin1         ' bitshift it into the LSBs
                        
backtostart             mov     turnpos, oldstate       ' PURE VOODOO MAGIC
                        rev     turnpos, #30            ' do some funky bit math
                        xor     turnpos, #%10           ' new state will match one of these
                                                        ' whichever it matches = turn direction                        
                        mov     turnneg, oldstate
                        rev     turnneg, #30
                        xor     turnneg, #%01           
                        
getnewstate             shl     oldstate, epin1
                        waitpne oldstate, quadmask      ' wait for pins to change
                        mov     newstate, ina           ' read encoder
                        and     newstate, quadmask      ' mask it against the encoder mask
                        shr     newstate, epin1         ' shift it into the LSBs
                                                        
                        cmp     turnpos, newstate       wz     ' see if it moved cw
              if_z      jmp     #turnedpos

                        cmp     turnneg, newstate       wz     ' see if it moved ccw
              if_z      jmp     #turnedneg
                        
                        jmp     #getnewstate            ' falls through, start over

turnedneg               add     accum, #%1
                        wrlong  accum, par
                        jmp     #updatestates           ' exit

turnedpos               sub     accum, #%1
                        wrlong  accum, par
                        jmp     #updatestates           ' exit

updatestates            mov     oldstate, newstate      ' mov newstate overwrite oldstate
                        jmp     #backtostart
                        
                     

epin1   long  12

accum         res 1
quadmask      res 1
oldstate      res 1
turnpos       res 1
turnneg       res 1
newstate      res 1
time          res 1

                        FIT

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ TERMS OF USE: MIT License │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}