module binary_nonrestoring_divider_v2 (
    input  logic [15:0] dividend,
    input  logic [7:0]  divisor,
    output logic [15:0] quotient,
    output logic [7:0]  remainder,
    output logic        div_by_zero
);

    // Internal signals
    logic signed [9:0] A;  // Partial remainder (10 bits signed: 9 magnitude + 1 sign)
    logic [15:0] Q;        // Quotient register
    logic signed [9:0] divisor_ext;  // Sign-extended divisor
    
    always_comb begin
        // Initialize outputs
        quotient = 16'b0;
        remainder = 8'b0;
        div_by_zero = 1'b0;
        
        // Check for division by zero
        if (divisor == 8'b0) begin
            div_by_zero = 1'b1;
            quotient = 16'hFFFF;
            remainder = 8'hFF;
        end else begin
            // Initialize algorithm state
            A = 10'sb0;    // Clear partial remainder
            Q = dividend;  // Load dividend
            divisor_ext = $signed({2'b00, divisor});  // Zero-extend to 10-bit signed
            
            // Non-restoring division: 16 iterations
            for (int i = 0; i < 16; i++) begin
                // Shift A,Q left by 1
                A = {A[8:0], Q[15]};
                Q = {Q[14:0], 1'b0};
                
                if (A >= 0) begin
                    // If remainder is non-negative, subtract divisor
                    A = A - divisor_ext;
                end else begin
                    // If remainder is negative, add divisor
                    A = A + divisor_ext;
                end
                
                // Set quotient bit based on result AFTER operation
                if (A >= 0) begin
                    Q[0] = 1'b1;
                end else begin
                    Q[0] = 1'b0;
                end
            end
            
            // Final adjustment: if A is still negative, add divisor back
            if (A < 0) begin
                A = A + divisor_ext;
            end
            
            // Extract final results
            quotient = Q;
            remainder = A[7:0];
        end
    end

endmodule
