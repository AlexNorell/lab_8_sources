`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2017 01:00:17 PM
// Design Name: 
// Module Name: DP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DP(
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



