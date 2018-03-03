///////////////////////////////////////////////////////////////////////////////
 // $Id: clock.v 916 2018-02-25 $
 //
 // Module: clock.v
 // Project: UART
 // Description: A clock that takes 1Hz frequency and produce time [secs/minutes/hours ..]
 // Author: Mostafa AMR  
 //
 // Change history: 
 //
 ///////////////////////////////////////////////////////////////////////////////
 
 module Clock (sec ,min ,hour ,day ,month ,clk_time ,reset);
  input clk_time, reset;
	output reg [6:0] sec , min ;
	output reg [5:0] hour , day ;
	output reg [4:0] month ;
  
  always @(posedge clk_time or posedge reset)
  begin
    if (reset)
      begin
        sec <= 0;
        min <= 0;
        hour <= 0;
				day <= 0 ;
				month <= 0 ;
      end
    else
		begin
		
		sec <= sec + 1 ;
		
		if ( sec == 59 & min != 59 ) begin sec <= 0 ; min <= min + 1 ; end  
		
		if ( min == 59 & sec == 59 & hour != 23 ) begin min <= 0 ; sec <= 0 ; hour <= hour + 1 ; end 
		
		if ( hour == 23 & min == 59 & sec == 59 & day != 29 ) begin hour <= 0 ; min <= 0 ; sec <= 0 ; day <= day + 1 ; end
		
		if ( day == 29 & hour == 23 & min == 59 & sec == 59 ) begin day <= 0 ; hour <= 0 ; min <= 0 ; sec <= 0 ; month <= month + 1 ; end
	
	
		end
	end
    
endmodule