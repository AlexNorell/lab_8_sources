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
        
        address = 2'b00;
        tick;
        if (data_out != gpi1) begin
            error_count = error_count+1;
            $display($time,"  Error incorrect output, Expected: %h, Actual: %h",  gpi1, data_out);
        end
        address = 2'b01;
        tick;
        if (data_out != gpi2) begin
            error_count = error_count+1;
            $display($time,"  Error incorrect output, Expected: %h, Actual: %h",  gpi2, data_out);
        end
        we = 1'b1;
        address = 2'b10;
        tick;
        address = 2'b11;
        tick;
        we = 1'b0;
        
        address = 2'b10;
        tick;
        if (data_out != data_in) begin
            error_count = error_count+1;
            $display($time,"  Error incorrect output, Expected: %h, Actual: %h",  data_in, data_out);
        end
        
        address = 2'b11;
        tick;
        if (data_out != data_in) begin
            error_count = error_count+1;
            $display($time,"  Error incorrect output, Expected: %h, Actual: %h", data_in, data_out);
        end
        
        address = 2'b11;
        tick;
        
        printResults;
        $finish;
    end
    
    task initialize; begin
        data_input  =   1;
        data_in     =   0;
        address     =   0;
        error_count =   0;
        we = 0;
        reset = 1; tick;
        reset = 0; tick;
    end
    endtask
    
    task tick;
    begin
        #1;clk = 1'b1; #1;
        #1;clk = 1'b0; #1;
    end
    endtask
    
    task printResults;
    begin
        if(error_count != 0) $display("Test completed with %d errors", error_count);
        else $display("Test completed with NO errors");
    end
    endtask
    

endmodule