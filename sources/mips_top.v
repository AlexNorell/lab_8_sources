module mips_top
(input clk, rst, [31:0] gpi1, gpi2, output we_dm, [31:0] pc_current, instr, alu_out, wd_dm, rd_dm, gpo1, gpo2);
    wire [31:0] DONT_USE;
    mips mips (clk, rst, 5'b0, instr, rd_dm, we_dm, pc_current, alu_out, wd_dm, DONT_USE);
    imem imem (pc_current[9:2], instr);
    //dmem dmem (clk, we_dm, alu_out[7:2], wd_dm, rd_dm);
    
    interface_wrapper mem_interface(
            .we(we_dm), .clk(clk), .reset(rst), .address(alu_out), .data_in(wd_dm),
             .gpi1(gpi1), .gpi2(gpi2), .data_out(rd_dm), .gpo1(gpo1), .gpo2(gpo2)
        );
endmodule