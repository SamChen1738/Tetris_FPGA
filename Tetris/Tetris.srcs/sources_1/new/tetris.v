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
    input [3:0] keypad_input, //not used yet
    input [9:0] x,              
    input [9:0] y, 
    input video_on,
    output reg [11:0] rgb
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
    reg [4:0] distance_traveled;
    reg shift_down;
    reg rows_cleared;
    
    parameter t_piece_top = 8'h10;
    parameter t_piece_bottom = 8'h38;
    parameter l_piece_top = 8'h38;
    parameter l_piece_bottom = 8'h20;
    parameter l_piece_mirrored_bottom = 8'h08;
    parameter line_piece = 8'h3C;
    parameter z_piece_left = 8'h30;
    parameter z_piece_right = 8'h18;
    
    integer i,j;
    
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0;
    reg [5:0] refresh_counter;
    wire N_refreshes;
    assign N_refreshes = (refresh_counter == 0) ? 1 : 0;
    
    always @(posedge reset or posedge clk) begin
        if(reset) begin
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
            lfsr = 8'hB0;
            bit = 8'h00;
            rng = 3'b000;
            distance_traveled = 0;
            shift_down = 0;
            rows_cleared = 0;
            refresh_counter = 0;
        end
        else begin
            for(i = 0; i < 16; i = i + 1) begin
                current_board[i] = current_board_next[i];
                player_board[i] = player_board_next[i];
                display_board[i] = current_board[i] | player_board[i];
            end
            if(refresh_tick) begin
                refresh_counter = refresh_counter + 1;
                //refresh_counter = ~refresh_counter;
            end
        end
        //rgb = 12'hF00;
    end
        
    always @(posedge clk) begin
        //generate state
        for(i = 0; i < 16; i = i + 1) begin
            player_board_next[i] = player_board[i];
            current_board_next[i] = current_board[i];
        end
        if(block_generate) begin
            //$display("refresh_tick = %d", refresh_tick);
            if(/*N_refreshes*/refresh_tick) begin
                block_generate = 0;
                bit = (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) & 1;
                lfsr = (lfsr >> 1) | (bit << 7);
                rng = lfsr & 3'b111;
                can_move = 1;
                case(rng) 
                    8'h00: begin 
                        player_board_next[15] = t_piece_top; 
                        player_board_next[14] = t_piece_bottom;
                    end 
                    8'h01: begin
                        player_board_next[14] = line_piece;
                    end
                    8'h02: begin
                        player_board_next[15] = l_piece_top;
                        player_board_next[14] = l_piece_bottom;
                    end
                    8'h03: begin 
                        player_board_next[15] = l_piece_top;
                        player_board_next[14] = l_piece_mirrored_bottom;
                    end
                    8'h04: begin
                        //it says z piece but it makes a square
                        player_board_next[15] = z_piece_left;
                        player_board_next[14] = z_piece_left;
                    end
                    8'h05: begin
                        player_board_next[15] = z_piece_left;
                        player_board_next[14] = z_piece_right;
                    end
                    8'h06: begin
                        player_board_next[15] = z_piece_right;
                        player_board_next[14] = z_piece_left;
                    end
                    8'h07: begin
                        player_board_next[15] = t_piece_top; 
                        player_board_next[14] = t_piece_bottom;
                    end
                endcase
                //$display("player_board_next[15] is %x", player_board_next[15]);
            end
        end
        
        //can move state
        if(can_move) begin
            //$display("aksdjf");
            if(/*N_refreshes*/refresh_tick) begin
                distance_traveled = distance_traveled + 1;
                //check for off by 1 error
                if(distance_traveled >= 15) begin
                    distance_traveled = 0;
                    can_move = 0;
                end
                for(i = 15; i > 0; i = i - 1) begin
                    if((player_board_next[i] & current_board_next[i-1]) != 8'h00) begin
                        $display("player_board_next[%d] & current_board_next[%d]: %x", i, i-1, (player_board_next[i] & current_board_next[i-1]));
                        can_move = 0;
                        distance_traveled = 0;
                    end
                end
                
                //no player inputs for now

                if(can_move) begin
                    for(i = 0; i < 15; i = i + 1) begin 
                        player_board_next[i] = player_board_next[i+1];
                    end
                    player_board_next[15] = 8'h00;
                end
            end 
        end
        if(!can_move) begin
            if(/*N_refreshes*/refresh_tick) begin
                for(i = 0; i < 15; i = i + 1) begin
                    current_board_next[i] = current_board_next[i] | player_board_next[i];
                    player_board_next[i] = 8'h00;
                    if(current_board_next[i] == 8'hff) begin
                        current_board_next[i] = 8'h0;
                        shift_down = 1;
                    end
                end
                block_generate = 1;
            end
        end
    end
    
    
//    always @(posedge shift_down) begin
//        //needs code 
//    end
    
    parameter BLOCK_SIZE = 28;          

    integer block_x;                
    integer block_y;                

    always @* begin
        if (reset || !video_on) begin
            rgb = 12'h000;          
        end else begin
            block_x = x / BLOCK_SIZE;
            block_y = y / BLOCK_SIZE;

            if ((block_x < 8) && (block_y < 16)) begin
                if (display_board[block_y][block_x]) begin
                    rgb = 12'hFFF;  
                end else begin
                    rgb = 12'hF00;  
                end
            end 
            else begin
                rgb = 12'h000;      
            end
        end 
    end
endmodule
