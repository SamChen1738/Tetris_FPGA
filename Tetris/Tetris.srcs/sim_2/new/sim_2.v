`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 04:21:49 PM
// Design Name: 
// Module Name: sim_2
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


module sim_2();

reg clk;
reg reset;
reg [3:0] keypad_input;
reg [9:0] x, y;
reg video_on;
wire [11:0] rgb;
integer i, j;

// Use named port connections
tetris tetris_inst(
    .clk(clk), 
    .reset(reset), 
    .keypad_input(keypad_input),
    .x(x), 
    .y(y), 
    .video_on(video_on), 
    .rgb(rgb)
);

always #1 clk = ~clk;

//always @(posedge clk) begin
//    if (x == 10) begin
//        x <= 0;
////        if (y == 524)
////            y <= 0;
////        else
////            y <= y + 1;
//    end
//    else
//        x <= x + 1;
//end

initial begin 
    reset = 1;
    clk = 0;
    keypad_input = 4'b0001;
    x = 1;
    y = 481;
    video_on = 1;
    #1 reset = 0;

    for(j = 0; j < 10500; j = j + 1) begin
        if(x <= 2) begin
            x = x + 1;
        end
        else begin
            x = 0;
        end
        if(keypad_input == 4'b0001) begin
            keypad_input = 4'b0010;
        end
        else begin
            keypad_input = 4'b0001;
        end
        #2;
            $display("Cycle %d:", j);
            $display("(%d, %d)", x, y);
            $display("keypad_input: %b", keypad_input);
            $display("rng: %d, lfsr: %x", tetris_inst.rng, tetris_inst.lfsr);
            $display("refresh_tick: %b, N_refreshes: %b", tetris_inst.refresh_tick, tetris_inst.N_refreshes);
            $display("distance_traveled: %d", tetris_inst.distance_traveled);
            $display("update_game_state: %b", tetris_inst.update_game_state);
            $display("update_display: %b", tetris_inst.update_display);
            $display("read_game_state: %b", tetris_inst.read_game_state);
            $display("block_generate: %b", tetris_inst.block_generate);
            $display("check_game_over: %b", tetris_inst.check_game_over);
            $display("game_over: %b", tetris_inst.game_over);
            $display("check_shift_left: %b", tetris_inst.check_shift_left);
            $display("check_shift_right: %b", tetris_inst.check_shift_right);
            $display("check_movement: %b", tetris_inst.check_movement);
            $display("can_shift_left: %b", tetris_inst.can_shift_left);
            $display("can_shift_right: %b", tetris_inst.can_shift_right);
            $display("can_move: %b", tetris_inst.can_move);
            $display("combine_boards: %b", tetris_inst.combine_boards);
            $display("clear_player_board: %b", tetris_inst.clear_player_board);
            $display("clear_rows: %b", tetris_inst.clear_rows);
            $display("shift_down: %b", tetris_inst.shift_down); 
            $display("number_of_shifts: %d", tetris_inst.number_of_shifts);
            for(i = 15; i >= 0; i = i - 1) begin
                $display("display_board[%0d]: %x    |    player_board[%0d]: %x    |    current_board[%0d]: %x   |   player_board_next[%0d]: %x   |   current_board_next[%0d]: %x", 
                    i, 
                    tetris_inst.display_board[i],
                    i,
                    tetris_inst.player_board[i],
                    i, 
                    tetris_inst.current_board[i],
                    i,
                    tetris_inst.player_board_next[i],
                    i,
                    tetris_inst.current_board_next[i]
                );
            end
    end

    $finish;
end

endmodule
