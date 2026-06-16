`timescale 1ns / 1ps

module tb_top();

    // Signals
    reg         clk;
    reg         rst_n;
    reg         btn;
    reg         btn_valid;
    wire [5:0]  led;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn(btn),
        .btn_valid(btn_valid),
        .led(led)
    );

    // Clock generation (50 MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initial values
        btn = 0;
        btn_valid = 0;
        rst_n = 0;
        
        // Reset
        #100;
        rst_n = 1;
        #20;
        
        $display(" ");
        $display("========== TEST START ==========");
        
        // -------------------------------------------------
        // TEST 1: Send 0xAA (10101010) LSB first
        // Bits: 0,1,0,1,0,1,0,1
        // -------------------------------------------------
        $display(" ");
        $display("[TEST 1] Send 0xAA");
        
        btn_valid = 1;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn_valid = 0;
        
        #100;
        
        // -------------------------------------------------
        // TEST 2: Send 0x55 (01010101) LSB first
        // Bits: 1,0,1,0,1,0,1,0
        // -------------------------------------------------
        $display(" ");
        $display("[TEST 2] Send 0x55");
        
        btn_valid = 1;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn_valid = 0;
        
        #100;
        
        // -------------------------------------------------
        // TEST 3: Send 0x1F (00011111) LSB first
        // Bits: 1,1,1,1,1,0,0,0
        // -------------------------------------------------
        $display(" ");
        $display("[TEST 3] Send 0x1F");
        
        btn_valid = 1;
        btn = 1; #20;
        btn = 1; #20;
        btn = 1; #20;
        btn = 1; #20;
        btn = 1; #20;
        btn = 0; #20;
        btn = 0; #20;
        btn = 0; #20;
        btn_valid = 0;
        
        #100;
        
        $display(" ");
        $display("========== TEST FINISHED ==========");
        $display(" ");
        $finish;
    end

    // Monitor data when valid is asserted
    always @(posedge clk) begin
        if (dut.valid) begin
            $display("[%0t ns] valid=1, data=0x%h, led=%b", 
                     $time, dut.data, led);
        end
    end

    // Visual monitor
    initial begin
        $monitor("[%0t ns] led = %b", $time, led);
    end

endmodule
