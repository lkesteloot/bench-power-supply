
CON

  ' Multiply crystal input by 16 to get system clock. Our crystal is 5 MHz, so
  ' our system clock is 80 MHz, the maximum that the Propeller can handle.
  _clkmode = xtal1 + pll16x
  
  ' Specify our crystal frequency in Hz. This (multiplied by 16 for the PPLL) is
  ' stored in _clkfreq and RAM (address zero), not used by the hardware.
  _xinfreq = 5_000_000
  
  LED_PIN = 0
  
PUB start
 
   dira[LED_PIN] := 1

   repeat
     waitcnt(clkfreq/4 + cnt)
     outa[LED_PIN] := 1
     waitcnt(clkfreq/4 + cnt)
     outa[LED_PIN] := 0
     