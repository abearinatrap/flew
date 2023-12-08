# Simulation/Emulation of FLEW: Fully Emulated WiFi

This is a repository for a project in CS538: Computer Communications and Networks at the University of Alabama

quency deviation that is permitted is specified in the Bluetooth® Core Specification and depends
on the selected symbol rate, which is either 1 or 2 mega-symbols per second (Msym/s) in Bluetooth
LE. For the 1 Msym/s symbol rate, a minimum frequency deviation of 185 kHz is specified, whereas
for the faster symbol rate, the minimum frequency deviation is 370 kHz. These values were chosen
carefully, to help make the recognition of encoded 1s and 0s in a signal reliable.

## Files
 - wave.m produces "modSig": demodulated 802.11b data. This can be seen in the data written below: bits 67-73 = 1010101 74-105 = 0x05AE4701

## Process by FSK chip
Following the [FLEW](https://doi.org/10.1145/3495243.3517030) paper proposal that, "with an appropriate frequency shift, conventional FM/FSK receivers can work as a DSSS plus DBPSK demodulater"

 - Receiver has a frequency offset of 1.22MHz and two low pass filters are used, allowing a 802.11b waveform to be demodulated by an FSK chip.

- After signal is demodulated, WiFi bits must be descrambled following this process: 

```c
/* The descrambling process is extremely simple. Furthermore, the descrambling can be done in batch to each byte or word, and does not require extracting/reassembling bits to process them one-by-one. Specifically, the descrambling in 802.11b can be simplified as XOR’ing the input with two shifted versions of the input. With least-significant-bit-first ordering, the descrambling process involves only 4 lines of code: */

// from FLEW
reg = (descrambling_in<<8) | lastbyte;
reg2 = reg ^ (reg>>3) ^ (reg>>7);
descrambling_out = 0xFF & (reg2);
lastbyte = descrambling_in;
```

bit 67 to
bit 73 of the DBPSK bit stream is [1,0,1,0,1,0,1] and bit 74 to bit 105
is 0x05AE4701. Therefore, we configure FSK chips to search for
0x05AE4701. Once this sequence is detected, FSK chips continuously
put subsequent bytes into the receive FIFO. We can thus periodically
retrieve these bytes and descramble them to recover the WiFi packet.
The reception is terminated once the number of bytes received
reaches the length specified in the PLCP header.

The tail of each WiFi packet is 4 bytes of FCS, which is the CRC32
of the data field. FCS is used to check the integrity of the received
packet and if the calculated FCS does not match the received FCS,
the receiver should not acknowledge this packet and the transmitter
will re-transmit the packet. The implementation of FCS in FLEW is
straightforward. We add a few optimizations, such as using table-
based calculation and updating the CRC immediately after receiving
each byte.

"The SSP module either sends 10110111000
or 01001000111, depending on each PSK bit."