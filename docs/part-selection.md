## Part Selection

### FPGA device

Considering *XCZU2CG-L1SFVC784I*:

- Supports DDR4 memory. (Lower-cost Zynq-7000 series only support up to DDR3.)
- SFVC784 package supports from U1 to U5, which means we can easily later extend to support PCIe Gen3, and GTH highspeed transceivers.
- In stock on Digikey: $406.25
- Dual core Arm Cortex-A53 (APU) + Dual core Arm Cortex-R5F (RPU)
- 103K Logic cells.

TODO: Re-verify
- 170 PS (Processing System) I/O, supporting 32-bit DDR4 only.
- 24 HD (High-Density) I/O. 58 HP (High-Performance) I/O.

Datasheet: ds891-zynq-ultrascale-plus-overview.pdf

#### Supported DDR4 memory speed

TODO: Re-verify section.

- For UBVA494 package
- For 1-rank components: Min 1000 Mb/s. Max 1866 Mb/s
- For 2-rank components w/ dual-rank package: Min 1000 Mb/s. Max 1600 Mb/s.
- For 2-rank components w/ single-rank package: Min 1000 Mb/s. Max 1333 Mb/s.

See Table 30 in *ds925-zynq-ultrascale-dc-ac-switching-characteristics.pdf*. 

#### Selecting a memory configuration

TODO: Re-verify section.
- Can the RAM be accessed from both the FPGA fabric and processing system?
- How much memory needed to buffer signal: (range / speed-of-sound) * samples-per-second * 2 (for transmit and receive).

1. Memory Type: DDR4
2. Total Capacity: 4 GB (32 Gb)
3. Data Width: 32-bit
4. Component Configuration: 2 x 16Gb DDR4 chips (x16 width each)
5. Single rank
6. No ECC

This configuration uses two 16 Gb (2 GB) DDR4 chips, each with a x16 interface, to create a 32-bit wide data bus with a total capacity of 4 GB. Keep the design simple using a single rank configuration, which also allows utilization of full 1866 Mb/s speed. See Table 17-1 in *ug1085-memory-excerpt.pdf*. 

### Memory ICs

Based on above requirements Micron *MT40A1G16TD-062E AIT:F* seems to work. Currently in-stock at Digikey for $18.73.

Datasheet: micron-MT40A1G16.pdf

### Selecting an ADC ###

The ZynQ has MIO (Multiplexed I/O) and EMIO (Extended Multipled I/O) pins, with SPI available on both. 

The datasheet says that SPI performance is better using the MIO pins. (Table 28-2 in technical reference manual). 

The MIO pins can be configured for 1.8V or 3.3V signaling. (Chapter 28 in technical reference manual.)

Consider the Analog Devices *AD7091R-8BCPZ-RL7*.

- 12-bit input
- 1M samples per second
- SPI interface
- Voltage 2.09V - 5.25V

In stock for $9.93 at Digikey.

Datasheet: AD7091R.pdf

VERIFY: Maximum I/O pad frequency on fpga. 

Ultrasonics:
https://www.digikey.com/en/products/detail/murata-electronics/MA40S4R/4358146
https://www.digikey.com/en/products/detail/murata-electronics/MA40S4S/4358147


### Supporting Flash ###

Considerations:
- For simplicity: Let's use QSPI Flash for bring-up. Ensure that the flash memory chip supports QSPI. (VERIFY)
- TODO: What storage capacity do we need? Can we start with 128 MB (1 Gb)?
- Ensure that chip's operating voltage matches. The FPGA operates at 1.8V or 3.3V for I/O banks.
- Ensure FPGA supports this Flash device.

TODO: 
- Check FPGA for typical bitstream size.
- May want to consider 256 MB to start.

Consider *MT25QL01GBBB1EW9-0SIT TR*:

- 1Gb organized into 128Mb x 8.
- FLASH-NOR technology.
- QSPI
- 133 MHz
- In stock for $14.92 at Digikey.

Datasheet: micron-flash-mt25ql01gbbb.pdf

### MicroSD ###

TODO:
- If you need any persistent storage: logging??
- If you screw up the Flash, you can also boot from MicroSD.

### Filter between Coaxial SMA Connector and ADC ###

Adjustments:
- Keep the same filter for all channels (Fancy: We can parameterize the filter configuration per-channel.)
- 500 kHz input frequency is fine.
- Let's choose what type of input signal we're dealing with: ultrasonic. At least 5 pairs of channels, separate transducers on each, one with ADC (for receive) and one with DAC (for send). We're building a sonar!
- Put the transducers on board directly. Get rid of the Coax.

- TODO: What's the gain on the receive side? We want a good signal back.
- Maybe the transducer datasheet will tell us?
- We want an amplifier where we can tweak the gain. Design it so that we can change this gain after the board gets back.

- We want an amplifier on the transmit side, to drive higher voltages
  into the transducer. Aim for ~20V. This can be driven with a standard industrial 24V rail.
  
- Same filtering strategy as before. Low-pass to cut it off before Nyquist. Assuming 500 kHz input frequency is fine. "2-pole inverted op-amp" filter. Use a potentiometer for variable-gain. Drive the bias voltage into the positive input of the opamp to bias it properly into the ADC.

TODO: Initial reasoning (verify)
- Nyquist frequency of a 1MSPS ADC is 500 kHZ.
- Let's stay conservative and analyze signals between 0 to 100 kHz.
- To prevent aliasing, we'll use a lowpass filter.
- Let's use an active filter to be fancy for no good reason.
- Consider *TI OPA1656IDR*:
- In stock for $2.89 at Digikey.
- We can configure it into a 2nd-order low-pass Sallen-Key filter: sallen-key-filter.pdf

Datasheet: opa1655.pdf

### Supporting USB2.0 ###

TODO:
- Look at Microzed design, and just copy them.


For PHY: Consider *USB3320C-EZK-TR*
- 32-VFQFN Exposed Pad
- Surface mount.
- In stock for $2.17 at Digikey.

Datasheet: usb3320.pdf

For connector: Consider Amphenol *UE27AC5410H-ND*
- In stock for $0.75 on Digikey

Datasheet: amphenol-pue27acx4x0x.pdf

### Supporting JTAG ###

TODO:
- Figure out our tooling:
  How do we program the Flash?
  How do we program the FPGA?
  How do we debug the processor?
  That will tell us how to support the JTAG.  
- Carl has experience with Diligent HS2. 
  Note: that was for a pure FPGA. 
https://digilent.com/shop/jtag-hs2-programming-cable/?srsltid=AfmBOoqLsZfmlgDTJVVUHPHTSla2UwbTzeCPXre_07Q5Ms6-uXvQFlXY

Ref Design for MpSOC Ultrascale Zync
https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/520618122/Zynq%2BUltraScale%2BMPSoC%2BBase%2BTRD%2B2020.1

On Mouser $3600:
https://www.mouser.com/ProductDetail/AMD-Xilinx/EK-U1-ZCU102-G?qs=rrS6PyfT74c3gZCy0VJZsg%3D%3D


Avnet $160
https://www.avnet.com/shop/us/products/avnet-engineering-services/aes-zub-1cg-dk-g-3074457345648900673/

https://www.avnet.com/wps/wcm/connect/onesite/a8454269-3183-459c-8a48-0e80bd88c1e7/AES-ZUB-1CG-DK-G-Rev1_SCH_2022-08-05.PDF?MOD=AJPERES&CACHEID=ROOTWORKSPACE.Z18_NA5A1I41L0ICD0ABNDMDDG0000-a8454269-3183-459c-8a48-0e80bd88c1e7-oicjEdB

Vivado supports XCZU2CG under free license:

https://www.xilinx.com/products/design-tools/vivado/vivado-buy.html#architecture

### Supporting Clock ###

TODO:
- Need a 12 MHz clock generator.
- The datasheet will tell us it needs from the input clock signal.
- Either crystal or oscillator.

## Power System Design ##

Reference: power-design-guide.pdf

See the above document for an example design of a power system.

For PMIC, Consider TI *TPS6508641RSKT*:
- In stock for $11.03
- Used by the power design reference manual.

Datasheet: tps650864.pdf

General plan:
- Assume we can get 20V input from industrial power supply.
- Feed that into TPS directly to generate the lower rails.

### List of Required Rails ###

TODO:
- Will want some filtering, especially on the lower-voltage rails.
  (Perhaps the reference design already has them?)

For the ZynQ:
- VCCINT (core voltage for Zynq): 0.85V
- VCCAUX: 1.8V
- VCCO_PSDDR (for DDR4 interface): 1.2V
- VCC_PSPLL: 1.8V
- VCCBRAM: 0.85V

For DDR4:
- VDD: 1.2V
- VDDQ: 1.2V
- VTT: 0.6V  (<-- Typically done with an LDO. )

For ADC:
- 3.3V

For Flash:
- 3.3V

For general-purpose I/O peripherals:
- 3.3V

Minimal Configuration:
- 0.85V rail for VCCINT and VCCBRAM
- 1.2V rail for VCCO_PSDDR and DDR4 VDD/VDDQ
- 1.8V for VCCAUX, VCC_PSPLL
- 3.3V for general I/O, ADC, Flash
- 0.6V for DDR4 VTT

TODO:
- Select parts for push-button power-on/off control.
- Compute caps, inductors, and resistors.
- Select connector for wall power.
- The TPS6508641 needs external FETS for BUCK1, BUCK2 and BUCK6.
  Consider the CSD87381P NexFET power blocks.
