///////////////////////////////////////////////////////////////////////////////
 // $Id: receiver_TB.v 916 2018-02-25 Ahmad Hegazy $
 //
 // Module: receiver_TB.v
 // Project: UART
 // Description: receiver testbench tests the receiver functionality. 
 // Author: receiver written by: Mostafa Amr 
 //					Modification: Ahmad Hegazy <ahegazipro@gmail.com> 
 //
 // Change history: 
 //
 ///////////////////////////////////////////////////////////////////////////////
 
`timescale 10ps / 10ps
module receiver_TB ;

	//INSTANCE OUTPUTS
	wire [7:0] d_out;
	wire [2:0] err;
	//INPUTS 
	reg clk_rx , reset , d_in , d_num , s_num ;
	reg [1:0] par ;
	//TEST OUTPUTS 
	reg [2:0] err_tb ;
	reg [7:0] d_out_tb ;	
	//TEST REGS
	reg [11:0] data_in ;
	reg [7:0] rx_data;
	reg [3:0] count ;
	reg [3:0] index ;
	reg [1:0] state ; parameter start = 0 ; parameter data = 1 ; parameter parity = 2 ; parameter stop = 3 ;
	reg Par_error , Frame_error , Overrun ;
	reg [3:0] parity_check ;
	reg stop_count ;
	reg [3:0] i ;

	receiver R0 ( .clk_rx(clk_rx) ,
								.reset(reset) , 
								.par (par), 
								.d_num (d_num), 
								.s_num (s_num), 
								.dout (d_out), 
								.rx (d_in), 
								.err (err)
								);

	initial 
	begin 
		$monitor("dout: %b ",d_out);
	end 
	/*START TEST RECEIVER*/

	always @ ( posedge clk_rx or reset )
	begin
		err_tb = { Par_error , Frame_error , Overrun } ;
		if ( reset ) begin  d_out_tb = 0 ;rx_data = 0; Par_error = 0 ; Frame_error = 0 ; Overrun = 0 ; index = 0 ; err_tb = 0 ; state = 0 ; count = 0 ; stop_count = 0 ; end 
		else 
		begin
		  case ( state )
			start : begin
					if ( d_in ) begin state <= start ; end else
					if ( ~ d_in & (count == 7) ) begin Frame_error <= 0 ; Par_error <= 0 ; Overrun <= 0;err_tb <=0; state <= data ; count <= 0 ;rx_data <= 0;  end
					else count <= count + 1 ;
					end
			
			data : begin
					count <= count + 1 ;
				    if ( ~d_num ) 
				     begin 
						if ( count == 15 & index != 7)
						begin
						  rx_data[index] <= d_in ; count <= 0 ; index <= index + 1 ;
						end
						if ( index == 7 ) 
						begin
						 if ( par == 0 | par == 3 )
						  begin state <= stop ; end else begin state <= parity ; end
						  index <= 0 ;
						end
					 end
				    if ( d_num )
					 begin
						if ( count == 15 & index != 8)
						begin
						  rx_data[index] <= d_in ; count <= 0 ; index <= index + 1 ;
						end
						if ( index == 8 ) 
						begin
						  if ( par == 0 | par == 3 )
						  begin state <= stop ; end else begin state <= parity ; end
						  index <= 0 ;
						end 
					 end
				   end
				   
			parity: begin
					count <= count + 1 ;
					if ( par == 0 | par == 3 ) begin state <= stop ; count <= 0 ; end else
					begin
					
		             case ( d_num )
					 0 : begin
						 parity_check = rx_data[0] + rx_data[1] + rx_data[2] + rx_data[3] + rx_data[4] + rx_data[5] + rx_data[6] ;
					     end
					 1 : begin
						 parity_check = rx_data[0] + rx_data[1] + rx_data[2] + rx_data[3] + rx_data[4] + rx_data[5] + rx_data[6] + rx_data[7] ;
						end
					 endcase
					if ( count == 15 )
						begin
						count <= 0 ; 
						if ( par == 1 ) 
							begin
							if ( (parity_check[0] == 0 & d_in == 1) | (parity_check[0] == 1 & d_in == 0)) 
							begin state <= stop ; Par_error <= 0 ;end else begin Par_error <= 1 ; state <= stop ;end
							end
						if ( par == 2 )
							begin
							if ( (parity_check[0] == 0 & d_in == 0) | (parity_check[0] == 1 & d_in == 1)) 
							begin state <= stop ; Par_error <= 0 ; end else begin Par_error <= 1 ; state <= stop ; end
							end
						end
					end
					end
	        
			stop : begin
					count <= count + 1 ;
					case ( s_num )
					0 : begin
						if ( count == 15 )
							begin
							  if ( d_in ) begin count <= 0 ;state <= start ;
								
									if(err_tb == 3'b000) d_out_tb <= rx_data;  end
									 else begin count <= 0 ; state <= start ; Frame_error <= 1 ; end
							end
						end
					1 : begin
						if ( count == 15 & stop_count == 0 )
							begin
							 if ( d_in ) begin count <= 0 ; stop_count <=1 ; end
									else begin count <= 0 ; Frame_error <= 1 ; end  
							end
						if ( count == 15 & stop_count == 1 )
							begin
							 if ( d_in ) begin 
							 count <= 0 ; 
							 state <= start ;
	   					 stop_count <= 0 ;
							 if(err_tb == 3'b000) d_out_tb <= rx_data;
							end
									else begin count <= 0 ; state <= start ; Frame_error <= 1 ; stop_count <= 0 ; end
							end
						end

				    endcase
  				   end
			
			
	      endcase
	    end
	end

	/*END TESTING CODE */

	
	
	
/*START TESTING CODE*/
	always #5 clk_rx = ~ clk_rx ;
	
	initial 
	begin 
		rx_data = 0;
		Par_error = 0 ;
		Frame_error = 0 ;
		Overrun = 0 ;
		index = 0 ;
		err_tb = 0 ;
		state = 0 ;
		count = 0 ;
		stop_count = 0 ; 
		state = start;
		clk_rx = 0 ;
		i = 0;
	end
	
	event reset_trigger;          
	event reset_done_trigger;
	initial 
	begin
  
	forever 
	begin
    
    @( reset_trigger );
    @( negedge clk_rx );
	# 1 ;
    reset = 1 ;
    @( negedge clk_rx );
	# 1 ;
    reset = 0 ;
    -> reset_done_trigger ;
    
	end
	end


integer j,k,x;//reg [1:0]
always @ ( d_num or s_num or par )
begin
case ({ d_num , s_num , par }) 
				4'b0000 : data_in <= 12'b111101010100 ;
				4'b0011 : data_in <= 12'b111101111110 ;
				4'b1000 : data_in <= 12'b110001010100 ; // frame error
				4'b0100 : data_in <= 12'b111101110110 ;
				4'b1011 : data_in <= 12'b111101010110 ;
				4'b0111 : data_in <= 12'b111101011110 ;
				4'b1100 : data_in <= 12'b101101010100 ; // frame error
				4'b1111 : data_in <= 12'b111101010100 ;
				4'b0001 : data_in <= 12'b111101010100 ; // parity error
				4'b0010 : data_in <= 12'b111001010110 ;  
				4'b1001 : data_in <= 12'b110111010100 ; 
				4'b1010 : data_in <= 12'b111101010100 ; // parity error
				4'b0101 : data_in <= 12'b111101010110 ;
				4'b0110 : data_in <= 12'b111101010100 ;
				4'b1101 : data_in <= 12'b111101010100 ;
				4'b1110 : data_in <= 12'b110101010100 ;
				endcase				
end

initial
begin
j=0;
k=0;
x=0; 
data_in =0;
s_num = 0;
d_num = 0 ; 
par = 0;
end 
	task gen_dum();
begin 
  for (x=0;x<4;x=x+1) //for parity
  begin
      par <= x;
    
    for (j=0;j<2;j=j+1)  //for s_num
    begin
      s_num <= j;
      for (k=0;k<2;k=k+1)   //for d_num
      begin
	  d_num <= k;
	  
	  
	  #2000;
				// wait # of cycles */
      #16;
      repeat(12)
	begin
	# 160 ;
	d_in = data_in[i];
	i = i + 1 ;
	end
	i = 0 ; d_in = 1 ;
	
	
	# 2000;
    
      end
    end
    end
  end 

endtask

always @ (d_out)
begin 
	if (err != err_tb | d_out != d_out_tb)
	begin
			$display ("ERROR @ err: %b, err_tb %b , data_in: %b , d_out: %b, d_out_tb: %b, d_num: %b,  s_num: %b,parity: %b ",err,err_tb,data_in,d_out,d_out_tb,d_num,s_num,par);
			#10;
		$stop; 
	end 

end 


	initial
	begin
	#10 -> reset_trigger ;
	@ ( reset_done_trigger );
	
	# 4 ; 
	gen_dum();
	$display("TEST succeeded");
	$stop;
	end 
	
	/*END TESTING CODE */
	endmodule