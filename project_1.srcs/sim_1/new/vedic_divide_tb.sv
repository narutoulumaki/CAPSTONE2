`timescale 1ns / 1ps

module vedicdivider_tb;
    // Inputs
    logic [15:0] dividend;
    logic [7:0] divisor;
    
    // Outputs
    logic [11:0] quotient;
    logic [7:0] remainder;
    
    // Counters for pass/fail
    int pass_count = 0;
    int fail_count = 0;
    
    // Instantiate the module
    vedicdivider_dhwajank dut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );
    
    // Test case function
    task test_case(
        input [15:0] div,
        input [7:0] dsr,
        input [11:0] expected_q,
        input [7:0] expected_r,
        input string test_name
    );
        int div_dec, dsr_dec, exp_q_dec, exp_r_dec, q_dec, r_dec;
        
        // Apply inputs
        dividend = div;
        divisor = dsr;
        
        // Wait for combinational logic to settle
        #10;
        
        // Convert BCD to decimal for display
        div_dec = div[3:0] + div[7:4]*10 + div[11:8]*100 + div[15:12]*1000;
        dsr_dec = dsr[3:0] + dsr[7:4]*10;
        exp_q_dec = expected_q[3:0] + expected_q[7:4]*10 + expected_q[11:8]*100;
        exp_r_dec = expected_r[3:0] + expected_r[7:4]*10;
        q_dec = quotient[3:0] + quotient[7:4]*10 + quotient[11:8]*100;
        r_dec = remainder[3:0] + remainder[7:4]*10;
        
        // Display results
        $display("\n%s:", test_name);
        $display("Dividend = %0d (BCD: %h)", div_dec, div);
        $display("Divisor  = %0d (BCD: %h)", dsr_dec, dsr);
        $display("Expected: Quotient = %0d (BCD: %h), Remainder = %0d (BCD: %h)", 
                 exp_q_dec, expected_q, exp_r_dec, expected_r);
        $display("Actual:   Quotient = %0d (BCD: %h), Remainder = %0d (BCD: %h)", 
                 q_dec, quotient, r_dec, remainder);
        
        // Check results
        if (quotient === expected_q && remainder === expected_r) begin
            $display("PASS");
            pass_count++;
        end else begin
            $display("FAIL");
            fail_count++;
        end
    endtask
    
    // Test cases
    initial begin
        $display("=== Vedic Divider Testbench ===");
        
        // Test Case 1: 1 ÷ 1 = 1 R 0
        test_case(16'h0001, 8'h01, 12'h001, 8'h00, "Test Case 1: 1 ÷ 1");
        
        // Test Case 2: 16 ÷ 4 = 4 R 0
        test_case(16'h0016, 8'h04, 12'h004, 8'h00, "Test Case 2: 16 ÷ 4");
        
        // Test Case 3: 379 ÷ 47 = 8 R 3
        test_case(16'h0379, 8'h47, 12'h008, 8'h03, "Test Case 3: 379 ÷ 47");
        
        // Test Case 4: 123 ÷ 12 = 10 R 3
        test_case(16'h0123, 8'h12, 12'h010, 8'h03, "Test Case 4: 123 ÷ 12");
        
        // Test Case 5: 999 ÷ 99 = 10 R 9
        test_case(16'h0999, 8'h99, 12'h010, 8'h09, "Test Case 5: 999 ÷ 99");
        
        // Test Case 6: Division by zero
        test_case(16'h0500, 8'h00, 12'h000, 8'h00, "Test Case 6: Division by zero");
        
        // Test Case 7: 456 ÷ 78 = 5 R 66
        test_case(16'h0456, 8'h78, 12'h005, 8'h66, "Test Case 7: 456 ÷ 78");
        
        // Edge Case 8: 9999 ÷ 99 = 101 R 0
        test_case(16'h9999, 8'h99, 12'h101, 8'h00, "Test Case 8: 9999 ÷ 99");
        
        // Additional Test Case 9: 845 ÷ 65 = 13 R 0
        test_case(16'h0845, 8'h65, 12'h013, 8'h00, "Test Case 9: 845 ÷ 65");
        
        // Additional Test Case 10: 729 ÷ 27 = 27 R 0
        test_case(16'h0729, 8'h27, 12'h027, 8'h00, "Test Case 10: 729 ÷ 27");
        
        // Additional Test Case 11: 888 ÷ 88 = 10 R 8
        test_case(16'h0888, 8'h88, 12'h010, 8'h08, "Test Case 11: 888 ÷ 88");
        
        // Additional Test Case 12: 2468 ÷ 34 = 72 R 20
        test_case(16'h2468, 8'h34, 12'h072, 8'h20, "Test Case 12: 2468 ÷ 34");
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", pass_count + fail_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        $finish;
    end
endmodule