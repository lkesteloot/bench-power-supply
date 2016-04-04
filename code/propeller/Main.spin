
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
  SCOPE_PIN = 15

  LCD_ADDR = %111
  LCD_WIDTH = 16
  
  INA219_ADDR = $40
  
OBJ
  lcd : "jm_lcd_pcf8574"
  ina219 : "ina219"
  quad : "QuadDecoder"  ' http://obex.parallax.com/object/485
  
DAT
  BootMsg    byte    "Bench Supply v1", 0
  Found      byte    "Found INA219", 0
  NotFound   byte    "Fail INA219", 0
  ShuntRead  byte    "Shunt reading", 0
  CurrentRead byte   "Current reading", 0
  BusRead    byte    "Bus reading", 0
  PowerRead  byte    "Power reading", 0
  Amp        byte    " A", 0
  Volt       byte    " V", 0
  Watt       byte    " W", 0
  
VAR
  long knob
  long freq
  long phase
  long targetVoltageMv
  long errorMv

PUB start | value
  ' Reset pins, all input.
  outa := 0
  dira := 0

  ' Initialize the LCD.
  waitcnt(clkfreq/10 + cnt)
  lcd.start(SCL_PIN, SDA_PIN, LCD_ADDR)
  waitcnt(clkfreq/10 + cnt)
  lcd.clear   
  lcd.backlight(true)   
  lcd.move_cursor(0, 0)
  waitcnt(clkfreq/10 + cnt)
  lcd.str(@BootMsg)
  waitcnt(clkfreq/10 + cnt)
  
  ' Initialize the INA219.
  ina219.start(SCL_PIN, SDA_PIN, INA219_ADDR)

  if 0
    ' Measure sampling frequency.
    dira[1] := 1
    repeat
      value := ina219.readCurrent
      outa[1] := 1
      value := ina219.readCurrent
      outa[1] := 0

  knob := 0
  quad.start(2, @knob)
  
  if 0
    dira[SCOPE_PIN] := 1
    frqa := 1
    ctra := (%00110 << 26) | SCOPE_PIN
    freq := 1
    phase := 0
    if 1
      repeat
        frqa := knob*$00a3_d70a
    else
      repeat
        frqa := phase
        phase += freq
        freq := knob*10000

  dira[SCOPE_PIN] := 1
  frqa := 1
  ctra := (%00110 << 26) | SCOPE_PIN

  repeat
    ' Display is laid out like this:
    ' Voltage (V)       Current (mA)
    ' Shunt (V)           Power (mW)

    targetVoltageMv := knob*25 #> 0 <# 13000

    ' Voltage (V).
    value := ina219.readBus
    lcd.move_cursor(0, 0)
    lcd.rjdec_milli(value, LCD_WIDTH/2 - 2, " ")
    lcd.str(@Volt)
    
    ' PID.
    errorMv := targetVoltageMv - value
    frqa += errorMv*300000

    ' Current (A).
    value := ina219.readCurrent
    lcd.rjdec_milli(value, LCD_WIDTH/2 - 2, " ")
    lcd.str(@Amp)

    ' Target voltage (mV)
    lcd.move_cursor(0, 1)
    lcd.rjdec_milli(targetVoltageMv, LCD_WIDTH/2 - 2, " ")
    lcd.str(@Volt)

    ' Power (W)
    value := ina219.readPower
    lcd.rjdec_milli(value, LCD_WIDTH/2 - 2, " ")
    lcd.str(@Watt)

    waitcnt(clkfreq/10 + cnt)

  ' Blink light.
  dira[LED_PIN] := 1
  repeat
    waitcnt(clkfreq/4 + cnt)
    outa[LED_PIN] := 1
    waitcnt(clkfreq/4 + cnt)
    outa[LED_PIN] := 0
