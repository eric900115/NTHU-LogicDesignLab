`timescale 1ns/1ps

module Lab2_Team32_Ripple_Carry_Adder_t;
reg [7:0] a = 8'b0;
reg [7:0] b = 8'b0;
reg cin = 1'b0;
wire [7:0] sum;
wire cout;
/*
Ripple_Carry_Adder rca(
    .a (a),
    .b (b),
    .cin (cin),
    .cout (cout),
    .sum (sum)
);*/
Carry_Look_Ahead_Adder_8bit cla(a, b, cin, sum, cout);
// uncommment and add "+access+r" to your nverilog command to dump fsdb waveform on NTHUCAD
// initial begin
//      $fsdbDumpfile("Adders.fsdb");
//      $fsdbDumpvars;
// end

initial begin
  repeat (2 ** 16) begin
   	#1 {a, b} = {a, b} + 1'b1;
	#1
	if(a + b + cin != {cout, sum})
		$display("error occurs at a=%b b=%b cin=%b cout=%b sum=%b", a, b, cin, cout,sum);
  end
  cin = 1'b1;
  repeat (2 ** 16) begin
   	#1 {a, b} = {a, b} + 1'b1;
	#1
	if(a + b + cin != {cout, sum})
		$display("error occurs at a=%b b=%b cin=%b cout=%b sum=%b", a, b, cin, cout,sum);
  end
  #1 {a, b} = 16'b0;
   #1 $finish;
  
end  
endmodule
