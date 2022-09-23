module testbenchl10();
reg clk,rst;
reg [31:0] Instruction,dReadData;
wire [31:0] PC,dAddress,dWriteData;
wire MemRead,MemWrite;
wire [31:0]RO1,WriteBackData;
riscv_pipelined_datapath rv32(clk,rst,Instruction,PC,dAddress,
									dWriteData,dReadData,MemRead,MemWrite,RO1,WriteBackData);

								
//-----------------------------INSTRUCTION MEMORY-----------------------------
reg [7:0] Inst_Mem [1023:0];
initial
begin
  $readmemh ("E:/mem2.dat", Inst_Mem);	
     //https://athena.ecs.csus.edu/~changw/class_docs/VerilogManual/memory.html
end
always@*
 begin 
 Instruction[7:0] = Inst_Mem[PC]; 
 Instruction[15:8] = Inst_Mem[PC+1]; 
 Instruction[23:16] = Inst_Mem[PC+2]; 
 Instruction[31:24] = Inst_Mem[PC+3]; 
 end
//----------------------------------------------------------------------------

//-----------------------------DATA MEMORY -----------------------------------
reg [7:0] Data_Mem [255:0];
always@*
begin
if (MemWrite)
begin
	Data_Mem[dAddress] = dWriteData[7:0];
	Data_Mem[dAddress+1] = dWriteData[15:8];
	Data_Mem[dAddress+2] = dWriteData[23:16];
	Data_Mem[dAddress+3] = dWriteData[31:24];
end
else if (MemRead)
begin
	dReadData[7:0] = Data_Mem[dAddress];
	dReadData[15:7] = Data_Mem[dAddress+1];
	dReadData[23:16] = Data_Mem[dAddress+2];
	dReadData[31:24] = Data_Mem[dAddress+3];
end
end

initial clk = 0;
always #10 clk = ~clk;
initial rst =1;
initial #15 rst =0;


endmodule 