'' =================================================================================================
''
''   File....... jm_lcd_pcf8574.spin
''   Purpose.... LCD via I2C using a PCF8574 or PCF8574A "backpack"
''   Author..... Jon "JonnyMac" McPhalen  
''               Copyright (c) 2010-2016 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 11 JAN 2015 
''
'' =================================================================================================

{

  Product Reference:
  -- http://www.dfrobot.com/wiki/index.php/I2C/TWI_LCD1602_Module_(SKU:_TOY0046)

  LCD is configure with 4-bit buss.

  Bit assignments for byte written to PCF8574 

    lcdbyte.7 = D7
    lcdbyte.6 = D6
    lcdbyte.5 = D5
    lcdbyte.4 = D4
    lcdbyte.3 = Backlight control
    lcdbyte.2 = E
    lcdbyte.1 = RW
    lcdbyte.0 = RS


  This code uses open-drain output which requires pull-ups on the SDA and SCL pins.
  If using the 5v interface to the LCD, use additional 4.7K pull-ups on the Propeller
  side to assist the weak pull-ups on the LCD module.
    
}

  
con
  
  CLS     = $01                                                 ' clear the LCD 
  HOME    = $02                                                 ' move cursor home
  CRSR_LF = $10                                                 ' move cursor left 
  CRSR_RT = $14                                                 ' move cursor right 
                                                                  
  CGRAM   = $40                                                 ' character ram
  DDRAM   = $80                                                 ' display ram
                                                                 
  LINE0   = DDRAM | $00                                         ' cursor positions for col 1
  LINE1   = DDRAM | $40                                          
  LINE2   = DDRAM | $14                                          
  LINE3   = DDRAM | $54                                          
                                                                 
  #0, CRSR_NONE, CRSR_ULINE, CRSR_BLINK, CRSR_UBLNK             ' cursor types
                                                                  
                                                                  
con                                                               
                                                                  
  RS_MASK = %0000_0001                                            
  RW_MASK = %0000_0010                                          ' not used!
  E_MASK  = %0000_0100                                            
  BL_MASK = %0000_1000                                            
  

obj

  iox : "jm_pcf8574"
  

var

  long  ms001                                                   ' ticks in 1ms
                                                                  
  byte  addr                                                    ' device address
                                                                  
  byte  ctrlbits                                                ' bl, e, rw, rs
  byte  dispctrl                                                ' display control bits
                                                                  

pub null                                                         
                                                                 
  ' This is not a top-level object                               
                                                                 
                                                               
pub start(sclpin, sdapin, device)                                 
                                                                  
'' Initializes LCD driver for PCF8574 using I2C buss                          
'' -- device is %000 to %111

  ms001 := clkfreq / 1_000                                      ' calcutate ticks/ms
                                                                 
  addr := device                                                ' save device address                                              
                                                                 
  iox.startx(sclpin, sdapin)                                    ' connect to PCF8474      
                                                                 
  setup_lcd                                                     ' initialize lcd for 4-bit mode


pub starta(sclpin, sdapin, device)                                 
                                                                  
'' Initializes LCD driver for PCF8574A using I2C buss                          
'' -- device is %000 to %111

  ms001 := clkfreq / 1_000                                      ' calcutate ticks/ms
                                                                 
  addr := device                                                ' save device address                                              
                                                                 
  iox.startax(sclpin, sdapin)                                   ' connect to PCF8474A
                                                                 
  setup_lcd                                                     ' initialize lcd for 4-bit mode


pub present                                                      
                                                                 
  return iox.present(addr)

                                                         
pub clear                                                        
                                                                 
  cmd(CLS)                                                       
                                                                 
                                                                 
pub crsr_home                                                    
                                                                 
  cmd(HOME)                                                      
                                                                 
                                                                 
pub crsr_left                                                    
                                                                 
  cmd(CRSR_LF)                                                   
                                                                 
                                                                 
pub crsr_right                                                   
                                                                 
  cmd(CRSR_RT)                                                   
                                                                 
                                                                 
pub line(lnum)                                                   
                                                                 
  case lnum                                                      
    0: cmd(LINE0)                                                
    1: cmd(LINE1)                                                
    2: cmd(LINE2)                                                
    3: cmd(LINE3)                                                
                                                                 
                                                                 
pub pad(pchar, n)                                                
                                                                 
'' Print pchar n times from current position                     
                                                                 
  if (n > 0)                                                     
    repeat n                                                     
      out(pchar)                                                 
                                                                 
                                                                 
pub cmd(c)                                                       
                                                                 
'' Write command byte to LCD                                     
                                                                 
  ctrlbits &= !RS_MASK                                          ' RS low
  wr_lcd(c)                                                      
                                                                 
                                                                 
pub out(c)                                                       
                                                                 
'' Write character byte to LCD                                   
                                                                 
  ctrlbits |= RS_MASK                                           ' RS high
  wr_lcd(c)                                                      
                                                                 
                                                                 
pub outx(c, n)                                                   
                                                                 
'' Print character n times                                       
                                                                 
  if (n > 0)                                                    ' valid?
    repeat n                                                     
      out(c)                                                     
                                                                 
                                                                 
pub str(p_str)                                                   
                                                                 
'' Print z-string                                                
'  -- borrowed from FullDuplexSerial                             
                                                                 
  repeat strsize(p_str)                                          
    out(byte[p_str++])                                           
                                                                 
                                                                 
pub sub_str(p_str, idx, len) | c                                 
                                                                 
'' Prints part of string                                         
'' -- p_str is pointer to start of string                        
'' -- idx is starting index of sub-string (0 to strsize()-1)     
'' -- len is # of chars to print                                 
                                                                 
  p_str += idx                                                   
  repeat len                                                     
    c := byte[p_str++]                                           
    if (c <> 0)                                                  
      out(c)                                                     
    else                                                         
      quit                                                       
                                                                 
                                                                 
pub dec(value) | i, x                                            
                                                                 
'' Print a decimal number                                        
'  -- borrowed from FullDuplexSerial                             
                                                                            
  x := (value == negx)                                                        
  if (value < 0)                                                 
    value := ||(value+x)                                                    
    out("-")                                                     
                                                                 
  i := 1_000_000_000                                                        
                                                                 
  repeat 10                                                                 
    if value => i                                                           
      out(value / i + "0" + x*(i == 1))                                     
      value //= i                                                           
      result~~                                                              
    elseif result or (i == 1)                                    
      out("0")                                                              
    i /= 10                                                      

' Decimal number, divided by 1000. Does not work on negative numbers.
pub dec_milli(value)
  dec(value/1000)
  out(".")
  rjdec(value//1000, 3, "0")
  
' Like dec_milli(), but right-justified. Does not work on negative numbers.
pub rjdec_milli(value, width, pchar)
  rjdec(value/1000, width - 4, pchar)
  out(".")
  rjdec(value//1000, 3, "0")
                                                                 
pub rjdec(val, width, pchar) | tmpval, padwidth                  
                                                                 
'' Print right-justified decimal value                           
'' -- val is value to print                                      
'' -- width is width of (space padded) field for value           
                                                                 
'  Original code by Dave Hein                                    
'  -- modifications by Jon McPhalen                              
                                                                 
  if (val => 0)                                                 ' if positive
    tmpval := val                                               '  copy value
    padwidth := width - 1                                       '  make room for 1 digit
  else                                                           
    if (val == negx)                                            '  if max negative
      tmpval := posx                                            '    use max positive for width
    else                                                        '  else
      tmpval := -val                                            '    make positive
    padwidth := width - 2                                       '  make room for sign and 1 digit
                                                                 
  repeat while (tmpval => 10)                                   ' adjust pad for value width > 1
    padwidth--                                                   
    tmpval /= 10                                                 
                                                                 
  repeat padwidth                                               ' print pad
    out(pchar)                                                   
                                                                 
  dec(val)                                                      ' print value
                                                                 
                                                                 
pub hex(value, digits)                                           
                                                                 
'' Print a hexadecimal number                                    
'  -- borrowed from FullDuplexSerial                             
                                                                 
  digits := 1 #> digits <# 8                                     
                                                                 
  value <<= (8 - digits) << 2                                    
  repeat digits                                                  
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))        
                                                                 
                                                                 
pub bin(value, digits)                                           
                                                                 
'' Print a binary number                                         
'  -- borrowed from FullDuplexSerial                             
                                                                 
  digits := 1 #> digits <# 32                                    
                                                                 
  value <<= (32 - digits)                                        
  repeat digits                                                  
    out((value <-= 1) & 1 + "0")                                 
                                                                 
                                                                 
pub set_char(n, p_char)

'' Write character map data to CGRAM
'' -- n is the custom character # (0..7)
'' -- p_char is the address of the bytes that define the character

  if ((n => 0) and (n < 8))                                     ' legal char # (0..7)?
    cmd(CGRAM + (n << 3))                                       ' move cursor
    repeat 8                                                    ' output character data
      out(byte[p_char++])                                        
    return true                                                  
  else                                                           
    return false                                                 
                                                                 
                                                                 
pub display(ison)                                                
                                                                 
  if (ison)                                                        
    dispctrl := dispctrl |  %0000_0100                          ' display bit on
  else                                                           
    dispctrl := dispctrl & !%0000_0100                          ' display bit off
                                                                 
  cmd(dispctrl)
  

pub cursor(mode)

'' Sets LCD cursor style: off (0), underline (1), blinking bkg (2), uline+bkg (3)

  case mode
    CRSR_NONE  : dispctrl := dispctrl & %0000_1100 | %0000_1000  
    CRSR_ULINE : dispctrl := dispctrl & %0000_1100 | %0000_1010 
    CRSR_BLINK : dispctrl := dispctrl & %0000_1100 | %0000_1001
    CRSR_UBLNK : dispctrl := dispctrl & %0000_1100 | %0000_1011
    other      : return false

  cmd(dispctrl) 
    
  return true


pub move_cursor(x, y) 

'' Moves DDRAM cursor to column, row position
'' -- home position is indexed as 0, 0

  case y
    0 : cmd(LINE0 + x)
    1 : cmd(LINE1 + x)
    2 : cmd(LINE2 + x)
    3 : cmd(LINE3 + x)


pub wr_mem(dram, src, n)

'' Writes n bytes from src to dram (display ram address) in display

  cmd(dram)                                                     ' setup where to write
  repeat n
    out(byte[src++])


pub backlight(state)

'' Enables (non-zero) or disables (zero) backlight

  if (state)
    ctrlbits |= BL_MASK
  else
    ctrlbits &= !BL_MASK

  cmd(dispctrl)                                                 ' refresh bl bit
  

pri setup_lcd

' Initializes LCD using 4-bit interface via PCF8574x
                                                                  
  ctrlbits := BL_MASK                                           ' backlight on, others 0
                                                                 
  waitcnt((ms001 * 15) + cnt)                                   ' allow power-up
  wr_4bits(%0011 << 4)                                          ' 8-bit mode
                                                                 
  waitcnt((ms001 * 5) + cnt)                                     
  wr_4bits(%0011 << 4)                                           
                                                                 
  waitcnt((ms001 >> 2) + cnt)                                   ' 250us
  wr_4bits(%0011 << 4)                                           
                                                                 
  wr_4bits(%0010 << 4)                                          ' 4-bit mode 
                                                                 
  cmd(%0010_1000)                                               ' multi-line
  cmd(%0000_0110)                                               ' auto-increment cursor
  dispctrl := %0000_1100                                        ' display on, no cursor
  cmd(dispctrl)                                                  
  cmd(CLS)                                                       
                                                                 
                                                                 
pri wr_lcd(b)                                         
                                                                 
' Writes byte b to LCD via PCF8574x using 4-bit interface         
                                                                 
  wr_4bits(b)                                                   ' high nibble
  wr_4bits(b << 4)                                              ' low nibble
                                                                 
  if ((b == CLS) or (b == HOME))                                 
    waitcnt(cnt + (ms001 * 3))                                  ' use 3ms for CLS and HOME
  else                                                           
    waitcnt(cnt + (ms001 >> 4))                                 ' else 63us
                                                                 
                                                       
pri wr_4bits(b)

'' Write b[7..4] to lcd with ctrlbits[3..0] (backlight, e, rw, rs)

  b := (b & $F0) | (ctrlbits & %1001)                           ' force E and RW low
                                                                  
  iox.write(b, addr)                                            ' setup nibble
  iox.write(b | E_MASK, addr)                                   ' blip lcd.e
  iox.write(b, addr)                                           
                                                               
  
dat { license }

{{

  Copyright (c) 2010-2016 Jon McPhalen 

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

}}                   