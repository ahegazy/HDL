# Arithmetic and logic unit (ALU)
	An arithmetic and logic unit (ALU) is a combinational logic digital circuit that performs arithmetic and logic
bitwise operations, you are required to design an ALU circuit that can perform addition, substation,
bitwise operations like AND ,OR ,Shift Left, Shift Right, Rotate Left and Rotate Right.

ALU has to accept an input data A and B of 8 bits , ctrl_op control operation signal of 3 bits so as the
user can choose the target operation and also ctrl_in control input signal of one bit to choose which
input to be used. Output has to be out _signal of 8 bits which is the result of the operation and
carry_bit which is one bit to hold the value of the carry in case of addition operation except that it has
to be zero all time.

## Control signals in design:
	Signal A and B will be our input data, ctrl_op control operation signal will be used to choose operation
where ( ooo….add , 001….subtract , 010….AND ,011….OR,100… Rotate one bit left, 101… Rotate one bit
right,110…. Shift one bit left , 111…. Shift one bit right). fisrt four operation required 2 operands (A and
B) but the last four take only one operand so we use ctrl_in control input signal to choose which input
will be used (A or B) in those operations , if ctrl_in is zero the operation will be applied on input A else
input B has to be in charge , ctrl_in has no effect at the first four operations, its effect appears only with
the last four.


## Language
- Verilog