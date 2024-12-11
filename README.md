# Tetris on Basys 3 FPGA

Welcome to the **Tetris on Basys 3 FPGA** project! This is a recreation of the classic Tetris game, implemented using finite state machines and hardware design principles. The game is designed to run on the Basys 3 FPGA board, featuring VGA output for live rendering and a 7-segment display for score tracking.

---

## Table of Contents
- [About the Project](#about-the-project)
- [Features](#features)
- [Getting Started](#getting-started)
- [How to Play](#how-to-play)
- [Implementation Details](#implementation-details)
- [Future Enhancements](#future-enhancements)
- [Acknowledgments](#acknowledgments)

---

## About the Project

This project brings the timeless fun of Tetris to the Basys 3 FPGA platform. The game logic is implemented using finite state machines, with several sequential components driving the gameplay. Players interact with the game using buttons on the Basys 3 board, while the VGA output provides real-time visuals of block movements and interactions. The 7-segment display tracks the player's score, which increases as rows are cleared.

### Key Highlights:
- **Platform**: Basys 3 FPGA
- **Game Logic**: Finite State Machines (FSMs)
- **Output**: VGA for live visuals
- **Score Tracking**: 7-segment display
- **Control**: On-board buttons for gameplay

---

## Features

- Classic Tetris gameplay with seven different tetromino shapes.
- Real-time rendering via VGA output.
- Score tracking based on cleared rows.
- Hardware-based implementation using Verilog HDL.
- Intuitive controls mapped to Basys 3 board buttons.

---

## Getting Started

### Prerequisites
To run this project, you will need:
1. A Basys 3 FPGA development board.
2. Xilinx Vivado software for synthesis and programming.
3. VGA monitor for visual output.

### Setup Instructions
1. Clone or download this repository to your local machine.
2. Open the project in Xilinx Vivado.
3. Synthesize and implement the design.
4. Program the Basys 3 board with the generated bitstream file.
5. Connect a VGA monitor to the board and power it up.

---

## How to Play

1. Use the on-board buttons to control tetromino movement:
   - **Left Button**: Move block left.
   - **Right Button**: Move block right.
   - **Center Button**: Reset.
2. Clear rows by completing horizontal lines without gaps.
3. The game ends when blocks stack up to the top of the playfield.

Scoring is displayed on the 7-segment display, with each cleared row adding to your total score.

---


## Implementation Details

### Game Logic
The game is driven by finite state machines (FSMs), which manage:
- Tetromino generation and movement.
- Collision detection with other blocks and boundaries.
- Row clearing logic.

### Hardware Components
1. **VGA Output Module**: Handles rendering of blocks on a connected monitor.
2. **Score Display Module**: Updates and displays score on the 7-segment display.
3. **Control Logic**: Maps button inputs to gameplay actions.

### Design Tools
The project is implemented in Verilog HDL and tested using Xilinx Vivado simulation tools.

---

## Future Enhancements

Here are some potential improvements for future iterations:
1. Add sound effects using an audio output module.
2. Implement rotation features. 
3. Implement difficulty levels that increase block drop speed over time.
4. Include a pause functionality using an additional button or switch.
5. Expand score tracking with multi-digit displays or external displays.

---

## Acknowledgments

This project was inspired by the classic Tetris game and serves as an educational exercise in hardware design using FPGAs. Special thanks to resources and tutorials that guided the development process.

--- 

Enjoy playing Tetris on your Basys 3 FPGA!

