module transmitter(tx ,clk_tx ,reset ,w_en ,par ,d_num ,s_num ,data_in);
	output reg tx;
	input clk_tx ,reset;
	input [7:0] data_in;
	input d_num,s_num ,w_en; // d_num: 0: 7 bits, 1: 8 bits | s_num: 0: 1 stop bit ,1: 2 stop bits 
	input [1:0] par; //parity //0 no // 1 even //2 odd
	
	reg [2:0] pos; // 8 bit transmitting 
	reg [1:0] state;
	reg s_count; //count sent stop bits
	reg dnum;
	reg [1:0] parity;
	
	parameter STATE_IDLE	= 2'b00;
	parameter STATE_SEND	= 2'b01;
	parameter STATE_PARITY = 2'b10;
	parameter STATE_STOP = 2'b11;


	parameter NO_PARITY  = 2'b00;
	parameter ODD_PARITY  = 2'b01;
	parameter EVEN_PARITY  = 2'b10;
	
	parameter MAX_7_BITS = 1'b0;
	parameter MAX_8_BITS = 1'b1;
	
	reg [7:0] data;
	
	initial begin 
		state <= STATE_IDLE;
		pos <= 0;
		data <= 0;
	end


	always @ (posedge clk_tx or posedge reset)
	begin
		if (reset)
		begin 
			state <= STATE_IDLE;
			pos <= 0;
			tx <= 1;
			data <= 0;
			dnum <= 0;
			s_count <=0;
			parity <=0;

		end
		else 
		begin 
		
		case (state)
		STATE_IDLE:  //tx = 1
			begin
				if (w_en)
				begin
					state <= STATE_SEND;
					pos <= 0;
					tx <= 0; //start bit
					data <= data_in; // to take data only once @ w_en active .. //in case data changed during process
					dnum <= d_num;
					s_count <= s_num;
					parity <= par;

				end
				else begin data <= 0; tx <= 1;end 
			end
		STATE_SEND: //tx = data >> serial 
		begin
				tx <= data[pos];
				if ((dnum == MAX_7_BITS & pos == 3'b110) | (dnum == MAX_8_BITS & pos == 3'b111))
				begin 
					pos <= 0;					
					case (parity)
					NO_PARITY: state <= STATE_STOP; 
					EVEN_PARITY: state <= STATE_PARITY;//
					ODD_PARITY: state <= STATE_PARITY;//
					default : state <= STATE_STOP; //default no parity 
					endcase 
				end
				else pos <= pos + 1;
			end
		STATE_PARITY:
		begin 
			state <= STATE_STOP;
			if (parity == EVEN_PARITY)	
			begin 
				if (dnum == MAX_8_BITS) tx <= ^data;//~^data; 
				else if(dnum == MAX_7_BITS) tx <= ^data[6:0];//~^data[6:0]; 
			end 
			else if (parity == ODD_PARITY)
			begin 
				if (dnum == MAX_8_BITS) tx <= ~^data;//^data;
				else if(dnum == MAX_7_BITS) tx <= ~^data[6:0];//^data[6:0];
			end 
		end
		STATE_STOP: 
		begin 
			case (s_count)
			0: begin tx <= 1'b1; state <= STATE_IDLE; end //ONE_STOP_BITS
			1: begin tx <= 1'b1; s_count <= 0; end //TWO_STOP_BITS
			endcase
		end 
		endcase
		end 
	end

endmodule