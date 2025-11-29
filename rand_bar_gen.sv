`timescale 1ns / 1ps

module rand_bar_gen(
    input logic clk_100MHz,
    input logic reset, 
    
    input logic [9:0] set_x,
    
    output logic [9:0] x_bar,
    output logic [8:0] y_gap
);  
    logic [31:0] clk_cnt;
    
    // Random Operations
    logic [8:0] random;
    always_ff @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            random <= 10'b1000000000;
        end else begin
            if (x_bar == 1) begin
                automatic logic result = random[8] ^ random[7] ^ random[5] ^ random[3] ^ random[2];
                random <= {random[7:0], result};
            end
        end
    end
    
    always_ff @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin   
            x_bar <= set_x; 
            y_gap <= 240; // y_gap sets to be in the middle
            clk_cnt <= 1'b0;
        end else begin
            clk_cnt <= clk_cnt + 1;
            // go left once when clk_cnt reaches 10M, can change accordingly
            if (clk_cnt == 10000000) begin
                clk_cnt <= '0;
                if (x_bar == 0) begin
                    x_bar <= set_x;
                    if (random <= 480) begin
                        y_gap <= random;
                    end else begin
                        y_gap <= 480; // Reaches the top
                    end
                end 
                x_bar <= x_bar - 1;
            end
        end
    end
endmodule
