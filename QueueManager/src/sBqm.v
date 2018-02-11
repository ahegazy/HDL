module sBqm (frontPC,backPC,Tcount,clk,rst,full,empty,Wtime,Pcount);
  input [1:0] Tcount;
  input frontPC,backPC,rst,clk;
  output full,empty;
  output [2:0] Pcount;
  output [4:0] Wtime;
  wire error;

  Counter C1 (Pcount,error,backPC,frontPC,clk,rst);
  Flags F1 (full,empty,error,Pcount);
  ROM R1 (Wtime,{Tcount,Pcount});
  
endmodule