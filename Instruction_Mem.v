`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2025 09:31:22 AM
// Design Name: 
// Module Name: Instruction_Mem
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


module Instruction_Mem(clk,reset,read_address,instruction_out);
    input clk,reset;
    input [31:0] read_address;
    output [31:0] instruction_out;
    integer k;
    reg [31:0] IMemory[63:0];
    assign instruction_out=IMemory[read_address];
    always@(posedge clk or posedge reset)
    begin
    if(reset)
    begin
    for( k=0;k<64;k=k+1)
    begin
    IMemory[k]<=32'b00;
     end
    end
    
    else 
    
    //R-type
     IMemory[0]=32'b00000000000000000000000000000000;  // no opration
     IMemory[4]=32'b0000000_11001_10000_000_01101_0110011; //add x13,x16,x25
     IMemory[8]=32'b0100000_00011_01000_000_00101_0110011;//sub x5,x8,x3
     IMemory[12]=32'b0000000_11001_00010_111_00001_0110011; //and x1,x2,x3
     IMemory[16]=32'b0000000_10101_00011_110_00100_0110011; //or x4,x3,x5
  //I-type      
         IMemory[20]=32'b000000000011_10101_000_10110_0010011; //addi,x22,x21,3
          IMemory[24]=32'b00000000001_01000_110_01001_0010011; //ori x9,x8,1
   //L-type       
           IMemory[28]= 32'b000000001111_11001_010_01000_0110011; //lw x8,15(x5)
            IMemory[32]=32'b000000000011_00011_010_01001_0000011; //lw x9,3(x3)
     //S-type       
             IMemory[36]=32'b0000000_01111_00101_010_01100_0100011; //sw x15,12(x5)
              IMemory[40]=32'b0000000_01110_00110_010_01010_0100011; //sw x14,10(x6)
      //SB-type        
               IMemory[44]=32'h00948663;  //beq x9 x9,12
     
    end
     
endmodule
