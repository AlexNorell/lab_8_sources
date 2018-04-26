`timescale 1ns / 1ps
module factorial_wrapper(
        input clk, reset,we,
        input   [1:0]   address,
        input   [3:0]   data_in,
        output  [31:0]  data_out
    );
    
    wire we1, we2,go, go_pulse_in, go_pulse, fact_done, fact_err, done_out, err_out;
    wire [1:0] read_sel;
    wire [3:0] fact_n;
    wire [31:0] fact_result, result_out;
    
    assign go_pulse_in = data_in & we2;
    
    fact_decoder 
        decoder_instance
        (
            .we(we), .address(address), .we1(we1), .we2(we2), .RdSel(read_sel)
        );
        
    Factorial
        factorial_instance(
            .GO(go_pulse), .clk(clk), .rst(reset), .N(fact_n),
            .OUTPUT(fact_result), .DONE(fact_done), .ERROR(fact_err)
        );

    dreg #( .DATA_WIDTH(1))
        go_pulse_reg_inst(
            .clk(clk), .rst(reset), .d(go_pulse_in), .q(go_pulse)
        );

    dreg_en #(.DATA_WIDTH(1)) 
        go_reg_inst(
            .clk(clk), .we(we2), .rst(reset), .d(data_in[0]), .q(go)
        );

    dreg_en #(.DATA_WIDTH(4))
        fact_n_reg_inst(
            .clk(clk), .we(we1), .rst(reset), .d(data_in[3:0]), .q(fact_n)
        );

    dreg_en #(.DATA_WIDTH(32))
        result_reg_inst(
            .clk(clk), .we(fact_done), .rst(reset), .d(fact_result), .q(result_out)
        );


    rsreg
        done_reg_inst(
            .clk(clk), .set(fact_done), .rst(go_pulse_in), .q(done_out)
        );

    rsreg
        err_reg_inst(
            .clk(clk), .set(fact_err), .rst(go_pulse_in), .q(err_out)
        );


    mux4 #(.DATA_WIDTH(32))
        output_mux_inst(
            .sel(read_sel), .a({{28{1'b0}},fact_n}), 
            .b({{31{1'b0}},go}), .c({{30{1'b0}},err_out,done_out}),
            .d(result_out), .y(data_out)
        );

endmodule
