module datapath
(input clk, rst, pc_src, jump, reg_dst, we_reg, alu_src, dm2reg, PCtoReg, shift_en, shift_dir,
       [6:0] alu_ctrl, 
       [4:0] ra3, 
       [31:0] instr, rd_dm, 
 output zero, [31:0] pc_current, alu_out, wd_dmM, rd3);
    wire zer0Unused;
    wire [4:0]  rf_wa, wa_final;
    wire [31:0] pc_plus4, pc_pre, pc_post, pc_next, sext_imm, ba, wd_dm,
                bta, jta, alu_pa, alu_pb, wd_rf_1, wd_rf_2, wd_rf_final, Hi, Lo, Mult_out;
    wire [63:0] Mult_res;
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

    // Assume imem gets fed in here
    // ---- Decode Register ---- //
    wire [31:0] instrD, pc_plus4D;
    dreg #(64) Dreg (clk, rst, {instr, pc_plus4}, {instrD, pc_plus4D});

    // --- RF Logic --- //
    mux2 #(5)  rf_wa_mux  (reg_dst, instrD[20:16], instrD[15:11], rf_wa);
    mux2 #(5)  rf_wa_final (.sel(PCtoReg), .a(31), .b(rf_wa), .y(wa_final));
    regfile    rf         (.clk(clk), .we(we_reg), .ra1(instrD[25:21]), .ra2(instrD[20:16]), 
                           .ra3(ra3), .wa(wa_final), .wd(wd_rf_final), 
                           .rd1(alu_pa), .rd2(wd_dm), .rd3(rd3));
                           
    assign zero = (alu_pa == wd_dm)? 1'b1:1'b0;
    
    signext    se         (instr[15:0], sext_imm);
    
    // ---- Execute Register ---- //
    wire [31:0] instrE, pc_plus4E, sext_immE, wd_dmE, alu_paE;
    dreg #(160) Ereg (clk, rst, {instrD, pc_plus4D, sext_imm, wd_dm, alu_pa}, {instrE, pc_plus4E, sext_immE, wd_dmE, alu_paE});
    
    
    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (alu_src, wd_dmE, sext_immE, alu_pb);
    shifter    shift_mod  (.shift_en(shift_en), .shift_dir(shift_dir), .shamt(instrE[10:6]), .rd1_pre(wd_dmE), .rd1_pst(wd_dmE));
    alu        alu        (alu_ctrl[6:4], alu_paE, alu_pb, zeroUnused, alu_out);
//    mult       mult       (.a(alu_pa), .b(wd_dm), .y(Mult_res)); 
    // The multiplier already contains an input register and a mid op register. The outputs should be stored in HI-LO
    pipelined_multiplier  (.clk(clk), .reset(rst), .en(1'b1), .mcand(alu_paE), .mplier(wd_dmE), .product(Mult_res));  
    
    
    // ---- Memory Register ---- //
    wire [31:0] alu_outM, wd_dmM; 
    dreg #(64) Mreg (clk, rst, {alu_out, wd_dmE}, {alu_outM, wd_dmM});


    // ---- Writeback Register ---- //
    wire [31:0] alu_outW, rd_dmW, HiW, LoW; 
    dreg #(128) Wreg (clk, rst, {alu_outM, rd_dm, Mult_res}, {alu_outW, rd_dmW, HiW, LoW});
    
//    dreg_en    HI         (.clk(clk), .we(alu_ctrl[1]), .rst(rst), .d(Mult_res[63:32]), .q(Hi));   // NEW FOR
//    dreg_en    LO         (.clk(clk), .we(alu_ctrl[1]), .rst(rst), .d(Mult_res[31:0]), .q(Lo));    // MULT, MFLO, MFHI
    mux2 #(32) HiorLo_mux (.sel(alu_ctrl[2]), .a(HiW), .b(LoW), .y(Mult_out));  
                               //
    // --- MEM Logic --- //
    mux2 #(32) rf_wd_mux  (dm2reg, alu_outW, rd_dmW, wd_rf_1);
    mux2 #(32) rf_wd_mux2 (.sel(alu_ctrl[0]), .a(wd_rf_1), .b(Mult_out), .y(wd_rf_2)); // NEW for Mult functions
endmodule