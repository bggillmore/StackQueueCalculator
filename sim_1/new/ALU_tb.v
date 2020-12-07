`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2020 10:16:04 PM
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb();
    // declare reg/variables //
    reg  [31:0] A_tb, B_tb;
    reg  [3:0] op_tb;
    wire [31:0] Y_tb;
    reg  period; // added for the sake of testing
    
    //
    integer i,j;
    reg [31:0] result;
    
    // instantiate module //
    ALU uut (
    .A(A_tb),
    .B(B_tb),
    .op(op_tb),
    .Y(Y_tb)
    );
    
    // testing body //
    always #10 period = ~period; // artificial delay allows waveform to show
                                 // different tests
    initial begin
        period = 0; 
        i = 0; j = 0;
        result = 0;
        
////////// test 1: addition overflow //////////////////////////////////////////////////
        $display("Beginning Edge Case Testing: Addition");
        A_tb = 32'h0000_FFFF;
        B_tb = 32'h0000_FFFF; 
        op_tb = 4'b0001;
        #10
        if (Y_tb == 32'h0001_FFFE)
            $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, Y_tb);
        else
            $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, Y_tb);
        #50;        
          
////////// test 2: subtraction overflow //////////////////////////////////////////////////
        $display("Beginning Edge Case Testing: Subtraction");
        A_tb = 32'h0000_0000;
        B_tb = 32'h0000_FFFF; 
        op_tb = 4'b0010;
        #10
        if (Y_tb == 32'hFFFF_0001)
            $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, Y_tb);
        else
            $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, Y_tb);
        #50;
        
////////// test 3: multiplication overflow //////////////////////////////////////////////////
        $display("Beginning Edge Case Testing: Multiplication");
        A_tb = 32'h0000_FFFF;
        B_tb = 32'h0000_FFFF; 
        op_tb = 4'b0100;
        #10
        if (Y_tb == 32'hFFFE_0001)
            $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, Y_tb);
        else
            $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, Y_tb);
        #50;
        
////////// test 4: division by 0 //////////////////////////////////////////////////
        $display("Beginning Edge Case Testing: Division");
        A_tb = 32'h0000_FFFF;
        B_tb = 32'h0000_0000; 
        op_tb = 4'b1000;
        #10
        if (Y_tb == 32'h0000_0000)
            $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, Y_tb);
        else
            $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, Y_tb);
        #50;
        
//=====================================================================//
// semi - exhaustive checking:
// CAUTION: in edge case where divisor (B)=0, results in error via sim
//          but correctly assign Y=32'h0
//=====================================================================//

////////// test case 5: add ////////////////////////////////////////////////////////////////
        A_tb = 0; B_tb = 0; op_tb = 4'b0001;
        $display("Beginning Exhasutive Testing: Addition");
        for(i=0;i< 1000;i = i +32'b1) begin
            for(j=0;j < 1000;j = j +32'b1) begin
                #10
                if (Y_tb == A_tb + B_tb)
                    $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, result);
                else
                    //$display("%h,   %h", (i+j), Y_tb);
                    $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, result);
                j = j+1;
                B_tb = B_tb + 32'b1;
            end
            i = i+1;
            A_tb = A_tb + 32'b1;
        end
        
////////// test case 6: sub ////////////////////////////////////////////////////////////////
        A_tb = 0; B_tb = 0; op_tb = 4'b0010;
        $display("Beginning Exhasutive Testing: Subtraction");
        for(i=0;i<1000;i = i +32'b1) begin
            for(j=0;j<1000;j = j +32'b1) begin
                #10
                if (Y_tb == A_tb - B_tb)
                    $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, result);
                else
                    //$display("%h,   %h", (i+j), Y_tb);
                    $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, result);
                j = j+1;
                B_tb = B_tb + 32'b1;
            end
            i = i+1;
            A_tb = A_tb + 32'b1;
        end
        
////////// test case 7: mult ////////////////////////////////////////////////////////////////
        A_tb = 0; B_tb = 0; op_tb = 4'b0100;
        $display("Beginning Exhasutive Testing: Multiplicaiton");
        for(i=0;i<1000;i = i +32'b1) begin
            for(j=0;j<1000;j = j +32'b1) begin
                #10
                if (Y_tb == A_tb * B_tb)
                    $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, result);
                else
                    //$display("%h,   %h", (i+j), Y_tb);
                    $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, result);
                j = j+1;
                B_tb = B_tb + 32'b1;
            end
            i = i+1;
            A_tb = A_tb + 32'b1;
        end
        
////////// test case 8: div ////////////////////////////////////////////////////////////////
        A_tb = 0; B_tb = 0; op_tb = 4'b1000;
        $display("Beginning Exhasutive Testing: Division");
        for(i=0;i<1000;i = i +32'b1) begin
            for(j=0;j<1000;j = j +32'b1) begin
                #10
                if(B_tb == 0)
                    $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, result);
                else if (Y_tb == A_tb / B_tb)
                    $display("A=%h | B=%h | Y=%h || No Error", A_tb, B_tb, result);
                else
                    //$display("%h,   %h", (i+j), Y_tb);
                    $display("A=%h | B=%h | Y=%h || Error Detected!", A_tb, B_tb, result);
                j = j+1;
                B_tb = B_tb + 32'b1;
            end
            i = i+1;
            A_tb = A_tb + 32'b1;
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    $display("DONE!");
    end  // end of testing //
endmodule

