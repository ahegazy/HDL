module uart (clk ,reset ,bd_rate ,par ,d_num ,s_num ,data_in ,err ,dout);
	/* UART INPUTS */
	input reset ,clk; //input frequency 50 MHz .. clk T = 20ns 
	input [1:0] bd_rate; // frequency choices <00:1200,01:2400,10:4800,11:9600> bps
	input [7:0] data_in;


	input d_num,s_num; // 0: 7 bits, 1: 8 bits
	input [1:0] par; //parity // no // even //odd

	/* UART OUTPUTS */
	output [7:0] dout;
	output [2:0] err;
	
	/* Connecting the modules */
	wire w_en;


	/* clock wires */
	wire [6:0] sec , min ;
	wire [5:0] hour , day ;
	wire [4:0] month ;


	wire clk_tx,clk_rx,clk_time;
	wire tx,rx;
	reg enable; //to be used in the always block.
	reg en_counter;
	
	assign rx = tx; // tx == rx 
	assign w_en = enable;
	/* tx should be an output pin/ rx should be an input pin /but we are testing on the same kit ._.*/
	
	baud_generator F0 (clk_tx,clk_rx,clk_time,clk,reset,bd_rate); //Generating CLOCKS

	Clock C0 (sec ,min ,hour ,day ,month ,clk_time ,reset);

	transmitter T0 (tx ,clk_tx ,reset ,w_en ,par ,d_num ,s_num ,data_in);

	receiver R0 (dout, clk_rx ,reset ,par ,d_num ,s_num ,err ,rx);
	
	initial 
	begin 
		enable = 0;
		en_counter = 0;
	end 
	
	always @(posedge clk_tx or posedge reset)
	begin 
		if (reset)
		begin
			enable <= 0;
			en_counter <= 0;
		end
		else
		begin
			if (( min == 0 | min == 15 | min == 30 | min == 45) & (sec == 0)) //enable sending the data every 15 minutes..
			begin
				if (en_counter != 1) //wait 1 cycle then enable = 0;
				begin
					en_counter <= en_counter + 1;
					enable = 1;
				end
				else enable <= 0;
			end 
			else 
			begin 
				enable <= 0;
				en_counter <= 0;
			end 
		end 
	end 
endmodule
