# FPGA-Audio-IIR

I realized realtime IIR-filters for audio signal processing in a FPGA.  
See my YouTube video here: https://www.youtube.com/watch?v=eE6Qwv997cs. 

The used hardware is a TinyFPGA-BX board (see here: https://tinyfpga.com/ ) and a PMOD I2S2 Board (see here: https://store.digilentinc.com/pmod-i2s2-stereo-audio-input-and-output/)

The whole systems runs at 96 kHz sampling-frequency with a FPGA system-clock of 25 MHz (internal PLL used).
The left channel is low-pass filtered at 1 kHz and the right channel is high-pass filtered at 1 kHz.

See in attach the VHDL-source files, screenshots of the simulation of I2S-RXTX and IIR filter and the original iCEcube2 project files



The ADC/DAC board is connect to the FPGA board via following pinout:

PIN24 - ADC-MCLK  
PIN23 - ADC-BCLK  
PIN22 - ADC-LR  
PIN21 - ADC-DATA  
PIN20 - DAC-MCLK  
PIN19 - DAC-BCLK  
PIN18 - DAC-LR  
PIN17 - DAC-DATA
