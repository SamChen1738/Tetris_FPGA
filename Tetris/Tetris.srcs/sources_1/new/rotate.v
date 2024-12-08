`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 08:05:58 PM
// Design Name: 
// Module Name: rotate
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


module rotate(
    input [3:0] input_block[3:0],
    input rotate_clockwise,
    output reg [3:0] output_block[3:0]
);

    integer i, j;
    reg [1:0] center_i, center_j;
    reg signed [2:0] new_i, new_j; // Changed to signed 3-bit
    integer count;
    reg [2:0] min_i, min_j, max_i, max_j;
    reg [1:0] shift_i, shift_j;

    always @(*) begin
        // Initialize
        for(i = 0; i < 4; i = i + 1) begin
            output_block[i] = 4'b0000;
        end
        center_i = 0;
        center_j = 0;
        count = 0;
        min_i = 3'b111; // Max value for 3-bit signed
        min_j = 3'b111;
        max_i = -4; // Min value for 3-bit signed
        max_j = -4;

        // Find the center of the 1 bits
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if (input_block[i][j] == 1'b1) begin
                    center_i = center_i + i;
                    center_j = center_j + j;
                    count = count + 1;
                end
            end
        end

        // Calculate average position (center)
        if (count > 0) begin
            center_i = center_i / count;
            center_j = center_j / count;
        end

        // Rotate each 1 bit around the calculated center
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if (input_block[i][j] == 1'b1) begin
                    if (rotate_clockwise) begin
                        new_i = center_i + (j - center_j);
                        new_j = center_j - (i - center_i);
                    end else begin
                        new_i = center_i - (j - center_j);
                        new_j = center_j + (i - center_i);
                    end
                    
                    // Update min and max
                    if (new_i < min_i) min_i = new_i;
                    if (new_j < min_j) min_j = new_j;
                    if (new_i > max_i) max_i = new_i;
                    if (new_j > max_j) max_j = new_j;
                end
            end
        end

        // Calculate required shift
        shift_i = (min_i < 0) ? -min_i : (max_i > 3) ? 3 - max_i : 0;
        shift_j = (min_j < 0) ? -min_j : (max_j > 3) ? 3 - max_j : 0;

        // Apply rotation and shift
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if (input_block[i][j] == 1'b1) begin
                    if (rotate_clockwise) begin
                        new_i = center_i + (j - center_j) + shift_i;
                        new_j = center_j - (i - center_i) + shift_j;
                    end else begin
                        new_i = center_i - (j - center_j) + shift_i;
                        new_j = center_j + (i - center_i) + shift_j;
                    end
                    
                    // Set the bit in the output block
                    output_block[new_i][new_j] = 1'b1;
                end
            end
        end
    end

endmodule
