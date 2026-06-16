`timescale 1ns / 1ps

module tb_timer();

    reg         clk;
    reg         rst_n;
    wire [5:0]  led;

    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .led(led)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        #50;
        
        $display("TEST: Hardware Timer (26-bit counter)");
        
        $display("[INFO] Timer parameters:");
        $display("  Clock frequency: 50 MHz");
        $display("  Counter width: 26 bits");
        $display("  Max count: %0d (2^26 = 67,108,864)", 2**26);
        $display("  Period: %0d ns (approx 1.34 seconds)", 2**26 * 20);
        $display("  LED shows bits 25..20 (most significant)\n");

        $display("[TEST 1] Check counter after reset");
        $display("--------------------------------------------");
        #20;
        $display("  counter = %0d (should be 0)", dut.u_timer.counter);
        $display("  led = %b (should be 000000)", led);
=
        $display("\n[TEST 2] Let counter run for 1000 ns");
        $display("--------------------------------------------");
        
        #1000;
        $display("  counter = %0d", dut.u_timer.counter);
        $display("  led = %b (shows MSB bits)", led);

        $display("\n[TEST 3] Check LED changes over time");
        $display("--------------------------------------------");
        
        for (int i = 0; i < 5; i = i + 1) begin
            #500;
            $display("  Time %0t: counter = %0d, led = %b", 
                     $time, dut.u_timer.counter, led);
        end

        $display("\n[TEST 4] Verify MSB bits extraction");
        $display("--------------------------------------------");

        dut.u_timer.counter = 26'b111111_00000000000000000000;
        #20;
        $display("  Manual counter = 26'b111111_00000000000000000000");
        $display("  led = %b (should be 111111)", led);
        
        dut.u_timer.counter = 26'b000001_00000000000000000000;
        #20;
        $display("  Manual counter = 26'b000001_00000000000000000000");
        $display("  led = %b (should be 000001)", led);
        
        dut.u_timer.counter = 26'b101010_00000000000000000000;
        #20;
        $display("  Manual counter = 26'b101010_00000000000000000000");
        $display("  led = %b (should be 101010)", led);

        $display("\n[TEST 5] Check wrap around behavior");
        $display("--------------------------------------------");

        dut.u_timer.counter = 2**26 - 10;
        $display("  Set counter near max: %0d", dut.u_timer.counter);
        
        for (int i = 0; i < 15; i = i + 1) begin
            #20;
            if (dut.u_timer.counter < 5) begin
                $display("  WRAP! counter = %0d at time %0t", 
                         dut.u_timer.counter, $time);
            end
        end

        #500;
        $display("TEST FINISHED");
        $finish;
    end

    // Монитор
    initial begin
        $monitor("[%0t ns] counter=%0d led=%b", 
                 $time, dut.u_timer.counter, led);
    end

endmodule
