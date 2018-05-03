module tb_mips_top;
    reg         clk, rst;
    wire        we_dm;
    wire [31:0] pc_current, instr, alu_out, wd_dm, rd_dm;
    
    mips_top DUT (clk, rst, gpi1, gpi2, we_dm, pc_current, instr, alu_out, wd_dm, rd_dm, gpo1, gpo2);
    
    task tick; begin #5 clk = 1; #5 clk = 0; end endtask
    task rest; begin #5 rst = 1; #5 rst = 0; end endtask
    
    initial begin
        rest;
        while(pc_current != 32'h20) tick;
        $finish;
    end
endmodule