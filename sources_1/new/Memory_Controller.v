`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2020 05:25:27 PM
// Design Name: 
// Module Name: Memory_Controller
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


module Memory_Controller(
    input clk, rst, stackQueue,
    input [31:0] aluY,
    input [15:0] switches,
    input [4:0] btns,
    output [31:0] sseg, 
    output reg [31:0] aluA, aluB,
    output empty, full
    );
    reg [2:0] n_state, state;
    reg push, pop, n_push, n_pop;
    reg [31:0] dataIn, n_dataIn, n_aluB, n_aluA;
    wire [31:0] stackOut, queueOut;
    
    assign sseg = stackOut; //display head of memory space
    
    Memory m1(.clk(clk), .rst(rst), .push(push), .pop(pop), .stackQueue(stackQueue), .dataIn(dataIn), 
        .stackOut(stackOut), .queueOut(queueOut), .empty(empty), .full(full));
        
    always @(posedge clk, negedge rst)
    begin
        if(~rst)
        begin
            state <= 3'b0;
            {push, pop} <= 2'b0;
            {aluA, aluB} <= 64'b0;
            dataIn <= 32'b0;
        end
        else
        begin
            state <= n_state;
            push <= n_push;
            pop <= n_pop;
            aluB <= n_aluB;
            aluA <= n_aluA;
            dataIn <= n_dataIn;
        end
    end 
    
    always @(*)
    begin
        if(btns[0] && ~|btns[4:1])  //push
        begin
            if(state == 3'b0)
            begin
                n_dataIn = {16'b0, switches};
                n_state = 2'b1;
                n_push = 1'b1;
            end
            else
            begin   //reset and wait
                n_push = 1'b0;
                n_state = state;
            end
        end
        else if(~btns[0] && ^btns[4:1]) //alu operation
        begin
            case(state)
                3'b000:
                begin   //copy
                    n_aluA = (stackQueue)?queueOut:stackOut;
                    n_state = state + 3'b1;
                    n_pop = 1'b0;
                    n_push = 1'b0;
                end
                3'b001:
                begin   //pop
                    n_state = state + 3'b1;
                    n_pop = 1'b1;
                    n_push = 1'b0;
                end
                3'b010: //wait to finalize pop
                begin
                    n_state = state + 3'b1;
                    n_pop = 1'b0;
                    n_push = 1'b0;
                end
                3'b011:
                begin   //copy
                    n_aluB = (stackQueue)?queueOut:stackOut;
                    n_state = state + 3'b1;
                    n_pop = 1'b0;
                    n_push = 1'b0;
                end
                3'b100:
                begin   //pop
                    n_state = state + 3'b1;
                    n_pop = 1'b1;
                    n_push = 1'b0;
                end
                3'b101: //wait to finalize pop
                begin
                    n_state = state + 3'b1;
                    n_pop = 1'b0;
                    n_push = 1'b0;
                end
                3'b110: //push
                begin
                    n_dataIn = aluY;
                    n_state = state + 3'b1;
                    n_pop = 1'b0;
                    n_push = 1'b1;
                end
                3'b111: //wait for button release and to finalize push
                begin
                    n_pop = 1'b0;
                    n_push = 1'b0;
                    n_state = state;
                end
            endcase
        end
        else
        begin
            n_state = 3'b0;
            n_push = 1'b0;
            n_pop = 1'b0;
            n_aluA = 32'b0;
            n_aluB = 32'b0;
            n_dataIn = 32'b0;
        end
    end
endmodule
