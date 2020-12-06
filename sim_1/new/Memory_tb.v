`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2020 05:38:06 PM
// Design Name: 
// Module Name: fifo_lifo2_TB
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
    reg clk, rst, push, pop, sel;
    reg [31:0] in;
    wire empty, full;
    wire [31:0] stackOut, queueOut, out, headOut, baseOut;

    integer i,j;
    integer memCheck [31:0];
    reg error;

    Memory m(.clk(clk), .rst(rst), .push(push), .pop(pop), .stackQueue(sel), .dataIn(in),
                   .empty(empty), .full(full), .stackOut(stackOut), .queueOut(queueOut));
                   
    always #5 clk = ~clk;
    assign out = (sel)?queueOut:stackOut;
    assign headOut = stackOut; //just for ease of readablity
    assign baseOut = queueOut;
    
    initial begin
        rst = 1'b0;
        clk = 1'b0;
        push = 1'b0;
        pop = 1'b0;
        sel = 0; //stack
        in = 32'b0;
        error = 1'b0; //just so that the sim wave is not just a red line for Section 1 if successful.
        #10;
        rst = 1'b1;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    
    
    
        //Section 1: stack mode, test pushing
        for(i = 0; i < 32; i= i+1) begin
            #10;
            push = 1'b1;
            memCheck[i] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j] !== memCheck[j]) begin
                    $display("Stack push error, IN = %h, Memory at space %f is %h", in, i, m.memory[j]);
                    error = 1'b1;
                end
            end
            if(out !== memCheck[i]) begin
                $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                error = 1'b1;
            end
        end
        if(~full) begin
            $display("No 'Full' flag after 32 stack pushes");
            error = 1'b1; // set error to high
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 1, Stack Push Failure"); 
        end
        else begin
            $display("Section 1, Stack Push Success");
        end 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////        
        
        
        
        
        //Section 2: stack mode, test popping
        for(i = 31; i >=0; i= i-1) begin
            if(out != memCheck[i]) begin //else
                error = 1'b1;
                $display("Stack pop display error, OUT = %h, memCheck = %h, i = %h", out, memCheck[i], i);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
            //if(i == 0) begin
            //    if(out != 32'b0) begin
            //        error = 1'b1;
            //        $display("Stack pop display error at empty, OUT = %h", out);
            //    end
            //end
            
        end
        if(~empty) begin
            error = 1'b1;
            $display("No 'Empty' flag after 32 stack pops");
        end
        #10;
        if(out != 32'b0) begin
            error = 1'b1;
            $display("Stack pop display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 2, Stack Pop Failure"); 
        end
        else begin
            $display("Section 2, Stack Pop Success"); 
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
        //Section 3: queue mode, test enqueue
        sel = 1'b1;
        for(i = 0; i < 32; i= i+1) begin
            #10;
            push = 1'b1;
            memCheck[i] = in;
            #10;
            push = 1'b0;
            #10
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j] !== memCheck[j]) begin
                    $display("Enqueue error, IN = %h, Memory at space %f is %h", in, i, m.memory[j]);
                    error = 1'b1;
                end
            end
            if(headOut !== memCheck[i]) begin
                $display("Enqueue display error, IN = %h, OUT = %h, i = %h ", in, headOut, i);
                error = 1'b1;
            end
        end
    
        if(~full) begin
            $display("No 'Full' flag after 32 enqueues");
            error = 1'b1;
        end
        if(error) begin
            error = 1'b0;
            $display("Section 3, Enqueue Failure"); 
        end
        else begin
            $display("Section 3, Enqueue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
     
     
     
        //Section 4: queue mode, test dequeue
        for(i = 0; i < 32; i= i+1) begin
            if(out !== memCheck[i]) begin
                error = 1'b1;
                $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
            
        end
        #20
        if(~empty) begin
            $display("No 'Empty' flag after 32 dequeues");
            error = 1'b1;
        end
        #10;
        if(out !== 32'b0) begin
            error = 1'b1;
            $display("Dequeue display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 4, Dequeue Failure"); 
        end
        else begin
            $display("Section 4, Dequeue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        //Section 5a
        //wrap around test 21 enqueue -> 5 dequeue -> 16 enqueue should result in full flag
        //verifying enqueue writes to previously free'd memory
        for(i=0; i<21; i=i+1) begin //Queuing 21 data sets to memory (Part 1)
            #10;
            push = 1'b1;
            memCheck[i] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j] !== memCheck[j]) begin
                    $display("Enqueue error, IN = %h, Memory at space %f is %h", in, i, m.memory[j]);
                    error = 1'b1;
                end
            end
            if(headOut !== memCheck[i]) begin
                $display("Enqueue display error, IN = %h, OUT = %h ", in, headOut);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0;
            $display("Section 5a Pt.1, Enqueue 21 Failure"); 
        end
        else begin
            $display("Section 5a Pt.1, Enqueue 21 Success");
        end
        
        for(i = 0; i < 5; i= i+1) begin //Remove first 5 items in front of line of memory (Part 2)
            if(out !== memCheck[i]) begin
                error = 1'b1;
                $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        #10;
        if(error) begin
            error = 1'b0;
            $display("Section 5a Pt.2, Dequeue 5 Failure"); 
        end
        else begin
            $display("Section 5a Pt.2, Dequeue 5 Success");
        end
        
        for(i=0; i<16; i=i+1) begin //continue Queuing where it stopped (Part 3)
            #10;
            push = 1'b1;
            if(i+21 >= 32)
                memCheck[i-11] = in;
            else 
                memCheck[i+21] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+21 >= 32) begin
                    if(m.memory[j-11] !== memCheck[j-11]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i-11), m.memory[j-11]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+21] !== memCheck[j+21]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i+21), m.memory[j+21]);
                        error = 1'b1;
                    end
                end
            end
            if(i+21 >= 32) begin
                if(headOut !== memCheck[i-11]) begin
                    $display("Enqueue display error, IN = %h, OUT = %h ", memCheck[i-11], headOut);
                    error = 1'b1;
                end
            end
            else begin
                if(headOut !== memCheck[i+21]) begin
                    $display("Enqueue display error, IN = %h, OUT = %h ", memCheck[i+21], headOut);
                    error = 1'b1;
                end
            end
        end
        
        if(~full) begin
            $display("No 'Full' flag after 16 more enqueues");
            error = 1'b1;
        end
        if(error) begin
            error = 1'b0;
            $display("Section 5a Pt.3, Enqueue 16 Failure"); 
        end
        else begin
            $display("Section 5a Pt.3, Enqueue 16 Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////





        //Section 5b: queue mode, dequeuing to empty the memory for section 6 (this is a copy of section 4)
        for(i = 0; i < 32; i= i+1) begin
            if(i+5 >=32) begin
                if(out !== memCheck[i-27]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i-27]);
                end
            end
            else begin
                if(out !== memCheck[i+5]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+5]);
                end
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            $display("No 'Empty' flag after 32 dequeues");
            error = 1'b1;
        end
        #10;
        if(out !== 32'b0) begin
            error = 1'b1;
            $display("Dequeue display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 5b, Dequeue Failure"); 
        end
        else begin
            $display("Section 5b, Dequeue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////






        //Section 6a
        //wrap around test 21 stack push -> 5 dequeue -> 16 stack push should result in full flag
        //verifying stack push writes to previously free'd memory
        sel = 1'b0;//Stack 21 (Part 1)
        for(i = 0; i < 21; i= i+1) begin //b/c 20+5 < 32, I ignored the if statement "if(i+5 >=32)"
            #10;
            push = 1'b1;
            memCheck[i+5] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+5] !== memCheck[j+5]) begin
                    $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+5), m.memory[j+5]);
                    error = 1'b1;
                end
            end
            if(out !== memCheck[i+5]) begin
                $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 6a Pt.1, Stack Push 21 Failure"); 
        end
        else begin
            $display("Section 6a Pt.1, Stack Push 21 Success");
        end 
        
        sel = 1'b1; //Dequeue 5 (Part 2)
        #10
        for(i = 0; i < 5; i= i+1) begin //Remove first 5 items in front of line of memory (Part 2)
            if(out !== memCheck[i+5]) begin
                error = 1'b1;
                $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+5]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        #10;
        if(error) begin
            error = 1'b0;
            $display("Section 6a Pt.2, Dequeue 5 Failure"); 
        end
        else begin
            $display("Section 6a Pt.2, Dequeue 5 Success");
        end
        
        sel = 1'b0; //Stack 16 (Part 3)
        for(i = 0; i < 16; i= i+1) begin //for each time the module queues/stacks or dequeues/pops a total of less than 32 times, I am updating and shifting the index to keep track of where the slot, front, and top pointers are.
            #10;
            push = 1'b1;
            if(i+26 >= 32)
                memCheck[i-6] = in;
            else
                memCheck[i+26] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+26 >= 32) begin
                    if(m.memory[j-6] !== memCheck[j-6]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i-6), m.memory[j-6]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+26] !== memCheck[j+26]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+26), m.memory[j+26]);
                        error = 1'b1;
                    end
                end
            end
            if(i+26 >= 32) begin
                if(out !== memCheck[i-6]) begin
                    $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                    error = 1'b1;
                end
            end
            else begin
                if(out !== memCheck[i+26]) begin
                    $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                    error = 1'b1;
                end
            end
        end
        
        if(~full) begin
            $display("No 'Full' flag after 16 more stack pushes");
            error = 1'b1; // set error to high
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 6a Pt.3, Stack Push 16 Failure"); 
        end
        else begin
            $display("Section 6a Pt.3, Stack Push 16 Success");
        end 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        //Section 6b: Queue mode => Dequeuing all slots to empty for Section 7
        sel = 1'b1;
        #10
        for(i=0; i < 32; i= i+1) begin
            if(i+10 >=32) begin
                if(out !== memCheck[i-22]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i-22]);
                end
            end
            else begin
                if(out !== memCheck[i+10]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+10]);
                end
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            $display("No 'Empty' flag after 32 dequeues");
            error = 1'b1;
        end
        #10;
        if(out !== 32'b0) begin
            error = 1'b1;
            $display("Dequeue display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 6b, Dequeue Failure"); 
        end
        else begin
            $display("Section 6b, Dequeue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        
        //Section 7a
        //consistancy test 16 stack push -> 16 enqueue should result in full flag
        //verifying enqueue can write to next value of a stack (transforming stack to a queue) 
        sel = 1'b0;//Stack 16 (Part 1)
        for(i = 0; i < 16; i= i+1) begin //b/c 15+10 < 32, I ignored if statement "if(i+10 >=32)"
            #10;
            push = 1'b1;
            memCheck[i+10] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+10] !== memCheck[j+10]) begin
                    $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+10), m.memory[j+10]);
                    error = 1'b1;
                end
            end
            if(out !== memCheck[i+10]) begin
                $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 7a Pt.1, Stack Push 16 Failure"); 
        end
        else begin
            $display("Section 7a Pt.1, Stack Push 16 Success");
        end 
        
        sel = 1'b1;//Queue 16 (Part 2)
        for(i = 0; i < 16; i= i+1) begin
            #10;
            push = 1'b1;
            if(i+26 >= 32) // b/c stacker left stopped at slot 26 (where 26 is the memory index that is next and awaiting for new inputted data)
                memCheck[i-6] = in;
            else
                memCheck[i+26] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+26 >= 32) begin
                    if(m.memory[j-6] !== memCheck[j-6]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i-6), m.memory[j-6]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+26] !== memCheck[j+26]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i+26), m.memory[j+26]);
                        error = 1'b1;
                    end
                end
            end
        end
        if(~full) begin
            $display("No 'Full' flag after 16 stacks and 16 enqueues");
            error = 1'b1;
        end
        if(error) begin
            error = 1'b0;
            $display("Section 7a Pt.2, Enqueue 16 Failure"); 
        end
        else begin
            $display("Section 7a Pt.2, Enqueue 16 Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        //Section 7b: Dequeue for Section 8
        for(i=0; i < 32; i= i+1) begin
            if(i+10 >=32) begin
                if(out !== memCheck[i-22]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h, i = %h", out, memCheck[i-22], i);
                end
            end
            else begin
                if(out !== memCheck[i+10]) begin
                    error = 1'b1;
                    $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+10]);
                end
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            $display("No 'Empty' flag after 32 dequeues");
            error = 1'b1;
        end
        #10;
        if(out !== 32'b0) begin
            error = 1'b1;
            $display("Dequeue display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 7b, Dequeue Failure"); 
        end
        else begin
            $display("Section 7b, Dequeue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        //Section 8a
        //consistancy test 16 enqueue -> 16 stack push should result in full flag
        //verifying stack push can write to next value of a queue (transforming queue to a stack)
        for(i = 0; i < 16; i= i+1) begin //Queue 16 (Part 1)
            #10;
            push = 1'b1;
            memCheck[i+10] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+10] !== memCheck[j+10]) begin
                    $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i+10), m.memory[j+10]);
                    error = 1'b1;
                end
            end
            if(headOut !== memCheck[i+10]) begin
                $display("Enqueue display error, IN = %h, OUT = %h ", memCheck[i+10], headOut);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0;
            $display("Section 8a Pt.1, Enqueue 16 Failure"); 
        end
        else begin
            $display("Section 8a Pt.1, Enqueue 16 Success");
        end
        
        sel = 1'b0;//Stack 16 (Part 2)
        for(i = 0; i < 16; i= i+1) begin 
            #10;
            push = 1'b1;
            if(i+26 >= 32)
                memCheck[i-6] = in;
            else
                memCheck[i+26] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+26 >= 32) begin
                    if(m.memory[j-6] !== memCheck[j-6]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i-6), m.memory[j-6]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+26] !== memCheck[j+26]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+26), m.memory[j+26]);
                        error = 1'b1;
                    end
                end
            end
            if(i+26 >= 32) begin
                if(out !== memCheck[i-6]) begin
                    $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                    error = 1'b1;
                end
            end
            else begin
                if(out !== memCheck[i+26]) begin
                    $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                    error = 1'b1;
                end
            end
        end
        if(~full) begin
            $display("No 'Full' flag after 16 enqueues and 16 stacks");
            error = 1'b1;
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 8a Pt.2, Stack Push 16 Failure"); 
        end
        else begin
            $display("Section 8a Pt.2, Stack Push 16 Success");
        end 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        //Section 8b: Stack Mode => Popping off all 32 slots for Section 9
        for(i = 31; i >=0; i= i-1) begin
            if(i+10 >= 32) begin
                if(out != memCheck[i-22]) begin
                    error = 1'b1;
                    $display("Stack pop display error, OUT = %h, memCheck = %h ", out, memCheck[i-22]);
                end
            end
            else if(out != memCheck[i+10]) begin
                error = 1'b1;
                $display("Stack pop display error, OUT = %h, memCheck = %h ", out, memCheck[i+10]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            error = 1'b1;
            $display("No 'Empty' flag after 32 stack pops");
        end
        #10;
        if(out != 32'b0) begin
            error = 1'b1;
            $display("Stack pop display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 8b, Stack Pop Failure"); 
        end
        else begin
            $display("Section 8b, Stack Pop Success"); 
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //Section 9
        //consistancy test 8 enqueue -> 8 stack push -> 8 dequeue -> 8 stack pop
        //should result in empty flag
        sel = 1'b1; //Enqueue 8 (Part 1)
        for(i = 0; i < 8; i= i+1) begin
            #10;
            push = 1'b1;
            memCheck[i+10] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+10] !== memCheck[j+10]) begin
                    $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i+10), m.memory[j+10]);
                    error = 1'b1;
                end
            end
            if(headOut !== memCheck[i+10]) begin
                $display("Enqueue display error, IN = %h, OUT = %h ", in, headOut);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0;
            $display("Section 9 Pt.1, Enqueue 8 Failure"); 
        end
        else begin
            $display("Section 9 Pt.1, Enqueue 8 Success");
        end
        
        sel = 1'b0;//Stack 8 (Part 2)
        for(i = 0; i < 8; i= i+1) begin 
            #10;
            push = 1'b1;
            memCheck[i+18] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+18] !== memCheck[j+18]) begin
                    $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+18), m.memory[j+18]);
                    error = 1'b1;
                end
            end
            if(out !== memCheck[i+18]) begin
                $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                error = 1'b1;
            end
        end
        #10; //Added this time delay so the Top pointer doesn't do an extra shift.
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 9 Pt.2, Stack Push 8 Failure"); 
        end
        else begin
            $display("Section 9 Pt.2, Stack Push 8 Success");
        end 
        
        sel = 1'b1; //Dequeue 8 (Part 3)
        #10
        for(i = 0; i < 8; i= i+1) begin
            if(out !== memCheck[i+10]) begin
                error = 1'b1;
                $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+10]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        #10;
        if(error) begin
            error = 1'b0;
            $display("Section 9 Pt.3, Dequeue 8 Failure"); 
        end
        else begin
            $display("Section 9 Pt.3, Dequeue 8 Success");
        end
        
        sel = 1'b0; //Stack Pop 8 (Part 4)
        for(i = 7; i >=0; i= i-1) begin
            if(headOut != memCheck[i+18]) begin
                error = 1'b1;
                $display("Stack pop display error, OUT = %h, memCheck = %h ", headOut, memCheck[i+18]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            error = 1'b1;
            $display("No 'Empty' flag after 8 dequeues and 8 stack pops");
        end
        #10;
        if(out != 32'b0) begin
            error = 1'b1;
            $display("Stack pop display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 9 Pt.4, Stack Pop 8 Failure"); 
        end
        else begin
            $display("Section 9 Pt.4, Stack Pop 8 Success"); 
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        //Section 10
        //consistancy test  8 stack push -> 8 enqueue  -> 8 stack pop -> 8 dequeue
        //should result in empty flag
        for(i = 0; i < 8; i= i+1) begin //Stack Push 8 (Part 1)
            #10;
            push = 1'b1;
            memCheck[i+18] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(m.memory[j+18] !== memCheck[j+18]) begin
                    $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+18), m.memory[j+18]);
                    error = 1'b1;
                end
            end
            if(out !== memCheck[i+18]) begin
                $display("Stack push display error, IN = %h, OUT = %h ", in, out);
                error = 1'b1;
            end
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 10 Pt.1, Stack Push 8 Failure"); 
        end
        else begin
            $display("Section 10 Pt.1, Stack Push 8 Success");
        end 
        
        sel = 1'b1; //Enqueue 8 (Part 2)
        for(i = 0; i < 8; i= i+1) begin
            #10;
            push = 1'b1;
            if(i+26 >= 32)
                memCheck[i-6] = in;
            else
                memCheck[i+26] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+26 >= 32) begin
                    if(m.memory[j-6] !== memCheck[j-6]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i-6), m.memory[j-6]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+26] !== memCheck[j+26]) begin
                        $display("Enqueue error, IN = %h, Memory at space %f is %h", in, (i+26), m.memory[j+26]);
                        error = 1'b1;
                    end
                end
            end
        end
        #10;
        if(error) begin
            error = 1'b0;
            $display("Section 10 Pt.2, Enqueue 8 Failure"); 
        end
        else begin
            $display("Section 10 Pt.2, Enqueue 8 Success");
        end
        
        sel=1'b0; //Stack Pop 8 (Part 3)
        for(i = 7; i >=0; i= i-1) begin
            if(i+26 > 32) begin
                if(headOut != memCheck[i-6]) begin
                    error = 1'b1;
                    $display("Stack pop display error, OUT = %h, memCheck = %h ", headOut, memCheck[i-6]);
                end
            end
            else if(out != memCheck[i+26]) begin
                error = 1'b1;
                $display("Stack pop display error, OUT = %h, memCheck = %h ", out, memCheck[i+26]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        #10;
        if(error) begin
            error = 1'b0;
            $display("Section 10 Pt.3, Stack Pop 8 Failure"); 
        end
        else begin
            $display("Section 10 Pt.3, Stack Pop 8 Success"); 
        end
        
        sel = 1'b1; //Dequeue 8 (Part 4)
        #10
        for(i = 0; i < 8; i= i+1) begin
            if(out !== memCheck[i+18]) begin
                error = 1'b1;
                $display("Dequeue display error, OUT = %h, memCheck = %h ", out, memCheck[i+18]);
            end
            #10;
            pop = 1'b1;
            #10;
            pop = 1'b0;
        end
        if(~empty) begin
            $display("No 'Empty' flag after 8 stack pops and 8 dequeues");
            error = 1'b1;
        end
        #10;
        if(out !== 32'b0) begin
            error = 1'b1;
            $display("Dequeue display error at empty (past exposing popped data), OUT = %h", out);
        end
        if(error) begin
            error = 1'b0;
            $display("Section 10 Pt.4, Dequeue Failure"); 
        end
        else begin
            $display("Section 10 Pt.4, Dequeue Success");
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //Section 11
        //trying to force an error
        //35 stack push -> 35 dequeue -> 16 stack push -> 16 dequeue -> 8 enqueue -> 
        //32 stack push -> 35 stack pop -> 35 enqueue -> rotate until empty -> rotate until full
        sel = 1'b0; //Part 1: Stack Push 35 Overflow
        for(i = 0; i < 35; i= i+1) begin //We want to get an error AFTER the memory has reached its limit.
            #10;
            push = 1'b1;
            if(i >= 32) ;//do nothing
            else if(i+26 >= 32)
                memCheck[i-6] = in;
            else
                memCheck[i+26] = in;
            #10;
            push = 1'b0;
            for(j = i; j>=0; j=j-1) begin
                if(i+26 >= 32) begin
                    if(m.memory[j-6] !== memCheck[j-6]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i-6), m.memory[j-6]);
                        error = 1'b1;
                    end
                end
                else begin
                    if(m.memory[j+26] !== memCheck[j+26]) begin
                        $display("Stack push error, IN = %h, Memory at space %f is %h", in, (i+26), m.memory[j+26]);
                        error = 1'b1;
                    end
                end
            end   
        end
        if(~full) begin
            $display("No 'Full' flag after 32 stack pushes");
            error = 1'b1; // set error to high
        end
        if(error) begin
            error = 1'b0; // reset error for next test section
            $display("Section 11 Pt.1 (Attempt Overload), 35 Stack Push Failure"); //what we want
        end
        else begin
            $display("Section 11 Pt.1 (Attempt Overload), 35 Stack Push Success");
        end 
        
        $display("DONE!");
    end

    always @(posedge clk) begin
        in <= $urandom();
    end
endmodule
