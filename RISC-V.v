`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 08:56:23 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input clk,
    input reset
);
    wire [31:0] PC_top, instruction_top, Rd1_top, Rd2_top, ImmExt_top, mux1_top;
    wire [31:0] Sum_out_top, NextoPC_top, PCin_top, address_top, Memdata_top, WriteBack_top;
    wire RegWrite_top, ALUSrc_top, zero_top, branch_top, sel2_top, MemtoReg_top, MemWrite_top, MemRead_top;
    wire [1:0] ALUOp_top;
    wire [3:0] control_top;

    Program_Counter PC (
        .clk(clk),
        .reset(reset),
        .PC_in(PCin_top),
        .PC_out(PC_top)
    );

    PCplus4 PC_Adder (
        .fromPC(PC_top),
        .NextoPC(NextoPC_top)
    );

    Instruction_Mem Inst_Memory (
        .clk(clk),
        .reset(reset),
        .read_address(PC_top),
        .instruction_out(instruction_top)
    );

    Reg_File Reg_File (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite_top),
        .Rs1(instruction_top[19:15]),
        .Rs2(instruction_top[24:20]),
        .Rd(instruction_top[11:7]),
        .Write_data(WriteBack_top),
        .read_data1(Rd1_top),
        .read_data2(Rd2_top)
    );

    ImmGen ImmGen (
        .Opcode(instruction_top[6:0]),
        .instruction(instruction_top),
        .ImmExt(ImmExt_top)
    );

    Control_Unit Control_Unit (
        .instruction(instruction_top[6:0]),
        .Branch(branch_top),
        .MemRead(MemRead_top),
        .MemtoReg(MemtoReg_top),
        .ALUOp(ALUOp_top),
        .MemWrite(MemWrite_top),
        .ALUSrc(ALUSrc_top),
        .RegWrite(RegWrite_top)
    );

    ALU_Control ALU_Control (
        .ALUOp(ALUOp_top),
        .fun7(instruction_top[30]),
        .fun3(instruction_top[14:12]),
        .Control_out(control_top)
    );

    Mux ALU_Mux (
        .sel(ALUSrc_top),
        .A(Rd2_top),
        .B(ImmExt_top),
        .Mux_out(mux1_top)
    );

    ALU ALU (
        .A(Rd1_top),
        .B(mux1_top),
        .Control_in(control_top),
        .ALU_Result(address_top),
        .zero(zero_top)
    );

    Adder Branch_Adder (
        .in_1(PC_top),
        .in_2(ImmExt_top),
        .Sum_out(Sum_out_top)
    );

    AND_Gate AND (
        .branch(branch_top),
        .zero(zero_top),
        .and_out(sel2_top)
    );

    Mux PC_Mux (
        .sel(sel2_top),
        .A(NextoPC_top),
        .B(Sum_out_top),
        .Mux_out(PCin_top)
    );

    Data_Memory Data_mem (
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite_top),
        .MemRead(MemRead_top),
        .address(address_top),
        .Write_data(Rd2_top),
        .Read_data(Memdata_top)
    );

    Mux WB_Mux (
        .sel(MemtoReg_top),
        .A(address_top),
        .B(Memdata_top),
        .Mux_out(WriteBack_top)
    );
endmodule

// Rest of the modules remain the same as in the previous corrected version
module Program_Counter (
    input clk,
    input reset,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule

module PCplus4 (
    input [31:0] fromPC,
    output [31:0] NextoPC
);
    assign NextoPC = fromPC + 32'd4;
endmodule

module Instruction_Mem (
    input clk,
    input reset,
    input [31:0] read_address,
    output reg [31:0] instruction_out
);
    reg [31:0] IMemory[0:63];
    integer i;

    // Initialize instruction memory (combinational)
    always @(*) begin
        instruction_out = IMemory[read_address[31:2]];
    end

    // Memory initialization (sequential)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear memory
            for (i = 0; i < 64; i = i + 1)
                IMemory[i] <= 32'b0;

            // Initialize instructions
            // R-type
            IMemory[0] <= 32'b0000000_11001_10000_000_01101_0110011; // add x13, x16, x25
            IMemory[1] <= 32'b0100000_00011_01000_000_00101_0110011; // sub x5, x8, x3
            IMemory[2] <= 32'b0000000_11001_00010_111_00001_0110011; // and x1, x2, x25
            IMemory[3] <= 32'b0000000_10101_00011_110_00100_0110011; // or x4, x3, x21

            // I-type
            IMemory[4] <= 32'b000000000011_10101_000_10110_0010011;  // addi x22, x21, 3
            IMemory[5] <= 32'b000000000001_01000_110_01001_0010011;  // ori x9, x8, 1

            // Load
            IMemory[6] <= 32'b000000001111_11001_010_01000_0000011;  // lw x8, 15(x25)
            IMemory[7] <= 32'b000000000011_00011_010_01001_0000011;  // lw x9, 3(x3)

            // Store
            IMemory[8] <= 32'b0000000_01111_00101_010_01100_0100011; // sw x15, 12(x5)
            IMemory[9] <= 32'b0000000_01110_00110_010_01010_0100011; // sw x14, 10(x6)

            // Branch
            IMemory[10] <= 32'b0000000_01001_01001_000_1100_1100011; // beq x9, x9, 12
        end
    end
endmodule
module Reg_File (
    input clk,
    input reset,
    input RegWrite,
    input [4:0] Rs1, Rs2, Rd,
    input [31:0] Write_data,
    output reg [31:0] read_data1, read_data2
);
    reg [31:0] Registers[31:0];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                Registers[i] <= 32'b0;
                
            // Initialize some registers with non-zero values
            Registers[1] <= 32'd4;
            Registers[2] <= 32'd2;
            Registers[3] <= 32'd24;
            Registers[4] <= 32'd4;
            Registers[5] <= 32'd1;
            Registers[6] <= 32'd44;
            Registers[7] <= 32'd4;
            Registers[8] <= 32'd2;
            Registers[9] <= 32'd1;
            Registers[10] <= 32'd23;
            Registers[16] <= 32'd40;
            Registers[21] <= 32'd80;
            Registers[25] <= 32'd65;
        end
        else if (RegWrite && Rd != 0) begin
            Registers[Rd] <= Write_data;
        end
    end

    always @(*) begin
        read_data1 = Registers[Rs1];
        read_data2 = Registers[Rs2];
    end
endmodule

module ImmGen (
    input [6:0] Opcode,
    input [31:0] instruction,
    output reg [31:0] ImmExt
);
    always @(*) begin
        case (Opcode)
            7'b0000011: // I-type (load)
                ImmExt = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S-type (store)
                ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type (branch)
                ImmExt = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default: 
                ImmExt = {{20{instruction[31]}}, instruction[31:20]}; // Default to I-type
        endcase
    end
endmodule

module Control_Unit (
    input [6:0] instruction,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);
    always @(*) begin
        case (instruction)
            7'b0110011: begin // R-type
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                ALUOp = 2'b10;
            end
            7'b0000011: begin // I-type (load)
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Branch = 0;
                ALUOp = 2'b00;
            end
            7'b0100011: begin // S-type (store)
                ALUSrc = 1;
                MemtoReg = 1'bx; // Don't care
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                Branch = 0;
                ALUOp = 2'b00;
            end
            7'b1100011: begin // B-type (branch)
                ALUSrc = 0;
                MemtoReg = 1'bx; // Don't care
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                ALUOp = 2'b01;
            end
            default: begin // Default case
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule

module ALU_Control (
    input [1:0] ALUOp,
    input fun7,
    input [2:0] fun3,
    output reg [3:0] Control_out
);
    always @(*) begin
        casex ({ALUOp, fun7, fun3})
            6'b00_?_000: Control_out = 4'b0010; // add (for loads/stores)
            6'b01_?_000: Control_out = 4'b0110; // subtract (for branches)
            6'b10_0_000: Control_out = 4'b0010; // add
            6'b10_1_000: Control_out = 4'b0110; // subtract
            6'b10_?_111: Control_out = 4'b0000; // and
            6'b10_?_110: Control_out = 4'b0001; // or
            6'b10_?_010: Control_out = 4'b0111; // slt
            default: Control_out = 4'b0000;
        endcase
    end
endmodule

module ALU (
    input [31:0] A, B,
    input [3:0] Control_in,
    output reg zero,
    output reg [31:0] ALU_Result
);
    always @(*) begin
        case (Control_in)
            4'b0000: ALU_Result = A & B;    // AND
            4'b0001: ALU_Result = A | B;    // OR
            4'b0010: ALU_Result = A + B;    // ADD
            4'b0110: ALU_Result = A - B;    // SUBTRACT
            4'b0111: ALU_Result = (A < B) ? 1 : 0; // SLT
            default: ALU_Result = 32'b0;
        endcase
        zero = (ALU_Result == 0);
    end
endmodule

module Mux (
    input sel,
    input [31:0] A, B,
    output reg [31:0] Mux_out
);
    always @(*) begin
        Mux_out = sel ? B : A;
    end
endmodule

module Adder (
    input [31:0] in_1, in_2,
    output [31:0] Sum_out
);
    assign Sum_out = in_1 + in_2;
endmodule

module AND_Gate (
    input branch, zero,
    output and_out
);
    assign and_out = branch & zero;
endmodule

module Data_Memory (
    input clk,
    input reset,
    input MemWrite,
    input MemRead,
    input [31:0] address,
    input [31:0] Write_data,
    output reg [31:0] Read_data
);
    reg [31:0] D_Memory[0:63];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1)
                D_Memory[i] <= 32'b0;
        end
        else if (MemWrite) begin
            D_Memory[address[31:2]] <= Write_data;
        end
    end

    always @(*) begin
        if (MemRead)
            Read_data = D_Memory[address[31:2]];
        else
            Read_data = 32'b0;
    end
endmodule
