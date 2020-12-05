`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2020 03:45:50 PM
// Design Name: 
// Module Name: rotate_gen
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


module rotate_gen(
    input clk, rst,
    output reg rotate
    );
    
    reg [17:0] count;
    
    always @(posedge clk, negedge rst)
    begin
        if(~rst)
        begin
            count <= 18'b0;
            rotate <= 1'b0;
        end
        else
        begin
            count <= count + 18'b1;
            if(count >= 200000)
            begin
                rotate <= 1'b1;
                count <= 0;
            end
            else
                rotate <= 1'b0;
        end
    end
endmodule
