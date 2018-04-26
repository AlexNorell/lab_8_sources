`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2017 01:00:17 PM
// Design Name: 
// Module Name: CU
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


module CU(
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
