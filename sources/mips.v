module mips
(input clk, rst, [4:0] ra3, [31:0] instr, rd_dm, 
 output we_dmM, [31:0] pc_current, alu_out, wd_dm, rd3);
    wire       pc_src, jump, reg_dst, we_reg, alu_src, dm2reg, PCtoReg, shift_en, shift_dir;
    wire [6:0] alu_ctrl;
    wire [31:0] instrD;
    datapath    dp (clk, rst, pc_src, jump, reg_dst, we_reg, alu_src, 
    				dm2reg, PCtoReg, shift_en, shift_dir, we_dm, alu_ctrl, ra3, instr, rd_dm, zero, we_dmM, 
    				pc_current, alu_out, wd_dm, rd3, instrD);
    controlunit cu (zero, instrD[31:26], instrD[5:0], pc_src, jump, reg_dst, 
    				we_reg, alu_src, we_dm, dm2reg, PCtoReg, shift_en, shift_dir, alu_ctrl);
endmodule