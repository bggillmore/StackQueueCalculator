`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 05:51:40 PM
// Design Name: 
// Module Name: memoryController_tb
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


module memoryController_tb();
    
reg clk, rst, stackQueue;
wire [31:0] aluY;
reg [15:0] switches;
reg[4:0] btns;
wire [31:0] sseg;
wire [31:0] aluA, aluB;
wire empty, full;

Memory_Controller mc1(.clk(clk), .rst(rst), .stackQueue(stackQueue), .aluY(aluY), .switches(switches), 
    .btns(btns), .sseg(sseg),  .aluA(aluA), .aluB(aluB), .empty(empty), .full(full));

assign aluY = aluA + aluB;
always #5 clk = ~clk;
initial begin
    clk = 1'b0;
    switches = 16'b0;
    btns = 5'b0;
    stackQueue = 1'b0; //queue
    rst = 1'b0;
    #10
    rst = 1'b1;
    #100
    
    switches = 16'hF0F0;
    btns = 5'b1;
    #1000 //100 clocks
    
    btns = 5'b0;
    #1000 //100 clocks
    
    switches = 16'hE3E3;
    btns = 5'b1;
    #1000 //100 clocks
    
    btns = 5'b0;
    #1000 //100 clocks
    
    btns = 5'b10;
    #1000 //100 clocks
    btns = 5'b0;
end
endmodule
