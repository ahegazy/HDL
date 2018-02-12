module Flags (full,empty,error,Pcount); 
	input [2:0] Pcount;
	input error; 
	output reg full,empty;
	
  always @ (Pcount,error)
  begin
		$display ("There are %d people waiting to be served..",Pcount); //# of people standing
		case (Pcount)
		3'b000:  
			begin 
			if(error) $display("Error Room is empty .. no one can leave ._."); //someone entered from the front gate 
			full = 0;
			empty = 1;
			end 
		3'b111: 
			begin 
			if(error) $display("Error Room is full .. no one can enter ._."); //FULL
			full = 1;
			empty = 0;
			end 
		default: 
			begin
				full = 0;
				empty = 0;
			end 
		endcase
	end

  
endmodule
