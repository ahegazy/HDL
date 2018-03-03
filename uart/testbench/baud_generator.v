///////////////////////////////////////////////////////////////////////////////
 // $Id: baud_generator.v 916 2018-02-25 Ahmad Hegazy $
 //
 // Module: baud_generator.v
 // Project: UART
 // Description: Generates baud rates from the system clock to run the transmitter and receiver 
 // Author: Ahmad Hegazy <ahegazipro@gmail.com> 
 //
 // Change history: 
 //
 ///////////////////////////////////////////////////////////////////////////////
module baud_generator(clk_tx,clk_rx,clk_time,clk,reset,bd_rate);
	input reset ,clk; //input frequency 50 MHz .. clk T = 20ns 
	input [1:0] bd_rate; // frequency choices <00:1200,01:2400,10:4800,11:9600> bps
	output reg clk_tx,clk_rx,clk_time; //tx T= 
	reg [10:0] count_rx;
	reg [4:0] count_tx;
	reg [25:0] count_timer;
	
	parameter INPUT_FREQUNCY = 50000000;
	parameter BAUD_1200 = INPUT_FREQUNCY/(1200*16*2);
	parameter BAUD_2400 = INPUT_FREQUNCY/(2400*16*2);
	parameter BAUD_4800 = INPUT_FREQUNCY/(4800*16*2);
	parameter BAUD_9600 = INPUT_FREQUNCY/(9600*16*2);
	
	parameter BAUD_1HZ = INPUT_FREQUNCY;
	
	initial 
	begin
		count_rx = 0;
		count_tx = 0;
		clk_rx = 0;
		clk_tx = 0;
		clk_time = 0;
	end

	//Generating BAUD 
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin 
			count_rx = 0;
			count_tx = 0;
			clk_rx = 0;
			clk_tx = 0;
		end
		else
		begin 
		count_rx <= count_rx + 1;
		case (bd_rate)
		2'b00: //baud = 1200;
			begin 
				if (count_rx == (BAUD_1200 - 1)) //50M/(1200*16*2)
					begin 
						clk_rx <= ~clk_rx;
						count_rx <= 0;

						count_tx <= count_tx + 1;
					end
			end  
		2'b01: //baud = 2400;
			begin 
				if (count_rx == (BAUD_2400 - 1)) // 50M/(2400*16*2)
					begin 
						clk_rx <= ~clk_rx;
						count_rx <= 0;
						
						count_tx <= count_tx + 1;
					end
			end  
		2'b10: //baud = 4800;
			begin 
				if (count_rx == (BAUD_4800 - 1))  // 50M/(4800*16*2)
					begin 
						clk_rx <= ~clk_rx;
						count_rx <= 0;

						count_tx <= count_tx + 1;
					end
			end  
		
		2'b11: //baud = 9600;
			begin 
				if (count_rx == (BAUD_9600 - 1)) //50M/(9600*16*2) 
					begin 
						clk_rx <= ~clk_rx;
						count_rx <= 0;

						count_tx <= count_tx + 1;

					end
			end  

		endcase 


		if (count_tx ==	 16)
		begin
			clk_tx <= ~clk_tx;
			count_tx <= 0;
		end
		end 
	end
	
	//Generating 1 Hz for timer ..
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin 
			count_timer = 0;
			clk_time = 0;
		end
		else 
		begin 
			if (count_timer == (BAUD_1HZ/2 - 1)) 
			begin 
				clk_time = ~clk_time;
				count_timer = 0;
			end 
			else count_timer = count_timer + 1;
		end 
		
	end 

endmodule