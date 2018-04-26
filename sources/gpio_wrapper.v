`timescale 1ns / 1ps
module gpio_wrapper(
        input clk, reset, we,
        input [1:0]     address,
        input [31:0]    gpi1, gpi2, data_in,
        output [31:0]   data_out, gpo1_out, gpo2_out
    );
    
    wire we1, we2;
    wire [1:0] read_sel;
    wire [31:0] gpo1, gpo2;
    
    assign gpo1_out = gpo1;
    assign gpo2_out = gpo2;
   
    gpio_decoder
        gpio_decoder_inst(
            .we(we), .address(address), .we1(we1), .we2(we2), .read_sel(read_sel)
        );
    
    dreg_en #(.DATA_WIDTH(32))
        gpo1_reg_instance(
            .clk(clk), .we(we1), .rst(reset), .d(data_in), .q(gpo1)
        );
        
    dreg_en #(.DATA_WIDTH(32))
        gpo2_reg_instance(
            .clk(clk), .we(we2), .rst(reset), .d(data_in), .q(gpo2)
        );
        
    mux4 #(.DATA_WIDTH(32))
            output_mux_inst(
                .sel(read_sel), .a(gpi1), .b(gpi2), 
                .c(gpo1), .d(gpo2), .y(data_out)
            );
endmodule
