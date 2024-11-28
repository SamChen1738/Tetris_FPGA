`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2024 03:03:58 PM
// Design Name: 
// Module Name: pixel_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pixel_gen(
    input clk,
    input reset,
    input [127:0] board,        // Tetris board state
    input [9:0] x,              // Current pixel x-coordinate from VGA controller
    input [9:0] y,              // Current pixel y-coordinate from VGA controller
    output reg [11:0] rgb        // RGB color output for VGA display
);
    parameter BLOCK_SIZE = 20;       // Size of each Tetris block in pixels
    parameter GRID_WIDTH = 8;       // Number of blocks horizontally
    parameter GRID_HEIGHT = 16;     // Number of blocks vertically

    integer block_x;                // Column index of current block
    integer block_y;                // Row index of current block

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rgb <= 12'hF00;          // Black screen on reset
        end else begin
            // Map pixel coordinates to Tetris blocks
            block_x = x / BLOCK_SIZE;
            block_y = y / BLOCK_SIZE;

            // Check if within bounds of Tetris grid
            if ((block_x < GRID_WIDTH) && (block_y < GRID_HEIGHT)) begin
                // Check if the current block is active
                if (board[block_x * GRID_WIDTH + block_y]) begin
                    rgb <= 12'hFFF;  // White for active blocks (can change color here)
                end else begin
                    rgb <= 12'hF00;  // Black for empty spaces
                end
            end else begin
                rgb <= 12'hF00;      // Black outside Tetris grid area
            end
        end 
    end
endmodule
