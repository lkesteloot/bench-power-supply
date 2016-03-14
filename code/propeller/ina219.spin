
{ Code for communcation with an INA219 current-sensing device. }

CON
  REG_CONFIG = 0
  REG_SHUNT_VOLTAGE = 1
  REG_BUS_VOLTAGE = 2
  REG_REG_POWER = 3
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
  reg := 5120 << 1  ' LSB not used.
  write_word(REG_CALIBRATION, reg)
  ' %0010_0000_0000_0000 |          ' 32 V for bus range
  ' %0001_1000_0000_0000 |          ' 320 mV shunt range (divide by 8)
  ' %0000_0001_1000_0000 |          ' 12-bit (532 µs) shunt sampling
  ' %0000_0000_0001_1000 |          ' 12-bit (532 µs) bus sampling
  ' %0000_0000_0000_0111            ' Continuous bus and shunt sampling.
  write_word(REG_CONFIG, %0011_1001_1001_1111)

PUB read | value
  i2c.start
  i2c.write((i2c_addr << 1) | 0)
  i2c.write(REG_SHUNT_VOLTAGE)
  i2c.start
  i2c.write((i2c_addr << 1) | 1)
  value := i2c.read(0)
  value := (value << 8) | i2c.read(0)
  i2c.stop
  return value
  
PRI write_word(register, value)
  i2c.start
  i2c.write((i2c_addr << 1) | 0)
  i2c.write(register)
  i2c.write((value >> 8) & $FF)
  i2c.write((value >> 0) & $FF)
  i2c.stop
