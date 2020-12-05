`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 04:34:24 PM
// Design Name: 
// Module Name: Memory_tb
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


module Memory_tb();
reg clk, rst, push, pop, stackQueue;
reg [31:0] dataIn;
wire [31:0] stackOut, queueOut;
wire empty, full;
integer i;

Memory m1(.clk(clk), .rst(rst), .push(push), .pop(pop), .stackQueue(stackQueue), 
    .dataIn(dataIn), .stackOut(stackOut), .queueOut(queueOut), .empty(empty), .full(full));

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 0;
    dataIn = 32'b0;
    push = 1'b0;
    pop = 1'b0;
    stackQueue = 1'b0; // stack
    #10
    rst = 1;
    
    //stack pushing
    for(i = 1; i <= 35; i = i+1)
    begin
        #10
        dataIn = i;
        push = 1'b1;
        #10
        push = 1'b0;
    end
    #100
    
    //stack poppin
    for(i = 1; i <= 35; i = i+1)
    begin
        #10
        pop = 1'b1;
        #10
        pop = 1'b0;
    end
    #100
    
    
    //queue pushing
    rst = 1'b0;
    stackQueue = 1'b1;
    #10
    rst = 1'b1;
    #10
    for(i = 1; i <= 35; i = i+1)
    begin
        #10
        dataIn = i;
        push = 1'b1;
        #10
        push = 1'b0;
    end
    #100
    
    //queue popping
    for(i = 1; i <= 35; i = i+1)
    begin
        #10
        pop = 1'b1;
        #10
        pop = 1'b0;
    end
end

endmodule
