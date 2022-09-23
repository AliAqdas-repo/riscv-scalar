module imm_gen(instruction, immediate);
input [31:0] instruction;
output reg [31:0] immediate;

always @ (instruction)
begin
	//I-Type and Load
	if (instruction [6:0] == 7'b0010011 || instruction [6:0] == 7'b0000011)
	begin
	immediate [11:0] = instruction[31:20];
	immediate [31:12] = {20{instruction[31]}};
	end
	// (S-Type) Store
	else 	if (instruction [6:0] == 7'b0100011)
	begin
	immediate [4:0] = instruction[11:7];
	immediate [11:5] = instruction[31:25];
	immediate [31:12] = {20{instruction[31]}};
	end
	
	// (SB-Type)Condition Branch
	else 	if (instruction [6:0] == 7'b1100011)
	begin
	immediate [0] = 1'b0;
	immediate [11] = instruction[7];
	immediate [4:1] = instruction[11:8];
	immediate [10:5] = instruction[30:25];
	immediate [31:12] = {20{instruction[31]}};
	end
	//UJ-Type
	else 	if (instruction [6:0] == 7'b1101111)
	begin
	immediate [0] = 1'b0;
	immediate [19:12] = instruction[19:12];
	immediate [11] = instruction[20];
	immediate [10:1] = instruction[30:21];
	immediate [31:20] = {12{instruction[31]}};
	end
	//U-Type
	else
	begin
	immediate [31:12] = instruction[31:12];
	immediate [11:0] = 0;
	end
	
	
end


endmodule 
