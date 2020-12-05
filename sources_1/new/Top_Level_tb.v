`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 06:29:16 PM
// Design Name: 
// Module Name: Top_Level_tb
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


module Top_Level_tb();
reg clk, rst, sq;
reg [15:0] sw;
reg [4:0] btns;
wire [31:0] sseg;
wire empty, full;
 
Top_Level tl(.clk(clk), .rst(rst), .stackQueue(sq), .switches(sw), .btns(btns), 
             .empty(empty), .full(full));
integer i, j, seriesSum;

assign sseg = tl.sseg; //memOut

//cant get this to work so in order to run this testbench you must switch wires to 
//bypass debounce in toplevel. input btns -> alu and memController
//assign tl.btn_db = btns; 

always #5 clk = ~clk;
initial begin
    rst = 0;
    clk = 0;
    btns = 5'b0;
    sw = 16'b0;
    sq = 1'b0;
    i=0;
    #10
    rst = 1;
    #100
    
    //fill memory as stack
    $display("Begining Stack Pushing Test");
    for(i = 0; i < 32; i= i+1)
    begin
        #20
        sw = sw + 1;
        btns = 5'b1;
        #20
        btns = 5'b0;
    end
    if(~full)
        $display("Error: should be full stack");
    for(i = 0; i <32; i = i+1)
    begin
        if(tl.mc1.m1.memory[i] != (i+1))
            $display("Error in stack push, mem[i == %h] = %h",i, tl.mc1.m1.memory[i]); 
    end
    $display("Memory Filled!");
    
    //add together values as stack
    $display("Begining Stack Adding Test");
    for(i = 0; i < 31; i = i+1)
    begin
        #20
        btns = 5'b00010;
        #100 //must be greater than number of states (8) in memController * clock period
        btns = 5'b0;
        seriesSum = 0;
        for(j = 32; j > (30-i); j = j-1)
        begin
            seriesSum = seriesSum + j;
        end
        if(seriesSum !== sseg)
            $display("Error in stack adding!    sum: %h    sseg: %h ", seriesSum, sseg);
    end
    
    //reset for queue operations
    rst = 1'b0;
    #200
    rst = 1'b1;
    
    //fill memory as queue
    $display("Begining Enqueue Test");
    sq = 1'b1;
    sw = 0;
    for(i = 0; i < 32; i= i+1)
    begin
        #20
        sw = sw + 1;
        btns = 5'b1;
        #20
        btns = 5'b0;
    end
    if(~full)
        $display("Error: should be full queue");
        
    for(i = 0; i <32; i = i+1)
    begin
        if(tl.mc1.m1.memory[i] != (i+1))
            $display("Error in enqueue, mem[i == %h] = %h",i, tl.mc1.m1.memory[i]); 
    end
    $display("Memory Filled!");
    
    
    //add together values as queue
    //Queue adding has been checked manually since finding an algorithm to check queue operation by itteration is suprisingly hard. 
    //One would need to actually code a fake queue. Seems pointless as i can just verify by the waveform.
    $display("Begining Queue Adding Test");
    for(i = 0; i < 28; i = i+1)
    begin
        #100
        btns = 5'b00010;
        #100 //must be greater than number of states (8) in memController * clock period
        btns = 5'b0;
    end
    
    
    $display("DONE!");
end
endmodule

