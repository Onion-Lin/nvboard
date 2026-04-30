module top(
    input  clk,
    input  rst,
    input  [15:0] switch_i,
    input  [4:0]  button,
    input ps2_data,
    input ps2_clk,
    input uart_rx,
    output uart_tx,
    output [15:0] led,
    output [7:0]  seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

   reg [3:0] s;

    //alu单元
    alu alu0(
        .A(switch_i[11:8]),
        .B(switch_i[15:12]),
        .op(switch_i[7:5]),
        .zero(led[0]),
        .overflow(led[1]),
        .carry(led[2]),
        .out(s)
    );
	
	seg7 sege7(s,seg0);
	assign seg1 = 8'b11111111;
	assign seg2 = 8'b11111111;
	assign seg3 = 8'b11111111;
	assign seg4 = 8'b11111111;
	assign seg5 = 8'b11111111;
	assign seg6 = 8'b11111111;
	assign seg7 = 8'b11111111;
  
endmodule
