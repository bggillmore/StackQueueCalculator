`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2020 04:08:41 PM
// Design Name: 
// Module Name: anode_selector
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


module anode_selector(
    input clk, rst, rotate,
    output reg [7:0] anode
    );
    
    always @(posedge clk, negedge rst)
    begin
        if(~rst)
            anode <= 8'hFE;
        else
        begin
            //anode <= rotate?{anode[6:0],anode[7]}: anode[7:0];
            if(rotate)
                anode <= {anode[6:0],anode[7]};
        end
    end
endmodule
