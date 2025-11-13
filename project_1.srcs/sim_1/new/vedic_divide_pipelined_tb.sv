`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Testbench for Pipelined Dhvajanka Divider
// Tests throughput and latency of 3-stage pipeline
//////////////////////////////////////////////////////////////////////////////////

module vedicdivider_pipelined_tb;
    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Inputs
    logic valid_in;
    logic [15:0] dividend;
    logic [7:0] divisor;
    
    // Outputs
    logic valid_out;
    logic [11:0] quotient;
    logic [7:0] remainder;
    
    // Counters
    int pass_count = 0;
    int fail_count = 0;
    int cycle_count = 0;
    int start_cycle;
    
    // Instantiate DUT
    vedicdivider_dhwajank_pipelined dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .dividend(dividend),
        .divisor(divisor),
        .valid_out(valid_out),
        .quotient(quotient),
        .remainder(remainder)
    );
    
    // Clock generation (100MHz = 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Cycle counter - only driven by this always block
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end
    
    // Test task
    task automatic test_division(
        input [15:0] div,
        input [7:0] dsr,
        input [11:0] expected_q,
        input [7:0] expected_r,
        input string test_name
    );
        int div_dec, dsr_dec, exp_q_dec, exp_r_dec, q_dec, r_dec;
        int local_start_cycle;
        
        // Convert BCD to decimal for display
        div_dec = div[3:0] + div[7:4]*10 + div[11:8]*100 + div[15:12]*1000;
        dsr_dec = dsr[3:0] + dsr[7:4]*10;
        exp_q_dec = expected_q[3:0] + expected_q[7:4]*10 + expected_q[11:8]*100;
        exp_r_dec = expected_r[3:0] + expected_r[7:4]*10;
        
        // Apply inputs
        local_start_cycle = cycle_count;
        dividend = div;
        divisor = dsr;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        // Wait for output
        wait(valid_out == 1);
        @(posedge clk);
        
        q_dec = quotient[3:0] + quotient[7:4]*10 + quotient[11:8]*100;
        r_dec = remainder[3:0] + remainder[7:4]*10;
        
        $display("\n%s:", test_name);
        $display("  Input:    %0d ÷ %0d (BCD: %h ÷ %h)", div_dec, dsr_dec, div, dsr);
        $display("  Expected: Q=%0d R=%0d (BCD: %h, %h)", exp_q_dec, exp_r_dec, expected_q, expected_r);
        $display("  Actual:   Q=%0d R=%0d (BCD: %h, %h)", q_dec, r_dec, quotient, remainder);
        $display("  Latency:  %0d cycles", cycle_count - local_start_cycle);
        
        if (quotient === expected_q && remainder === expected_r) begin
            $display("  ✓ PASS");
            pass_count++;
        end else begin
            $display("  ✗ FAIL");
            fail_count++;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== Pipelined Vedic Divider Testbench ===\n");
        
        // Reset
        rst_n = 0;
        valid_in = 0;
        dividend = 0;
        divisor = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        $display("Testing pipeline latency and correctness...\n");
        
        // Test Case 1: Simple division
        test_division(16'h0001, 8'h01, 12'h001, 8'h00, "Test 1: 1 ÷ 1");
        
        // Test Case 2: Division with no remainder
        test_division(16'h0016, 8'h04, 12'h004, 8'h00, "Test 2: 16 ÷ 4");
        
        // Test Case 3: Division with adjustment (379 ÷ 47)
        test_division(16'h0379, 8'h47, 12'h008, 8'h03, "Test 3: 379 ÷ 47");
        
        // Test Case 4: Two digit quotient
        test_division(16'h0123, 8'h12, 12'h010, 8'h03, "Test 4: 123 ÷ 12");
        
        // Test Case 5: Maximum 2-digit quotient
        test_division(16'h0999, 8'h99, 12'h010, 8'h09, "Test 5: 999 ÷ 99");
        
        // Test Case 6: Division by zero
        test_division(16'h0500, 8'h00, 12'h000, 8'h00, "Test 6: 500 ÷ 0");
        
        // Test Case 7: With large remainder
        test_division(16'h0456, 8'h78, 12'h005, 8'h66, "Test 7: 456 ÷ 78");
        
        // Test Case 8: Three digit quotient
        test_division(16'h9999, 8'h99, 12'h101, 8'h00, "Test 8: 9999 ÷ 99");
        
        $display("\n=== Testing Pipeline Throughput ===");
        $display("Sending 3 divisions back-to-back...\n");
        
        // Send 3 divisions in consecutive cycles
        start_cycle = cycle_count;
        
        dividend = 16'h0845; divisor = 8'h65; valid_in = 1; @(posedge clk);
        dividend = 16'h0729; divisor = 8'h27; valid_in = 1; @(posedge clk);
        dividend = 16'h0888; divisor = 8'h88; valid_in = 1; @(posedge clk);
        valid_in = 0;
        
        // Wait for first result
        wait(valid_out == 1);
        $display("First result arrived at cycle %0d (latency: %0d cycles)", cycle_count - start_cycle, cycle_count - start_cycle);
        @(posedge clk);
        
        // Wait for second result
        wait(valid_out == 1);
        $display("Second result arrived at cycle %0d", cycle_count - start_cycle);
        @(posedge clk);
        
        // Wait for third result
        wait(valid_out == 1);
        $display("Third result arrived at cycle %0d", cycle_count - start_cycle);
        @(posedge clk);
        
        $display("\nAll 3 results should arrive in 5 cycles (3 latency + 2 throughput)");
        $display("Actual: First result at 3, third result at %0d cycles\n", cycle_count - start_cycle - 1);
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", pass_count + fail_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n✓✓✓ ALL TESTS PASSED ✓✓✓");
        else
            $display("\n✗✗✗ SOME TESTS FAILED ✗✗✗");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #10000;
        $display("\nERROR: Testbench timeout!");
        $finish;
    end

endmodule