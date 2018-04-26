`timescale 1ns / 1ps

module gpio_decoder(
    input we,
    input [3:2] address,
    output reg we1, we2,
    output reg [1:0] read_sel
    );
    always @(*) begin
        case (address)
            2'b00:
                begin
                    we1 = 1'b0;
                    we2 = 1'b0;
                    read_sel = 2'b00;
                end
            2'b01:
                begin
                    we1 = 1'b0;
                    we2 = 1'b0;
                    read_sel = 2'b01;
                end
            2'b10:
                begin
                    if (we)begin
                        we1 = 1'b0;
                        we2 = 1'b0;
                        read_sel = 2'b10;
                    end
                    else begin
                        we1 = 1'b0;
                        we2 = 1'b0;
                        read_sel = 2'b10;
                    end
                end
            default:
                begin
                    if (we)begin
                        we1 = 1'b0;
                        we2 = 1'b1;
                        read_sel = 2'b11;
                    end
                    else begin
                        we1 = 1'b0;
                        we2 = 1'b0;
                        read_sel = 2'b11;
                    end
                end
        endcase
    end
endmodule
