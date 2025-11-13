/**
 * Binary SRT Division Algorithm (Simplified)
 */

module binary_srt_divider_v2 (
    input  logic [15:0] dividend,
    input  logic [7:0]  divisor,
    output logic [15:0] quotient,
    output logic [7:0]  remainder,
    output logic        div_by_zero
);

    // Internal signals
    logic signed [9:0] A;              // Partial remainder (10 bits signed)
    logic signed [15:0] Q_signed;      // Signed quotient accumulator
    logic [15:0] Q;                    // Quotient register for shifting
    logic signed [9:0] divisor_ext;    // Sign-extended divisor
    
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
            A = 10'sb0;
            Q = dividend;
            Q_signed = 16'sb0;
            divisor_ext = $signed({2'b00, divisor});
            
            // SRT division: 16 iterations
            for (int i = 0; i < 16; i++) begin
                // Shift A,Q left by 1
                A = {A[8:0], Q[15]};
                Q = {Q[14:0], 1'b0};
                
                // Quotient digit selection and accumulation
                Q_signed = Q_signed << 1;
                
                if (A >= divisor_ext) begin
                    // Quotient digit = +1
                    A = A - divisor_ext;
                    Q_signed = Q_signed + 1;
                end else if (A < -divisor_ext) begin
                    // Quotient digit = -1
                    A = A + divisor_ext;
                    Q_signed = Q_signed - 1;
                end
                // else: Quotient digit = 0, no change
            end
            
            // Final adjustment if remainder is negative
            if (A < 0) begin
                A = A + divisor_ext;
                Q_signed = Q_signed - 1;
            end
            
            // Extract results
            quotient = Q_signed[15:0];
            remainder = A[7:0];
        end
    end

endmodule
