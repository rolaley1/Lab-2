# Lab 2 - Hamming Distance in Assembly

## Description
This program asks the user to enter two strings and then calculates the Hamming distance between them. The program compares the strings up to the length of the shorter string and counts how many bits are different between the two strings.

The source code is written in x86-64 Assembly and uses Linux system calls for input and output.

## Files
- `project2.s` - Assembly source code
- `README.md` - Project information and compiling instructions

## Requirements
To compile and run this program, you need:

- A Linux environment or GitHub Codespaces
- GNU assembler and linker, usually included with `binutils`
- `gcc`, if using the GCC compile option

## How to Compile

### Option 1: Using `as` and `ld`

Run these commands in the terminal:

```bash
as -o project2.o project2.s
ld -o project2 project2.o
