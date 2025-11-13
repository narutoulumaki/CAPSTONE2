/**
 * Comprehensive Testbench for All Division Algorithms
 * 
 * This testbench instantiates and tests:
 * 1. Vedic BCD Divider (Combinational)
 * 2. Vedic BCD Divider (Pipelined)
 * 3. Binary Non-Restoring Divider (Combinational)
 * 4. Binary Non-Restoring Divider (Pipelined)
 * 5. Binary Restoring Divider (Combinational)
 * 6. Binary Restoring Divider (Pipelined)
 * 7. Binary SRT Divider (Combinational)
 * 8. Binary SRT Divider (Pipelined)
 * 
 * Test Cases:
 * - Standard division cases
 * - Division by zero
 * - Edge cases (max values, small dividends)
 * 
 * Compares results across all implementations
 */

`timescale 1ns / 1ps

module tb_all_dividers;

    // Pipeline latency parameter for pipelined dividers
    parameter int PIPELINE_LATENCY = 4;

    // Clock and reset for pipelined implementations
    logic clk;
    logic rst_n;
    
    // Common test inputs
    logic [15:0] dividend;
    logic [7:0]  divisor;
    
    // Vedic BCD outputs (combinational)
    logic [15:0] vedic_bcd_quotient;
    logic [7:0]  vedic_bcd_remainder;
    logic        vedic_bcd_div_by_zero;
    logic        vedic_bcd_done;
    
    // Vedic BCD outputs (pipelined)
    logic [15:0] vedic_bcd_pipe_quotient;
    logic [7:0]  vedic_bcd_pipe_remainder;
    logic        vedic_bcd_pipe_div_by_zero;
    logic        vedic_bcd_pipe_done;
    
    // Binary Non-Restoring outputs (combinational)
    logic [15:0] bin_nr_quotient;
    logic [7:0]  bin_nr_remainder;
    logic        bin_nr_div_by_zero;
    
    // Binary Non-Restoring outputs (pipelined)
    logic [15:0] bin_nr_pipe_quotient;
    logic [7:0]  bin_nr_pipe_remainder;
    logic        bin_nr_pipe_div_by_zero;
    
    // Binary Restoring outputs (combinational)
    logic [15:0] bin_rest_quotient;
    logic [7:0]  bin_rest_remainder;
    logic        bin_rest_div_by_zero;
    
    // Binary Restoring outputs (pipelined)
    logic [15:0] bin_rest_pipe_quotient;
    logic [7:0]  bin_rest_pipe_remainder;
    logic        bin_rest_pipe_div_by_zero;
    
    // Binary SRT outputs (combinational)
    logic [15:0] bin_srt_quotient;
    logic [7:0]  bin_srt_remainder;
    logic        bin_srt_div_by_zero;
    
    // Binary SRT outputs (pipelined)
    logic [15:0] bin_srt_pipe_quotient;
    logic [7:0]  bin_srt_pipe_remainder;
    logic        bin_srt_pipe_div_by_zero;
    
    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    //==========================================================================
    // DUT Instantiations
    //==========================================================================
    
    // Vedic BCD Divider (Combinational)
    vedicdivider_dhwajank u_vedic_bcd (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(vedic_bcd_quotient),
        .remainder(vedic_bcd_remainder),
        .div_by_zero(vedic_bcd_div_by_zero),
        .done(vedic_bcd_done)
    );
    
    // Vedic BCD Divider (Pipelined)
    vedicdivider_dhwajank_pipelined u_vedic_bcd_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(vedic_bcd_pipe_quotient),
        .remainder(vedic_bcd_pipe_remainder),
        .div_by_zero(vedic_bcd_pipe_div_by_zero),
        .done(vedic_bcd_pipe_done)
    );
    
    // Binary Non-Restoring Divider (Combinational)
    binary_nonrestoring_divider u_bin_nr (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_nr_quotient),
        .remainder(bin_nr_remainder),
        .div_by_zero(bin_nr_div_by_zero)
    );
    
    // Binary Non-Restoring Divider (Pipelined)
    binary_nonrestoring_divider_pipelined u_bin_nr_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_nr_pipe_quotient),
        .remainder(bin_nr_pipe_remainder),
        .div_by_zero(bin_nr_pipe_div_by_zero)
    );
    
    // Binary Restoring Divider (Combinational)
    binary_restoring_divider u_bin_rest (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_rest_quotient),
        .remainder(bin_rest_remainder),
        .div_by_zero(bin_rest_div_by_zero)
    );
    
    // Binary Restoring Divider (Pipelined)
    binary_restoring_divider_pipelined u_bin_rest_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_rest_pipe_quotient),
        .remainder(bin_rest_pipe_remainder),
        .div_by_zero(bin_rest_pipe_div_by_zero)
    );
    
    // Binary SRT Divider (Combinational)
    binary_srt_divider u_bin_srt (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_srt_quotient),
        .remainder(bin_srt_remainder),
        .div_by_zero(bin_srt_div_by_zero)
    );
    
    // Binary SRT Divider (Pipelined)
    binary_srt_divider_pipelined u_bin_srt_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_srt_pipe_quotient),
        .remainder(bin_srt_pipe_remainder),
        .div_by_zero(bin_srt_pipe_div_by_zero)
    );
    
    //==========================================================================
    // Helper Functions
    //==========================================================================
    
    // Convert BCD to binary, with validity check
    function automatic logic [15:0] bcd_to_binary(input logic [15:0] bcd_val);
        logic [15:0] result;
        if ((bcd_val[15:12] > 9) || (bcd_val[11:8] > 9) ||
            (bcd_val[7:4] > 9) || (bcd_val[3:0] > 9)) begin
            result = 16'd0; // or use 'x if you want to indicate error
        end else begin
            result = (bcd_val[15:12] * 1000) + (bcd_val[11:8] * 100) +
    // Converts a 16-bit binary value to BCD representation.
    // Note: This function supports up to 4 BCD digits (max value 9999).
    // For values above 9999, the result will not be a valid BCD encoding.
    function automatic logic [15:0] binary_to_bcd(input logic [15:0] bin_val);
        logic [15:0] result;
        logic [15:0] temp;
        temp = bin_val;
        result[3:0]   = temp % 10; temp = temp / 10;
        result[7:4]   = temp % 10; temp = temp / 10;
        result[11:8]  = temp % 10; temp = temp / 10;
        result[15:12] = temp % 10;
        return result;
    endfunction
        result[7:4]   = temp % 10; temp = temp / 10;
        result[11:8]  = temp % 10; temp = temp / 10;
        result[15:12] = temp % 10;
        return result;
    endfunction
    
    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        // Initialize
        rst_n = 0;
        dividend = 16'b0;
        divisor = 8'b0;
        
        // VCD dump for waveform viewing
        $dumpfile("all_dividers_tb.vcd");
        $dumpvars(0, tb_all_dividers);
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        $display("========================================");
        $display("Testing All Division Algorithms");
        $display("========================================");
        $display("");
        
        // Test Case 1: Standard division (9876 ÷ 45 in BCD = 39321 ÷ 45 in binary)
        $display("Test 1: 9876 (BCD) / 45 (BCD) = 39321 (binary) / 45 (binary)");
        dividend = 16'h9876; // BCD for Vedic, binary for others
        divisor = 8'h45;     // BCD for Vedic, binary for others
        test_division(39321, 45, "9876÷45 (BCD) vs 39321÷45 (binary)");
        
        // Test Case 2: Simple binary division
        $display("Test 2: 1000 / 25");
        dividend = 16'd1000;
        divisor = 8'd25;
        test_division(1000, 25, "1000÷25");
        
        // Test Case 3: Division with remainder
        $display("Test 3: 12345 / 67");
        dividend = 16'd12345;
        divisor = 8'd67;
        test_division(12345, 67, "12345÷67");
        
        // Test Case 4: Small dividend
        $display("Test 4: 50 / 10");
        dividend = 16'd50;
        divisor = 8'd10;
        test_division(50, 10, "50÷10");
        
        // Test Case 5: Maximum values
        $display("Test 5: 65535 / 255");
        dividend = 16'd65535;
        divisor = 8'd255;
        test_division(65535, 255, "65535÷255 (max values)");
        
        // Test Case 6: Dividend < Divisor
        $display("Test 6: 25 / 100");
        dividend = 16'd25;
        divisor = 8'd100;
        test_division(25, 100, "25÷100 (dividend < divisor)");
        
        // Test Case 7: Division by 1
        $display("Test 7: 12345 / 1");
        dividend = 16'd12345;
        divisor = 8'd1;
        test_division(12345, 1, "12345÷1");
        
        // Test Case 8: Division by zero
        $display("Test 8: 1000 / 0 (Division by zero)");
        dividend = 16'd1000;
        divisor = 8'd0;
        test_division_by_zero();
        
        // Test Case 9: Zero dividend
        $display("Test 9: 0 / 50");
        dividend = 16'd0;
        divisor = 8'd50;
        test_division(0, 50, "0÷50");
        
        // Test Case 10: Power of 2 divisor
        $display("Test 10: 1024 / 16");
        dividend = 16'd1024;
        divisor = 8'd16;
        test_division(1024, 16, "1024÷16 (power of 2)");
        
        $display("");
        $display("========================================");
        $display("All tests completed!");
        $display("========================================");
        
        #100;
        $finish;
    end
    
    //==========================================================================
    // Test Tasks
    task test_division(input logic [15:0] expected_dividend_bin, input logic [7:0] expected_divisor_bin, input string test_name);
        logic [15:0] expected_quotient;
        logic [7:0]  expected_remainder;
        int error_count;
        
        if (expected_divisor_bin == 0) begin
            expected_quotient = 16'd0;
            expected_remainder = 8'd0;
            $display("  [WARNING] Division by zero detected in test_division task. Setting expected quotient and remainder to 0.");
        end else begin
            expected_quotient = expected_dividend_bin / expected_divisor_bin;
            expected_remainder = expected_dividend_bin % expected_divisor_bin;
        end
        
        // Wait for combinational results
        #1;
        
        $display("  %s", test_name);
        $display("  Expected: Q=%0d, R=%0d", expected_quotient, expected_remainder);
        $display("  %s", test_name);
        $display("  Expected: Q=%0d, R=%0d", expected_quotient, expected_remainder);
        
        error_count = 0;
        
        // Check Binary Non-Restoring (Combinational)
        if (bin_nr_quotient !== expected_quotient || bin_nr_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary Non-Restoring (Comb): Q=%0d, R=%0d", bin_nr_quotient, bin_nr_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary Non-Restoring (Comb): Q=%0d, R=%0d", bin_nr_quotient, bin_nr_remainder);
        end
        
        // Check Binary Restoring (Combinational)
        if (bin_rest_quotient !== expected_quotient || bin_rest_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary Restoring (Comb): Q=%0d, R=%0d", bin_rest_quotient, bin_rest_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary Restoring (Comb): Q=%0d, R=%0d", bin_rest_quotient, bin_rest_remainder);
        end
        
        // Check Binary SRT (Combinational)
        if (bin_srt_quotient !== expected_quotient || bin_srt_remainder !== expected_remainder) begin
        // Wait for pipelined results (parameterized latency)
        repeat(PIPELINE_LATENCY) @(posedge clk);
        #1;
        
        // Check Binary Non-Restoring (Pipelined)
        if (bin_nr_pipe_quotient !== expected_quotient || bin_nr_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
        end
        if (bin_nr_pipe_quotient !== expected_quotient || bin_nr_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
        end
        
        // Check Binary Restoring (Pipelined)
        if (bin_rest_pipe_quotient !== expected_quotient || bin_rest_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary Restoring (Pipe): Q=%0d, R=%0d", bin_rest_pipe_quotient, bin_rest_pipe_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary Restoring (Pipe): Q=%0d, R=%0d", bin_rest_pipe_quotient, bin_rest_pipe_remainder);
        end
        
        // Check Binary SRT (Pipelined)
        if (bin_srt_pipe_quotient !== expected_quotient || bin_srt_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Binary SRT (Pipe): Q=%0d, R=%0d", bin_srt_pipe_quotient, bin_srt_pipe_remainder);
            error_count++;
        end else begin
            $display("  [PASS] Binary SRT (Pipe): Q=%0d, R=%0d", bin_srt_pipe_quotient, bin_srt_pipe_remainder);
        $display("  [INFO] Vedic BCD (Comb): Q=%h (BCD), R=%h (BCD)", vedic_bcd_quotient, vedic_bcd_remainder);
        $display("  [INFO] Vedic BCD (Pipe): Q=%h (BCD), R=%h (BCD)", vedic_bcd_pipe_quotient, vedic_bcd_pipe_remainder);
        $display("  [NOTE] Vedic BCD results are in BCD format and not directly comparable to binary results above.");
        // Note: Vedic dividers work with BCD, so results will differ
        $display("  [INFO] Vedic BCD (Comb): Q=%h (BCD), R=%h (BCD)", vedic_bcd_quotient, vedic_bcd_remainder);
        $display("  [INFO] Vedic BCD (Pipe): Q=%h (BCD), R=%h (BCD)", vedic_bcd_pipe_quotient, vedic_bcd_pipe_remainder);
        
        if (error_count == 0) begin
            $display("  ✓ All binary algorithms passed!");
        end else begin
            $display("  ✗ %0d algorithm(s) failed", error_count);
        end
        
        $display("");
        
        // Small delay between tests
        #10;
    endtask
    
    task test_division_by_zero();
        // Wait for combinational results
        #1;
        
        $display("  Testing divide by zero handling...");
        // Check all dividers set div_by_zero flag
        if (bin_nr_div_by_zero) $display("  [PASS] Binary Non-Restoring (Comb): div_by_zero asserted");
        else $display("  [FAIL] Binary Non-Restoring (Comb): div_by_zero not asserted");

        if (vedic_bcd_div_by_zero) $display("  [PASS] Vedic BCD (Comb): div_by_zero asserted");
        else $display("  [FAIL] Vedic BCD (Comb): div_by_zero not asserted");

        // Wait for pipelined results
        repeat(PIPELINE_LATENCY) @(posedge clk);
        #1;

        if (bin_nr_pipe_div_by_zero) $display("  [PASS] Binary Non-Restoring (Pipe): div_by_zero asserted");
        else $display("  [FAIL] Binary Non-Restoring (Pipe): div_by_zero not asserted");

        if (vedic_bcd_pipe_div_by_zero) $display("  [PASS] Vedic BCD (Pipe): div_by_zero asserted");
        else $display("  [FAIL] Vedic BCD (Pipe): div_by_zero not asserted");

        if (bin_rest_pipe_div_by_zero) $display("  [PASS] Binary Restoring (Pipe): div_by_zero asserted");
        else $display("  [FAIL] Binary Restoring (Pipe): div_by_zero not asserted");

        if (bin_srt_pipe_div_by_zero) $display("  [PASS] Binary SRT (Pipe): div_by_zero asserted");
        else $display("  [FAIL] Binary SRT (Pipe): div_by_zero not asserted");

        $display("");
        #10;
        #10;
    endtask

endmodule
