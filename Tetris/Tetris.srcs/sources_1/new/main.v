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
    output [11:0] rgb
    );
    
    wire video_on, p_tick;
    wire [9:0] x, y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    
    vga_controller vga (.clk(clk), .reset(reset), .video_on(video_on),
                        .hsync(hsync), .vsync(vsync), .p_tick(p_tick), .x(x), .y(y));
    tetris tetris(.clk(clk), .reset(reset), .keypad_input(keypad_input), .x(x), .y(y), .video_on(video_on), .rgb(rgb_next));
    
    
//    always @(posedge clk) begin 
//        if(p_tick) begin
//            rgb_reg = rgb_next;
//        end
//    end
    
//    assign rgb = rgb_reg;
    assign rgb = 12'hF00;
endmodule
