`timescale 1ns / 1ps

module Factorial(
    input GO, clk, rst,
    input [3:0] N,
    output [31:0] OUTPUT,
    output DONE, ERROR);
    
    wire GT, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT;
    
    CU CONTROL_UNIT(GO, GT, N, clk, rst, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, DONE, ERROR);
    DP DATAPATH(N, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, clk, rst, GT, OUTPUT);
    
endmodule
