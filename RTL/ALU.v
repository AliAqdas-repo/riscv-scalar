module ALU(
           input [31:0] A,B,  // ALU 8-bit Inputs                
           input [3:0] ALU_Sel,// ALU Selection
           output [31:0] ALU_Out, // ALU 8-bit Output
           output Zero // Carry Out Flag
    );
    reg [31:0] ALU_Result;
    assign ALU_Out = ALU_Result; // ALU out
    always @(*)
    begin
        case(ALU_Sel)
        4'b0010: // Addition
           ALU_Result = A + B ;
        4'b0110: // Subtraction
           ALU_Result = A - B ;
     
          4'b0000: //  Logical and
           ALU_Result = A & B;
          4'b0001: //  Logical or
           ALU_Result = A | B;
          4'b1100: //  Logical xor
           ALU_Result = A ^ B;
         
          4'b0111: // set less comparison
           ALU_Result = ($signed(A) < $signed(B))?32'd1:32'd0 ;
			  
			 4'b1001: //Shift right logical
			  ALU_Result = A >> B;
			  
			 4'b1101: //Shift left logical
			  ALU_Result = A << B;
			  
			 4'b1011: //Shift right arithmetic
			  ALU_Result = A >>> B;
			  
			 4'b1111: // SLTIU
				ALU_Result = (A < B) ? 32'd1:32'd0 ;
			  
			4'b1010: //lui
			   ALU_Result = B;
			  
			
        endcase
    end
	 assign Zero = (ALU_Result == 0);

endmodule
