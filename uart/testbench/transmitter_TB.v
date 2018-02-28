`timescale 10 us / 1 us

module transmitter_TB;
  reg clk_tx, reset, en, d_num, s_num;
  reg [1:0] par;
  reg [7:0] data_in;
  wire tx; //output

  reg [3:0] i;
  reg [1:0] state;

	
 //regs 

  reg [1:0] parity;
  reg [7:0] data;
  
  
  transmitter TB0 (tx ,clk_tx ,reset ,en ,par ,d_num ,s_num ,data_in);
  
  
	
	//START TEST CASES

  initial
  begin
    clk_tx = 0;
    reset = 0;
    data_in = 0;
    d_num = 0;
    s_num = 0;
    par = 0;
    en = 0;
  end
  
  always
    #1 clk_tx = ~clk_tx;
    
  event RST_Done_Trigger;
   
  initial
  begin
    @(negedge clk_tx);
    reset = 1;
    @(negedge clk_tx);
    reset = 0;
    #10;
    -> RST_Done_Trigger;
  end
  
	//generating input pos
integer j,k,x;//reg [1:0]

initial
begin
j=0;
k=0;
x=0; 
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
			  data_in <= $urandom;
				en <= 1;
				// wait # of cycles 
      #5;
      en <= 0;
      #50;
      end
    end
    end
  end 

endtask

	
	initial
	begin 
  @(RST_Done_Trigger)
   begin
	 #4;
   gen_dum;
	 	$display("TEST succeeded");

	$stop;
  end
	end 


always @ (posedge clk_tx)
begin 
  if(reset)
 begin 
	if (tx != 1)
	begin 
	    $display("ERR: DIDN't RESET tx: %b ",tx);
      #1
			$stop; 
  end 
          
end 
  else 
  begin
    //count i 
    //data 
    case (i)
      0: //reading 1st bit // starting bit
      begin
      if (en ==  1) begin 
       if(tx != 0 )
     	  begin 
	       $display("ERR: DIDN't RESET tx: %b ",tx);
         #1
			   $stop;
        end 
        else begin i = i + 1;data = data_in; end 
        end else i = 0; 
      end 
      1: //reading data
      begin 
        if (tx != data[0])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[0],tx);
             #1
			       $stop;
        end else i = i + 1; 
      end 
      2:       begin 
        if (tx != data[1])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[1],tx);
             #1
			       $stop;
        end else i = i + 1; 
      end
      3:       begin 
        if (tx != data[2])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[2],tx);
             #1
			       $stop;
        end else i = i + 1; 
    end
      4:       begin 
        if (tx != data[3])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[3],tx);
             #1
			       $stop;
        end else i = i + 1; 
     end 
      5:       begin 
        if (tx != data[4])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[1],tx);
             #1
			       $stop;
        end else i = i + 1; 
   end 
      6:       begin 
        if (tx != data[5])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[5],tx);
             #1
			       $stop;
        end else i = i + 1; 
 end 
    7:       begin 
        if (tx != data[6])
        begin 
              $display("ERR: Data[0]: %b != tx: %b ",data[6],tx);
             #1
			       $stop;
        end else if (d_num) i = 8; //i + 1
        else if(~d_num & (par == 1 | par == 2)) i = 9; // there is parity .. 
      else i = 10;// stop state 
       end 
      8:       
      begin 
        if (tx != data[7])
        begin 
              $display("ERR: Data[7]: %b != tx: %b ",data[7],tx);
             #1
			       $stop;
        end         
        else if((par == 1 | par == 2)) i = 9; // there is parity .. 
        else i = 10;// stop state 

      end 
        /* checking parity and stop */
      9:       
      begin //there is parity 
        case (par)
        1: //odd parity 
        begin 
          if ((d_num == 1 & tx != ~^data) | (d_num == 0 & tx != ~^data[6:0]))
          begin 
            $display("ERR: d_num %b PARITY %b Data: %b = tx: %b ",d_num,par,data,tx);
            #1
			      $stop;
          end 
          else i = 10; //check for stop bits 
        end
        2:   //odd parity 
        begin 
          if ((d_num == 1 & tx != ^data) | (d_num == 0 & tx != ^data[6:0]))
          begin 
              $display("ERR: dnum %b PARITY %b Data: %b = tx: %b ",d_num,par,data,tx);
             #1
			       $stop;
          end 
          else i = 10; //check for stop bits 
        end 
        endcase  
      end 
      10:       
      begin //stop bits 
        if (tx != 1)
        begin 
              $display("ERR: STPOP BIT ERROR Data: %b tx: %b ",data,tx);
             #1
			       $stop;
        end 
        else if (s_num == 1 ) i = 11;
        else i = 0; 
      end
      11:       begin 
        if (tx != 1)
        begin 
             $display("ERR: STPOP BIT ERROR Data: %b tx: %b ,s_num = %b ",data,tx,s_num);
             #1
			       $stop;
        end else i = 0; 
 end   
 endcase 
  end 				
			end
	//		end
	//END TEST CASES
  endmodule


