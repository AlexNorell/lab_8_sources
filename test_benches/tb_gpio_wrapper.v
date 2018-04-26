`timescale 1ns / 1ps
module tb_gpio_wrapper(
    );
    reg clk, reset, we;
    reg [1:0]   address;
    reg [31:0]  gpi1, gpi2, data_in;
    wire [31:0] data_out, gpo1_out, gpo2_out;
    integer error_count, data_input;
    
    gpio_wrapper
        DUT(
            .clk(clk), .reset(reset), .we(we),
            .address(address), .gpi1(gpi1),
            .gpi2(gpi2), .data_in(data_in),
            .data_out(data_out), .gpo1_out(gpo1_out),
            .gpo2_out(gpo2_out)
        );
        
    initial begin
        initialize;
        gpi1 = 32'h8a1b5ef7;
        gpi2 = 32'h24fba254;
        data_in = 32'haef48fc9;
        
        check_output(2'b00, gpi1, data_out, address, error_count);
        check_output(2'b01, gpi2, data_out, address, error_count);
        address = 2'b10;
        we = 1'b1;
        tick;
        address = 2'b11;
        tick;
        we = 1'b0;
        
        check_output(2'b10, data_in, data_out, address, error_count);
        check_output(2'b11, data_in, data_out, address, error_count);
        
        address = 2'b11;
        tick;
        
               
        //write data
        //check data
        
        printResults;
    end
    
    task initialize; begin
        data_input  =   1;
        data_in     =   0;
        address     =   0;
        error_count =   0;
    end
    endtask
    
    task tick;
    begin
        clk = 1; #1;
        clk = 0; #1;
    end
    endtask
    
    task printResults;
    begin
        if(error_count != 0) $display("Test completed with %d errors", error_count);
        else $display("Test completed with NO errors");
    end
    endtask
    
    task check_output;
        input check_address;
        input expected_value;
        input output_value;
        output address;
        output error_count;
    begin
        address = check_address;
        tick;
        if (output_value != expected_value) begin
            error_count = error_count+1;
            $display($time,"  Error incorrect output, Expected: %d, Actual: %d", expected_value, output_value);
        end
    end
    endtask
endmodule