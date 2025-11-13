module binary_restoring_divider_v2 (
    input  logic [15:0] dividend,
    input  logic [7:0]  divisor,
    output logic [15:0] quotient,
    output logic [7:0]  remainder,
    output logic        div_by_zero
);

    // Internal signals
    logic [8:0] A;    // Partial remainder (9 bits: 8-bit remainder + 1 overflow bit)
    logic [15:0] Q;   // Quotient register
    
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
            A = 9'b0;      // Clear partial remainder
            Q = dividend;  // Load dividend into quotient register
            
            // Restoring division: 16 iterations for 16-bit quotient
            for (int i = 0; i < 16; i++) begin
                // Shift A,Q left by 1 (A gets MSB of Q, Q shifts left)
                A = {A[7:0], Q[15]};
                Q = {Q[14:0], 1'b0};
                
                // Try subtracting divisor from A
                if (A >= {1'b0, divisor}) begin
                    // If A >= divisor, subtract and set quotient bit
                    A = A - {1'b0, divisor};
                    Q[0] = 1'b1;
                end
                // else: A < divisor, so quotient bit stays 0 (already set above)
            end
            
            // Extract final results
            quotient = Q;
            remainder = A[7:0];  // Lower 8 bits of A contain remainder
        end
    end

endmodule
