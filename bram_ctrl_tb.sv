`timescale 1ns / 1ps

module tb_bram_ctrl();

    reg         clk;
    reg         rst_n;
    reg         btn_wr;
    reg         btn_rd;
    reg  [2:0]  addr;
    wire [5:0]  led;

    // Инстанцируем top модуль
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_wr(btn_wr),
        .btn_rd(btn_rd),
        .addr(addr),
        .led(led)
    );

    // Генерация такта 50 МГц (период 20 нс)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        // Сброс
        btn_wr = 0;
        btn_rd = 0;
        addr = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
        #50;
        
        $display("TEST: BRAM Controller (8 words x 6 bit)");
        
        $display("[TEST 1] Write 3 values to addresses 0,1,2");
        $display("--------------------------------------------");
        
        addr = 0; #40; btn_wr = 1; #20; btn_wr = 0; #40;
        $display("  Wrote %d to addr 0", dut.wr_data);
        
        addr = 1; #40; btn_wr = 1; #20; btn_wr = 0; #40;
        $display("  Wrote %d to addr 1", dut.wr_data);
        
        addr = 2; #40; btn_wr = 1; #20; btn_wr = 0; #40;
        $display("  Wrote %d to addr 2", dut.wr_data);
        
        $display("\n[TEST 2] Read from addresses 0,1,2");
        $display("--------------------------------------------");
        
        addr = 0; #40; btn_rd = 1; #20; $display("  Read addr0: %d", dut.rd_data); btn_rd = 0; #40;
        addr = 1; #40; btn_rd = 1; #20; $display("  Read addr1: %d", dut.rd_data); btn_rd = 0; #40;
        addr = 2; #40; btn_rd = 1; #20; $display("  Read addr2: %d", dut.rd_data); btn_rd = 0; #40;
        
        $display("\n[TEST 3] Overwrite addr1 and verify");
        $display("--------------------------------------------");
        
        addr = 1; 
        for (int i = 0; i < 5; i = i + 1) begin
            #40; btn_wr = 1; #20; btn_wr = 0;
        end
        $display("  Wrote 5 times to addr1 (now value = %d)", dut.wr_data);
        
        addr = 1; #40; btn_rd = 1; #20; $display("  Read addr1: %d", dut.rd_data); btn_rd = 0; #40;
        
        $display("\n[TEST 4] Check addr0 and addr2 unchanged");
        $display("--------------------------------------------");
        
        addr = 0; #40; btn_rd = 1; #20; $display("  Read addr0: %d (should still be 1)", dut.rd_data); btn_rd = 0; #40;
        addr = 2; #40; btn_rd = 1; #20; $display("  Read addr2: %d (should still be 3)", dut.rd_data); btn_rd = 0; #40;
        
        $display("\n[TEST 5] LED display");
        $display("--------------------------------------------");
        $display("  led = %b (shows last read value)", led);
        
        #100;
        $display("TEST FINISHED");
        $finish;
    end

    initial begin
        $monitor("[%0t ns] btn_wr=%b btn_rd=%b addr=%d rd_data=%d", 
                 $time, btn_wr, btn_rd, addr, dut.rd_data);
    end

endmodule
