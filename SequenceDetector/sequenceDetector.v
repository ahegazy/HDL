module sequnceDetector(input DATA_IN,clk,rst ,output reg SEQ_FOUND);
  reg [2:0] state;
  reg A;
  always @(posedge clk,posedge rst) 
  begin
   SEQ_FOUND <= 1'b0; //NEW CYCLE BACK TO ZERO
	 A = DATA_IN;
	if(rst) state = 3'b000;
	else begin
    case (state)
      3'b000: state = A ? 3'b001 : 3'b000; 
      3'b001: state = A ? 3'b010 : 3'b000;
      3'b010: state = A ? 3'b001 : 3'b011;
      3'b011: state = A ? 3'b100 : 3'b000;
      3'b100: state = A ? 3'b010 : 3'b101;
      3'b101: //begin state <= A ? 3'b001 : 3'b000; SEQ_FOUND = A ? 1'b0 : 1'b1; end
      begin
        if(A) state = 3'b001;
        else 
        begin
          state <= 3'b000;
          SEQ_FOUND <= 1'b1;
        end
      end
    endcase
	end
  end
endmodule
