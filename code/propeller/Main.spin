
CON

  ' Multiply crystal input by 16 to get system clock. Our crystal is 5 MHz, so
  ' our system clock is 80 MHz, the maximum that the Propeller can handle.
  _clkmode = xtal1 + pll16x
  
  ' Specify our crystal frequency in Hz. This (multiplied by 16 for the PPLL) is
  ' stored in _clkfreq and RAM (address zero), not used by the hardware.
  _xinfreq = 5_000_000
  
  LED_PIN = 0
  SDA_PIN = 29
  SCL_PIN = 28

  LCD_ADDR = %111
  LCD_WIDTH = 16
  
  INA219_ADDR = $40
  
OBJ
  lcd : "jm_lcd_pcf8574"
  ina219 : "ina219"
  
DAT
  BootMsg    byte    "Bench Supply v1", 0
  Found      byte    "Found INA219", 0
  NotFound   byte    "Fail INA219", 0

PUB start | value
  ' Reset pins, all input.
  outa := 0
  dira := 0

  ' Initialize the LCD.
  lcd.start(SCL_PIN, SDA_PIN, LCD_ADDR)
  lcd.clear   
  lcd.backlight(true)   
  lcd.move_cursor(0, 0)
  lcd.str(@BootMsg)
  
  ' Initialize the INA219.
  ina219.start(SCL_PIN, SDA_PIN, INA219_ADDR)

  lcd.move_cursor(0, 1)

  repeat
    value := ina219.read
    ~~value ' sign-extend from 16 bits to 32.
    lcd.move_cursor(0, 1)
    lcd.rjdec(value, LCD_WIDTH, " ")

  ' Blink light.
  dira[LED_PIN] := 1
  repeat
    waitcnt(clkfreq/4 + cnt)
    outa[LED_PIN] := 1
    waitcnt(clkfreq/4 + cnt)
    outa[LED_PIN] := 0
