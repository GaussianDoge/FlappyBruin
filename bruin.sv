`timescale 1ns / 1ps

module bruin(
    input logic clk_100MHz,
    input logic clk_25MHz,
    input logic rst,
    input logic flap,
    output logic [11:0] bruin_color,
    output logic [8:0] x,
    output logic [8:0] y,
    output logic [4:0] high,
    output logic [4:0] width
    );
    
    assign high = 5'd20;
    assign width = 5'd20;
   
    logic [8:0] y_0 = 9'd240; // 240
    logic [8:0] up_div = 9'd10; // move up 10 pixel
    logic [8:0] max_high = 9'd10; // 20/2=10
    assign x = 9'd200; // 200

    assign bruin_color = 12'b1111_0000_1111; // yellow/gold?
	
	// Capture flap signal in 25Mhz (Same as VGA scanning rate)
	logic flap_sync0, flap_sync1;
    logic flap_rise;
    assign flap_rise = flap_sync0 & ~flap_sync1;  // one-cycle pulse on press

    always_ff @(posedge clk_25MHz or posedge rst) begin
        if (rst) begin
            flap_sync0 <= 1'b0;
            flap_sync1 <= 1'b0;
        end else begin
            flap_sync0 <= flap;
            flap_sync1 <= flap_sync0;
        end
    end
	
    // Update Bruin position in 25Mhz (Same as VGA scanning rate)
    always_ff @(posedge clk_25MHz or posedge rst) begin
        if (rst) begin
            y <= y_0;
        end else if (flap_rise) begin
            if (y > up_div + 5) begin
                y <= y - up_div;
            end else begin
                y <= max_high;
            end
        end
    end
    
endmodule
