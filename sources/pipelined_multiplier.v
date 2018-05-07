`timescale 1ns / 1ps

module pipelined_multiplier #(parameter WIDTH=32)(
    input wire clk, reset, en,
    input wire [WIDTH-1:0] mcand,
    input wire [WIDTH-1:0] mplier,
    output wire [2*WIDTH-1:0] product);
    
    wire [WIDTH-1:0] mcandq, mplierq;
    wire [2*WIDTH-1:0] productd;
    wire [WIDTH*WIDTH-1:0] partial_product0;
    
    wire [WIDTH*32-1:0] sum16;
    wire [WIDTH*16-1:0] sum8d;
    wire [WIDTH*16-1:0] sum8q;
    wire [WIDTH*8-1:0] sum4;
    wire [WIDTH*4-1:0] sum2;
    
    flopenr #(WIDTH) MCAND(clk, reset, en, mcand, mcandq);
    flopenr #(WIDTH) MPLIER(clk, reset, en, mplier, mplierq);
    
    genvar index;
    generate
        for (index = 0; index < WIDTH; index = index+1) begin:gennum
            and_unit_piped #(WIDTH) AND_UNIT_inst(mcandq, mplierq[index], partial_product0[(index*WIDTH+WIDTH-1):(index*WIDTH)]);
        end
    endgenerate
    
    genvar index2;
    generate
        for (index2 = 0; index2 < 16; index2 = index2+1) begin:gennum2
            assign sum16[(index2*WIDTH*2+WIDTH*2-1):index2*WIDTH*2] = (partial_product0[(2*index2*WIDTH+WIDTH-1):(2*index2*WIDTH)] << 2*index2)+(partial_product0[((2*index2+1)*WIDTH+WIDTH-1):((2*index2+1)*WIDTH)] << (2*index2+1));
        end
    endgenerate
    
    genvar index3;
    generate
        for (index3 = 0; index3 < 8; index3 = index3+1) begin:gennum3
            assign sum8d[(index3*WIDTH*2+WIDTH*2-1):index3*WIDTH*2] = sum16[(2*2*index3*WIDTH+2*WIDTH-1):(2*2*index3*WIDTH)]+sum16[(2*(2*index3+1)*WIDTH+2*WIDTH-1):(2*(2*index3+1)*WIDTH)];
        end
    endgenerate
    
    flopenr #(WIDTH*16) stage_reg(clk, reset, en, sum8d, sum8q);
    
    genvar index4;
    generate
        for (index4 = 0; index4 < 4; index4 = index4+1) begin:gennum4
            assign sum4[(index4*WIDTH*2+WIDTH*2-1):index4*WIDTH*2] = sum8q[(2*2*index4*WIDTH+2*WIDTH-1):(2*2*index4*WIDTH)]+sum8q[(2*(2*index4+1)*WIDTH+2*WIDTH-1):(2*(2*index4+1)*WIDTH)];
        end
    endgenerate
    
    genvar index5;
    generate
        for (index5 = 0; index5 < 2; index5 = index5+1) begin:gennum5
            assign sum2[(index5*WIDTH*2+WIDTH*2-1):index5*WIDTH*2] = sum4[(2*2*index5*WIDTH+2*WIDTH-1):(2*2*index5*WIDTH)]+sum4[(2*(2*index5+1)*WIDTH+2*WIDTH-1):(2*(2*index5+1)*WIDTH)];
        end
    endgenerate
    
    assign product = sum2[127:64] + sum2[63:0];    
    
//    flopenr #(2*WIDTH) OUTPUT(clk, reset, en, productd, product);
    
endmodule

module and_unit_piped #(parameter MCAND=4)(
    input wire [MCAND-1:0] multiplicand,
    input wire multiplier,
    output wire [MCAND-1:0] pproduct);
    
    assign pproduct = {MCAND{multiplier}} & multiplicand;
    
endmodule

//module flopenr#(parameter WIDTH=8)(
//    input wire clk, reset, en,
//    input wire [WIDTH-1:0] d,
//    output reg [WIDTH-1:0] q);
    
//    always @(posedge clk, posedge reset)
//        if (reset) q <= 0;
//        else if (en) q <= d;
//        else q <= q;
//endmodule