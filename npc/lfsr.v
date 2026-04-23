module lfsr8(
    input clk;
    output [7:0]]opt;
);
    reg [7:0] lfsr;
    assign lfsr = 8'h1; // 初始值不能为0
    always @(posedge clk) begin
        lfsr <= {lfsr[4]^lfsr[3]^lfsr[2]^lfsr[0], lfsr[7:1]};
    end
    assign opt = lfsr;
endmodule