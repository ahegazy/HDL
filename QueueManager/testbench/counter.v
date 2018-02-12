 module Counter (Pcount,error,backPC,frontPC,clk,rst);
	
	output reg [2:0] Pcount;
	output reg error;
	input backPC,frontPC,clk,rst;
	
	reg PrevUP,PrevDown,CurUP,CurDown;

 always @ (posedge clk or posedge rst)
  begin
	if (rst)
	begin 
		Pcount = 0; 
		PrevUP = 1 ;
		PrevDown = 1;
		error = 0;
	end
	else
		begin 
		CurUP = backPC; CurDown = frontPC;
		case (Pcount)
		3'b000 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) begin Pcount = 3'b000;error = 0; end // 1 in , 1 out 
				else if(~CurUP & PrevUP) begin Pcount = 3'b001;error = 0; end // 1 in 
				else if(~CurDown & PrevDown) begin Pcount = 3'b000;error = 1; end  // 1 out  // no change //error
				else Pcount = 3'b000; // nochange			
			end	
		3'b001 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b001;
				else if(~CurUP & PrevUP) Pcount = 3'b010;
				else if(~CurDown & PrevDown) Pcount = 3'b000; // 1 out 
				else Pcount = 3'b001; // nochange
			end	
		3'b010 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b010;
				else if(~CurUP & PrevUP) Pcount = 3'b011;
				else if(~CurDown & PrevDown) Pcount = 3'b001; // 1 out 
				else Pcount = 3'b010; // nochange				
			end	
		3'b011 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b011;
				else if(~CurUP & PrevUP) Pcount = 3'b100;
				else if(~CurDown & PrevDown) Pcount = 3'b010; // 1 out 
				else Pcount = 3'b011; // nochange				
			end	
		3'b100 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b100;
				else if(~CurUP & PrevUP) Pcount = 3'b101;
				else if(~CurDown & PrevDown) Pcount = 3'b011; // 1 out 
				else Pcount = 3'b100; // nochange
			end	
		3'b101 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b101;
				else if(~CurUP & PrevUP) Pcount = 3'b110;
				else if(~CurDown & PrevDown) Pcount = 3'b100; // 1 out 
				else Pcount = 3'b101; // nochange
			end	
		3'b110 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) Pcount = 3'b110;
				else if(~CurUP & PrevUP) Pcount = 3'b111;
				else if(~CurDown & PrevDown) Pcount = 3'b101; // 1 out 
				else Pcount = 3'b110; // nochange
			end	
		3'b111 : 
			begin 
				if (~CurUP & PrevUP & ~CurDown & PrevDown) begin Pcount = 3'b111;error = 0; end
				else if(~CurUP & PrevUP) begin Pcount = 3'b111;error = 1; end // no change Limit 7  // add error limited up 
				else if(~CurDown & PrevDown) begin Pcount = 3'b110;error = 0; end // 1 out 
				else Pcount = 3'b111; // no change
			end	
		endcase
		PrevUP <= backPC;
		PrevDown <= frontPC;
	end	
	
  end

endmodule