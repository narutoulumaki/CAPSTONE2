/**
 * Testbench for Binary Division Algorithms
 * Tests all 6 implementations: 3 combinational + 3 pipelined
 */

module tb_binary_dividers;

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Test inputs
    logic [15:0] dividend;
    logic [7:0]  divisor;
    
    // Outputs for Non-Restoring Divider (Combinational)
    logic [15:0] bin_nr_quotient;
    logic [7:0]  bin_nr_remainder;
    logic        bin_nr_div_by_zero;
    
    // Outputs for Non-Restoring Divider (Pipelined)
    logic [15:0] bin_nr_pipe_quotient;
    logic [7:0]  bin_nr_pipe_remainder;
    logic        bin_nr_pipe_div_by_zero;
    
    // Outputs for Restoring Divider (Combinational)
    logic [15:0] bin_rest_quotient;
    logic [7:0]  bin_rest_remainder;
    logic        bin_rest_div_by_zero;
    
    // Outputs for Restoring Divider (Pipelined)
    logic [15:0] bin_rest_pipe_quotient;
    logic [7:0]  bin_rest_pipe_remainder;
    logic        bin_rest_pipe_div_by_zero;
    
    // Outputs for SRT Divider (Combinational)
    logic [15:0] bin_srt_quotient;
    logic [7:0]  bin_srt_remainder;
    logic        bin_srt_div_by_zero;
    
    // Outputs for SRT Divider (Pipelined)
    logic [15:0] bin_srt_pipe_quotient;
    logic [7:0]  bin_srt_pipe_remainder;
    logic        bin_srt_pipe_div_by_zero;
    
    // Test statistics
    int total_tests = 0;
    int passed_tests = 0;
    int failed_tests = 0;
    
    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    //==========================================================================
    // DUT Instantiations
    //==========================================================================
    
    // Binary Non-Restoring Divider (Combinational)
    binary_nonrestoring_divider_v2 u_bin_nr (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_nr_quotient),
        .remainder(bin_nr_remainder),
        .div_by_zero(bin_nr_div_by_zero)
    );
    
    // Binary Non-Restoring Divider (Pipelined)
    binary_nonrestoring_divider_pipelined_v2 u_bin_nr_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_nr_pipe_quotient),
        .remainder(bin_nr_pipe_remainder),
        .div_by_zero(bin_nr_pipe_div_by_zero)
    );
    
    // Binary Restoring Divider (Combinational)
    binary_restoring_divider_v2 u_bin_rest (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_rest_quotient),
        .remainder(bin_rest_remainder),
        .div_by_zero(bin_rest_div_by_zero)
    );
    
    // Binary Restoring Divider (Pipelined)
    binary_restoring_divider_pipelined_v2 u_bin_rest_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_rest_pipe_quotient),
        .remainder(bin_rest_pipe_remainder),
        .div_by_zero(bin_rest_pipe_div_by_zero)
    );
    
    // Binary SRT Divider (Combinational)
    binary_srt_divider_v2 u_bin_srt (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_srt_quotient),
        .remainder(bin_srt_remainder),
        .div_by_zero(bin_srt_div_by_zero)
    );
    
    // Binary SRT Divider (Pipelined)
    binary_srt_divider_pipelined_v2 u_bin_srt_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(bin_srt_pipe_quotient),
        .remainder(bin_srt_pipe_remainder),
        .div_by_zero(bin_srt_pipe_div_by_zero)
    );
    
    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        // Initialize
        rst_n = 0;
        dividend = 16'b0;
        divisor = 8'b0;
        total_tests = 0;
        passed_tests = 0;
        failed_tests = 0;
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        $display("========================================");
        $display("Testing Binary Division Algorithms");
        $display("========================================");
        $display("");
        
        // Run test cases
        test_division(100, 10, "100 ÷ 10");
        test_division(1000, 27, "1000 ÷ 27");
        test_division(50000, 123, "50000 ÷ 123");
        test_division(65535, 255, "65535 ÷ 255");
        test_division(50, 200, "50 ÷ 200");
        test_division(12345, 1, "12345 ÷ 1");
        test_division(1024, 2, "1024 ÷ 2");
        test_division(4096, 16, "4096 ÷ 16");
        test_division(32768, 128, "32768 ÷ 128");
        test_division(9973, 97, "9973 ÷ 97");
        test_division(0, 50, "0 ÷ 50");
        test_division(7, 3, "7 ÷ 3");
        test_division(255, 255, "255 ÷ 255");
        test_division(100, 99, "100 ÷ 99");
        test_division(1000, 253, "1000 ÷ 253");
        test_division_by_zero(1000, "1000 ÷ 0");
        test_division(16383, 127, "16383 ÷ 127");
        test_division(32767, 181, "32767 ÷ 181");
        test_division(9999, 11, "9999 ÷ 11");
        test_division(8888, 88, "8888 ÷ 88");
        
        $display("");
        $display("========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", total_tests);
        $display("  Passed: %0d", passed_tests);
        $display("  Failed: %0d", failed_tests);
        if (failed_tests == 0)
            $display("  ✓ ALL TESTS PASSED!");
        else
            $display("  ✗ SOME TESTS FAILED!");
        $display("========================================");
        
        #100;
        $finish;
    end
    
    //==========================================================================
    // Test Tasks
    //==========================================================================
    
    task test_division(input logic [15:0] test_dividend, input logic [7:0] test_divisor, input string test_name);
        logic [15:0] expected_quotient;
        logic [7:0]  expected_remainder;
        int errors;
        
        dividend = test_dividend;
        divisor = test_divisor;
        
        expected_quotient = test_dividend / test_divisor;
        expected_remainder = test_dividend % test_divisor;
        
        // Wait for combinational results
        #1;
        
        $display("Test: %s", test_name);
        $display("  Input: Dividend=%0d, Divisor=%0d", test_dividend, test_divisor);
        $display("  Expected: Q=%0d, R=%0d", expected_quotient, expected_remainder);
        
        errors = 0;
        
        // Check Combinational implementations
        if (bin_nr_quotient !== expected_quotient || bin_nr_remainder !== expected_remainder) begin
            $display("  [FAIL] Non-Restoring (Comb): Q=%0d, R=%0d", bin_nr_quotient, bin_nr_remainder);
            errors++;
        end else begin
            $display("  [PASS] Non-Restoring (Comb): Q=%0d, R=%0d", bin_nr_quotient, bin_nr_remainder);
        end
        
        if (bin_rest_quotient !== expected_quotient || bin_rest_remainder !== expected_remainder) begin
            $display("  [FAIL] Restoring (Comb): Q=%0d, R=%0d", bin_rest_quotient, bin_rest_remainder);
            errors++;
        end else begin
            $display("  [PASS] Restoring (Comb): Q=%0d, R=%0d", bin_rest_quotient, bin_rest_remainder);
        end
        
        if (bin_srt_quotient !== expected_quotient || bin_srt_remainder !== expected_remainder) begin
            $display("  [FAIL] SRT (Comb): Q=%0d, R=%0d", bin_srt_quotient, bin_srt_remainder);
            errors++;
        end else begin
            $display("  [PASS] SRT (Comb): Q=%0d, R=%0d", bin_srt_quotient, bin_srt_remainder);
        end
        
        // Wait for pipelined results (4 cycles latency)
        repeat(4) @(posedge clk);
        #1;
        
        // Check Pipelined implementations
        if (bin_nr_pipe_quotient !== expected_quotient || bin_nr_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
            errors++;
        end else begin
            $display("  [PASS] Non-Restoring (Pipe): Q=%0d, R=%0d", bin_nr_pipe_quotient, bin_nr_pipe_remainder);
        end
        
        if (bin_rest_pipe_quotient !== expected_quotient || bin_rest_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] Restoring (Pipe): Q=%0d, R=%0d", bin_rest_pipe_quotient, bin_rest_pipe_remainder);
            errors++;
        end else begin
            $display("  [PASS] Restoring (Pipe): Q=%0d, R=%0d", bin_rest_pipe_quotient, bin_rest_pipe_remainder);
        end
        
        if (bin_srt_pipe_quotient !== expected_quotient || bin_srt_pipe_remainder !== expected_remainder) begin
            $display("  [FAIL] SRT (Pipe): Q=%0d, R=%0d", bin_srt_pipe_quotient, bin_srt_pipe_remainder);
            errors++;
        end else begin
            $display("  [PASS] SRT (Pipe): Q=%0d, R=%0d", bin_srt_pipe_quotient, bin_srt_pipe_remainder);
        end
        
        total_tests++;
        if (errors == 0) begin
            $display("  ✓ All algorithms passed!");
            passed_tests++;
        end else begin
            $display("  ✗ %0d algorithm(s) failed!", errors);
            failed_tests++;
        end
        
        $display("");
        #10;
    endtask
    
    task test_division_by_zero(input logic [15:0] test_dividend, input string test_name);
        int errors;
        
        dividend = test_dividend;
        divisor = 8'd0;
        
        // Wait for combinational results
        #1;
        
        $display("Test: %s (Division by Zero)", test_name);
        $display("  Input: Dividend=%0d, Divisor=0", test_dividend);
        
        errors = 0;
        
        // Check combinational implementations
        if (bin_nr_div_by_zero)
            $display("  [PASS] Non-Restoring (Comb): div_by_zero asserted");
        else begin
            $display("  [FAIL] Non-Restoring (Comb): div_by_zero NOT asserted");
            errors++;
        end
        
        if (bin_rest_div_by_zero)
            $display("  [PASS] Restoring (Comb): div_by_zero asserted");
        else begin
            $display("  [FAIL] Restoring (Comb): div_by_zero NOT asserted");
            errors++;
        end
        
        if (bin_srt_div_by_zero)
            $display("  [PASS] SRT (Comb): div_by_zero asserted");
        else begin
            $display("  [FAIL] SRT (Comb): div_by_zero NOT asserted");
            errors++;
        end
        
        // Wait for pipelined results
        repeat(4) @(posedge clk);
        #1;
        
        // Check pipelined implementations
        if (bin_nr_pipe_div_by_zero)
            $display("  [PASS] Non-Restoring (Pipe): div_by_zero asserted");
        else begin
            $display("  [FAIL] Non-Restoring (Pipe): div_by_zero NOT asserted");
            errors++;
        end
        
        if (bin_rest_pipe_div_by_zero)
            $display("  [PASS] Restoring (Pipe): div_by_zero asserted");
        else begin
            $display("  [FAIL] Restoring (Pipe): div_by_zero NOT asserted");
            errors++;
        end
        
        if (bin_srt_pipe_div_by_zero)
            $display("  [PASS] SRT (Pipe): div_by_zero asserted");
        else begin
            $display("  [FAIL] SRT (Pipe): div_by_zero NOT asserted");
            errors++;
        end
        
        total_tests++;
        if (errors == 0) begin
            $display("  ✓ All algorithms handled div-by-zero correctly!");
            passed_tests++;
        end else begin
            $display("  ✗ %0d algorithm(s) failed!", errors);
            failed_tests++;
        end
        
        $display("");
        #10;
    endtask

endmodule
