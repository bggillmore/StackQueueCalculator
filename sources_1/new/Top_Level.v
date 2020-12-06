`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 06:17:48 PM
// Design Name: 
// Module Name: Top_Level
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


module Top_Level(
    input clk, rst, stackQueue,
    input [15:0] switches,
    input [4:0] btns,
    output empty, full,
    output [7:0] anode, 
    output [7:0] cathode,
    output stackQueueLed
    //output [15:0] LED
    );
    wire [31:0] aluY, sseg, aluA, aluB;
    wire [4:0] btn_db;
    
    assign stackQueueLed = stackQueue;
    //wire stackQueue;    
    //assign stackQueue = 1'b1;
    //assign LED = {aluA[7:0], aluB[7:0]};
    
    //debounce btns
    debounce db0(.clk(clk), .reset(rst), .sw(btns[0]), .db(btn_db[0]));
    debounce db1(.clk(clk), .reset(rst), .sw(btns[1]), .db(btn_db[1]));
    debounce db2(.clk(clk), .reset(rst), .sw(btns[2]), .db(btn_db[2]));
    debounce db3(.clk(clk), .reset(rst), .sw(btns[3]), .db(btn_db[3]));
    debounce db4(.clk(clk), .reset(rst), .sw(btns[4]), .db(btn_db[4]));
   
    //alu
    ALU alu(.A(aluA), .B(aluB), .op(btns[4:1]), .Y(aluY), .overflow());
    
    Memory_Controller mc1(.clk(clk), .rst(rst), .stackQueue(stackQueue), .aluY(aluY), .switches(switches), 
    .btns(btns), .sseg(sseg),  .aluA(aluA), .aluB(aluB), .empty(empty), .full(full));
    
    //sseg
    SSEG sseg1(.clk(clk), .rst(rst), .in(sseg), .anode(anode), .cathode(cathode));
    
endmodule

