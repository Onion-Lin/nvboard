module moore(
    input clk,rst,
    input [3:0] ipt,
    output reg opt
);
    parameter IDLE = 1'b0,RECEIVE=1'b1;
    reg state,next_state;

    always @(posedge clk) begin
        case (state)
            IDLE:begin
              if (ipt == 4'b1101) begin
                next_state <= RECEIVE;
              end else begin
                  next_state <= IDLE;
              end
            end 
            RECEIVE:begin
              if (ipt == 4'b1101) begin
                next_state <= RECEIVE;
              end else begin
                  next_state <= IDLE;
              end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;            
        end
    end

    always @(*) begin
        case (state)
            RECEIVE: opt <= 1; 
            default: opt <= 0;
        endcase
    end

endmodule