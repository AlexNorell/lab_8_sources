module controlunit
(input zero, [5:0] opcode, funct, 
	output pc_src, jump, reg_dst, we_reg, alu_src, we_dm, dm2reg, PCtoReg, shift_en, shift_dir,
		   [6:0] alu_ctrl);
    wire [1:0] alu_op;
    assign pc_src = branch & zero;
    maindec md (opcode, branch, jump, reg_dst, we_reg, alu_src, we_dm, dm2reg, PCtoReg, alu_op);
    auxdec  ad (alu_op, funct, shift_en, shift_dir, alu_ctrl);
endmodule