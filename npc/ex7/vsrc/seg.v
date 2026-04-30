module bcd7seg(
  input [3:0] b,
  input en,
  output reg [7:0] h
);

  always @(*) begin
    if (!en) begin
      h = 8'b11111111;
    end else begin
      case (b)
        4'b0000: h = 8'b00000010; 
        4'b0001: h = 8'b10011111; 
        4'b0010: h = 8'b00100101; 
        4'b0011: h = 8'b00001101; 
        4'b0100: h = 8'b10011001; 
        4'b0101: h = 8'b01001001; 
        4'b0110: h = 8'b01000001; 
        4'b0111: h = 8'b00011111; 
        4'b1000: h = 8'b00000000; 
        4'b1001: h = 8'b00001001; 
        4'b1010: h = 8'b00010001; 
        4'b1011: h = 8'b11000001; 
        4'b1100: h = 8'b01100011; 
        4'b1101: h = 8'b10000101; 
        4'b1110: h = 8'b01100001; 
        4'b1111: h = 8'b01110001; 
        default: h = 8'b11111111;
      endcase
    end
  end
endmodule
