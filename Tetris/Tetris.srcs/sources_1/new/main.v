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
    input sw,
    output hsync,
    output vsync,
    output [11:0] rgb
    );
    
    wire video_on, p_tick;
    wire [9:0] x, y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [3:0] keypad_input;
    reg sw_reg;
    integer i;
    
    assign keypad_input = {2'b00, right_button, left_button};
    vga_controller vga (.clk(clk), .reset(reset), .video_on(video_on),
                        .hsync(hsync), .vsync(vsync), .p_tick(p_tick), .x(x), .y(y));
    tetris tetris_inst(.clk(clk), .reset(reset), /*.keypad_input(keypad_input),*/ .x(x), .y(y), .video_on(video_on), .rgb(rgb_next));
    
    always @(posedge clk or posedge reset)
    if (reset)
       rgb_reg <= 0;
    else if(p_tick) begin
       for(i = 15; i >= 0; i = i - 1) begin
            $display("display_board[%0d]: %x    |    player_board[%0d]: %x    |    current_board[%0d]: %x", 
                i, 
                tetris_inst.display_board[i],
                i,
                tetris_inst.player_board[i],
                i, 
                tetris_inst.current_board[i]
            );
        end
       rgb_reg <= rgb_next;
    end
    
    // Output
    assign rgb = (video_on) ? rgb_reg : 12'b0; 
endmodule
