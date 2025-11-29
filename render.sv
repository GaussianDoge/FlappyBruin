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

    
    logic clk_25MHz;
    logic clk_60Hz;
    logic clk_5Hz;
    clk_gen clk_generator(.clk_100MHz(clk_100MHz), .clk_25MHz(clk_25MHz), .clk_60Hz(clk_60Hz), .clk_5Hz(clk_5Hz));
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
    logic bruin_over;
    logic game_start = 1'b1;

    // Instantiate Bruin
    bruin bruin_bird(.clk_100MHz(clk_100MHz), .clk_25MHz(clk_25MHz), .clk_60Hz(clk_60Hz), .clk_5Hz(clk_5Hz), 
                        .rst(reset), .flap(flap), .game_start(game_start), .bruin_color(bruin_color), .x(bruin_x), .y(bruin_y), 
                        .high(bruin_high), .width(bruin_width), .game_over(bruin_over));
    
    // Bar Operation
    logic [9:0] x_bar_arr[0:3];
    logic [8:0] y_gap_arr[0:3];
    logic [4:0] width_gap = 80;
    logic [5:0] bar_width = 40;
    logic [11:0] bar_color = 12'b000011110000;
   
    rand_bar_gen bar_1 (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        
        .set_x(640),
        .x_bar(x_bar_arr[0]),
        .y_gap(y_gap_arr[0])
    );
    
    rand_bar_gen bar_2 (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        
        .set_x(560),
        .x_bar(x_bar_arr[1]),
        .y_gap(y_gap_arr[1])
    );
    
    rand_bar_gen bar_3 (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        
        .set_x(480),
        .x_bar(x_bar_arr[2]),
        .y_gap(y_gap_arr[2])
    );
    
    rand_bar_gen bar_4 (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        
        .set_x(420),
        .x_bar(x_bar_arr[3]),
        .y_gap(y_gap_arr[3])
    );
    
    
    // RGB Buffer
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)begin
           rgb_reg <= sky;
        end else begin
            // Rendering Bruin
           if (x <= (bruin_x+bruin_width/2) && x >= (bruin_x-bruin_width/2)
                && y <= (bruin_y+bruin_high/2) && y >= (bruin_y-bruin_high/2)) begin
                rgb_reg <= bruin_color;
           end else begin
                // Rendering obstacles
                for (logic [2:0] i = 0; i <= 3; i++) begin
                    if ((x > x_bar_arr[i]-bar_width && x < x_bar_arr[i])
                        && (y < (y_gap_arr[i]-width_gap/2) || y > (y_gap_arr[i]+width_gap/2))) begin
                        rgb_reg <= bar_color;
                    end else begin
                        rgb_reg <= sky;
                    end
                end
            end
        end
    end
    
    // Output
    assign rgb = (video_on) ? rgb_reg : 12'b0;   // while in display area RGB, else all OFF
        
endmodule