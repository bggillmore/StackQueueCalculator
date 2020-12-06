`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 04:14:32 PM
// Design Name: 
// Module Name: Memory
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

module Memory(
    input clk, rst, push, pop, stackQueue,
    input [31:0] dataIn,
    output [31:0] stackOut, queueOut,
    output empty, full
    );
    
    reg [31:0] memory [0:31];
    reg [4:0] headPtr, basePtr, n_headPtr, n_basePtr, headPtr_succ, basePtr_succ, headPtr_prev;
    reg [5:0] writeCount, n_writeCount;
    integer i;
    
    assign full = (writeCount == 6'b100000); //32
    assign empty = ~|writeCount;
    assign stackOut = (empty)? 32'b0 : memory[(headPtr - 5'b1)];
    assign queueOut = (empty)? 32'b0 : memory[basePtr];
    
    always@(posedge clk, negedge rst)
    begin
        if(~rst)
        begin
            for(i = 0; i <32; i = i+1)
                memory[i] <= 32'b0;
            headPtr <= 5'b0;
            basePtr <= 5'b0;
            writeCount <= 6'b0;
        end
        else
        begin
            headPtr <= n_headPtr;
            basePtr <= n_basePtr;
            writeCount <= n_writeCount;
            if(push && ~full)
                memory[headPtr] <= dataIn;
        end
    end
    
    always @(*)
    begin
        /*
         *              IMPORTANT!
         *  Do not remove there succ/prev pointers!
         *  know the code is more expressive with: 
         *          nPtr = ptr +/- 5'b1;
         *  but i'm preventing a prop delay issue in queue 
         *  mode by moving the adder prior to the mux.
         */
        //next pointer values 
        basePtr_succ = basePtr + 5'b1;
        headPtr_prev = headPtr - 5'b1;
        headPtr_succ = headPtr + 5'b1;
        //keep old values
        n_headPtr = headPtr;
        n_basePtr = basePtr;
        n_writeCount = writeCount;

        if(push && ~full)
        begin                       //write
            n_headPtr = headPtr_succ;
            n_writeCount = writeCount + 6'b1;
        end
        else if(pop && ~empty)
        begin                       //read
            if(stackQueue)
            begin           //queue
                n_basePtr = basePtr_succ;
            end
            else
            begin           //stack
                n_headPtr = headPtr_prev;
            end
            n_writeCount = writeCount - 6'b1;
        end
    end
endmodule

