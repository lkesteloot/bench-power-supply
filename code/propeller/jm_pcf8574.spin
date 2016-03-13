'' =================================================================================================
''
''   File....... jm_pcf8574.spin
''   Purpose.... Consolodated driver for PCF8574 or PCF8574A
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2013-2016 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 11 JAN 2016
''
'' =================================================================================================


con { fixed io pins }

  RX1 = 31                                                      ' programming / terminal
  TX1 = 30
  
  SDA = 29                                                      ' eeprom / i2c
  SCL = 28


con

  PCF8574  = %0100_000_0
  PCF8574A = %0111_000_0
  

obj

  i2c : "jm_i2c"


var

  long  devbase                                                 ' device code base
  

pub null                                                         
                                                                 
  ' This is not a top-level object                               
                                                                 

pub start

'' Start PCA8574 object
'' -- connects to boot EE buss

  startx(SCL, SDA)


pub starta

'' Start PCA8574A object
'' -- connects to boot EE buss

  startax(SCL, SDA)


pub startx(sclpin, sdapin)

'' Start PCF8574 object
'' -- sclpin and sdapin define i2c buss

  i2c.setupx(sclpin, sdapin)

  devbase := PCF8574


pub startax(sclpin, sdapin)

'' Start PCF8574A object
'' -- sclpin and sdapin define i2c buss

  i2c.setupx(sclpin, sdapin)

  devbase := PCF8574A


pub present(addr)

  return i2c.present(devbase | (addr << 1))


pub write(b, addr)

'' Write byte b to PCF8574x port

  i2c.start
  i2c.write(devbase | (addr << 1))
  i2c.write(b)
  i2c.stop


pub read(addr) | b

'' Read port bits from PCA8574x

  i2c.start
  i2c.write(devbase | (addr << 1) | %1)
  b := i2c.read(i2c#ACK)
  i2c.stop

  return b


dat

{{

  Copyright (c) 2013-2016 Jon McPhalen   

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
