module riscv_pipelined_datapath(clk,rst,instruction,PC,dAddress
											,dWriteData,dReadData,MemRead,MemWrite,RO1,RO2);
									
input clk,rst;

input [31:0] instruction,dReadData;
output [31:0] PC,dAddress,dWriteData;
output MemRead,MemWrite;
wire IFID_WriteEn,PC_Write,CTRL_Flush,IF_Flush;


//EX Stage Wires
wire [31:0] ALUresult_EX,PCAddress;
reg [31:0] ALUop1_EX,ALUop2_EX;
wire Zero_EX,Branch_EX;
reg PCSrc_EX;
wire [31:0] rout1_EX,rout2_EX,immediate_EX,PCAddress_EX;
wire [3:0] ALUCtrl_EX;
wire [4:0] Rd_EX;
wire ALUSrc_EX,MemRead_EX,MemWrite_EX,MemtoReg_EX,RegWrite_EX;

//MEM Stage Wires
wire [31:0] WriteData_MEM,ALUresult_MEM,PCAddress_MEM;
wire MemRead_MEM,MemWrite_MEM,MemtoReg_MEM,RegWrite_MEM;
wire [4:0] Rd_MEM;
wire Branch_MEM,Zero_MEM,PCSrc_MEM;
//WB Stage Wires
wire [31:0] ALUresult_WB,dReadData_WB;
wire MemtoReg_WB,RegWrite_WB;
wire [31:0] RegDataIn;


//Forwarding CTRL
wire [1:0] ForwardA,ForwardB;

//Program Counter 
PCReg #(32'h00000000)pcc(clk,PC_Write,rst,PCSrc_EX,PCAddress,PC);

//Pipeline IM/ID
wire [31:0] instruction_ID;
wire MemRead_ID,MemWriteID;
wire Branch_ID,ALUSrc_ID,RegWrite_ID,MemtoReg_ID;
wire [3:0] ALUCtrl_ID;
wire [31:0] rout1_ID,rout2_ID,immediate_ID,PCAddress_ID; //Sign Extended Immediate
//Pipeline IF/ID

pipeline_reg #(32) IFID_Inst(instruction,instruction_ID,
									IFID_WriteEn & clk,rst | IF_Flush);
pipeline_reg #(32) IFID_PC(PC,PCAddress_ID,IFID_WriteEn & clk,rst | IF_Flush);


//Register File
registerfile_pipelined reg_file(instruction_ID[19:15],instruction_ID[24:20],
						instruction_ID[11:7],RegDataIn,RegWrite_WB,rout1_ID,rout2_ID,clk);

//Immediate Generation Unit
imm_gen my_gen(instruction_ID,immediate_ID);

control_logic control_block(instruction_ID,1'b1,Branch_ID,ALUSrc_ID,ALUCtrl_ID,
										RegWrite_ID,MemtoReg_ID,MemRead_ID,MemWrite_ID);


//Pipeline ID/EX
wire [2:0]func3_EX;
pipeline_reg #(32) IDEX_PC(PCAddress_ID,PCAddress_EX,clk,rst);
pipeline_reg #(32) IDEXimm(immediate_ID,immediate_EX,clk,rst);
pipeline_reg #(32) IDEXfunc3(instruction_ID[14:12],func3_EX,clk,rst);
pipeline_reg #(5) IDEX_CTRLEX({ALUSrc_ID,ALUCtrl_ID} & {5{CTRL_Flush}}										 ,{ALUSrc_EX,ALUCtrl_EX},clk,rst);
										 
pipeline_reg #(3) IDEX_CTRLMEM({Branch_ID,MemRead_ID,MemWrite_ID} & {3{CTRL_Flush}},
											{Branch_EX,MemRead_EX,MemWrite_EX},clk,rst);
pipeline_reg #(2) IDEX_CTRLWB({MemtoReg_ID,RegWrite_ID} & {2{CTRL_Flush}},
											{MemtoReg_EX,RegWrite_EX},clk,rst);
											
pipeline_reg #(5) IDEX_RD(instruction_ID[11:7],Rd_EX,clk,rst);
assign rout1_EX = rout1_ID;
assign rout2_EX = rout2_ID;

										
//ALUSrc - Selecting Op2 of ALU
//assign ALUop1_EX = rout1_EX;
//assign ALUop2_EX = ALUSrc_EX ? immediate_EX : rout2_EX;
always @ (*)
begin
	case(ForwardA)
		2'b00: ALUop1_EX = rout1_EX;
		2'b10: ALUop1_EX = ALUresult_MEM;
		2'b01: ALUop1_EX = ALUresult_WB;
	default : ALUop1_EX = rout1_EX;
	endcase
	if (ALUSrc_EX) 
		ALUop2_EX = immediate_EX;
	else 
	begin
			case(ForwardB)
				2'b00: ALUop2_EX = rout2_EX;
				2'b10: ALUop2_EX = ALUresult_MEM;
				2'b01: ALUop2_EX = ALUresult_WB;
			default : ALUop2_EX = rout2_EX;
			endcase
	end
	
end




//ALU Unit
ALU my_ALU(ALUop1_EX,ALUop2_EX,ALUCtrl_EX,ALUresult_EX,Zero_EX);
assign PCAddress = PCAddress_EX + immediate_EX;
//assign PCSrc_EX = Branch_EX & Zero_EX;
always @ (*)
begin
	if (Branch_EX)
	begin
		if (func3_EX == 3'b000 && Zero_EX == 1) PCSrc_EX = 1;
		else if (func3_EX == 3'b001 && Zero_EX == 0) PCSrc_EX = 1;
		else if (func3_EX == 3'b100 && ALUresult_EX == 32'd1) PCSrc_EX = 1;
		else if (func3_EX == 3'b101 && ALUresult_EX == 32'd0) PCSrc_EX = 1;
		else if (func3_EX == 3'b110 && ALUresult_EX == 32'd1) PCSrc_EX = 1;
		else if (func3_EX == 3'b111 && ALUresult_EX == 32'd0) PCSrc_EX = 1;
		else PCSrc_EX = 0;
	end
	else PCSrc_EX = 0;
end

//Pipeline EX/MEM
pipeline_reg #(32) EXMEM_ALUresult(ALUresult_EX,ALUresult_MEM,clk,rst);
pipeline_reg #(32) EXMEM_PC(PCAddress,PCAddress_MEM,clk,rst);
pipeline_reg #(32) EXMEM_WriteData(rout2_EX,WriteData_MEM,clk,rst);
pipeline_reg #(5) EXMEM_CTRLMEM({PCSrc_EX,Zero_EX,Branch_EX,MemRead_EX,MemWrite_EX},
											{PCSrc_MEM,Zero_MEM,Branch_MEM,MemRead_MEM,MemWrite_MEM},clk,rst);
pipeline_reg #(2) EXMEM_CTRLWB({MemtoReg_EX,RegWrite_EX},
											{MemtoReg_MEM,RegWrite_MEM},clk,rst);
pipeline_reg #(5) EXMEM_RD(Rd_EX,Rd_MEM,clk,rst);

assign MemRead = MemRead_MEM;
assign MemWrite = MemWrite_MEM;
assign dWriteData = WriteData_MEM;
assign dAddress = ALUresult_MEM;


//Pipeline MEM/WB
wire [4:0] Rd_WB;
pipeline_reg #(32) MEMWB_ALUresult(ALUresult_MEM,ALUresult_WB,clk,rst);
pipeline_reg #(32) MEMWB_DataMem(dReadData,dReadData_WB,clk,rst);
pipeline_reg #(2) MEMWB_CTRLWB({MemtoReg_MEM,RegWrite_MEM},
											{MemtoReg_WB,RegWrite_WB},clk,rst);
											
pipeline_reg #(5) MEMWB_RD(Rd_MEM,Rd_WB,clk,rst);										
											

assign RegDataIn = MemtoReg_WB ? dReadData_WB : ALUresult_WB;


// Hazard Detection 
hazard_detect staller(instruction_ID,MemRead_EX,Rd_EX,Branch_EX,
							IFID_WriteEn,PC_Write,CTRL_Flush,IF_Flush);

// Forwarding 
forwarding_unit fback(RegWrite_MEM,RegWrite_WB,rout1_EX,
								rout2_EX,Rd_MEM,Rd_WB,ForwardA,ForwardB);						
							
							
							
//TESTING
output [31:0]RO1,RO2;
assign RO2 = RegDataIn;

assign RO1 = instruction_ID;

endmodule 




module PCReg(clk,PCWrite,rst,PCSrc,branch_off,PCOut);
parameter INITIAL_PC = 32'h00400000;
input clk,PCSrc,rst,PCWrite;
input [31:0] branch_off;
output reg [31:0] PCOut;

initial PCOut = INITIAL_PC;
always @ (posedge clk)
begin
if (rst) PCOut <= INITIAL_PC;
else if (PCSrc) PCOut <= branch_off;
else if (!PCWrite) PCOut<=PCOut;
else PCOut <= PCOut + 4;
end
endmodule 


module pipeline_reg(dataIn,dataOut,clock,rst);
parameter n=32;
input [n-1:0] dataIn;
input clock,rst;
output reg [n-1:0] dataOut;
initial dataOut = 0;

always @ (posedge clock)
begin
	if (rst) dataOut<=0;
	else dataOut<=dataIn;
end

endmodule 

module registerfile_pipelined(Read1,Read2,WriteReg,WriteData,RegWrite,Data1,Data2,clock);
input [4:0]Read1,Read2,WriteReg;
input [31:0] WriteData;
input RegWrite,clock;
output reg [31:0] Data1,Data2;
reg[31:0] RF[31:0];

integer i;
initial
begin
 for (i=0;i<32;i=i+1)
	RF[i] = i;
end
  // synchronous write and read with "write first" mode
  always @(posedge clock)
  begin
    // Default read: read old values
    Data1 <= RF[Read1];
    Data2 <= RF[Read2];
    if (RegWrite && WriteReg!=0) begin
      RF[WriteReg] <= WriteData;
      // If reading same register we are writing, return new data
      if (Read1 == WriteReg)
        Data1 <= WriteData;
      if (Read2 == WriteReg)
        Data2 <= WriteData;
    end
  end
endmodule 
