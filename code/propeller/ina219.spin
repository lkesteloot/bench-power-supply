
{ Code for communcation with an INA219 current-sensing device. }

CON
  REG_CONFIG = 0
  REG_SHUNT_VOLTAGE = 1
  REG_BUS_VOLTAGE = 2
  REG_POWER = 3
  REG_CURRENT = 4
  REG_CALIBRATION = 5

OBJ
  i2c : "jm_i2c"

VAR
  byte scl_pin
  byte sda_pin
  byte i2c_addr

PUB null                                                         
                                                                 
  ' This is not a top-level object   

PUB start(scl, sda, addr) | reg
  scl_pin := scl
  sda_pin := sda
  i2c_addr := addr

  i2c.setup

  ' See page 12 of the datasheet.
  ' max_current = 2.62A
  ' current_lsb = max_current / 2^15
  ' R_shunt = 0.1 Ω
  ' calibration = 0.04096 / (current_lsb * R_shunt) = 5122
  ' round to 5120
  reg := 5120   ' LSB not used.
  write_word(REG_CALIBRATION, reg)
  ' %0010_0000_0000_0000 |          ' 32 V for bus range
  ' %0001_1000_0000_0000 |          ' 320 mV shunt range (divide by 8)
  ' %0000_0001_1000_0000 |          ' 12-bit (532 µs) shunt sampling
  ' %0000_0000_0001_1000 |          ' 12-bit (532 µs) bus sampling
  ' %0000_0000_0000_0111            ' Continuous bus and shunt sampling.
  write_word(REG_CONFIG, %0011_1001_1001_1111)

' Shunt resistor voltage drop, in µV.
PUB readShunt
  return read_word(REG_SHUNT_VOLTAGE)*10

' Current in mA.
PUB readCurrent
  return read_word(REG_CURRENT)*8/100

' Bus voltage in mV.
PUB readBus
  ' The 3 least significant bits are for other things.
  ' The LSB is 4 mV.
  return (read_word(REG_BUS_VOLTAGE) >> 3)*4

' Power being used, in mW.
PUB readPower
  ' Reading times current LSB times 20.
  return read_word(REG_POWER)*8/5
  
PRI read_word(reg) | value
  i2c.start
  i2c.write((i2c_addr << 1) | 0)
  i2c.write(reg)
  i2c.start
  i2c.write((i2c_addr << 1) | 1)
  value := i2c.read(0)
  value := (value << 8) | i2c.read(0)
  i2c.stop
  return value    ' sign-extend from 16 bits to 32.

PRI write_word(register, value)
  i2c.start
  i2c.write((i2c_addr << 1) | 0)
  i2c.write(register)
  i2c.write((value >> 8) & $FF)
  i2c.write((value >> 0) & $FF)
  i2c.stop
