module hazard_detect(instruction,IDEX_MemRead,IDEX_Rd,IDEX_Branch,
							IFID_Write,PC_Write,FlushCtrl,IF_Flush);
input [31:0] instruction;
input IDEX_MemRead,IDEX_Branch;
input [4:0] IDEX_Rd;
output reg IFID_Write,PC_Write,FlushCtrl,IF_Flush;

always @ (*)
begin
// Data Hazard
	if (IDEX_MemRead && ((IDEX_Rd==instruction[19:15]) || (IDEX_Rd==instruction[24:20]))
	&& ((instruction[6:0]==7'b0110011) || (instruction[6:0]==7'b1100011)))
		begin
			IFID_Write = 0;
			PC_Write = 0;
			FlushCtrl = 0;
			IF_Flush = 0;
		end
	else if (instruction[6:0]==7'b1100011)
		begin
			IFID_Write = 1;
			IF_Flush = 1;
			PC_Write = 0;
			FlushCtrl = 1;
		end
	else if (IDEX_Branch && instruction[6:0] == 7'b0000000)
		begin
					PC_Write = 0;
					IFID_Write = 1;
					FlushCtrl = 1;
					IF_Flush = 1;
		end
	else 
		begin
			PC_Write = 1;
			IFID_Write = 1;
			FlushCtrl = 1;
			IF_Flush = 0;
		end

end

endmodule 

