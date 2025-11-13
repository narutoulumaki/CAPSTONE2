`timescale 1ns/1ps

// Simple testbench for vedicdivider_dhwajank.sv
// Applies a set of BCD-valid test vectors and prints quotient/remainder

module vedicdivider_tb;
    // DUT signals
    logic [15:0] dividend;
    logic [7:0] divisor;
    logic [11:0] quotient;
    logic [7:0] remainder;

    // Instantiate DUT
    vedicdivider_dhwajank uut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    // Helper: convert 12-bit BCD to integer
    function int bcd12_to_int(input [11:0] b);
        int d0, d1, d2;
        begin
            d0 = b[11:8];
            d1 = b[7:4];
            d2 = b[3:0];
            bcd12_to_int = d0*100 + d1*10 + d2;
        end
    endfunction

    // Helper: convert 8-bit BCD remainder to int
    function int bcd8_to_int(input [7:0] b);
        int d0, d1;
        begin
            d0 = b[7:4];
            d1 = b[3:0];
            bcd8_to_int = d0*10 + d1;
        end
    endfunction

    // Simple task to apply vector and display results
    task apply_vector(input [15:0] d, input [7:0] v, input string comment);
        begin
            dividend = d;
            divisor = v;
            #5; // wait for combinational update
            $display("TEST: %s", comment);
            $display("  Dividend BCD = %0h (decimal %0d)", dividend, bcd12_to_int(dividend));
            $display("  Divisor  BCD = %0h (decimal %0d)", divisor, bcd8_to_int(divisor));
            $display("  Quotient BCD = %0h (decimal %0d)", quotient, bcd12_to_int(quotient));
            $display("  Remainder BCD = %0h (decimal %0d)", remainder, bcd8_to_int(remainder));
            $display("");
        end
    endtask

    initial begin
        $display("Starting Vedic Divider testbench...\n");

        // Valid BCD vectors (format: 4 nibbles for dividend, 2 nibbles for divisor)
        // 1) small dividend < divisor
        apply_vector(16'h0012, 8'h05, "12 / 5 (dividend < divisor)");

        // 2) exact division
        apply_vector(16'h0120, 8'h04, "120 / 4 (exact)");

        // 3) non-exact division
        apply_vector(16'h0456, 8'h07, "456 / 7 (remainder)");

        // 4) dividend with leading zeros
        apply_vector(16'h0009, 8'h03, "9 / 3 (single-digit)");

        // 5) maximum BCD digits (9999 / 99)
        apply_vector(16'h9999, 8'h99, "9999 / 99 (boundary)");

        // 6) divisor = 0 (should be handled)
        apply_vector(16'h1234, 8'h00, "1234 / 0 (division by zero)");

        // 7) divisors with single-digit first nibble zero (v1=0 case handled by algorithm)
        apply_vector(16'h0306, 8'h06, "306 / 6 (v1 might be non-zero)");

        $display("All vectors applied.\n");
        $finish;
    end

endmodule
