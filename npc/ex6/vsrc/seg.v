module seg7(
    input [3:0] in,
    output reg [7:0] out
);
    reg [7:0] reg1;
    always @(*) begin
        case (in)
          4'h0: reg1 = 8'b00000011;
          4'h1: reg1 = 8'b10011111;
          4'h2: reg1 = 8'b00100101;
          4'h3: reg1 = 8'b00001101;
          4'h4: reg1 = 8'b10011001;
          4'h5: reg1 = 8'b01001001;
          4'h6: reg1 = 8'b01000001;
          4'h7: reg1 = 8'b00011111;
          4'h8: reg1 = 8'b00000001;
          4'h9: reg1 = 8'b00001001;
          4'hA: reg1 = 8'b00010001;
          4'hB: reg1 = 8'b10000001;
          4'hC: reg1 = 8'b01100111;
          4'hD: reg1 = 8'b10000101;
          4'hE: reg1 = 8'b01100001;
          4'hF: reg1 = 8'b01110001;
          default: reg1 = 8'b11111111;
        endcase
    end
    assign out = reg1;
endmodule