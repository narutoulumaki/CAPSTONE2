`timescale 1ns / 1ps

module tb_vedicdivider_hybrid;

    logic [15:0] dividend_bcd;
    logic [7:0] divisor_bcd;
    logic [11:0] quotient_bcd;
    logic [7:0] remainder_bcd;
    
    // Debug signals to monitor internal conversions
    logic [13:0] debug_dividend_bin;
    logic [6:0] debug_divisor_bin;
    
    // Instantiate hybrid divider
    vedicdivider_dhwajank_hybrid dut (
        .dividend_bcd(dividend_bcd),
        .divisor_bcd(divisor_bcd),
        .quotient_bcd(quotient_bcd),
        .remainder_bcd(remainder_bcd)
    );
    
    // Monitor internal binary values
    assign debug_dividend_bin = dut.dividend_bin;
    assign debug_divisor_bin = dut.divisor_bin;
    
    // Helper function to convert BCD to decimal for display
    function integer bcd4_to_dec(input [15:0] bcd);
        return (bcd[15:12] * 1000) + (bcd[11:8] * 100) + (bcd[7:4] * 10) + bcd[3:0];
    endfunction
    
    function integer bcd2_to_dec(input [7:0] bcd);
        return (bcd[7:4] * 10) + bcd[3:0];
    endfunction
    
    function integer bcd3_to_dec(input [11:0] bcd);
        return (bcd[11:8] * 100) + (bcd[7:4] * 10) + bcd[3:0];
    endfunction
    
    initial begin
        $display("\n========================================");
        $display("Hybrid Vedic Divider Test (BCD I/O, Binary Core)");
        $display("========================================\n");
        
        // Test 1: 9876 / 12 = 823 R 0
        dividend_bcd = 16'h9876; divisor_bcd = 8'h12;
        #10;
        $display("Test 1: %0d / %0d = %0d R %0d (Expected: 823 R 0)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 2: 1234 / 56 = 22 R 2
        dividend_bcd = 16'h1234; divisor_bcd = 8'h56;
        #10;
        $display("Test 2: %0d / %0d = %0d R %0d (Expected: 22 R 2)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 3: 9999 / 99 = 101 R 0
        dividend_bcd = 16'h9999; divisor_bcd = 8'h99;
        #10;
        $display("Test 3: %0d / %0d = %0d R %0d (Expected: 101 R 0)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        $display("  DEBUG: dividend_bcd=%h, divisor_bcd=%h, quotient_bcd=%h, remainder_bcd=%h",
                 dividend_bcd, divisor_bcd, quotient_bcd, remainder_bcd);
        $display("  DEBUG: dividend_bin=%0d, divisor_bin=%0d", debug_dividend_bin, debug_divisor_bin);
        
        // Test 4: 5000 / 25 = 200 R 0
        dividend_bcd = 16'h5000; divisor_bcd = 8'h25;
        #10;
        $display("Test 4: %0d / %0d = %0d R %0d (Expected: 200 R 0)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 5: 8765 / 43 = 203 R 36
        dividend_bcd = 16'h8765; divisor_bcd = 8'h43;
        #10;
        $display("Test 5: %0d / %0d = %0d R %0d (Expected: 203 R 36)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 6: 100 / 7 = 14 R 2
        dividend_bcd = 16'h0100; divisor_bcd = 8'h07;
        #10;
        $display("Test 6: %0d / %0d = %0d R %0d (Expected: 14 R 2)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 7: 7777 / 88 = 88 R 33
        dividend_bcd = 16'h7777; divisor_bcd = 8'h88;
        #10;
        $display("Test 7: %0d / %0d = %0d R %0d (Expected: 88 R 33)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        // Test 8: Division by zero protection
        dividend_bcd = 16'h1234; divisor_bcd = 8'h00;
        #10;
        $display("Test 8: %0d / %0d = %0d R %0d (Expected: 0 R 0 - div by zero)",
                 bcd4_to_dec(dividend_bcd), bcd2_to_dec(divisor_bcd),
                 bcd3_to_dec(quotient_bcd), bcd2_to_dec(remainder_bcd));
        
        $display("\n========================================");
        $display("Test Complete!");
        $display("========================================\n");
        
        $finish;
    end

endmodule
