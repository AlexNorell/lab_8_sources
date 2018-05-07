`timescale 1ns / 1ps

module fact_DP(
    input [3:0] N,
    input LOADCNT, ENCNT,
    input selMUXPROD, LOADPROD,
    input selMUXOUT,
    input clk, rst,
    output GT,
    output [31:0] OUTPUT);    
    
    wire [31:0] muxProdOut, outPROD;
    wire [31:0] outMUL; 
    wire [3:0] outCNT;
    
    wire [31:0] unused;
    
    MUX_2 #32 MUXPROD(selMUXPROD, outMUL, 32'b1, muxProdOut);
    MUX_2 #32 MUXOUT(selMUXOUT, outPROD, 32'b0, OUTPUT);
    
    MUL #32 MULTIPLIER({28'b0, outCNT}, outPROD, {unused, outMUL});
    
    REG_D #32 PROD(clk, rst, LOADPROD, muxProdOut, outPROD);
    
    CMP_GT #4 CMP(outCNT, 4'b1, GT);
    
    CNT_DOWN #4 CNT(clk, LOADCNT, ENCNT, rst, N, outCNT);
       
endmodule

module CNT_DOWN#(parameter WIDTH = 4)(
    input clk, load, en, rst,
    input [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q);
    
    always@(posedge clk, posedge rst)
        if(rst) Q <= 0;
        else if(load && !en) Q <= D;
        else if(en) Q <= Q-1;
        else Q <= Q;
    
endmodule

module MUX_2#(parameter WIDTH = 32)(
    input sel,
    input [WIDTH-1:0] A, B,
    output [WIDTH-1:0] OUT);
    
    assign OUT = sel ? A : B;
    
endmodule

module REG_D#(parameter WIDTH = 32)(
    input clk, rst, en,
    input [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q);
    
    always@(posedge clk, posedge rst)
        if(rst) Q <= 0;
        else if (en) Q <= D;
        else Q <= Q;
    
endmodule

module MUL#(parameter WIDTH = 24)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output [(WIDTH*2)-1:0] PRODUCT);
    
    assign PRODUCT = A*B;
    
endmodule

module CMP_GT#(parameter WIDTH = 4)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output GT);
    
    assign GT = (A>B) ? 1'b1 : 1'b0;
    
endmodule


module fact_CU(
    input GO, GT, 
    input [3:0] N,
    input clk, rst,
    output reg LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT,
    output reg DONE,
    output ERROR);
    
    reg [1:0] CS, NS;
    reg [5:0] ctrl;
    
    parameter
        S0 = 2'b00, S1 = 2'b01, S2 = 2'b10,
        S00 = 6'b000000,
        S01 = 6'b100100,
        S10 = 6'b001000,
        S11 = 6'b011100,
        S20  = 6'b000011;
    
    assign ERROR = N > 4'b1100 ? 1:0;
     
    always@(ctrl) {LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, DONE} = ctrl;
    
    always@(CS, NS, GO, GT, ERROR) begin
        case(CS)
            S0: begin 
                    if(GO & !ERROR) begin ctrl = S01; NS = S1; end
                    else begin ctrl = S00; NS = S0; end
                end
            S1: begin
                    if(GT) begin ctrl = S11; NS = S1; end
                    else begin ctrl = S10; NS = S2; end
                end
            S2: begin
                    ctrl = S20; NS = S0;
                end
            default: begin ctrl = S00; NS = S0; end
        endcase
    end
    
    always@(posedge clk, posedge rst) begin
        if(rst) CS <= S0;
        else CS <= NS;
    end
    
endmodule

module fact_decoder(
        input we,
        input [1:0] address,
        output reg we1, we2, reg [1:0] RdSel
    );
    always@(*) begin
        case (address)
            2'b00:
                begin
                    if(we) begin
                        we1 = 1'b1;
                        we2 = 1'b0;
                        RdSel = 2'b00;
                    end
                    else begin
                        we1 = 1'b0;
                        we2 = 1'b0;
                        RdSel = 2'b00;
                    end
                end
            2'b01:
                begin
                    if(we) begin
                        we1 = 1'b0;
                        we2 = 1'b1;
                        RdSel = 2'b01;
                    end
                    else begin
                        we1 = 1'b0;
                        we2 = 1'b0;
                        RdSel = 2'b01;
                    end
                end
            2'b10:
                begin
                    we1 = 1'b0;
                    we2 = 1'b0;
                    RdSel = 2'b10;
                end
            default:
                begin
                    we1 = 1'b0;
                    we2 = 1'b0;
                    RdSel = 2'b11;
                end
        endcase
    end
endmodule


module Factorial(
    input GO, clk, rst,
    input [3:0] N,
    output [31:0] OUTPUT,
    output DONE, ERROR);
    
    wire GT, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT;
    
    fact_CU CONTROL_UNIT(GO, GT, N, clk, rst, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, DONE, ERROR);
    fact_DP DATAPATH(N, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, clk, rst, GT, OUTPUT);
    
endmodule
