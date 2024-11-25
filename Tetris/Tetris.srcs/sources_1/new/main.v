`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2024 03:05:07 PM
// Design Name: 
// Module Name: main
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


module main(
    input clk,
    input reset,
    input [3:0] keypad_input,
    output hsync,
    output vsync,
    output [2:0] rgb
    );
    
    wire w_reset, video_on, p_tick;
    wire [9:0] x, y;
    reg [2:0] rgb_reg;
    wire [2:0] rgb_next;
    wire [127:0] board;
    
    
    vga_controller vga (.clk(clk), .reset(w_reset), .video_on(video_on),
                        .hsync(hsync), .vsync(vsync), .p_tick(p_tick), .x(x), .y(y));
    tetris tetris(.clk(clk), .reset(w_reset), .keypad_input(keypad_input), .board(board));
    pixel_gen pixel(.clk(clk), .reset(reset), .board(board), .x(x), .y(y), .rgb(rgb_next));
    
    always @(posedge clk) begin 
        if(p_tick) begin
            rgb_reg = rgb_next;
        end
    end
    
    assign rgb = rgb_reg;
endmodule
