`timescale 1ns / 1ps
module interface_wrapper(
        input we, clk, reset,
        input [31:0] address, data_in,
        output [31:0] data_out
    );
    wire wem, we1, we2;
    wire [1:0] read_sel;
    wire [31:0] Dmem_out, fact_out, gpio_out;
    
    mux4 #(32)
        data_out_mux(
            .sel(read_sel), .a(Dmem_out), .b(Dmem_out), .c(fact_out), .d(gpio_out), .y(data_out) 
        );
    
    main_address_decoder
        main_decoder_inst(
          .we(we), .address(address), .we2(we2), .we1(we1), .wem(wem), .read_sel(read_sel)
        );

    factorial_wrapper
        factorial_inst(
        .clk(clk), .reset(reset), .we(wem), .address(address[7:2]), .data_in(data_in[3:0]), .data_out(fact_out)
    );

    gpio_wrapper
        gpio_inst(
            .clk(clk), .reset(reset), .we(we2), .address(address[3:2]), .gpi1(), .gpi2(), .data_in(data_in),
            .data_out(gpio_out), .gpo1_out(), .gpo2_out()
        );

    dmem
        dmem_inst(
            .clk(clk), .we(wem), .a(address[7:2]), .d(data_in), .q(Dmem_out)
        );

endmodule
