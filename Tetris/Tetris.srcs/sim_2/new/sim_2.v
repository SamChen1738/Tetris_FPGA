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
    /*.keypad_input(keypad_input), */
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
    //keypad_input = 4'b0001;
    x = 0;
    y = 481;
    video_on = 1;
    #1 reset = 0;

    for(j = 0; j < 500; j = j + 1) begin
        
        #1;
            $display("Cycle %d:", j);
            $display("(%d, %d)", x, y);
            $display("rng: %d, lfsr: %x", tetris_inst.rng, tetris_inst.lfsr);
            $display("distance_traveled: %d", tetris_inst.distance_traveled);
            $display("block_generate: %b, can_move: %b, can_shift: %b, refresh_counter : %d", 
                tetris_inst.block_generate, 
                tetris_inst.can_move,
                tetris_inst.can_shift,
                tetris_inst.refresh_counter
            );
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
    end

    $finish;
end

endmodule
