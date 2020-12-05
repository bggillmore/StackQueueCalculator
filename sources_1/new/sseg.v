`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2020 04:29:06 PM
// Design Name: 
// Module Name: top_level
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


module SSEG(
    input clk, rst,
    input [31:0] in,
    output [7:0] anode, 
    output [7:0] cathode
    );
    wire rotate;
    wire [3:0]hexVal;
    
    rotate_gen rt_gen(.clk(clk), .rst(rst), .rotate(rotate));
    anode_selector an_sel(.clk(clk), .rst(rst), .rotate(rotate), .anode(anode));
    Counter cntr(.clk(clk), .rst(rst), .rotate(rotate), .in(in), .hexVal(hexVal));
    hex_to_sseg x_2_sseg(.hexIn(hexVal), .dp(1'b1), .sseg(cathode));
endmodule
