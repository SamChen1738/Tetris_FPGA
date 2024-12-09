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
    input left_button,
    input right_button,
    output hsync,
    output vsync,
    output [11:0] rgb,
    output [0:6] seg,
    output [3:0] digit
    );
    
    wire video_on, p_tick;
    wire [9:0] x, y;
    reg [11:0] rgb_reg;
    wire [3:0] score_ones, score_tens, score_hundreds, score_thousands;
    wire [11:0] rgb_next;
    wire [3:0] keypad_input;
    integer i;
    
    assign keypad_input = {2'b00, right_button, left_button};

    vga_controller vga (.clk(clk), .reset(reset), .video_on(video_on),
                        .hsync(hsync), .vsync(vsync), .p_tick(p_tick), .x(x), .y(y));
    tetris tetris_inst(.clk(clk), .reset(reset), .keypad_input(keypad_input), .x(x), .y(y), .video_on(video_on), .rgb(rgb_next), .score_ones(score_ones), .score_tens(score_tens), .score_hundreds(score_hundreds), .score_thousands(score_thousands));
    seg7_control seg_control(.clk_100MHz(clk), .reset(reset), .ones(score_ones), .tens(score_tens), .hundreds(score_hundreds), .thousands(score_thousands), .seg(seg), .digit(digit));
    
    always @(posedge clk or posedge reset)
    if (reset)
       rgb_reg <= 0;
    else if(p_tick) begin
       rgb_reg <= rgb_next;
    end
    
    // Output
    assign rgb = (video_on) ? rgb_reg : 12'b0; 
endmodule
