`timescale 1ns / 1ps
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
