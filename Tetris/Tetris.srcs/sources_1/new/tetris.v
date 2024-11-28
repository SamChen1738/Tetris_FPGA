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
    input reset,
    input clk,
    input [3:0] keypad_input,
    output reg [127:0] board
    );
    reg [7:0] current_board [15:0];
    reg [7:0] current_board_next [15:0];
    reg [7:0] player_board [15:0];
    reg [7:0] player_board_next [15:0];
    reg [7:0] display_board [15:0];
    reg can_move;
    reg game_over;
    reg block_generate;
    reg [7:0] lfsr;
    reg [7:0] bit;
    reg [2:0] rng;
    reg distance_traveled;
    reg shift_down;
    reg rows_cleared;
    
    wire t_piece_top = 8'h10;
    wire t_piece_bottom = 8'h38;
    wire l_piece_top = 8'h38;
    wire l_piece_bottom = 8'h20;
    wire l_piece_mirrored_bottom = 8'h08;
    wire line_piece = 8'h3C;
    wire z_piece_left = 8'h30;
    wire z_piece_right = 8'h18;
    
    integer i,j;
    always @(posedge reset or posedge clk) begin
        if(reset | game_over) begin
            for(i = 0; i < 16; i = i + 1) begin
                current_board[i] = 8'h00;
                player_board[i] = 8'h00;
                display_board[i] = 8'h00;
                current_board_next[i] = 8'h00;
                player_board_next[i] = 8'h00;
            end
            can_move = 1;
            game_over = 0;
            block_generate = 1;
            lfsr = 8'hA8;
            bit = 8'h00;
            rng = 3'b000;
            distance_traveled = 0;
            shift_down = 0;
            rows_cleared = 0;
        end
        else begin
            for(i = 0; i < 16; i = i + 1) begin
                current_board[i] = current_board_next[i];
                player_board[i] = player_board_next[i];
                display_board[i] = player_board[i] | current_board[i];
                for(j = 0; j < 8; j = j + 1) begin
                    board[i * 8 + j] = display_board[i][j]; 
                end
            end
        end
    end
        
    //generate state
    always @(posedge block_generate) begin
        block_generate = 0;
        bit = (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) & 1;
        lfsr = (lfsr >> 1) | (bit << 7);
        rng = lfsr & 3'b111;
        can_move = 1;
        case(rng) 
                8'h00: begin 
                    player_board[15] = t_piece_top; 
                    player_board[14] = t_piece_bottom;
                end 
                8'h01: begin
                    player_board[14] = line_piece;
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
    end
    
    always @(posedge can_move) begin
        distance_traveled = distance_traveled + 1;
        //check for off by 1 error
        if(distance_traveled >= 14) begin
            distance_traveled = 0;
            can_move = 0;
        end
        for(i = 0; i < 16; i = i + 1) begin
            player_board_next[i] = player_board[i];
            current_board_next[i] = current_board[i];
        end
        for(i = 15; i > 0; i = i - 1) begin
            if(player_board_next[i] & current_board_next[i-1] != 8'h00) begin
                can_move = 0;
            end
        end
        
        //no player inputs for now
        
        if(can_move) begin
            for(i = 0; i < 15; i = i + 1) begin 
                player_board[i] = player_board[i+1];
            end
        end
    end
    
    always @(negedge can_move) begin
        for(i = 0; i < 15; i = i + 1) begin
            current_board[i] = current_board[i] | player_board[i];
            player_board[i] = 8'h0;
            if(current_board[i] == 8'hff) begin
                current_board[i] = 8'h0;
                shift_down = 1;
            end
        end
    end
    
    always @(posedge shift_down) begin
        //needs code 
    end
    
    
    
endmodule
