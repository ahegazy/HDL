// DUT : sBqm
`timescale 1ps/1ps // unit/precision  
	/*
		1 error appears when counting as the DUT counter depends on the clock, while the test counter depends one the negedge of the photocells so there is a 1/2 clock delay between both ..
		can be skipped by using @(Pcount) only, in the always block line 127
	*/
module sBqm_tb;
  
  reg [1:0] Tcount;
  reg frontPC,backPC,rst,clk;
  wire full,empty;
  wire [2:0] Pcount;
  wire [4:0] Wtime;
	//TestBench regs
  reg [2:0] Pcount_tb;
  reg oldUP_tb,oldDown_tb;
  
 sBqm q0 (
 .frontPC (frontPC), //input
 .backPC (backPC),
 .Tcount (Tcount),
 .clk (clk),
 .rst (rst),
 .full (full), //output
 .empty (empty),
 .Wtime (Wtime),
 .Pcount (Pcount)
 );
 
// initializing all inputs  
 initial 
 begin
   frontPC = 1;
   backPC = 1;
   Tcount = 0;
   clk = 0;
   rst = 0;
   
   //initializing testing regs
   oldUP_tb = 1;
   oldDown_tb = 1;
   Pcount_tb = 0;
 end
 
 // Generating The clock
 always 
 #5 clk = ~clk;
 

 //Displaying the values
initial begin 
  //$display ("\t\ttime,\tclk,\trst,\tUP\tDOWN\tPcount\tTcount\tWtime\tfull\tempty");
  //$monitor ("%d,\t%b,\t%b,\t%b,\t%b,\t%d,\t%d,\t%d,\t%b,\t%b",$time,clk,rst,backPC,frontPC,Pcount,Tcount,Wtime,full,empty);
  $display ("\t\ttime,\tclk,\tPcount\tPcount_tb");
  $monitor ("%d,\t%b,\t%d,\t%d",$time,clk,Pcount,Pcount_tb);
end


//controlling tasks
task reset(); 
begin 
	@(negedge clk);
		rst = 1;
	@(negedge clk);
		rst = 0;
end
endtask 

task change_T(); 
begin
	Tcount = Tcount + 1;
end 
endtask


task up(); 
begin
	@(negedge clk);
		backPC = ~backPC;
	@(negedge clk);
		backPC = ~backPC;
end
endtask

task down(); 
begin
	@(negedge clk);
		frontPC = ~frontPC;
	@(negedge clk);
		frontPC = ~frontPC;
end
endtask

task up_down(); 
begin
	@(negedge clk);
		backPC = ~backPC;
		frontPC = ~frontPC;
	@(negedge clk);
		backPC = ~backPC;
		frontPC = ~frontPC;
end
endtask

//A Counter for Testing block 

always @ (negedge backPC or negedge frontPC or rst)
begin 
	if (rst) begin 
		Pcount_tb = 0;
		oldUP_tb = 1;
		oldDown_tb = 1;
	end
	else 
	begin 
		if (~backPC & oldUP_tb) begin Pcount_tb = (Pcount_tb == 3'b111) ? Pcount_tb : Pcount_tb + 1;end
		if (~frontPC & oldDown_tb) begin Pcount_tb = (Pcount_tb == 3'b000) ? Pcount_tb : Pcount_tb - 1;end
	end
end

always @ (backPC)  oldUP_tb = #5 backPC;
always @ (frontPC)  oldDown_tb = #5 frontPC;



//Testing 
always @(Pcount or Pcount_tb)
begin 
	if (Pcount != Pcount_tb) begin 
		$display ("Error @ time: %d ,clk: %b, Pcount: %d, Pcount_tb: %d",$time,clk,Pcount,Pcount_tb);
		$display ("see TB 'sBqm_tb' code comments ... ");
		#10 $stop;
	end
end

initial
begin 
  #10 reset(); //wait 10 timeunits then reset
  change_T();
  up_down();
  repeat (8)
   up();
   
  repeat (8)
   down();   
  up_down();
end
endmodule