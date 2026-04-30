module alu (
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] op,
    output reg [3:0] out,
    output reg       zero,
    output reg       overflow,
    output reg       carry
);

    reg [3:0] diff;
    reg       sign;
    reg       ovf;

    always @(*) begin
        out      = 4'b0;
        zero     = 1'b0;
        overflow = 1'b0;
        carry    = 1'b0;
        diff     = 4'b0;
        sign     = 1'b0;
        ovf      = 1'b0;

        case (op)
            3'b000: begin
                {carry, out} = {1'b0, A} + {1'b0, B};
                zero     = ~|out;
                overflow = (A[3] == B[3]) && (out[3] != A[3]);
            end

            3'b001: begin
                {carry, out} = {1'b0, A} + {1'b0, ~B} + 1'b1;
                zero     = ~|out;
                overflow = (A[3] != B[3]) && (out[3] != A[3]);
            end

            3'b010: begin
                out  = ~A;
                zero = ~|out;
            end

            3'b011: begin
                out  = A & B;
                zero = ~|out;
            end

            3'b100: begin
                out  = A | B;
                zero = ~|out;
            end

            3'b101: begin
                out  = A ^ B;
                zero = ~|out;
            end

            3'b110: begin
                diff = A - B;
                sign = diff[3];
                ovf  = (A[3] != B[3]) && (sign != A[3]);
                out  = {3'b000, ovf ^ sign};
            end

            3'b111: begin
                out  = {3'b000, (A == B)};
            end

            default: out = 4'b0;
        endcase
    end

endmodule
