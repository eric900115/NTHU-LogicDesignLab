`timescale 1ns/1ps

module Traffic_Light_Controller (clk, rst_n, lr_has_car, hw_light, lr_light, state);
input clk, rst_n;
input lr_has_car;
output [2:0] hw_light;
output [2:0] lr_light;
output [2:0] state;

//light[0]:Red light[1]:Yellow light[2]:Green
reg [2:0] hw_light, lr_light;
reg [2:0] state, next_state;

reg [6:0] cycles, next_cycles;
wire is_80_cycles;

parameter HW_G = 3'd0;//lr:r
parameter HW_Y = 3'd1;//lr:r
parameter HW_R = 3'd2;//lr:r
parameter LR_G = 3'd3;//hw:r
parameter LR_Y = 3'd4;//hw:r
parameter LR_R = 3'd5;//hw:r

always @(posedge clk) begin
    if(rst_n == 1'b0) begin
        state <= HW_G;
        cycles <= 7'd1;
    end
    else begin
        state <= next_state;
        cycles <= next_cycles;
    end
end

assign is_80_cycles = (cycles == 7'd80) ? 1'b1 : 1'b0;

always @(*) begin
    case(state)
        HW_G:begin
            hw_light = 3'b100;
            lr_light = 3'b001;
            next_state = (is_80_cycles == 1'b1 && lr_has_car == 1'b1) ? HW_Y : HW_G;
            if(is_80_cycles == 1'b0) begin
                next_cycles = cycles + 7'd1;
            end
            else begin
                if(lr_has_car == 1'b0)
                    next_cycles = 7'd80;
                else
                    next_cycles = 7'd1;
            end
        end
        HW_Y:begin
            hw_light = 3'b010;
            lr_light = 3'b001;
            if(cycles == 7'd20) begin
                next_state = HW_R;
                next_cycles = 7'd1;
            end
            else begin
                next_state = HW_Y;
                next_cycles = cycles + 1;
            end
        end
        HW_R:begin
            hw_light = 3'b001;
            lr_light = 3'b001;
            if(cycles == 7'd1) begin
                next_state = LR_G;
                next_cycles = 7'd1;
            end
            else begin
                next_state = HW_R;
                next_cycles = cycles + 1;
            end
        end
        LR_G:begin
            hw_light = 3'b001;
            lr_light = 3'b100;
            if(cycles == 7'd80) begin
                next_state = LR_Y;
                next_cycles = 7'd1;
            end
            else begin
                next_state = LR_G;
                next_cycles = cycles + 1;
            end
        end
        LR_Y:begin
            hw_light = 3'b001;
            lr_light = 3'b010;
            if(cycles == 7'd20) begin
                next_state = LR_R;
                next_cycles = 7'd1;
            end
            else begin
                next_state = LR_Y;
                next_cycles = cycles + 1;
            end
        end
        default:begin //LR_R
            hw_light = 3'b001;
            lr_light = 3'b001;
            if(cycles == 7'd1) begin
                next_state = HW_G;
                next_cycles = 7'd1;
            end
            else begin
                next_state = LR_R;
                next_cycles = cycles + 1;
            end
        end
    endcase
end

endmodule