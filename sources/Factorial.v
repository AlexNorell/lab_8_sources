`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2018 11:21:42 PM
// Design Name: 
// Module Name: Factorial
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


module Factorial(
    input GO, clk, rst,
    input [3:0] N,
    output [31:0] OUTPUT,
    output DONE, ERROR);
    
    wire GT, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT;
    
    CU CONTROL_UNIT(GO, GT, N, clk, rst, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, DONE, ERROR);
    DP DATAPATH(N, LOADCNT, ENCNT, MUXPROD, LOADPROD, MUXOUT, clk, rst, GT, OUTPUT);
    
endmodule
