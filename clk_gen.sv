`timescale 1ns / 1ps

module clk_gen(
    input logic clk_100MHz,
    input logic reset,
    
    output logic clk_25MHz,
    output logic clk_420KHz
    );
    
    // Generate 25Mhz clk(60hz) for vga_controller and other object's movement
    logic  [1:0] c_25MHz;
    assign clk_25MHz = (c_25MHz == 0) ? 1 : 0; // assert tick 1/4 of the time
    
    always_ff @(posedge clk_100MHz or posedge reset) begin
		if(reset) begin
		  c_25MHz <= 0;
		end else begin
		  c_25MHz <= c_25MHz + 1;
		end
	end
	
	// Generate 420KHz clk (1 cycle for scanning whole display buffer)
    logic  [7:0] c_420KHz;
    assign clk_420KHz = (c_420KHz >= 240) ? 1 : 0; // assert tick 1/4 of the time
    
    always_ff @(posedge clk_100MHz or posedge reset) begin
		if(reset) begin
		  c_420KHz <= 8'd0;
		end else begin
		  if (c_420KHz >= 240) begin
		      c_420KHz <= 8'd0;
		  end else begin
		      c_420KHz <= c_420KHz + 1;
		  end
		end
	end
endmodule
