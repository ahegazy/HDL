module receiver(dout, clk_rx ,reset ,par ,d_num ,s_num ,err ,rx);
	output reg [7:0] dout;
	output reg [2:0] err; // data overrun, frame error,parity //err = {PAR_ERR,FRAME_ERR,DO_ERR}; 
	input reset,clk_rx,rx;

	input d_num,s_num; // 0: 7 bits, 1: 8 bits
	input [1:0] par; //parity // no // even //odd

	reg [7:0] rx_data;
	reg [1:0] state;//00 idle - 01 start - 10 din - 11 stop
	reg [3:0] sample_counter;
	reg [2:0] pos;	
	reg s_count; //count sent stop bits
	reg PAR_ERR,FRAME_ERR,DO_ERR;
	
	parameter STATE_START	= 2'b00;
	parameter STATE_READ	= 2'b01;
	parameter STATE_PARITY	= 2'b10;
	parameter STATE_STOP = 2'b11;
	
	parameter NO_PARITY  = 2'b00;
	parameter EVEN_PARITY  = 2'b01;
	parameter ODD_PARITY  = 2'b10;
	
	parameter MAX_7_BITS = 1'b0;
	parameter MAX_8_BITS = 1'b1;
	
	initial 
	begin 
		state <= STATE_START;
		pos <= 0;
		sample_counter <= 0;
		PAR_ERR <= 0;
		FRAME_ERR <= 0;
		DO_ERR <= 0;
	end
	
	always @ (posedge clk_rx or posedge reset)
	begin 
		if (reset) 
		begin
			state <= STATE_START;
			pos <= 0;
			sample_counter <= 0;
			PAR_ERR <= 0;
			FRAME_ERR <= 0;
			DO_ERR <= 0;
			err <= 0;
			dout <= 0;
			rx_data <= 0;
			
		end 
		else 
		begin 
			err = {PAR_ERR,FRAME_ERR,DO_ERR};///-----
			case (state)
				STATE_START: 
				begin 
					if (rx == 1)
					begin
						sample_counter <= 0;
						pos <= 0;
					end
					else if (rx == 0 & sample_counter == 7)
						begin 
							
							sample_counter <= 0;
							pos <= 0;
							rx_data <= 0;
							PAR_ERR <= 0;
			        FRAME_ERR <= 0;
			        DO_ERR <= 0;
			        err <= 0;
							state <= STATE_READ;
						end
					else sample_counter <= sample_counter + 1;
				end
				STATE_READ:
					begin
						if (sample_counter == 15) // 7 or 8 bits 
						begin
								rx_data[pos] <= rx;
								sample_counter <= 0;
								
								if ((d_num == MAX_7_BITS & pos == 3'b110) | (d_num == MAX_8_BITS & pos == 3'b111))
								begin 
									s_count <= s_num;
									pos <= 0;
									case (par)
										NO_PARITY: state <= STATE_STOP; 
										EVEN_PARITY: state <= STATE_PARITY;
										ODD_PARITY: state <= STATE_PARITY;
										default : state <= STATE_STOP; //default no parity 
									endcase 
								end 
								else pos <= pos + 1;
						end
						else sample_counter <= sample_counter + 1;
					end				
				STATE_PARITY:
				begin 
					if (sample_counter == 15) //
					begin
						state <= STATE_STOP;
						sample_counter <= 0;
						if (par == EVEN_PARITY)	
						begin 
							if (d_num == MAX_8_BITS) PAR_ERR <= (~^rx_data != rx) ? 1'b1 : 1'b0;
							else if(d_num == MAX_7_BITS) PAR_ERR <= (~^rx_data[6:0] != rx) ? 1'b1 : 1'b0; 
						end 
						else if (par == ODD_PARITY)
						begin 
							if (d_num == MAX_8_BITS) PAR_ERR <= (^rx_data != rx) ? 1'b1 : 1'b0;
							else if(d_num == MAX_7_BITS) PAR_ERR <= (^rx_data[6:0] != rx) ? 1'b1 : 1'b0; 
						end 
					end
					else  sample_counter <= sample_counter + 1;
				end 
				STATE_STOP:
				begin 
					if (sample_counter == 15) 
					begin //stop bit is 1 
						sample_counter <= 0;
						case (s_count)
						0: // one stop bit
						begin 
							if (rx != 1'b1) 
							begin  
								FRAME_ERR <= 1'b1;
							end
							else if (err == 3'b000) dout <= rx_data;
							state <= STATE_START;
						end
						1: 
						begin //TWO_STOP_BITS 
							s_count <= s_count - 1; 
							if (rx != 1'b1) 
							begin  
								FRAME_ERR <= 1'b1;
							end 
						end 
						endcase
					end 
					else sample_counter <= sample_counter + 1;
				end 
			endcase 
		end
	end
endmodule
