# Understanding the Reference Design #

## Documents ##

[Overview of Reference Design](../datasheets/zynq-ref-board-overview.pdf)

[Update on Reference Design](../datasheets/zynq-ref-board-update.pdf)
- Read and verify this update to the design. Previously missing termination resistor for DDR4.

[Link to Site with Documents](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/zuboard-1cg/)

[Getting Started](../datasheets/zynq-ref-board-getting-started.pdf)

[Hardware User's Guide](../datasheets/zynq-ref-board-hw-users-guide.pdf)

[Schematic](../datasheets/zynq-ref-board-schematic.pdf)

## Overall Architecture ##

- Provides microSD.
- Connects to 1GB RAM. 
- Connects to Ethernet.
- Provides JTAG/UART over microUSB.
- Provides USB2.0
- Powered by USB-C (Check whether enough for us.)
- Provides 256Mb Flash for boot

We don't need:
- Pressure & Temp sensors.
- MikroE Click expansion
- RTC
- SYZYGY expansion

## Generating the Reference Clock for the ARM Cores ##

![Reference Clock](figures/ref-clock.png)

Main component:
- U28 (DSC1525MI2A-33M33333) : Oscillator chip that produces a 33.33MHz clock signal. (VERIFY)

Power supply:
- Powered by 3.3V supply.
- C32 (100nF): Decoupling cap to reduce noise.

Enable Circuit:
- R198 (2.21K): Pull up resistor to keep EN high.

Output Circuit:
- R207 (22.1 ohm): Series termination resistor for clock trace. Keep this resistor close to OUT pin on clock chip. Keep overall trace to Pin H14 on ZynQ chip short.

## Supporting Flash ##

![QSPI](figures/qspi.png)

Main component:
- U10 (IS25WP256E-JLLE) flash memory chip.

Power supply:
- Powered by 1.8V supply.
- C31 (100nF): Decoupling cap to reduce noise.

Enable Circuit:
- R60 (4.75K): Pull-up resistor to keep CE# (Chip Enable) high.

SPI Clock input:
- SCK pin on flash chip.

Data lines:
- IO0, IO1, IO2, IO3 pins on flash chip going to MIO pins on ZynQ.

Defaults Configuration:
- WP# is Write Protect pin, active low on flash chip. (Verify)
  R65 (4.75K) pull-up resistor used to disable write protect by default.
- Hold# (Reset) is active low on flash chip. (Verify)
  R64 (4.75K) pull-up resistor used to keep it high for normal operation.

## uSD ##

![MicroSD](figures/usd.png)

Main components:
- U20 (PI4ULS3V4857): This is the voltage level translator chip. Used to convert signals between the 1.8V domain from the ZynQ to the 3.3V domain used by the SD card.
- J12 (2201778-1): The physical microSD card socket.

Power supplies:
- 1.8V supply for the ZynQ side.
- C79 (100nF): Decoupling cap for 1.8V side of level translator.
- 3.3V supply for the SD card side.
- C81 (100nF): Decoupling cap for 3.3V side of level translator.
- C208 (100nF): Decoupling cap for 3.3V supply for microSD socket.

MicroSD Spec:
- R286 (4.99K): Pull up resistor to keep CMD line high. Dictated by spec. (VERIFY)

Signal lines from ZynQ:
- MIO50_SD1_CMD: command signaled by
- MIO50_SD1_CLK: clock signal
- MIO46_SD1_DAT0, MIO47_SD1_DAT1, MIO48_SD1_DAT2, MIO49_SD1_DAT3: data signals
  These signals go into DAT0, DAT1, DAT2, DAT3 pins on microSD.
  
Configuring the level translator:
- R113 (0 ohm): Sets the mode of operation for the level translator. (VERIFY)

Remaining questions:
- What are the 0-ohm resistors for? How does the CardDetect circuitry work?
- What are the SWA/SWB pins on the MicroSD? What is R274 for?
- Why do the GND pins on J12 require a ferrite bead? Why don't the other GND pins need one?

## Supporting JTAG ##

### Level Translation ###

![JTag Level Translation](figures/jtag-level-translation.png)

Main component:
- U24 (NVT2010PW,118): This is the voltage level translator.
  Converts 1.8V signals from FPGA to 3.3V for JTAG.
- 1.8V and 3.3V supplies connected to VREFA and VREFB pins respectively.

Signals being translated:
- JTAG signals:
  JTAG_TCK_1V8 => JTAG_TCK_3V3
  JTAG_TMS_1V8 => JTAG_TCK_3V3
  JTAG_TDI_1V8 => JTAG_TCK_3V3
  JTAG_TDO_1V8 => JTAG_TCK_3V3
- System reset:
  PS_SRST_N_1V8 => PS_SRST_N_3V3
- Power-on reset:
  PS_POR_N_1V8 => PS_POR_N_3V3
- UART transmit and receive:
  MIO11_UART0_TX_1V8 => MIO11_UART0_TX_3V3
  MIO10_UART0_RX_1V8 => MIO10_UART0_RX_3V3
  
Pull-up resistors:
- R184, R178, R41, R176, R39, R171, R37, R168 (4.75K): Ensure signals are high when not actively driven.

Enable circuit:
- Simple low-pass filter R42(200K) and C115(100nF) to reduce noise on EN.

Remaining questions:
- There are no decoupling caps on VREFA and VREFB. Why?

### JTAG/UART MicroUSB Connector ###

![JTAG MicroUSB](figures/jtag-microusb.png)

Main component:
- J16 (47589-0001): This is the 5-pin MicroUSB connector. 
  - Pin USB5V0: 5V power supply from the USB.
  - Pins D- and D+: The USB data lines.
  - Pin ID: Identifies the type of USB connection.
  - Pin GND: Ground connection.
  
Power rails:
- USB1_5V0: This will be the 5V power supply line from the USB connector.

USB Signals:
- ULPI1_D_N, ULPI1_D_P: The USB differential data lines.

Remaining questions:
- Do we use the USB1_5V0 anywhere else on the board?
- What is the ID_JTAG_UART signal for?
- What is the C101 and 0-ohm R144 doing on the S1,S2,S3,S4 pins?

### JTAG/UART Interface ###

![JTAG UART](figures/jtag-uart.png)

Main component:
- U17 (FT2232HL) is a USB to UART IC: it converts USB signals to UART and JTAG protocols.
- VREGIN: Main 3.3V input.
- VREGOUT: Integrated voltage regulator 1.8V output. This can be used to connect to VCORE with 3.3uF filter capacitor.
- VPHY: This pin powers the USB physical layer interface.
  It needs a clean 3.3V supply.
  We connect it to a dedicated 3V3_PHY supply.
- VPLL: This pin powers the internal PLL of the chip.
  It needs a very clean, low-noise 3.3V supply.
  We connect it to a dedicated 3V3_PLL supply.
- VCORE: This powers the internal core logic of the chip, and needs a 1.8V supply.
  We connect it to the integrated VREGOUT pin.
- VCCIO: This powers the I/O banks of the chip.
  Our desired I/O voltage is 3.3V so we connect it to the main 3V3 rail.
- C73 (4.7uF) and C74 (100nF) are decoupling caps for VREGIN.
- C61 (4.7uF) is the decoupling cap for VREGOUT.
- REF pin: Current reference. Specified on datasheet to be connected via 12K@1% resistor (R272) to ground.

USB Signals and ESD Protection:
- D21 (CDSOT23-SR208) is a TVS (Transient Voltage Suppressor) diode array. It protects the USB data lines (ULPI1_D_N, ULPI1_D_P) from electrostatic discharge.
- Once protected, the signal goes into the DM and DP pins on the FT2232.
- Note: Make sure during physical layout that the TVS diodes are close to the USB connector.

JTAG Signals:
- The four primary jtag signals (JTAG_TCK_3V3, JTAG_TDI_3V3, JTAG_TDO_3V3, JTAG_TMS_3V3) are output by pins ADBUS[0-3].
- R128, R129, R130, R131 (22.1 ohm) are series termination resistors for matching impedance.

Reset Signals:
- Power-on reset and system reset (PS_POR_N_3V3, PS_SRST_N_3V3) is output from ADBUS[6-7].

UART Signals:
- UART signals from fpga (MIO10_UART0_RX_3V3, MIO11_UART0_TX_3V3) connect to BDBUS[0-1].
- Note: UART transmit MIO11_UART0_TX_3V3 is *received* by FT2232HL_RX (BDBUS1).
        UART receive  MIO10_UART0_RX_3V3 is *transmitted* by FT2232HL_TX (BDBUS0).
        
USB suspend:
- Suspend mode detection is not used. SUSPEND pin is left floating.

Enable circuit:
- PWREN# pin is an active-low power enable. Connected to PWREN_N signal.

Unused Pins:
- ACBUS[0-7] unused.
- BDBUS[2-7] unused but go to test points for debugging.
- BCBUS[0-7] unused. 

EEPROM Configuration:
- U38 (93LC56B) is a 2MHz, 2Kb EEPROM for storing configuration data for the FT2232HL chip.
- Powered by 3V3 rail connected to VCC pin. C204 (100nF) for decoupling.
- EEPROM signals connected to FT2232.
  CS (Chip Select)           -> EECS
  CLK (Clock)                -> EECLK (with R275 22.1ohm termination resistor)
  DI,DO (Data In, Data Out)  -> EEDATA (Bidirectional data line)
- DI, CLK, CS signals default to high using pull-up resistors (R276, R278, R282, 10K)
  DO default to high through an additional R283 (2K) resistor.

- Note about bidirectional data line:
  To write to EEPROM:
  - FT2232HL drives EEDATA directly.
  To read from EEPROM:
  - FT2232HL sets EEDATA to Hi-Z.
  - EEPROM then drives DO.
  
Clock for FT2232 chip:
- Provided by X2 (ECS-120-10-33B-CKM-TR), a 12MHz crystal with C86, C97 (18pF) load capacitors.
- Feeds into OSCI and OSCO pins.

Test mode:
- TEST pin is jumpered to GND using R265 (0-ohm).
- This sets FT2232HL to "Normal Operation Mode" instead of "Test Mode".


Remaining questions:
- What are the VREGIN and VREGOUT pins on U17. How to use them?
- How does the 5V supply from USB1_5V0 relate to this part of the schematic?
- VPHY and VPLL supplies need to be as clean as possible. Are they connected to separate regulators?
- No decoupling caps are needed for VPHY, VPLL, VCORE, VCCIO?
- Where is ID_JTAG_UART going?
- How do we correctly use the CDSOT23? What is the USB1_5V0 connection for?
- The DNP resistors R136, R133, R135, R134 for the JTAG signals ensure a default high signal. Are they necessary?
- What is the pull-up R120 on ADBUS4 for?
- What is happening to the ADBUS5 pin?
- How do we know the reset signals come out of ADBUS[6-7]?
- Why do the reset signals (PS_POR_N_3V3, PS_SRST_N_3V3) have 0-ohm jumpers and test points? Delicate place in the schematic?
- Why does BDBUS[2-7] have test points? What about the other unused pins?
- How do we program these EEPROMs on the board?
- How is the BCBUS7 power saving configuration working?
- Who sends out the PWREN_N signal? Is this for boot sequencing?
- Values of C86 and C97 load capacitors come from crystal datasheet?
- Where does the FT2232H_RST_N reset signal come from?

## Supporting USB2.0 ##

TODO...

## Supporting USB-C Power Input ##

TODO...

## Power Supplies ##

TODO...

## Supporting Ethernet ##

TODO...

## Supporting DDR4 ##