module control_logic(instruction,Zero,PCSrc,ALUSrc,ALUCtrl,RegWrite,MemtoReg,MemRead,MemWrite);
input [31:0]instruction;
input Zero;
//PCSrc is used for Controlling Branch. It needs to be processed with other control
//signals from ALU
output reg PCSrc,ALUSrc,RegWrite,MemtoReg,MemRead,MemWrite;
output reg [3:0] ALUCtrl;

always @ (*)
begin
	//R-Type
	if (instruction [6:0] == 7'b0110011)
	begin
	PCSrc = 0;
	ALUSrc = 0;
	RegWrite = 1;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
		case(instruction[14:12])
		3'b000 :	
		begin
			if(instruction[31:25] == 0) ALUCtrl = 4'b0010;
			else 	ALUCtrl = 4'b0110;
		end
		3'b010 : ALUCtrl = 4'b0111; 
		3'b100 : ALUCtrl = 4'b1100;
		3'b110 : ALUCtrl = 4'b0001;
		3'b111 : ALUCtrl = 4'b0000;
		3'b001 : ALUCtrl = 4'b1101;
		3'b101 :
		if(instruction[31:25] == 6'b000000) ALUCtrl = 4'b1001;
			else ALUCtrl = 4'b1011;
		default : ALUCtrl = 4'b0000;
		endcase
	end
	
	
	//I-Type and Load
	else if (instruction [6:0] == 7'b0010011 || instruction [6:0] == 7'b0000011)
	begin
	PCSrc = 0;
	ALUSrc = 1;
	RegWrite = 1;
	MemtoReg =  (instruction [6:0] == 7'b0000011) ? 1 :0;
	MemRead = (instruction [6:0] == 7'b0000011) ? 1 :0;
	MemWrite = 0;
	if(instruction [6:0] == 7'b0000011)
		ALUCtrl = 4'b0010;
	else
		begin
			case(instruction[14:12])
			3'b000 :	ALUCtrl = 4'b0010;
			3'b010 : ALUCtrl = 4'b0111;
			3'b100 : ALUCtrl = 4'b1100;
			3'b110 : ALUCtrl = 4'b0001;
			3'b111 : ALUCtrl = 4'b0000;
			3'b001 : ALUCtrl = 4'b1101;
			3'b011 : ALUCtrl = 4'b1111;
			3'b101 : 
			if(instruction[31:25] == 6'b000000) ALUCtrl = 4'b1001;
			else ALUCtrl = 4'b1011;
			
			default : ALUCtrl = 4'b0000;
			endcase
		end
	end
	// (S-Type) Store
	else 	if (instruction [6:0] == 7'b0100011)
	begin
	PCSrc = 0;
	ALUSrc = 1;
	RegWrite = 0;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=1;
	ALUCtrl = 4'b0010;
	end
	
	// (SB-Type)Condition Branch
	else 	if (instruction [6:0] == 7'b1100011)
 
	begin
	PCSrc = 1;
	ALUSrc = 0;
	RegWrite = 0;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
	case (instruction [14:12])
	3'b000: ALUCtrl = 4'b0110; //beq
	3'b001: ALUCtrl = 4'b0110; //bne
	3'b100: ALUCtrl = 4'b0111; //blt
	3'b101: ALUCtrl = 4'b0111; //bge
	3'b110: ALUCtrl = 4'b1111; //bltu
	3'b111: ALUCtrl = 4'b1111; //bgeu
	

   endcase
	end
	
	//jump instruction(jalr & jal) - Not Yet Implemented
	else if(instruction [6:0] == 7'b1101111 && instruction [6:0] == 7'b1100111)
	begin
	PCSrc = 1;
	ALUSrc = 0;
	RegWrite = 0;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
	end
	
	//Auipc  - Not Yet Implemented
	else if(instruction [6:0] == 7'b0010111)
	begin
	PCSrc = 0;
	ALUSrc = 1;
	RegWrite = 1;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
	ALUCtrl=4'b0010;
	end
	// lui 
	
	else if(instruction [6:0] == 7'b0110111)
	begin
	PCSrc = 0;
	ALUSrc = 1;
	RegWrite = 1;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
	ALUCtrl = 4'b1010;
	end
	
	
	//nop
	else 
	begin
	PCSrc = 0;
	ALUSrc = 0;
	RegWrite = 0;
	MemtoReg = 0;
	MemRead=0;
	MemWrite=0;
	ALUCtrl = 4'b0000;
	end


end


endmodule 
