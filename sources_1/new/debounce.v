`timescale 1ns / 1ns
module debounce(
	input wire clk, reset,
	input wire sw,
	output reg db
	);
	
	//symbolic state declaration
	localparam [2:0]
		   zero		= 3'b000,
		   wait1_1 	= 3'b001,
		   wait1_2	= 3'b010,
		   wait1_3	= 3'b011,
		   one		= 3'b100,
		   wait0_1	= 3'b101,
		   wait0_2	= 3'b110,
		   wait0_3	= 3'b111;
						  
	//number of counter bits (2^N * 10 ns = 10ms tick )
	//signal declaration
	
	localparam N = 20;
	reg [N-1:0] q_reg;
	wire [N-1:0] q_next;
	
	
	wire m_tick;
	reg [2:0] state_reg, state_next;

	//body
	
	//===================================================================
	// Counter to generate 10 ms tick
	//===================================================================
	always @(posedge clk, negedge reset)
		if (~reset)
			q_reg <= 20'b0;
		else 
			q_reg <= q_next;

	// next-state logic
		assign q_next = (m_tick) ? 1'b0 : q_reg + 1;
	// output tick
		assign m_tick = (q_reg== 20'd666666 ) ? 1'b1 : 1'b0;

	//===================================================================
	// debouuncing FSM
	//===================================================================
	// state register
	always @(posedge clk, negedge reset)
		if (~reset)
			state_reg <= zero;
		else 
			state_reg <= state_next;
			
	// next-state logic and output logic
	always @*
	begin
		state_next = state_reg; //default state : the same
		db = 1'b0;
		case(state_reg)
			zero: 
			begin
			    db = 1'b0;
				if(sw)
				    state_next = wait1_1;
            end
			wait1_1:
			begin
			    db = 1'b0;
				if(sw && m_tick)
				    state_next = wait1_2;
                else if(sw && ~m_tick)
                    state_next = wait1_1;
                else
                    state_next = zero;
            end
			wait1_2:
			begin
			    db = 1'b0;
				if(sw && m_tick)
				    state_next = wait1_3;
                else if(sw && ~m_tick)
                    state_next = wait1_2;
                else
                    state_next = zero;
            end
			wait1_3:
			begin
			    db = 1'b0;
				if(sw && m_tick)
				    state_next = one;
                else if(sw && ~m_tick)
                    state_next = wait1_3;
                else
                    state_next = zero;
            end
			one:
			begin
			    db = 1'b1;
				if(sw)
				    state_next = one;
                else
                    state_next = wait0_1;
            end
			wait0_1:
			begin
			    db = 1'b1;
				if(sw)
				    state_next = one;
                else if(~sw && ~m_tick)
                    state_next = wait0_1;
                else if(~sw && m_tick)
                    state_next = wait0_2;
            end
			wait0_2:
			begin
			    db = 1'b1;
				if(sw)
				    state_next = one;
                else if(~sw && ~m_tick)
                    state_next = wait0_2;
                else if(~sw && m_tick)
                    state_next = wait0_3;
            end
			wait0_3:
			begin
			    db = 1'b1;
				if(sw)
				    state_next = one;
                else if(~sw && ~m_tick)
                    state_next = wait0_3;
                else if(~sw && m_tick)
                    state_next = zero;
            end
				default: state_next = zero;
			endcase
		end
		
	
endmodule
