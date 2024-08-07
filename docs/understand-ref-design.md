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

TODO...

## Supporting USB2.0 ##

TODO...

## Supporting USB-C Power Input ##

TODO...

## Power Supplies ##

TODO...
