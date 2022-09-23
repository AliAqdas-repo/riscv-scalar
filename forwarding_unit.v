module forwarding_unit(EXMEM_RegWrite,MEMWB_RegWrite,IDEX_Rs1,
								IDEX_Rs2,EXMEM_Rd,MEMWB_Rd,ForwardA,ForwardB);
input [4:0] IDEX_Rs1,IDEX_Rs2,EXMEM_Rd,MEMWB_Rd;
input EXMEM_RegWrite,MEMWB_RegWrite;
output reg [1:0] ForwardA,ForwardB;


always @ (*)
begin
//EX Hazard
if (EXMEM_RegWrite && (EXMEM_Rd != 0) && (EXMEM_Rd == IDEX_Rs1))
			begin
				ForwardA = 2'b10;
				ForwardB = 2'b00;
			end
else if (EXMEM_RegWrite && (EXMEM_Rd != 0) && (EXMEM_Rd == IDEX_Rs2))
			begin
				ForwardA = 2'b00;
				ForwardB = 2'b10;
			end

else if (MEMWB_RegWrite && (MEMWB_Rd != 0)
&& !(EXMEM_RegWrite && (EXMEM_Rd != 0) && (EXMEM_Rd == IDEX_Rs1))
&& (MEMWB_Rd == IDEX_Rs1)) 
begin
	ForwardA = 2'b01;
	ForwardB = 2'b00;
end

else if (MEMWB_RegWrite && (MEMWB_Rd != 0)
&& !(EXMEM_RegWrite && (EXMEM_Rd != 0) && (EXMEM_Rd == IDEX_Rs2))
&& (MEMWB_Rd == IDEX_Rs2)) 
begin
	ForwardB = 2'b01;
	ForwardA = 2'b00;
end

else 
	begin
	ForwardB = 2'b00;
	ForwardA = 2'b00;
	end
			
end

endmodule 