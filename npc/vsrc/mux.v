module mux_2bit_4to1(
	input [1:0] X0,
	input [1:0] X1,
	input [1:0] X2,
	input [1:0] X3,
	input [1:0] Y,
	output [1:0] F
);
    wire [1:0] slect [4-1:0];
    assign select = {x0, x1, x2, x3};
    assign F = select[Y];
endmodule