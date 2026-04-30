module seg7(
    input [3:0] in,
    output reg [7:0] out
);
    always @(*) begin
        case (in)
            4'h0: out = 8'b00000011;
            4'h1: out = 8'b10011111;
            4'h2: out = 8'b00100101;
            4'h3: out = 8'b00001101;
            4'h4: out = 8'b10011001;
            4'h5: out = 8'b01001001;
            4'h6: out = 8'b01000001;
            4'h7: out = 8'b00011111;
            4'h8: out = 8'b00000001;
            4'h9: out = 8'b00001001;
            4'hA: out = 8'b00010001;
            4'hB: out = 8'b11000001;
            4'hC: out = 8'b01100011;
            4'hD: out = 8'b10000101;
            4'hE: out = 8'b01100001;
            4'hF: out = 8'b01110001;
            default: out = 8'b11111111;
        endcase
    end
endmodule
