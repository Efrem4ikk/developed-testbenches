`timescale 1ns / 1ps

module tb_dsp_mac();

    reg         clk;
    reg         rst_n;
    reg         mult_en;
    reg         acc_en;
    reg         acc_clr;
    reg  signed [7:0] a;
    reg  signed [7:0] b;
    wire signed [23:0] result;
    wire signed [15:0] mult_out;

    dsp_mac #(
        .DATA_WIDTH(8),
        .ACC_WIDTH(24)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .mult_en(mult_en),
        .acc_en(acc_en),
        .acc_clr(acc_clr),
        .result(result),
        .mult_out(mult_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        a = 0; b = 0;
        mult_en = 0; acc_en = 0; acc_clr = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
        #50;

        $display("TEST: DSP Multiply-Accumulate (MAC)");

        $display("[TEST 1] Simple multiplication");
        $display("--------------------------------------------");
        
        a = 8'd5; b = 8'd3;
        #40; mult_en = 1; #20; mult_en = 0; #40;
        $display("  5 * 3 = %0d (mult_out = %0d)", 5*3, mult_out);
        
        a = 8'd7; b = 8'd6;
        #40; mult_en = 1; #20; mult_en = 0; #40;
        $display("  7 * 6 = %0d (mult_out = %0d)", 7*6, mult_out);
        
        a = 8'd10; b = 8'd4;
        #40; mult_en = 1; #20; mult_en = 0; #40;
        $display("  10 * 4 = %0d (mult_out = %0d)", 10*4, mult_out);

        $display("\n[TEST 2] Multiply-Accumulate (MAC)");
        $display("--------------------------------------------");
        
        #40; acc_clr = 1; #20; acc_clr = 0; #40;
        $display("  Accumulator cleared = %0d", result);
        
        // 3 * 4 = 12
        a = 8'd3; b = 8'd4;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  After 3*4 = 12, accumulator = %0d", result);

        a = 8'd5; b = 8'd2;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  + 5*2 = 10, accumulator = %0d (expected 22)", result);
        
        // + 1 * 8 = 8, всего 30
        a = 8'd1; b = 8'd8;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  + 1*8 = 8, accumulator = %0d (expected 30)", result);

        $display("\n[TEST 3] Signed multiplication (negative numbers)");
        $display("--------------------------------------------");
        
        #40; acc_clr = 1; #20; acc_clr = 0; #40;
        
        a = -8'sd5; b = 8'sd3;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  (-5) * 3 = %0d, accumulator = %0d", -15, result);
        
        a = 8'sd4; b = -8'sd2;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  + 4 * (-2) = %0d, accumulator = %0d (expected -23)", -8, result);
        
        a = -8'sd3; b = -8'sd3;
        #40; mult_en = 1; #20; mult_en = 0;
        #40; acc_en = 1; #20; acc_en = 0; #40;
        $display("  + (-3)*(-3) = %0d, accumulator = %0d (expected -14)", 9, result);

        $display("\n[TEST 4] Accumulator reset test");
        $display("--------------------------------------------");
        
        $display("  Before reset: accumulator = %0d", result);
        #40; acc_clr = 1; #20; acc_clr = 0; #40;
        $display("  After reset: accumulator = %0d (should be 0)", result);

        #100;
        $display("TEST FINISHED");
        $finish;
    end

    initial begin
        $monitor("[%0t] a=%0d b=%0d mult=%b acc=%b clr=%b result=%0d", 
                 $time, a, b, mult_en, acc_en, acc_clr, result);
    end

endmodule
