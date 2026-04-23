module alu(
    input [3:0] A,
    input [3:0] B,
    input [2:0] op,
    output reg [3:0] out
);
reg [4:0] result;
    always @(*) begin
        result = 5'b0;
        case (op)
            3'b000:begin
                result = A + B;
                out = result[3:0];
            end
            3'b001:begin
                result = A - B;
                out = result[3:0];
            end
            3'b010:begin
              out = ~A;
            end
            3'b011:begin
              out = A & B;
            end
            3'b100:begin
              out = A | B;
            end
            3'b101:begin
              out = A ^ B;
            end
            3'b110:begin
                result = A - B;
                out = {3'b000, result[4]};
            end
            3'b111:begin
                result = A - B;
                out = {3'b000, ~|result};
            end
             default: out = 4'b0000;
        endcase
    end
endmodule