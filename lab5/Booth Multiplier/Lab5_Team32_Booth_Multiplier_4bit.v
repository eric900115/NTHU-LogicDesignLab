`timescale 1ns/1ps 

module Booth_Multiplier_4bit(clk, rst_n, start, a, b, p);
input clk;
input rst_n; 
input start;
input signed [3:0] a, b;
output signed [7:0] p;

reg [1:0] state, next_state;
wire finish_cal;

parameter Wait = 2'd0;
parameter Cal = 2'd1;
parameter Finish = 2'd2;

Booth mul(start, finish_cal, a, b, p, clk);

always @(posedge clk) begin
    if(rst_n == 1'b0) begin
        state <= Wait;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        Wait: begin
            next_state = (start == 1'b1) ? Cal : Wait;
        end
        Cal: begin
            next_state = (finish_cal == 1'b1) ? Finish : Cal; 
        end
        default: begin //Finish
            next_state = Wait;
        end
    endcase
end

endmodule

module Booth(start, finish, a, b, product, clk);
input start;
input clk;
input signed [3:0] a, b;
output signed [7:0] product;
output finish;

reg signed [8:0] p;
reg signed [8:0] next_p;
//reg signed [8:0] product;
wire signed [8:0] a_8bits;
reg [2:0] cycles, next_cycles;
reg shift_bit, next_shift_bit;

always @(posedge clk) begin
    if(start == 1'b0) begin
        cycles <= 3'd1;
        shift_bit <= 1'b0;
        p <= {5'b0, b};
    end
    else begin
        cycles <= next_cycles;
        shift_bit <= next_shift_bit;
        p <= next_p;   
    end
end

assign finish = (cycles == 3'd4) ? 1'b1 : 1'b0;
assign a_8bits = {a[3], a, 4'd0};
assign product = p[7:0];

always @(*) begin
    if(cycles <= 3'd4) begin
        next_cycles = cycles + 3'd1;
        next_shift_bit = p[0];
        case({p[0], shift_bit})
            2'b01: begin
                next_p = (p + a_8bits) >>> 1;
            end
            2'b10: begin
                next_p = (p - a_8bits) >>> 1;
            end
            default: begin
                next_p = p >>> 1;            
            end
        endcase
    end
    else begin
        next_cycles = cycles;
        next_shift_bit = shift_bit;
        next_p = p;
    end
end


endmodule
