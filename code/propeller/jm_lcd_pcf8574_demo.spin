'' =================================================================================================
''
''   File....... jm_lcd_pcf8574_demo.spin
''   Purpose....
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (C) 2010-2016 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started....
''   Updated.... 08 JAN 2016
''
'' =================================================================================================


con { timing }

  _clkmode = xtal1 + pll16x                                     
  _xinfreq = 5_000_000                                          ' use 5MHz crystal

  CLK_FREQ = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
  MS_001   = CLK_FREQ / 1_000                                   ' ticks in 1ms
  US_001   = CLK_FREQ / 1_000_000                               ' ticks in 1us


con { io pins }

  RX1 = 31                                                      ' programming / terminal
  TX1 = 30

  SDA = 29                                                      ' eeprom / i2c
  SCL = 28


con

  LCD_ADDR  = %111

  LCD_WIDTH = 16  


obj

' main                                                          ' * master Spin cog
  time : "jm_time"                                              '   timing and delays
  prng : "jm_prng"                                              '   pseudo-random number generator
  lcd  : "jm_lcd_pcf8574"                                       '   LCD via PCF8574
                                                                 
' * uses cog when loaded                                         
                                                                 
                                                                 
var


dat

  Mouth0        byte    $0E, $1F, $1C, $18, $1C, $1F, $0E, $00
  Mouth1        byte    $0E, $1F, $1F, $18, $1F, $1F, $0E, $00
  Mouth2        byte    $0E, $1F, $1F, $1F, $1F, $1F, $0E, $00
  Smile         byte    $00, $0A, $0A, $00, $11, $0E, $06, $00

  Banner1       byte    $20, $20, $20, $20, $20, $20, $20, $20
                byte    $20, $20, $20, $20, $20, $20, $20, $20
                byte    $4A, $4F, $4E, $4E, $59, $4D, $41, $43
                byte    $20, $52, $55, $4C, $45, $53, $21, $03
                byte    $00

  Banner2       byte    "  I2C LCD DEMO  ", 0                                                              
                                                                 
                                                                 
pub main                                                         
                                                                 
  setup                                                          
                                                                 
  repeat
    clear_display
    scroll_line1
    scroll_line2
    time.pause(2000)
    temperature_display
    flash_backlight
    

pub clear_display

  lcd.clear  
  lcd.backlight(true)   
  time.pause(250)
  

pub scroll_line1 | pos

  repeat pos from 0 to LCD_WIDTH                                ' reaveal line 1                
    lcd.move_cursor(0, 0)                                       ' move to top line, left column                 
    lcd.sub_str(@Banner1, pos, LCD_WIDTH)                       ' print section of Banner1   
    time.pause(75)


pub scroll_line2 | pos, char, frame, newchar

  repeat pos from 0 to 15                                       ' scroll through all chars
    char := byte[@Banner2][pos]                                 ' get char from banner2
    repeat frame from 1 to 5                                    ' loop through animation frames
      lcd.move_cursor(pos, 1)                                   ' position cursor
      newchar := lookup(frame : 0, 1, 2, 1, char)               ' get char for frame
      lcd.out(newchar)                                          ' write it
      time.pause(75)                                            ' short, inter-frame delay
                                                                 

pub temperature_display | tf, tc

  lcd.clear
  time.pause(100)

  repeat tf from 95_0 to 105_0                                  ' loop Fahrenheit
    tc := (tf - 32_0) * 5 / 9                                   ' convert to 0.1C
    lcd.move_cursor(0, 0)
    lcd.rjdec(tf / 10, 3, " ")
    lcd.out(".")
    lcd.out("0" + (tf // 10))
    lcd.out("F")
    lcd.move_cursor(0, 1)
    lcd.rjdec(tc / 10, 3, " ")
    lcd.out(".")
    lcd.out("0" + (tc // 10))
    lcd.out("C")
    time.pause(100)


pub flash_backlight

  repeat 3                  
    lcd.backlight(false)    
    time.pause(500)              
    lcd.backlight(true)     
    time.pause(500)              
                                                  
                                                                 
pub setup                                                        
                                                                 
'' Setup IO and objects for application                          
                                                                 
  time.start                                                    ' setup timing & delays
                                                                 
  prng.seed(-cnt, -cnt ~> 2, $EA7_BEEF, cnt << 2, cnt)          ' seed randomizer
                                                                 
  outa := 0
  dira := 0                                                     ' clear all pins (master cog)
                                                                 
  lcd.start(SCL, SDA, LCD_ADDR)                                 ' start LCD (set for address %111)
  lcd.set_char(0, @Mouth0)                                      ' define custom characters
  lcd.set_char(1, @Mouth1)
  lcd.set_char(2, @Mouth2)
  lcd.set_char(3, @Smile) 


dat { license }                                                  

{{

  Copyright (C) 2010-2016 Jon McPhalen

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