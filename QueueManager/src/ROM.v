module ROM(Wtime,address); //address = {Tcount,Pcount}
  output reg [4:0] Wtime;
  input [4:0] address; 
  
  always @(address)
  
  begin
  case(address)
	5'b01001:Wtime = 3;
	5'b10001:Wtime = 3;
	5'b11001:Wtime = 3;
	5'b01010:Wtime = 6;
	5'b10010:Wtime = 4;
	5'b11010:Wtime = 4;
	5'b01011:Wtime = 9;
	5'b10011:Wtime = 6;
	5'b11011:Wtime = 5;
	5'b01100:Wtime = 12;
	5'b10100:Wtime = 7;
	5'b11100:Wtime = 6;
	5'b01101:Wtime = 15;
	5'b10101:Wtime = 9;
	5'b11101:Wtime = 7;
	5'b01110:Wtime = 18;
	5'b10110:Wtime = 10;
	5'b11110:Wtime = 8;
	5'b01111:Wtime = 21;
	5'b10111:Wtime = 12;
	5'b11111:Wtime = 9;
	default: Wtime=0;
  endcase
  $display("Please Wait %d Minutes To Be Served.", Wtime) ;

end
endmodule
