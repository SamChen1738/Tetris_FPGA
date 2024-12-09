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
    input [9:0] x,              
    input [9:0] y, 
    input video_on,
    output reg [11:0] rgb,
    output reg [3:0] score_ones,
    output reg [3:0] score_tens,
    output reg [3:0] score_hundreds,
    output reg [3:0] score_thousands
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
    reg [5:0] distance_traveled;
    reg [2:0] number_of_shifts;
    reg shift_down;
    reg update_display;
    reg update_game_state;
    reg read_game_state;
    reg rows_cleared;
    reg check_movement;
    reg combine_boards;
    reg check_shift_left;
    reg check_shift_right;
    reg clear_player_board;
    reg clear_rows;

    reg check_game_over;
    reg game_over;
    
    parameter t_piece_top = 8'h10;
    parameter t_piece_bottom = 8'h38;
    parameter l_piece_top = 8'h38;
    parameter l_piece_bottom = 8'h20;
    parameter l_piece_mirrored_bottom = 8'h08;
    parameter line_piece = 8'h3C;
    parameter z_piece_left = 8'h30;
    parameter z_piece_right = 8'h18;
    
    integer i,j;
    
    reg refresh_tick;
    reg [1:0] refresh_counter;
    reg N_refreshes;
    reg [2:0] refresh_counter_2;
    reg N_refreshes_2;
    
    parameter BLOCK_SIZE = 14;          

    integer block_x;                
    integer block_y;                
    
    reg can_shift_left;
    reg can_shift_right;

    always @(posedge reset or posedge clk) begin
        refresh_tick <= ((y == 481) && (x == 0)) ? 1 : 0;
        N_refreshes <= (refresh_counter == 0) ? 1 : 0;
        N_refreshes_2 <= (refresh_counter_2 == 0) ? 1 : 0;
        if(reset) begin
            $display("reset");
            for(i = 0; i < 16; i = i + 1) begin
                current_board[i] <= 8'h00;
                player_board[i] <= 8'h00;
                display_board[i] <= 8'h00;
                current_board_next[i] <= 8'h00;
                player_board_next[i] <= 8'h00;
            end
            can_move <= 0;
            check_game_over <= 0;
            game_over <= 0;
            block_generate <= 1;
            lfsr <= 8'hB0;
            bit <= 8'h00;
            rng <= 3'b000;
            distance_traveled <= 0;
            shift_down <= 0;
            rows_cleared <= 0;
            refresh_counter <= 0;
            refresh_counter_2 <= 0;
            check_movement <= 0;
            update_game_state <= 1;
            update_display <= 0;
            read_game_state <= 0;
            clear_player_board <= 0;
            combine_boards <= 0;    
            clear_rows <= 0;
            check_shift_left <= 0;
            check_shift_right <= 0;
            can_shift_left <= 0;
            can_shift_right <= 0;
            number_of_shifts <= 0;
            score_ones <= 0;
            score_tens <= 0;
            score_hundreds <= 0;
            score_thousands <= 0;
        end
        else if(clk)begin
            if(!refresh_tick) begin
                if(update_game_state && !shift_down) begin
                    for(i = 0; i < 16; i = i + 1) begin
                        current_board[i] <= current_board_next[i];
                        player_board[i] <= player_board_next[i];
                    end
                    update_display <= 1;
                    update_game_state <= 0;
                end
                if(update_display) begin
                    for(i = 0; i < 16; i = i + 1) begin
                        display_board[i] <= (current_board[i] | player_board[i]);
                    end
                    update_display <= 0;
                    read_game_state <= 1;
                end
                if(read_game_state) begin
                    for(i = 0; i < 16; i = i + 1) begin
                        player_board_next[i] <= player_board[i];
                        current_board_next[i] <= current_board[i];
                    end
                    read_game_state <= 0;
                end
            end
            //$display("refresh_tick = %b, N_refreshes = %b", refresh_tick, N_refreshes);
            if(refresh_tick) begin
                refresh_counter <= refresh_counter + 1;
                refresh_counter_2 <= refresh_counter_2 + 1;
                if(!game_over) begin
                    update_game_state <= 1;
                end
                if(N_refreshes && !N_refreshes_2) begin
                    //generate state
                    if(block_generate && !shift_down) begin
                        block_generate <= 0;
                        //check_shift_left <= 1;
                        check_game_over <= 1;
                        bit <= (lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) & 1;
                        lfsr <= (lfsr >> 1) | (bit << 7);
                        rng <= lfsr & 3'b111;
                        case(rng) 
                            8'h00: begin 
                                player_board_next[15] <= t_piece_top; 
                                player_board_next[14] <= t_piece_bottom;
                                //player_board_next[14] <= 8'hff;
                                //$display("generated t piece");
                            end 
                            8'h01: begin
                                player_board_next[14] <= line_piece;
                            end
                            8'h02: begin
                                player_board_next[15] <= l_piece_top;
                                player_board_next[14] <= l_piece_bottom;
                            end
                            8'h03: begin 
                                player_board_next[15] <= l_piece_top;
                                player_board_next[14] <= l_piece_mirrored_bottom;
                            end
                            8'h04: begin
                                //it says z piece but it makes a square
                                player_board_next[15] <= z_piece_right;
                                player_board_next[14] <= z_piece_right;
                            end
                            8'h05: begin
                                player_board_next[15] <= z_piece_left;
                                player_board_next[14] <= z_piece_right;
                            end
                            8'h06: begin
                                player_board_next[15] <= z_piece_right;
                                player_board_next[14] <= z_piece_left;
                            end
                            8'h07: begin 
                                player_board_next[15] <= t_piece_top; 
                                player_board_next[14] <= t_piece_bottom;
                            end
                        endcase
                    end
                    if(check_game_over) begin
                        check_shift_left <= 1;
                        check_game_over <= 0;
                        for(i = 0; i < 16; i = i + 1) begin
                            if((current_board_next[i] & player_board_next[i]) != 8'h00) begin
                                can_move <= 0;
                                game_over <= 1;
                                block_generate <= 0;
                                lfsr <= 8'hB0;
                                bit <= 8'h00;
                                rng <= 3'b000;
                                distance_traveled <= 0;
                                shift_down <= 0;
                                rows_cleared <= 0;
                                refresh_counter <= 0;
                                check_movement <= 0;
                                clear_player_board <= 0;
                                combine_boards <= 0;    
                                clear_rows <= 0;
                                check_shift_left <= 0;
                                check_shift_right <= 0;
                                can_shift_left <= 0;
                                can_shift_right <= 0;
                                number_of_shifts <= 0;
                                update_display <= 0;
                                update_game_state <= 0;
                                read_game_state <= 0;
                            end
                        end
                    end
                    if(game_over) begin
                        display_board[15] = 8'h00;
                        display_board[14] = 8'h7e;
                        display_board[13] = 8'h40;
                        display_board[12] = 8'h40;
                        display_board[11] = 8'h4e;
                        display_board[10] = 8'h42;
                        display_board[9] = 8'h7e;
                        display_board[8] = 8'h00;
                        display_board[7] = 8'h00;
                        display_board[6] = 8'h7e;
                        display_board[5] = 8'h40;
                        display_board[4] = 8'h40;
                        display_board[3] = 8'h4e;
                        display_board[2] = 8'h42;
                        display_board[1] = 8'h7e;
                        display_board[0] = 8'h00;
                    end
                    if(check_shift_left && !block_generate && !check_game_over) begin
                        can_shift_left <= 1;
                        check_shift_left <= 0;
                        check_shift_right <= 1;
                        for(i = 0; i < 16; i = i + 1) begin
                            if(player_board_next[i][7]) begin
                                can_shift_left <= 0;
                            end
                            for(j = 6; j >= 0; j = j - 1) begin
                                if(player_board_next[i][j] && current_board_next[i][j+1]) begin
                                    can_shift_left <= 0;
                                end
                            end
                        end
                    end
                    if(check_shift_right) begin
                        can_shift_right <= 1;
                        check_shift_right <= 0;
                        check_movement <= 1;
                        for(i = 0; i < 16; i = i + 1) begin
                            if(player_board_next[i][0]) begin
                                can_shift_right <= 0;
                            end
                            for(j = 1; j <= 7; j = j + 1) begin
                                if(player_board_next[i][j] && current_board_next[i][j-1]) begin
                                    can_shift_right <= 0;
                                end
                            end
                        end
                    end
                    if(can_shift_left && !check_shift_right) begin
                        $display("shifted left");
                        can_shift_left <= 0;
                        if(keypad_input == 4'b0001) begin
                            for(i = 0; i < 16; i = i + 1) begin
                                player_board_next[i] <= (player_board_next[i] << 1);
                            end
                        end
                    end
                    if(can_shift_right && !can_shift_left) begin
                        $display("shifted right");
                        can_shift_right <= 0;
                        if(keypad_input == 4'b0010) begin
                            for(i = 0; i < 16; i = i + 1) begin
                                player_board_next[i] <= (player_board_next[i] >> 1);
                            end
                        end
                    end
                    if(check_movement && !can_shift_left && !can_shift_right) begin
                        can_move <= 1;
                        check_movement <= 0;
                        check_shift_left <= 1;
                        if(distance_traveled >= 14) begin
                            distance_traveled <= 0;
                            can_move <= 0;
                            combine_boards <= 1;
                        end
                        for(i = 15; i > 0; i = i - 1) begin
                            if((player_board_next[i] & current_board_next[i-1]) != 8'h00) begin
                                can_move <= 0;
                                distance_traveled <= 0;
                                combine_boards <= 1;
                            end 
                        end
                    end
                    if(combine_boards) begin
                        combine_boards <= 0;
                        for(i = 0; i < 16; i = i + 1) begin
                            current_board_next[i] <= current_board_next[i] | player_board_next[i];
                        end
                        clear_player_board <= 1;
                    end
                    if(clear_player_board) begin
                        clear_player_board <= 0;
                        for(i = 0; i < 16; i = i + 1) begin
                            player_board_next[i] <= 8'h00;
                        end
                        clear_rows <= 1;
                    end
                    if(clear_rows) begin    
                        clear_rows <= 0;
                        for(i = 0; i < 16; i = i + 1) begin
                            if(current_board_next[i] == 8'hff) begin
                                current_board_next[i] <= 8'h0;
                                shift_down <= 1;
                                score_ones <= score_ones + 1;
                                if(score_ones == 10) begin
                                    score_ones <= 0;
                                    score_tens <= score_tens + 1;
                                end
                                if(score_tens == 10) begin
                                    score_tens <= 0;
                                    score_hundreds <= score_hundreds + 1;
                                end
                                if(score_hundreds == 10) begin
                                    score_hundreds <= 0;
                                    score_thousands <= score_thousands + 1;
                                end
                            end
                        end
                        block_generate <= 1;
                    end
                    if(shift_down) begin
                        number_of_shifts <= number_of_shifts + 1;
                        if(number_of_shifts >= 4) begin
                            shift_down <= 0;
                            number_of_shifts <= 0;
                        end
                        for(i = 0; i < 15; i = i + 1) begin
                            if(current_board_next[i] == 8'h00) begin
                                current_board_next[i] <= current_board_next[i+1];
                                current_board_next[i+1] <= 8'h00;
                            end
                        end
                        current_board_next[15] <= 8'h00;
                    end
                end
                if(N_refreshes_2 && can_move && !can_shift_left && !can_shift_right) begin
                    //$display("block moved down");
                    for(i = 0; i < 15; i = i + 1) begin 
                        player_board_next[i] <= player_board_next[i+1];
                    end
                    player_board_next[15] <= 8'h00;
                    distance_traveled <= distance_traveled + 1;
                    can_move <= 0;
                end
            end
            //can move state
        end
    end

    always @* begin

        if (reset || !video_on) begin
            rgb = 12'h000;          
    //        end else if(y < 50) begin
    //            rgb <= 12'h00F;
    //        end else if(x> 100) begin
    //            rgb <= 12'hFFF;
        end else begin
            if(x < 24 || y < 36) begin
                rgb = 12'h111;
            end else begin
                block_x = (x-24) / BLOCK_SIZE;
                block_y = (y-36) / BLOCK_SIZE;
                
                if ((block_x < 8) && (block_y < 16)) begin
                    if (display_board[15-block_y][block_x]) begin
                        rgb = 12'hFFF;  
                    end else begin
                        rgb = 12'hF00;  
                    end
                end 
                else begin
                    rgb = 12'h111;      
                end
            end
        end 
    end
endmodule
