`timescale 1ns / 1ps

// FOR USE WITH AN FPGA THAT HAS 12 PINS FOR RGB VALUES, 4 PER COLOR


module render(
	input logic clk_100MHz,      // from FPGA
	input logic reset,
	input logic flap,
	input logic [11:0] sw,       // 12 bits for color
	output logic hsync, 
	output logic vsync,
	output logic [11:0] rgb      // 12 FPGA pins for RGB(4 per color)
);
	
	logic [11:0] sky = 12'b111100000000;
	
	// Signal Declaration
	logic [11:0] rgb_reg;    // Registar for displaying color on a screen
	logic video_on;         // Same signal as in controller
	logic[9:0] x;
	logic[9:0] y;

    // Instantiate VGA Controller
    vga_controller vga_c(.clk_100MHz(clk_100MHz), .reset(reset), .hsync(hsync), .vsync(vsync),
                         .video_on(video_on), .p_tick(), .x(x), .y(y));
                         
                       
    // Bruin Info
    logic [11:0] bruin_color;
    logic [8:0] bruin_x;
    logic [8:0] bruin_y;
    logic [3:0] bruin_high;
    logic [3:0] bruin_width;
      
    // Instantiate Bruin
    bruin bruin_bird(.clk(clk_100MHz), .rst(reset), .flap_btn(flap), .bruin_color(bruin_color), .x(bruin_x), .y(bruin_y), .high(bruin_high), .width(bruin_width));
    
    // RGB Buffer
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)begin
           rgb_reg <= 0;
        end else begin
           if (x <= (bruin_x+bruin_width/2) && x >= (bruin_x-bruin_width/2)
               ) begin
                rgb_reg <= bruin_color;
           end else begin
                rgb_reg <= sky;
           end
        end
    end
    
    // Output
    assign rgb = (video_on) ? rgb_reg : 12'b0;   // while in display area RGB color = sw, else all OFF
        
endmodule