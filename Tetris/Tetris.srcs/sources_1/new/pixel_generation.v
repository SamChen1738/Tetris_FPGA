`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 02:25:46 PM
// Design Name: 
// Module Name: pixel_generation
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


module pixel_generation(
        input reset,
        input clk,
        input [9:0] x,              
        input [9:0] y, 
        input video_on,
        input [127:0] board,
        output reg [11:0] rgb
    );
    
    parameter BLOCK_SIZE = 20;          

    integer block_x;                
    integer block_y;                

    always @* begin
        if (reset | ~video_on) begin
            rgb = 12'hF11;          
        end else begin
            block_x = x / BLOCK_SIZE;
            block_y = y / BLOCK_SIZE;

            if ((block_x < 8) && (block_y < 16)) begin
                if (board[block_x * 8 + block_y]) begin
                    rgb = 12'hFFF;  
                end else begin
                    rgb = 12'hF11;  
                end
            end else begin
                rgb = 12'hF11;      
            end
        end 
    end
     
endmodule
