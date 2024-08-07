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

### Chosen Demonstration Design

Our project involves designing a simple ultrasonic sonar board. The design will incorporate ten ultrasonic transducers: five for transmitting signals and five for receiving them. These transducers will be directly integrated into the circuit board. Initial signal filtering and basic processing will be performed within the FPGA fabric, while more complex computations will be handled by the ARM cores. The final results will be displayed via a DisplayPort output, providing a visual representation of the sonar data.

## Architecture #

Here's the key components of the design:

1. Xilinx Zynq SoC
2. DDR4 memory
3. Flash memory for bring-up
4. Ultrasonic transducers.
5. Low-pass filter for receiving transducers.
6. ADC for receiving transducers.
7. Amplifier for transmitting transducers.
8. DAC for transmitting transducers.
9. USB 2.0 and JTAG interface for bring-up and debugging
10. Ethernet for output.
11. MicroSD for permanent storage.

![Block diagram of the Zynq FPGA-based Design](../pics/block-diagram.png)

## Brainstorming Questions ##

- What ethernet PHY do we use?
- Can the FPGA fabric read from the same DDR RAM as the ARM cores?
- How do we boot this board?
- How do we program this board? FPGA, ARM cores, Flash.
- How do we design the transducer transmit and receive circuits?

## Project Milestones

- Learn the software toolchain. Buy a reference board and try to bring it up and boot Linux. [](learn-software-toolchain.md)
- Understand the reference design schematic. [](understand-ref-design.md)
- (OLD) Detailed part selection. [](part-selection.md)
