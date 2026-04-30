module vga (
    input pclk,
    input reset,
    input [23:0] vga_data,
    output [9:0] h_addr,
    output [9:0] v_addr,
    output hsync,
    output vsync,
    output valid,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;

parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;

reg [9:0] x_cnt;
reg [9:0] y_cnt;
reg [18:0] mem_addr;

wire h_valid;
wire v_valid;

always @(posedge pclk) begin
    if(reset) begin
        x_cnt <= 1;
        y_cnt <= 1;
        mem_addr <= 0;
    end
    else begin
        if(x_cnt == h_total) begin
            x_cnt <= 1;
            if(y_cnt == v_total) begin
                y_cnt <= 1;
                mem_addr <= 0;
            end
            else begin
                y_cnt <= y_cnt + 1;
            end
        end
        else begin
            x_cnt <= x_cnt + 1;
        end
        
        if(h_valid && v_valid) begin
            if(mem_addr == 640*480 - 1)
                mem_addr <= 0;
            else
                mem_addr <= mem_addr + 1;
        end
    end
end

assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);

assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;

assign h_addr = valid ? mem_addr[9:0] : 10'd0;
assign v_addr = valid ? {1'b0, mem_addr[18:10]} : 10'd0;

assign {vga_r, vga_g, vga_b} = valid ? vga_data : 24'd0;

endmodule


module vmem(
    input [9:0] h_addr,
    input [8:0] v_addr,
    output [23:0] vga_data
);

reg [23:0] vga_mem [307199:0];

initial begin
    $readmemh("vga_image.hex", vga_mem);
end

wire [18:0] mem_addr = {v_addr, h_addr};

assign vga_data = (mem_addr < 307200) ? vga_mem[mem_addr] : 24'd0;

endmodule
