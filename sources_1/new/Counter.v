`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2020 03:40:22 PM
// Design Name: 
// Module Name: Counter
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


module Counter(
    input clk, rst, rotate,
    input [31:0] in,
    output reg [3:0] hexVal
    );
    reg [2:0] sel;
    
    always @(posedge clk, negedge rst)
    begin
        if(~rst)
            sel = 3'b000;
        else
            sel <= rotate ? sel + 3'b001 : sel;
            case(sel)
                3'o0: hexVal = in[3:0];
                3'o1: hexVal = in[7:4];
                3'o2: hexVal = in[11:8];
                3'o3: hexVal = in[15:12];
                3'o4: hexVal = in[19:16];
                3'o5: hexVal = in[23:20];
                3'o6: hexVal = in[27:24];
                3'o7: hexVal = in[31:28];
                default hexVal = 3'b000;
            endcase
    end
endmodule
