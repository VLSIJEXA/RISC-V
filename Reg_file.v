`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2025 09:43:23 AM
// Design Name: 
// Module Name: Reg_File
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


module Reg_File(clk,reset,RegWrite,Rs1,Rs2,Rd,Write_data,read_data1,read_data2);
input clk,reset,RegWrite;
input[4:0]Rs1,Rs2,Rd;
input[31:0]Write_data;
output [31:0] read_data1,read_data2;
integer k;
reg [31:0] Registers[31:0];
initial begin
Registers[0]=0;
Registers[1]=4;
Registers[2]=2;
Registers[3]=24;
Registers[4]=4;
Registers[5]=1;
Registers[6]=44;
Registers[7]=4;
Registers[8]=2;
Registers[9]=1;
Registers[10]=23;
Registers[11]=4;
Registers[12]=90;
Registers[13]=10;
Registers[14]=20;
Registers[15]=30;
Registers[16]=40;
Registers[17]=50;
Registers[18]=60;
Registers[19]=70;
Registers[20]=80;
Registers[21]=80;
Registers[22]=90;
Registers[23]=70;
Registers[24]=60;
Registers[25]=65;
Registers[26]=4;
Registers[27]=32;
Registers[28]=12;
Registers[29]=34;
Registers[30]=5;
Registers[31]=10;
end

always@(posedge clk or posedge reset)
begin
if(reset) 
begin 
for(k=0;k<32;k=k+1)begin
Registers[k]<=32'b00;
end
end 
else if(RegWrite)begin
Registers[Rd]<=Write_data;
end

end
assign read_data1=Registers[Rs1];
assign read_data2=Registers[Rs2];


endmodule
