module ps2_receiver(clk,clrn,ps2_clk,ps2_data,data,ready,nextdata_n,overflow);
    input clk,clrn,ps2_clk,ps2_data;
    input nextdata_n;
    output [7:0] data;
    output reg ready;
    output reg overflow;     

    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     
    reg [2:0] w_ptr,r_ptr;   
    reg [3:0] count; 
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin 
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end
        else begin
            if ( ready ) begin 
                if(nextdata_n == 1'b0)
                begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+1'b1))
                        ready <= 1'b0;
                end
            end
            if (sampling) begin
              if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  
                    (ps2_data)       &&  
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;   
              end else begin
                buffer[count] <= ps2_data;  
                count <= count + 3'b1;
              end
            end
        end
    end
    assign data = fifo[r_ptr];

endmodule


module ps2_keyboard(
    input clk, clrn,
    input ps2_clk, ps2_data,
    output ready,
    output overflow,
    output [7:0] seg0,
    output [7:0] seg1,
    output [7:0] seg2,
    output [7:0] seg3,
    output [7:0] seg4,
    output [7:0] seg5
);

    wire [7:0] key_data;
    wire key_ready;
    wire [7:0] dummy_data;
    reg nextdata_n;
    reg ack_request;
    reg last_ready;

    reg seg_en;
    reg [7:0] cur_data;
    reg [7:0] ascii_data;
    reg [7:0] press_cnt;
    reg waiting_release;    //0非断码，1断码

   
    ps2_receiver u_receiver(
        .clk(clk),
        .clrn(clrn),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .data(key_data),
        .ready(key_ready),
        .nextdata_n(nextdata_n),
        .overflow(overflow)
    );

    
    ascii_decoder u_ascii(
        .clk(clk),
        .key_data(cur_data),
        .ascii(ascii_data)
    );

    assign ready = key_ready;

    always @(posedge clk) begin
        if (clrn == 0) begin
            seg_en <= 1'b0;
            cur_data <= 8'b0;
            ascii_data <= 8'b0;
            press_cnt <= 8'b0;
            waiting_release <= 1'b0;
            last_ready <= 1'b0;
            ack_request <= 1'b0;
            nextdata_n <= 1'b1;
        end else begin
            if (ack_request) begin
                nextdata_n <= 1'b0;
                ack_request <= 1'b0;
            end else begin
                nextdata_n <= 1'b1;
            end

            if (key_ready && !last_ready) begin
                if (key_data == 8'hF0) begin
                    waiting_release <= 1'b1;
                end else begin
                    if (waiting_release) begin
                        press_cnt <= press_cnt + 1'b1;
                        seg_en <= 1'b0;
                        waiting_release <= 1'b0;
                    end else begin
                        cur_data <= key_data;
                        seg_en <= 1'b1;
                    end
                end
                ack_request <= 1'b1;
            end

            last_ready <= key_ready;
        end
    end

    bcd7seg b0(.en(seg_en), .b(cur_data[3:0]), .h(seg0));
    bcd7seg b1(.en(seg_en), .b(cur_data[7:4]), .h(seg1));
    bcd7seg b2(.en(seg_en), .b(ascii_data[3:0]), .h(seg2));
    bcd7seg b3(.en(seg_en), .b(ascii_data[7:4]), .h(seg3));
    bcd7seg b4(.en(1'b1), .b(press_cnt[3:0]), .h(seg4));
    bcd7seg b5(.en(1'b1), .b(press_cnt[7:4]), .h(seg5));

endmodule

module ascii_decoder (
    input clk,
    input [7:0] key_data,
    output reg [7:0] ascii
);

always @(posedge clk) begin
    case (key_data)
        8'h45: ascii <= 8'h30; // 0
        8'h16: ascii <= 8'h31; 
        8'h1e: ascii <= 8'h32; 
        8'h26: ascii <= 8'h33; 
        8'h25: ascii <= 8'h34; 
        8'h2e: ascii <= 8'h35; 
        8'h36: ascii <= 8'h36; 
        8'h3d: ascii <= 8'h37; 
        8'h3e: ascii <= 8'h38; 
        8'h46: ascii <= 8'h39; // 9
        8'h1c: ascii <= 8'h61; // a
        8'h32: ascii <= 8'h62; 
        8'h21: ascii <= 8'h63;
        8'h23: ascii <= 8'h64;
        8'h24: ascii <= 8'h65;
        8'h2b: ascii <= 8'h66;
        8'h34: ascii <= 8'h67;
        8'h33: ascii <= 8'h68;
        8'h43: ascii <= 8'h69;
        8'h3b: ascii <= 8'h6a;
        8'h42: ascii <= 8'h6b;
        8'h4b: ascii <= 8'h6c;
        8'h3a: ascii <= 8'h6d; 
        8'h31: ascii <= 8'h6e; 
        8'h44: ascii <= 8'h6f; 
        8'h4d: ascii <= 8'h70; 
        8'h15: ascii <= 8'h71; 
        8'h2d: ascii <= 8'h72; 
        8'h1b: ascii <= 8'h73; 
        8'h2c: ascii <= 8'h74; 
        8'h3c: ascii <= 8'h75; 
        8'h2a: ascii <= 8'h76; 
        8'h1d: ascii <= 8'h77; 
        8'h22: ascii <= 8'h78; 
        8'h35: ascii <= 8'h79; 
        8'h1a: ascii <= 8'h7a; // z
        default: ascii <= 8'h00;
    endcase
end

endmodule

