module datapath
(input clk, rst, pc_src, jump, reg_dst, we_reg, alu_src, dm2reg, PCtoReg, 
       [6:0] alu_ctrl, 
       [4:0] ra3, 
       [31:0] instr, rd_dm, 
 output zero, [31:0] pc_current, alu_out, wd_dm, rd3);
    wire [4:0]  rf_wa, wa_final;
    wire [31:0] pc_plus4, pc_pre, pc_post, pc_next, sext_imm, ba, 
                bta, jta, alu_pa, alu_pb, wd_rf_1, wd_rf_2, wd_rf_final, Hi, Lo, Mult_out;
    wire [64:0] Mult_res;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    // --- PC Logic --- //
    dreg       pc_reg     (clk, rst, pc_next, pc_current);
    adder      pc_plus_4  (pc_current, 4, pc_plus4);
    adder      pc_plus_br (pc_plus4, ba, bta);
    mux2 #(32) pc_src_mux (pc_src, pc_plus4, bta, pc_pre);
    mux2 #(32) pc_jmp_mux (jump, pc_post, jta, pc_next);
    mux2 #(32) reg_to_pc  (.sel(alu_ctrl[3]), .a(pc_pre), .b(alu_pa), .y(pc_post)); //NEW for JR command
    mux2 #(32) pc_or_data_to_rf  (.sel(PCtoReg), .a(pc_plus4), .b(wd_rf_2), .y(wd_rf_final)); // NEW for MFHI, MFLO, JAL

    // --- RF Logic --- //
    mux2 #(5)  rf_wa_mux  (reg_dst, instr[20:16], instr[15:11], rf_wa);
    mux2 #(5)  rf_wa_final (.sel(PCtoReg), .a(31), .b(rf_wa), .y(wa_final));
    regfile    rf         (.clk(clk), .we(we_reg), .ra1(instr[25:21]), .ra2(instr[20:16]), 
                           .ra3(ra3), .wa(wa_final), .wd(wd_rf_final), 
                           .rd1(alu_pa), .rd2(wd_dm), .rd3(rd3));

    signext    se         (instr[15:0], sext_imm);
    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (alu_src, wd_dm, sext_imm, alu_pb);
    alu        alu        (alu_ctrl[6:4], alu_pa, alu_pb, zero, alu_out);
    mult       mult       (.a(alu_pa), .b(wd_dm), .y(Mult_res));                                    //
    dreg_en    HI         (.clk(clk), .we(alu_ctrl[1]), .rst(rst), .d(Mult_res[63:32]), .q(Hi));   // NEW FOR
    dreg_en    LO         (.clk(clk), .we(alu_ctrl[1]), .rst(rst), .d(Mult_res[31:0]), .q(Lo));    // MULT, MFLO, MFHI
    mux2 #(32) HiorLo_mux (.sel(alu_ctrl[2]), .a(Hi), .b(Lo), .y(Mult_out));                             //
    // --- MEM Logic --- //
    mux2 #(32) rf_wd_mux  (dm2reg, alu_out, rd_dm, wd_rf_1);
    mux2 #(32) rf_wd_mux2 (.sel(alu_ctrl[0]), .a(wd_rf_1), .b(Mult_out), .y(wd_rf_2)); // NEW for Mult functions
endmodule