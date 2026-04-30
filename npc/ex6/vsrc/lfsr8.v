module lfsr8(
    input clk,
    input rst,
    output [7:0]opt
);
    reg [7:0] lfsr;
    always @(posedge clk,rst) begin
        if (rst) begin
            lfsr <= 8'd1;
        end else begin
            lfsr <= {lfsr[4]^lfsr[3]^lfsr[2]^lfsr[0], lfsr[7:1]};
        end
    end
    assign opt = lfsr;
endmodule
