module maindec
(   input [5:0] opcode, 
    output branch, jump, reg_dst, we_reg, alu_src, we_dm, dm2reg, PCtoReg, [1:0]alu_op);
    reg [9:0] ctrl;
    assign {branch, jump, reg_dst, we_reg, alu_src, we_dm, dm2reg, alu_op, PCtoReg} = ctrl;
    always @ (opcode)
    begin
        case (opcode)           //branch jump reg_dst we_reg alu_src we_dm dm2reg alu_op PCtoReg
            6'b00_0000: ctrl = 10'b__0_____0_____1_______1______0______0______0_____10______1___; // R-type
            6'b00_1000: ctrl = 10'b__0_____0_____0_______1______1______0______0_____00______1___; // ADDI
            6'b00_0100: ctrl = 10'b__1_____0_____0_______0______0______0______0_____01______1___; // BEQ
            6'b00_0010: ctrl = 10'b__0_____1_____0_______0______0______0______0_____00______1___; // J
            6'b00_0011: ctrl = 10'b__0_____1_____0_______1______0______0______0_____00______0___; // JAL
            6'b10_1011: ctrl = 10'b__0_____0_____0_______0______1______1______0_____00______1___; // SW
            6'b10_0011: ctrl = 10'b__0_____0_____0_______1______1______0______1_____00______1___; // LW

            default:    ctrl = 10'b__x_____x_____x_______x______x______x______x_____xx______x___;
        endcase
    end
endmodule

module auxdec
(input [1:0] alu_op, [5:0] funct, output [6:0] alu_ctrl);
    reg [6:0] ctrl;
    assign {alu_ctrl} = ctrl;
    always @ (alu_op, funct)
    begin
        case (alu_op)      //                RegtoPC HiOrLo MultRegwrite MemtoReg2
            2'b00: ctrl = 7'b___0____1____0_____0_______0_________0__________0; // ADD
            2'b01: ctrl = 7'b___1____1____0_____0_______0_________0__________0; // SUB

            default: case (funct)   //                RegtoPC HiOrLo MultRegwrite MemtoReg2
                6'b10_0100: ctrl = 7'b___0____0____0_____0_______0_________0__________0; // AND
                6'b10_0101: ctrl = 7'b___0____0____1_____0_______0_________0__________0; // OR
                6'b10_0000: ctrl = 7'b___0____1____0_____0_______0_________0__________0; // ADD
                6'b10_0010: ctrl = 7'b___1____1____0_____0_______0_________0__________0; // SUB
                6'b10_1010: ctrl = 7'b___1____1____1_____0_______0_________0__________0; // SLT
                6'b00_1000: ctrl = 7'b___1____1____1_____1_______0_________0__________0; // JR
                6'b01_1001: ctrl = 7'b___1____1____1_____0_______0_________1__________0; // MULTU
                6'b01_0010: ctrl = 7'b___1____1____1_____0_______1_________0__________1; // MFLO
                6'b01_0000: ctrl = 7'b___1____1____1_____0_______0_________0__________1; // MFHI
                default:    ctrl = 7'b___x____x____x_____0_______0_________0__________0;
            endcase
        endcase
    end
endmodule