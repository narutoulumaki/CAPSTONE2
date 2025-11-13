`timescale 1ns / 1ps

module vedicdivider_dhwajank_pipelined_opt_tb;

    logic clk;
    logic rst_n;
    logic valid_in;
    logic [15:0] dividend;
    logic [7:0] divisor;
    logic valid_out;
    logic [11:0] quotient;
    logic [7:0] remainder;

    vedicdivider_dhwajank_pipelined_opt dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .dividend(dividend),
        .divisor(divisor),
        .valid_out(valid_out),
        .quotient(quotient),
        .remainder(remainder)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        int passed = 0;
        int failed = 0;
        
        rst_n = 0;
        valid_in = 0;
        dividend = 0;
        divisor = 0;
        
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test 1: 0001 ÷ 0001 = Q:001 R:00
        $display("\n=== Test 1: 1 ÷ 1 ===");
        dividend = 16'h0001;
        divisor = 8'h01;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h001 && remainder == 8'h00) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:001 R:00"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 2: 0016 ÷ 0004 = Q:004 R:00
        $display("\n=== Test 2: 16 ÷ 4 ===");
        dividend = 16'h0016;
        divisor = 8'h04;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h004 && remainder == 8'h00) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:004 R:00"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 3: 0379 ÷ 0047 = Q:008 R:03
        $display("\n=== Test 3: 379 ÷ 47 ===");
        dividend = 16'h0379;
        divisor = 8'h47;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h008 && remainder == 8'h03) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:008 R:03"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 4: 0123 ÷ 0012 = Q:010 R:03
        $display("\n=== Test 4: 123 ÷ 12 ===");
        dividend = 16'h0123;
        divisor = 8'h12;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h010 && remainder == 8'h03) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:010 R:03"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 5: 0999 ÷ 0099 = Q:010 R:09
        $display("\n=== Test 5: 999 ÷ 99 ===");
        dividend = 16'h0999;
        divisor = 8'h99;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h010 && remainder == 8'h09) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:010 R:09"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 6: 0500 ÷ 0000 = Q:000 R:00 (division by zero)
        $display("\n=== Test 6: 500 ÷ 0 (div by zero) ===");
        dividend = 16'h0500;
        divisor = 8'h00;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h000 && remainder == 8'h00) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:000 R:00"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 7: 0456 ÷ 0078 = Q:005 R:66
        $display("\n=== Test 7: 456 ÷ 78 ===");
        dividend = 16'h0456;
        divisor = 8'h78;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h005 && remainder == 8'h66) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:005 R:66"); failed++;
        end
        
        repeat(5) @(posedge clk);
        
        // Test 8: 9999 ÷ 0099 = Q:101 R:00
        $display("\n=== Test 8: 9999 ÷ 99 ===");
        dividend = 16'h9999;
        divisor = 8'h99;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;
        
        wait(valid_out);
        @(posedge clk);
        $display("Quotient: %03h, Remainder: %02h", quotient, remainder);
        if (quotient == 12'h101 && remainder == 8'h00) begin
            $display("PASS"); passed++;
        end else begin
            $display("FAIL - Expected Q:101 R:00"); failed++;
        end
        
        $display("\n====================================");
        $display("Tests Passed: %0d/8", passed);
        $display("Tests Failed: %0d/8", failed);
        $display("====================================\n");
        
        $finish;
    end

endmodule
