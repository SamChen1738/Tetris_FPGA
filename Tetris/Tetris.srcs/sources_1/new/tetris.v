`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 05:48:42 PM
// Design Name: 
// Module Name: tetris
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


module tetris(
    input [3:0] keypad_input,
    input reset,
    input clk,
    output [15:0] board [7:0]
    );
    reg [7:0] current_board [15:0];
    reg [7:0] player_board [15:0];
    reg [7:0] display [15:0];
    reg [7:0] temp_byte;
    reg can_move;
    reg game_over;
    reg [7:0] lfsr;
    reg [7:0] bit;
    reg [2:0] rng;
    
    wire t_piece_top = 8'h10;
    wire t_piece_bottom = 8'h38;
    wire l_piece_top = 8'h38;
    wire l_piece_bottom = 8'h20;
    wire l_piece_mirrored_bottom = 8'h08;
    wire line_piece = 8'h3C;
    wire z_piece_left = 8'h30;
    wire z_piece_right = 8'h18;
    
    integer i, j, k;
    
    always @(posedge reset) begin 
        if(reset) begin  
            can_move <= 1;
            game_over <= 0;
            lfsr <= 8'hA8;
        end else begin
            bit <= (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) & 1;
            lfsr = (lfsr >> 1) | (bit << 15);
            for(i = 0; i < 16; i = i + 1) begin
                current_board[i] <= 8'h0;
                player_board[i] <= 8'h0;
                display[i] <= 8'h0;
            end
            while(~game_over) begin
                //generate new piece
                rng = lfsr & 3'b111;
                case(rng) 
                    8'h00: begin 
                        player_board[15] = t_piece_top; 
                        player_board[14] = t_piece_bottom;
                    end 
                    8'h01: begin
                        player_board[15] = line_piece;
                    end
                    8'h02: begin
                        player_board[15] = l_piece_top;
                        player_board[14] = l_piece_bottom;
                    end
                    8'h03: begin 
                        player_board[15] = l_piece_top;
                        player_board[14] = l_piece_mirrored_bottom;
                    end
                    8'h04: begin
                        //it says z piece but it makes a square
                        player_board[15] = z_piece_left;
                        player_board[14] = z_piece_left;
                    end
                    8'h05: begin
                        player_board[15] = z_piece_left;
                        player_board[14] = z_piece_right;
                    end
                    8'h06: begin
                        player_board[15] = z_piece_right;
                        player_board[14] = z_piece_left;
                    end
                    8'h07: begin
                        player_board[15] = t_piece_top; 
                        player_board[14] = t_piece_bottom;
                    end
                endcase
                while(can_move) begin
                    //add code for moving piece
                    //missing code
                    //checks if moving is possible
                    for(i = 15; i > 0; i = i - 1) begin
                        if(player_board[j] & current_board[j-1] != 8'h0) begin
                            can_move = 0;
                        end
                    end
                    //moves the player block down and updates the display
                    if(can_move) begin
                        for(i = 0; i < 15; i = i + 1) begin 
                            player_board[j] = player_board[j+1];
                            display[j] = current_board[j] | player_board[j];
                        end
                        display[15] = current_board[15] | player_board[15];
                    end
                end
                //updates the current board, clears the player board, and clears any rows
                for(i = 0; i < 15; i = i + 1) begin
                    current_board[i] = current_board[i] | player_board[i];
                    player_board[i] = 8'h0;
                    if(current_board[i] == 8'hff) begin
                        current_board[i] = 8'h0;
                    end
                end
                //moves rows down if there are any cleared rows
                for(i = 0; i < 15; i = i + 1) begin
                    if(current_board[i] == 8'h0) begin
                        for(j = i; j < 14; j = j + 1) begin
                            current_board[j] = current_board[j+1];
                        end
                        i = i - 1;
                    end
                end
            end
        end
    end
endmodule
