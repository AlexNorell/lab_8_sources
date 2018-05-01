module mux2 #(parameter wide = 8)
(input sel, [wide-1:0] a, b, output [wide-1:0] y);
    assign y = (sel) ? b : a;
endmodule

module mux4 #(parameter DATA_WIDTH = 32)
(input [1:0] sel, [DATA_WIDTH-1:0] a,b,c,d, output reg [DATA_WIDTH-1:0] y);
    always @ (*) begin
        case (sel) 
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            default: y = d;
        endcase
    end
endmodule

module adder
(input [31:0] a, b, output [31:0] y);
    assign y = a + b;
endmodule

module signext
(input [15:0] a, output [31:0] y);
    assign y = {{16{a[15]}}, a};
endmodule

module alu
(input [2:0] op, [31:0] a, b, output zero, reg [31:0] y);
    assign zero = (y == 0);
    always @ (op, a, b)
    begin
        case (op)
            3'b000: y = a & b;
            3'b001: y = a | b;
            3'b010: y = a + b;
            3'b110: y = a - b;
            3'b111: y = (a < b) ? 1 : 0;
        endcase
    end
endmodule

module mult // NEW INFERRED MULT
(input [31:0] a, b, output reg [63:0] y);
	always @ (a, b)
	begin
		y = a * b;
	end
endmodule

module dreg_en #(parameter DATA_WIDTH = 32) 
(input clk, we, rst, [DATA_WIDTH-1:0] d, output reg [DATA_WIDTH-1:0] q);
	always @ (posedge clk, posedge rst)
	begin
		if(rst) q <= 0;
		else if (we) q <= d;
		else q <= q;
	end
endmodule

module dreg #(parameter DATA_WIDTH = 32)
(input clk, rst, [DATA_WIDTH-1:0] d, output reg [DATA_WIDTH-1:0] q);
    always @ (posedge clk, posedge rst)
    begin
        if (rst) q <= 0;
        else     q <= d;
    end
endmodule

module rsreg
(input clk, set, rst, output reg q);
    always @ (posedge clk, posedge rst)
    begin
        if(rst) q <=0;
        else if(set) q <= 1;
        else q <= q;
    end
endmodule

module regfile
(input clk, we, [4:0] ra1, ra2, ra3, wa, [31:0] wd, output [31:0] rd1, rd2, rd3);
    reg [31:0] rf [0:31];
    integer n;
    initial begin
        for (n = 0; n < 32; n = n + 1) rf[n] = 32'h0;
    end
    always @ (posedge clk)
    begin
        if (we) rf[wa] <= wd;
    end
    assign rd1 = (ra1 == 0) ? 0 : rf[ra1];
    assign rd2 = (ra2 == 0) ? 0 : rf[ra2];
    assign rd3 = (ra3 == 0) ? 0 : rf[ra3];
endmodule

module shifter
(input  shift_en, shift_dir, 
        [4:0]  shamt,
        [31:0] rd1_pre,
 output [31:0] rd1_pst);

always @(*) 
begin
    if (shift_en && shift_dir) // if shift_dir = 1, shift left 
        begin
            case(shamt)
                5'b00000 : rd1_pst = rd1_pre;
                5'b00001 : rd1_pst = {rd1_pre, {1'b0}};
                5'b00010 : rd1_pst = {rd1_pre, {2'b0}};
                5'b00011 : rd1_pst = {rd1_pre, {3'b0}};
                5'b00100 : rd1_pst = {rd1_pre, {4'b0}};
                5'b00101 : rd1_pst = {rd1_pre, {5'b0}};
                5'b00110 : rd1_pst = {rd1_pre, {6'b0}};
                5'b00111 : rd1_pst = {rd1_pre, {7'b0}};
                5'b01000 : rd1_pst = {rd1_pre, {8'b0}};
                5'b01001 : rd1_pst = {rd1_pre, {9'b0}};
                5'b01010 : rd1_pst = {rd1_pre, {10'b0}};
                5'b01011 : rd1_pst = {rd1_pre, {11'b0}};
                5'b01100 : rd1_pst = {rd1_pre, {12'b0}};
                5'b01101 : rd1_pst = {rd1_pre, {13'b0}};
                5'b01110 : rd1_pst = {rd1_pre, {14'b0}};
                5'b01111 : rd1_pst = {rd1_pre, {15'b0}};
                5'b10000 : rd1_pst = {rd1_pre, {16'b0}};
                5'b10001 : rd1_pst = {rd1_pre, {17'b0}};
                5'b10010 : rd1_pst = {rd1_pre, {18'b0}};
                5'b10011 : rd1_pst = {rd1_pre, {19'b0}};
                5'b10100 : rd1_pst = {rd1_pre, {20'b0}};
                5'b10101 : rd1_pst = {rd1_pre, {21'b0}};
                5'b10110 : rd1_pst = {rd1_pre, {22'b0}};
                5'b10111 : rd1_pst = {rd1_pre, {23'b0}};
                5'b11000 : rd1_pst = {rd1_pre, {24'b0}};
                5'b11001 : rd1_pst = {rd1_pre, {25'b0}};
                5'b11010 : rd1_pst = {rd1_pre, {26'b0}};
                5'b11011 : rd1_pst = {rd1_pre, {27'b0}};
                5'b11100 : rd1_pst = {rd1_pre, {28'b0}};
                5'b11101 : rd1_pst = {rd1_pre, {29'b0}};
                5'b11110 : rd1_pst = {rd1_pre, {30'b0}};
                5'b11111 : rd1_pst = {rd1_pre, {31'b0}};
            endcase
        end
    else if (shift_en && !shift_dir) // if shift_dir = 0, shift right
        begin
            case(shamt)
                5'b00000 : rd1_pst = rd1_pre;
                5'b00001 : rd1_pst = {{1'b0}, rd1_pre[31:1]};
                5'b00010 : rd1_pst = {{2'b0}, rd1_pre[ 31:2]};
                5'b00011 : rd1_pst = {{3'b0}, rd1_pre[ 31:3]};
                5'b00100 : rd1_pst = {{4'b0}, rd1_pre[ 31:4]};
                5'b00101 : rd1_pst = {{5'b0}, rd1_pre[ 31:5]};
                5'b00110 : rd1_pst = {{6'b0}, rd1_pre[ 31:6]};
                5'b00111 : rd1_pst = {{7'b0}, rd1_pre[ 31:7]};
                5'b01000 : rd1_pst = {{8'b0}, rd1_pre[ 31:8]};
                5'b01001 : rd1_pst = {{9'b0}, rd1_pre[ 31:9]};
                5'b01010 : rd1_pst = {{10'b0}, rd1_pre[ 31:10]};
                5'b01011 : rd1_pst = {{11'b0}, rd1_pre[ 31:11]};
                5'b01100 : rd1_pst = {{12'b0}, rd1_pre[ 31:12]};
                5'b01101 : rd1_pst = {{13'b0}, rd1_pre[ 31:13]};
                5'b01110 : rd1_pst = {{14'b0}, rd1_pre[ 31:14]};
                5'b01111 : rd1_pst = {{15'b0}, rd1_pre[ 31:15]};
                5'b10000 : rd1_pst = {{16'b0}, rd1_pre[ 31:16]};
                5'b10001 : rd1_pst = {{17'b0}, rd1_pre[ 31:17]};
                5'b10010 : rd1_pst = {{18'b0}, rd1_pre[ 31:18]};
                5'b10011 : rd1_pst = {{19'b0}, rd1_pre[ 31:19]};
                5'b10100 : rd1_pst = {{20'b0}, rd1_pre[ 31:20]};
                5'b10101 : rd1_pst = {{21'b0}, rd1_pre[ 31:21]};
                5'b10110 : rd1_pst = {{22'b0}, rd1_pre[ 31:22]};
                5'b10111 : rd1_pst = {{23'b0}, rd1_pre[ 31:23]};
                5'b11000 : rd1_pst = {{24'b0}, rd1_pre[ 31:24]};
                5'b11001 : rd1_pst = {{25'b0}, rd1_pre[ 31:25]};
                5'b11010 : rd1_pst = {{26'b0}, rd1_pre[ 31:26]};
                5'b11011 : rd1_pst = {{27'b0}, rd1_pre[ 31:27]};
                5'b11100 : rd1_pst = {{28'b0}, rd1_pre[ 31:28]};
                5'b11101 : rd1_pst = {{29'b0}, rd1_pre[ 31:29]};
                5'b11110 : rd1_pst = {{30'b0}, rd1_pre[ 31:30]};
                5'b11111 : rd1_pst = {{31'b0}, rd1_pre[31]};
            endcase
        end
    else 
        begin
            rd1_pst = rd1_pre;   
        end
end
endmodule