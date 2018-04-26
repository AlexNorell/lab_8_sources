`timescale 1ns / 1ps
module main_address_decoder(
        input we,
        input [31:0] address,
        output reg we2, we1, wem,
        output reg [1:0] read_sel
    );
    
    always @ (*) begin
        case (address[31:8])
            24'd0:
                begin
                    if(we) begin
                        read_sel = 2'b00;
                        we1 = 0;
                        we2 = 0;
                        wem = 1;
                    end
                    else begin
                        read_sel = 2'b00;
                        we1 = 0;
                        we2 = 0;
                        wem = 0;
                    end
                end
            24'd8:
                begin
                    if(we) begin
                        read_sel = 2'b10;
                        we1 = 1;
                        we2 = 0;
                        wem = 0;
                    end
                    else begin
                        read_sel = 2'b10;
                        we1 = 0;
                        we2 = 0;
                        wem = 0;
                    end
                end
            default:
                begin
                    if(we) begin
                        read_sel = 2'b11;
                        we1 = 0;
                        we2 = 1;
                        wem = 0;
                    end
                    else begin
                        read_sel = 2'b11;
                        we1 = 0;
                        we2 = 0;
                        wem = 0;
                    end
                end
        endcase
    end
endmodule
