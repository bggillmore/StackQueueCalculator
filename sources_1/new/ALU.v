`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CSULB
// Engineer: Rio Bungalon
// 
// Create Date: 11/02/2020 10:03:27 PM
// Design Name: Stack Calculator
// Module Name: ALU
// Project Name: ALU Stack Queue Calculator
// Target Devices: Artix A-7 100T
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

// ALU.v takes two signed 32-bit input values (A,B), and performs a arithmetic 
// operation based on the 4-bit op value. The resulting value is assigned to
// signed 32-bit variable Y w/ an overflow bit as MSB
module ALU(
    A,
    B,
    op,
    Y,
    overflow
    );
    
    // I/O declarations //
    input  wire [31:0] A, B; // ALU 32-bit inputs
    input  wire [3:0] op;    // ALU operation
    output reg overflow;    // overflow signal
    output reg  [31:0] Y;    // ALU 32-bit output
    initial Y = 32'b0;
    
    // internal variables, calculate overflow //
    wire [63:0] temp;
    assign temp = {32'b0, A} * {32'b0, B};
    //assign temp = {1'b0,A} + {1'b0,B}; // calculate overflow 
    //assign overflow = temp[32];        // assign overflow to MSB
    
    // Arithmetic Operations //
    always @ (*) begin
        case(op)
            // 4 operations //
            4'b0001: {overflow, Y} = {1'b0, A} + {1'b0, B};  // addition
            4'b0010: {overflow, Y} = {1'b0, A} - {1'b0, B};  // subtraction
            4'b0100: {overflow, Y} = {|temp[63:32],temp[31:0]};  // multiplication
            4'b1000: begin
                overflow = 0;
                if  (B != 32'd0) Y = A / B; // division, prevent division by 0
                else Y = 32'd0;  // assigned 33-bit bc of overflow
            end
            
            // non-operation cases: maintain output //
            // added to prevent errors //                           // case values //
            4'b0000: Y=0; 4'b0011: Y=0; 4'b0101: Y=0; 4'b0110: Y=0; // 0, 3, 5, 6  //
            4'b0111: Y=0; 4'b1001: Y=0; 4'b1010: Y=0; 4'b1011: Y=0; // 7, 9, A, B  //
            4'b1100: Y=0; 4'b1101: Y=0; 4'b1110: Y=0; 4'b1111: Y=0; // C, D, E, F  //
            
            default: {overflow, Y} = 33'b0; // default Y = 0, (i.e. upon reset)
        endcase
    end
endmodule
