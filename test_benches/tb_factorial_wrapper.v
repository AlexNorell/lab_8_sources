`timescale 1ns / 1ps
module tb_factorial_wrapper(
    );
    reg clk, reset, we;
    reg [1:0] address;
    reg [3:0] data_in;
    wire [31:0] data_out;
    integer error_count, tb_fact_in;
    
    
    factorial_wrapper
        DUT(
            .clk(clk), .reset(reset), .we(we), .address(address), .data_in(data_in), .data_out(data_out)
        );
    
    initial begin
        initialize;
        tick;
        while (tb_fact_in <= 10) begin
            data_in = tb_fact_in;
            load_start;
            address = 2'b10;
//            #5;
            while(!data_out[0]) tick; 
            tick;
            checkSolution;
            tb_fact_in = tb_fact_in + 1;
            tick;
        end
        //check for error
        printResults;
        $finish;    
    end
    
    task initialize; begin
        reset = 1; #5;
        reset = 0; #5;
        tb_fact_in  =   1;
        data_in     =   0;
        address     =   0;
        error_count =   0;
    end
    endtask
          
    task tick;
    begin
        #1 clk = 1; #1;
        clk = 0; #1;
    end
    endtask
    
    task load_start;
    begin
        address = 2'b00;//set n
        we = 1;
        tick;
        address = 2'b01;
        data_in = 4'b1;//assert go
        tick;
        data_in = tb_fact_in;//idk
        we=0;
    end
    endtask
    
    task checkSolution;
        integer count, fact_expected;
    begin
        address = 2'b11;
        count = 1;
        fact_expected = 1;
        while (count <= tb_fact_in) begin
            fact_expected = fact_expected * count;
            count = count + 1;
        end
        if (data_out != fact_expected)begin
            $display($time," ERROR: Incorrect factorial solution || Input: %d Expected: %d Actual: %d\n",tb_fact_in, fact_expected, data_out);
            error_count = error_count + 1;
        end
    end
    endtask
    
    task printResults;
    begin
        if(error_count != 0) $display("Test completed with %d errors", error_count);
        else $display("Test completed with NO errors");
    end
    endtask
endmodule
