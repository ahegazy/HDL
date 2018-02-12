`timescale 1ps / 1ps

/*
	A friend  created this test for his code .. 
	tested it on mine , :D 
	Creator: Mostafa Amr <FOE AlexUni> 
	Date:  12/2/2018
*/
 
module SBqM_TB2 ;
  
  reg clk , reset , FPC , BPC  ;
  reg [1:0] Tcount;
  wire Empty_Flag , Full_Flag;
  wire [2:0] Pcount ;
  wire [4:0] Wtime ;
  reg [2:0] Pcount_TB ;
  reg state1_TB , state2_TB , Up_TB , Down_TB ;
  
  
  
 sBqm q0 (
 .frontPC (FPC), //input
 .backPC (BPC),
 .Tcount (Tcount),
 .clk (clk),
 .rst (reset),
 .full (Full_Flag), //output
 .empty (Empty_Flag),
 .Wtime (Wtime),
 .Pcount (Pcount)
 );

  initial
  begin
    
    FPC = 1 ; BPC = 1 ; reset = 0 ; clk = 0 ; Pcount_TB = 0 ; Tcount = 0 ; 
    
  end
  
  always #5 clk = ~clk ;
  
  initial
  begin
    
    $display ("\t\ttime,\tclk,\tPcount,\tPcount_tb");
    $monitor ("%d,\t%b,\t%d,\t%d",$time,clk,Pcount,Pcount_TB);
    
  end

event reset_trigger;
event reset_done_trigger;

initial 
begin
  
  forever 
  begin
    
    @( reset_trigger );
    @( negedge clk );
    reset = 1 ;
    @( negedge clk );
    reset = 0 ;
    -> reset_done_trigger ;
    
  end
end


always @ ( reset )
begin
  if ( reset ) begin Pcount_TB = 0 ; state1_TB <= 0 ; Down_TB <= 0 ; state2_TB <= 0 ; Up_TB <= 0 ; end
end
  
always @ ( posedge clk ) // FSM for each photocell to count when input signal goes from 1 to 0
  begin
         
    case (state1_TB)                                     // FSM for the front sensor 
      
    0 : begin                                         // state1 = 0 when signal = 1
        if (FPC) begin state1_TB <= 0 ; Down_TB <= 0 ; end  // when input is 1 , stay in the same state , no count
        else begin state1_TB <= 1 ; Down_TB <= 1 ; end      // when input is 0 , move to state1 = 1 , Pcount = Pcount - 1
        
        end
        
    1 : begin                                         // state1 = 1 when signal = 0
        if (FPC) begin state1_TB <= 0 ; Down_TB <= 0 ; end  // when input is 1 , move to state1 = 0 , no count
        else begin state1_TB <= 1 ; Down_TB <= 0 ; end      // when input is 0 , stay in the same state , no count
  
        end
    endcase  
      
    case (state2_TB)                                     // FSM for the back sensor
      
    0 : begin                                         // state2 = 0 when signal = 1
        if (BPC) begin state2_TB <= 0 ; Up_TB <= 0 ; end    // when input is 1 , stay in the same state , no count
        else begin state2_TB <= 1 ; Up_TB <= 1 ; end        // when input is 0 , move to state2 = 1 , Pcount = Pcount + 1
        
        end
        
    1 : begin                                         // state1 = 2 when signal = 0
        if (BPC) begin state2_TB <= 0 ; Up_TB <= 0 ; end    // when input is 1 , move to state2 = 0 , no count
        else begin state2_TB <= 1 ; Up_TB <= 0 ; end        // when input is 0 , stay in the same state , no count
  
        end 
    endcase 
    end   

always @ ( Up_TB or Down_TB )
begin
  
  if ( (Pcount_TB != 7) & Up_TB & ~Down_TB ) begin Pcount_TB = Pcount_TB + 1 ; end else
         if ( (Pcount_TB != 0) & ~Up_TB & Down_TB ) begin Pcount_TB = Pcount_TB - 1 ; end else
           begin Pcount_TB = Pcount_TB  ; end
end

always @ ( posedge clk )
begin
  if ( Pcount != Pcount_TB )
    begin 
      $display (" DUT Error at %d " , $time);
      $display (" Expected value %d  , Got %d " , Pcount_TB , Pcount );
      #5 $stop ;  
    end
end

initial
begin
  #10 -> reset_trigger ;
  @ ( reset_done_trigger );
	Tcount = 2'b11;
  repeat (8)
  begin
    @( negedge clk );
    BPC = ~BPC ;
    @( negedge clk );
    BPC = ~BPC ;
  end 
  
  repeat (8)
  begin
    @( negedge clk );
    FPC = ~FPC;
    @( negedge clk );
    FPC = ~FPC;
  end
  
  @( negedge clk );
  BPC = ~BPC ;
  FPC = ~FPC ;
   
end


endmodule

