# FPGA Example Design: Xilinx Zynq Board

## Project Goals and Future Prospects

### Primary Objectives

- Develop an FPGA design of moderate complexity using JITX, serving as a comprehensive overview of the tool's capabilities.
- Utilize this design as a stress test to identify and resolve bugs in the JITX toolchain, while ensuring adequate performance.
- Create a compelling marketing asset: A Zynq-based board represents a significant engineering challenge. Successfully implementing this design demonstrates JITX's ability to handle complex projects, appealing to professionals already working with the Zynq platform and those engaged in projects of similar complexity.

### Future Enhancements

- Refactor the codebase to improve reusability and parameterization, with the ultimate goal of integrating it into the JSL library.
- Expand the design to interface with a VPX backplane, contingent upon the development of a VPX backplane generator. This addition would transform the project into a highly attractive example for specific industry players, such as Lockheed-Martin.
- Potential to evolve into a world-class VPX backplane solution, further enhancing JITX's market position in specialized, high-performance computing applications.

## Architecture

Here's the key components of the design:

1. Xilinx Zynq SoC
2. DDR4 memory
3. Flash memory for bring-up
4. ADC input to the FPGA, fed from a Coax connector
5. HDMI output
6. USB 2.0 and JTAG interface for bring-up and debugging

![Block diagram of the Zynq FPGA-based Design](../pics/block-diagram.png)

## Part Selection

### FPGA device

Considering *XCZU1CG-1UBVA494I*:

- Driven by need to support DDR4 memory. Lower-cost Zynq-7000 series only support up to DDR3.
- Lowest-cost Zynq Ultrascale+ part in stock on Digikey is XCZU1CG-1UBVA494I: $292.52
- Dual core Arm Cortex-A53 (APU) + Dual core Arm Cortex-R5F (RPU)
- 81,900 Logic cells.
- 170 PS (Processing System) I/O, supporting 32-bit DDR4 only.
- 24 HD (High-Density) I/O. 58 HP (High-Performance) I/O.

#### Supported DDR4 memory speed

- For UBVA494 package
- For 1-rank components: Min 1000 Mb/s. Max 1866 Mb/s
- For 2-rank components w/ dual-rank package: Min 1000 Mb/s. Max 1600 Mb/s.
- For 2-rank components w/ single-rank package: Min 1000 Mb/s. Max 1333 Mb/s.

See Table 30 in *ds925-zynq-ultrascale-dc-ac-switching-characteristics.pdf*. 

#### Selecting a memory configuration

1. Memory Type: DDR4
2. Total Capacity: 4 GB (32 Gb)
3. Data Width: 32-bit
4. Component Configuration: 2 x 16Gb DDR4 chips (x16 width each)
5. Single rank
6. No ECC

This configuration uses two 16 Gb (2 GB) DDR4 chips, each with a x16 interface, to create a 32-bit wide data bus with a total capacity of 4 GB. Keep the design simple using a single rank configuration, which also allows utilization of full 1866 Mb/s speed. See Table 17-1 in *ug1085-memory-excerpt.pdf*. 

### Memory ICs

Based on above requirements Micron *MT40A1G16TD-062E AIT:F* seems to work. Currently in-stock at Digikey for $18.73.

## Selecting an ADC

The ZynQ has MIO (Multiplexed I/O) and EMIO (Extended Multipled I/O) pins, with SPI available on both. 

The datasheet says that SPI performance is better using the MIO pins. (Table 28-2 in technical reference manual). 

The MIO pins can be configured for 1.8V or 3.3V signaling. (Chapter 28 in technical reference manual.)

Consider the Analog Devices *AD7091R-8BCPZ-RL7*.

- 12-bit input
- 1M samples per second
- SPI interface
- Voltage 2.09V - 5.25V

In stock for $9.93 at Digikey.
