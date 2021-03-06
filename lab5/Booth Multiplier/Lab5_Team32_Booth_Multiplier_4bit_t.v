`timescale 1ns/1ps

module Multiplier_t;
reg signed [3:0] a = 4'b1000, b = 4'b0000;
wire signed [3:0] c_a, c_b;
reg clk = 1'b0;
reg rst_n = 1'b0;
reg start = 1'b0;
wire signed [7:0] p;
wire [1:0] state;
reg signed [7:0] tmp;
reg signed [3:0] tmp_a = 4'b1010, tmp_b = 4'b1100;
//wire c_a, c_b;

// specify duration of a clock cycle.
parameter cyc = 2;

// generate clock.
always #(cyc/2) clk = !clk;

Booth_Multiplier_4bit mul(clk, rst_n, start, a, b, p);

initial begin
    /*@(negedge clk)
    a = 4'b1000;
    b = 4'b1000;*/
    
    repeat (2 ** 8) begin
        @(negedge clk)
        rst_n = 1'b1;
        start = 1'b1; 
        
        #(cyc * 2)
        start = 1'b0;
        #(cyc * 2)
        {tmp_a, tmp_b} = {a, b};
        {a, b} = 8'b11001110;

        #(cyc)
        {a, b} = {tmp_a, tmp_b};
        start = 1'b0;
        tmp = a * b;
        if(tmp !== p)
            $display("error occurs at sub a=%d b=%d p=%b a*b=%b", a, b, p, tmp);
        $display("a=%d b=%d p=%b a*b=%b", a, b, p, tmp);
        {a, b} = {a, b} + 4'b0001;
        
        #cyc
        tmp = a*b;
    end
    #1 $finish;
end
endmodule