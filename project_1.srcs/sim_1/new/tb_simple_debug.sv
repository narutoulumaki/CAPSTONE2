/**
 * Simple debug testbench for binary division
 * Tests just one case: 100 ÷ 10 = 10 R 0
 */

module tb_simple_debug;
    logic [15:0] dividend;
    logic [7:0]  divisor;
    logic [15:0] q_restore;
    logic [7:0]  r_restore;
    logic        dbz_restore;
    
    // Instantiate restoring divider
    binary_restoring_divider_v2 dut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(q_restore),
        .remainder(r_restore),
        .div_by_zero(dbz_restore)
    );
    
    initial begin
        $display("Simple Debug Test: 100 ÷ 10");
        $display("==========================================");
        
        dividend = 16'd100;
        divisor = 8'd10;
        
        #10;
        
        $display("Input: dividend=%0d, divisor=%0d", dividend, divisor);
        $display("Output: quotient=%0d, remainder=%0d, div_by_zero=%0b", 
                 q_restore, r_restore, dbz_restore);
        $display("Expected: quotient=10, remainder=0");
        
        if (q_restore == 16'd10 && r_restore == 8'd0) begin
            $display("PASS!");
        end else begin
            $display("FAIL!");
        end
        
        $finish;
    end
endmodule
