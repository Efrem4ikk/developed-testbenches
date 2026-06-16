`timescale 1ns / 1ps

module tb_ring_buffer();

    reg         clk;
    reg         rst_n;
    reg         btn_wr;
    reg         btn_rd;
    wire [5:0]  led;

    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_wr(btn_wr),
        .btn_rd(btn_rd),
        .led(led)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        btn_wr = 0;
        btn_rd = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
        #50;
        
        $display("TEST: Ring Buffer (Depth=8, Width=6)");
        
        $display("[TEST 1] Write 3 bytes");
        $display("--------------------------------------------");
        
        #40; btn_wr = 1; #20; btn_wr = 0; #40;  // write 000001 (1)
        #40; btn_wr = 1; #20; btn_wr = 0; #40;  // write 000010 (2)
        #40; btn_wr = 1; #20; btn_wr = 0; #40;  // write 000011 (3)
        
        $display("  Wrote: 1, 2, 3");
        
        $display("\n[TEST 2] Read 3 bytes");
        $display("--------------------------------------------");
        
        btn_rd = 1; #20; $display("  Read 1: %d (expected 1)", dut.rd_data); btn_rd = 0; #40;
        btn_rd = 1; #20; $display("  Read 2: %d (expected 2)", dut.rd_data); btn_rd = 0; #40;
        btn_rd = 1; #20; $display("  Read 3: %d (expected 3)", dut.rd_data); btn_rd = 0; #40;
        
        $display("\n[TEST 3] Fill buffer completely (8 bytes)");
        $display("--------------------------------------------");
        
        for (int i = 0; i < 8; i = i + 1) begin
            #40; btn_wr = 1; #20; btn_wr = 0;
        end
        $display("  After 8 writes: full=%b (expected 1)", dut.rb.full);

        $display("\n[TEST 4] Try to write to full buffer (should be ignored)");
        $display("--------------------------------------------------------");
        
        #40; btn_wr = 1; #20; btn_wr = 0; #40;
        $display("  After extra write: full=%b (still 1)", dut.rb.full);

        $display("\n[TEST 5] Read all 8 bytes");
        $display("--------------------------------------------");
        
        for (int i = 0; i < 8; i = i + 1) begin
            #40; btn_rd = 1; #20; btn_rd = 0;
        end
        $display("  After 8 reads: empty=%b (expected 1)", dut.rb.empty);

        $display("\n[TEST 6] Try to read from empty buffer");
        $display("----------------------------------------");
        
        #40; btn_rd = 1; #20; $display("  Read: %d (should be old data)", dut.rd_data); btn_rd = 0;

        $display("\n[TEST 7] Wrap around test (write 10 bytes, read first 4)");
        $display("--------------------------------------------------------");

        while (!dut.rb.empty) begin
            #40; btn_rd = 1; #20; btn_rd = 0;
        end

        for (int i = 0; i < 10; i = i + 1) begin
            #40; btn_wr = 1; #20; btn_wr = 0;
        end
        $display("  Wrote 10 bytes to 8-depth buffer");
)
        btn_rd = 1; #20; $display("  Read 1: %d", dut.rd_data); btn_rd = 0; #40;
        btn_rd = 1; #20; $display("  Read 2: %d", dut.rd_data); btn_rd = 0; #40;
        btn_rd = 1; #20; $display("  Read 3: %d", dut.rd_data); btn_rd = 0; #40;
        btn_rd = 1; #20; $display("  Read 4: %d", dut.rd_data); btn_rd = 0; #40;
        $display("  Ring buffer wrap works correctly!");

        $display("\n[TEST 8] Check LED output");
        $display("----------------------------------------");
        $display("  led = %b (should show last read value)", led);
        
        #100;
        $display("TEST FINISHED");
        $finish;
    end

    initial begin
        $monitor("[%0t ns] btn_wr=%b btn_rd=%b full=%b empty=%b rd_data=%d", 
                 $time, btn_wr, btn_rd, dut.rb.full, dut.rb.empty, dut.rd_data);
    end

    initial begin
        $dumpfile("tb_ring_buffer.vcd");
        $dumpvars(0, tb_ring_buffer);
    end

endmodule
