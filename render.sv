`timescale 1ns / 1ps

module render(
	input logic clk_100MHz,      // from FPGA
	input logic reset,
	input logic flap,
	input logic [11:0] sw,       // 12 bits for color
	output logic hsync, 
	output logic vsync,
	output logic [11:0] rgb      // 12 FPGA pins for RGB(4 per color) Green: [11:8]; Blue: [7:4]; Red: [3:0]
);
    // Generate 25Mhz clk(60hz) for vga_controller and other object's movement
    logic clk_25MHz;
    logic  [1:0] r_25MHz;
    assign clk_25MHz = (r_25MHz == 0) ? 1 : 0; // assert tick 1/4 of the time
    
    always_ff @(posedge clk_100MHz or posedge reset) begin
		if(reset) begin
		  r_25MHz <= 0;
		end else begin
		  r_25MHz <= r_25MHz + 1;
		end
	end
	// ****************************************************************************************
	

	logic [11:0] sky = 12'b1010_1111_0000; // background color (blue)
	
	// Signal Declaration
	logic [11:0] rgb_reg;    // Registar for displaying color on a screen
	logic video_on;         // Same signal as in controller
	logic[9:0] x;
	logic[9:0] y;

    // Instantiate VGA Controller
    vga_controller vga_c(.clk_100MHz(clk_100MHz), .clk_25MHz(clk_25MHz), .reset(reset), .hsync(hsync), .vsync(vsync),
                         .video_on(video_on), .p_tick(), .x(x), .y(y));
                         
                       
    // Bruin Info
    logic [11:0] bruin_color;
    logic [8:0] bruin_x;
    logic [8:0] bruin_y;
    logic [4:0] bruin_high;
    logic [4:0] bruin_width;
      
    // Instantiate Bruin
    bruin bruin_bird(.clk_100MHz(clk_100MHz), .clk_25MHz(clk_25MHz), .rst(reset), .flap(flap), .bruin_color(bruin_color), .x(bruin_x), .y(bruin_y), .high(bruin_high), .width(bruin_width));
    
    // RGB Buffer
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)begin
           rgb_reg <= sky;
        end else begin
           if (x <= (bruin_x+bruin_width/2) && x >= (bruin_x-bruin_width/2)
                && y <= (bruin_y+bruin_high/2) && y >= (bruin_y-bruin_high/2)) begin
                rgb_reg <= bruin_color;
           end else begin
                rgb_reg <= sky;
           end
        end
    end
    
    // Output
    assign rgb = (video_on) ? rgb_reg : 12'b0;   // while in display area RGB, else all OFF
        
endmodule