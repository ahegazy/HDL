///////////////////////////////////////////////////////////////////////////////
 // $Id: uart_TB.v 916 2018-02-25 Ahmad Hegazy $
 //
 // Module: uart_TB.v
 // Project: UART
 // Description: uart test bench .. tests the uart inputs/outputs and functionality.
 // Author: Ahmad Hegazy <ahegazipro@gmail.com> 
 //
 // Change history: 
 //
 ///////////////////////////////////////////////////////////////////////////////
`timescale 10ns/1ns
module uart_TB;


/*INPUTS*/
reg clk ,reset ,d_num ,s_num;
reg [7:0] data_in;
reg [1:0] bd_rate ,par;

/* OUTPUTS */
wire [7:0] dout;
wire [2:0] err;


/* calculate waiting time*/

parameter WAIT_9600 = (1000_000_000/9600)*11; //wait 11 cycles 
parameter WAIT_4800 = (1000_000_000/4800)*11; //wait 11 cycle
parameter WAIT_2400 = (1000_000_000/2400)*11; //wait 11 cycle
parameter WAIT_1200 = (1000_000_000/1200)*11; //wait 11 cycle
parameter WAIT_15MINS = 15 * 60 * 100_000_000; // 15 minutes to ns - 10 timeunits ..

//UART instance

uart UART0	(			.clk(clk) ,
							.reset(reset) ,
							.bd_rate(bd_rate) ,
							.par(par) ,
							.d_num(d_num) ,
							.s_num(s_num) ,
							.data_in(data_in)
							);

assign dout = UART0.dout;
assign err = UART0.err;

/*Initializing inputs*/
initial 
begin 
 //initialize here 
	clk = 0;
	reset = 0;
	bd_rate = 0;
	par = 0;
	d_num = 0;
	s_num = 0;
 
end 

/*Monitor values*/
initial 
begin 
  $display ("\t\ttime,\tdata_in,\tbaud,\ts_num,\td_num,\terr,\tdout");
  $monitor ("%d,\t%b,\t%b,\t%b,\t%b,\t%b,\t%b",$time,data_in,bd_rate,s_num,d_num,err,dout);
end

//Generate clock 
always 
#1 clk = ~clk;

event rst_done;
/*Generating input values */
task rst();
  begin
  @(negedge clk);
    reset = 1;
	#5
  @(negedge clk);
		begin 
		reset = 0;
		->rst_done;
		end
	
	

end 
endtask

//generating input pos
integer j,k,x,i;//reg [1:0]

initial
begin
j=0;k=0;x=0;i=0; 
end 

task gen_dum();
begin 
 for (i=0;i<4;i=i+1) //for baud
  begin
    bd_rate = i;

  for (x=0;x<4;x=x+1) //for baud
  begin
      par = x;
    
    for (j=0;j<2;j=j+1)  //for s_num
    begin
      s_num = j;
      for (k=0;k<2;k=k+1)   //for d_num
      begin
        d_num = k;
			  data_in <= $urandom;				
				
				#WAIT_15MINS;

/* //WE can use these values and force the enable signal .. 
				case (bd_rate)
				0: #WAIT_1200;
				1: #WAIT_2400;
				2: #WAIT_4800;
				3: #WAIT_9600;
				endcase				
				/***/
				
      end
    end
    end
  end 
end
endtask


initial 
begin 
  #1 rst();
end

initial
begin 
  @(rst_done)
  begin

  gen_dum;
  #100;
	$display("TEST succeeded");

  $stop;
  end
end 
  
always @ (dout)
begin 

	//checking reset ERROR
	if(reset == 1 & dout != 0) 
		begin
      $display("ERR reset: %b != dout: %b ",reset,dout);
      #1
			$stop; 
		end 
		
  //checking dout == din 
	if ((((d_num == 0) & (data_in[6:0] != dout[6:0])) | ((d_num == 1) & (data_in != dout))) & (reset != 1)) 
    begin
			$display("ERR din: %b != dout: %b ",data_in,dout);
      #1
			$stop;
	end
			

end 
 
endmodule