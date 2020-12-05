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
    reg [4:0] headPtr, basePtr, n_headPtr, n_basePtr;
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
            //n_headPtr <= 5'b0;
            //n_basePtr <= 5'b0;
            //empty <= 1'b1;
            //full <= 1'b0;
            writeCount <= 6'b0;
            //n_empty <=1'b1;
            //n_full <=1'b0;
        end
        else
        begin
            headPtr <= n_headPtr;
            basePtr <= n_basePtr;
            writeCount <= n_writeCount;
            //empty <= n_empty;
            //full <= n_full;
            if(push && ~full)
                memory[headPtr] <= dataIn;
        end
    end
    
    always @(*)
    begin
        if(push && ~full)
        begin                       //write
            n_headPtr = headPtr + 5'b1;
            //n_full = (n_headPtr == basePtr);
            //n_full = ((headPtr+5'b1) == basePtr);
            //n_empty = 1'b0;
            n_writeCount = writeCount + 6'b1;
        end
        else if(pop && ~empty)
        begin                       //read
            if(stackQueue)
            begin           //queue
                n_basePtr = basePtr + 5'b1;
            end
            else
            begin           //stack
                n_headPtr = headPtr - 5'b1;
            end
            n_writeCount = writeCount - 6'b1;
            //two different cases. either the stack aproaches empty from the front (stack) or rear(queue)
            //n_empty = (stackQueue)?(headPtr == n_basePtr):(n_headPtr == basePtr);
            //n_empty = (headPtr - 5'b1 == basePtr);
            //n_full = 1'b0;
        end
        else
        begin                       //no op
            n_headPtr = headPtr;
            n_basePtr = basePtr;
            n_writeCount = writeCount;
            //n_full = full;
            //n_empty = empty;
        end
    end
endmodule





/*

module Memory(
    input clk, rst, push, pop, stackQueue,
    input [31:0] dataIn,
    output [31:0] stackOut, queueOut,
    output reg empty, full
    );
    
    reg [31:0] memory [0:31];
    reg [4:0] headPtr, basePtr, n_headPtr, n_basePtr;
    reg n_empty, n_full;
    integer i;
    
    //assign full = ((headPtr + 5'b1) == basePtr);
    //assign empty = (headPtr == basePtr);
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
            //n_headPtr <= 5'b0;
            //n_basePtr <= 5'b0;
            empty <= 1'b1;
            full <= 1'b0;
            //n_empty <=1'b1;
            //n_full <=1'b0;
        end
        else
        begin
            headPtr <= n_headPtr;
            basePtr <= n_basePtr;
            empty <= n_empty;
            full <= n_full;
            if(push && ~full)
                memory[headPtr] <= dataIn;
        end
    end
    
    always @(*)
    begin
        if(push && ~full)
        begin                       //write
            n_headPtr = headPtr + 5'b1;
            //n_full = (n_headPtr == basePtr);
            n_full = ((headPtr+5'b1) == basePtr);
            n_empty = 1'b0;
        end
        else if(pop && ~empty)
        begin                       //read
            if(stackQueue)
            begin           //queue
                n_basePtr = basePtr + 5'b1;
            end
            else
            begin           //stack
                n_headPtr = headPtr - 5'b1;
            end
            //two different cases. either the stack aproaches empty from the front (stack) or rear(queue)
            n_empty = (stackQueue)?(headPtr == n_basePtr):(n_headPtr == basePtr);
            //n_empty = (headPtr - 5'b1 == basePtr);
            n_full = 1'b0;
        end
        else
        begin                       //no op
            n_headPtr = headPtr;
            n_basePtr = basePtr;
            n_full = full;
            n_empty = empty;
        end
    end
endmodule

*/









/*

module fifo_buffer#(
        parameter N = 16,         // number of bits in a word
        W = 3                     // number of address bits
     )
    (
    input clk,
    input reset,
    input rd,
    input wr,
    input [N-1:0] dataIn,
    output [N-1:0] dataOut,
    output empty,
    output full
    );
        
        // signal declaration
        reg [N-1:0] array_reg [2**W-1:0]; // register array
        reg [W-1:0] headPtr, headPtr_next;
        reg [W-1:0] basePtr, basePtr_next;
        reg full_reg, empty_reg, full_next, empty_next;
        wire wr_en;
        
        // body
        // register file write operation
        always@(posedge clk)
            if(wr_en)
                array_reg[headPtr] <= dataIn;
         
        // register file read operation
        assign dataOut = array_reg[basePtr];
        // write enabled only when FIFO is not full and wr is enabled
        assign wr_en = wr & ~full_reg;
        
        // fifo control logic
        // register for read and write pointers
        always@(posedge clk, posedge reset)
            if (reset)
                begin 
                    headPtr <= 0;
                    basePtr <= 0;
                    
                    full_reg  <= 1'b0;
                    empty_reg <= 1'b1;
                    
                    headPtr_next <= 1'b0;
                    basePtr_next <= 1'b0;
                end           
        else
            begin
                headPtr <= headPtr_next;
                basePtr <= basePtr_next;
                full_reg  <= full_next;
                empty_reg <= empty_next;
            end         
            
        // next_state logic for read and write pointers
        always@(*) begin
            // default: keep old values
            headPtr_next = headPtr;
            basePtr_next = basePtr;
            full_next = full_reg;
            empty_next = empty_reg;
            case({wr,rd})
            // 2'b00: no op
            2'b01: // read
                if (~empty_reg) // not_empty (check empty reg)
                    begin
                        basePtr_next = basePtr + 8'b1;;
                        full_next = 1'b0;
                        if (basePtr + 8'b1 == headPtr)
                            empty_next = 1'b1; 
                    end
            2'b10: // write
                if (~full_reg) // not full (check full reg)
                    begin 
                        headPtr_next = headPtr + 8'b1;
                        empty_next = 1'b0;
                        if (headPtr + 8'b1 == basePtr)
                            full_next = 1'b1;    
                    end                
            2'b11: // write and read
                begin 
                    headPtr_next = headPtr + 8'b1;
                    basePtr_next = basePtr + 8'b1;;
                end               
            endcase
        end       
          
    // output
    assign full = full_reg;
    assign empty = empty_reg;
endmodule
*/
