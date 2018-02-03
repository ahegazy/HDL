module alu(A,B,ctrl_op,ctrl_in,out_signal,carry_bit);
  input [7:0] A,B;
  input [2:0] ctrl_op;
  input ctrl_in;
  output reg [7:0] out_signal;
  output reg carry_bit;
  
  always @(A or B or ctrl_op or ctrl_in)
  begin
    carry_bit = 0;
    case(ctrl_op)
      3'b000:{carry_bit, out_signal} = A + B;
      3'b001: out_signal = A - B;
      3'b010: out_signal = A & B;
      3'b011: out_signal = A | B;
      3'b100: out_signal = ctrl_in ? {B[6:0],B[7]} : {A[6:0],A[7]};
      3'b101: out_signal = ctrl_in ? {B[0],B[7:1]} : {A[0],A[7:1]};
      3'b110: out_signal = ctrl_in ? B[7:0] << 1'b1: A[7:0] << 1'b1;
      3'b111: out_signal = ctrl_in ? B[7:0] >> 1'b1 : A[7:0] >> 1'b1; 
      default: out_signal = 0; 
      endcase
  end
endmodule