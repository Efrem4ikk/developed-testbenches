module psram_test (
    input wire clk,           // 27 МГц
    input wire rst_n,         // Сброс (активный низкий)
    
    // Интерфейс к PSRAM IP
    output reg [31:0] wr_data,
    input wire [31:0] rd_data,
    input wire rd_data_valid,
    output reg [20:0] addr,
    output reg cmd,
    output reg cmd_en,
    input wire init_calib,
    output reg [3:0] data_mask,
    
    output reg [5:0] led
);

    // Состояния
    reg [2:0] state;
    reg [31:0] test_data;
    reg [20:0] test_addr;
    reg [7:0] delay_cnt;
    
    // Сброс
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 0;
            test_data <= 32'hAAAAAAAA;
            test_addr <= 0;
            delay_cnt <= 0;
            wr_data <= 0;
            addr <= 0;
            cmd <= 0;
            cmd_en <= 0;
            data_mask <= 4'b0000;
            led <= 6'b000000;
        end else begin
            cmd_en <= 0;
            
            case (state)
                0: begin
                    led[0] <= 1'b1;
                    if (init_calib) begin
                        state <= 1;
                        led[0] <= 1'b0;
                    end
                end
                
                1: begin
                    led[1] <= 1'b1;
                    cmd_en <= 1;
                    cmd <= 1;
                    addr <= test_addr;
                    wr_data <= test_data;
                    data_mask <= 4'b0000;
                    state <= 2;
                    delay_cnt <= 10;
                end
                
                2: begin
                    if (delay_cnt > 0) begin
                        delay_cnt <= delay_cnt - 1;
                    end else begin
                        led[1] <= 1'b0;
                        state <= 3;
                    end
                end
                
                3: begin
                    led[2] <= 1'b1;
                    cmd_en <= 1;
                    cmd <= 0;
                    addr <= test_addr;
                    state <= 4;
                    delay_cnt <= 20;
                end
                
                4: begin
                    if (delay_cnt > 0) begin
                        delay_cnt <= delay_cnt - 1;
                    end else if (rd_data_valid) begin
                        led[2] <= 1'b0;
                        if (rd_data == test_data) begin
                            led[3] <= 1'b1;
                            test_addr <= test_addr + 1;
                            test_data <= test_data + 32'h00000001;
                            state <= 1;
                        end else begin
                            led[4] <= 1'b1;
                            state <= 5;
                        end
                    end
                end
                
                5: begin
                    led[5] <= 1'b1;
                    state <= 5;
                end
                
                default: state <= 0;
            endcase
        end
    end

endmodule
