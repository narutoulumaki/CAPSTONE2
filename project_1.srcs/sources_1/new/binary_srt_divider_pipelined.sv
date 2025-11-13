/**
 * Pipelined Binary SRT Division (3 stages)
 * Stage 1: 6 iterations, Stage 2: 5 iterations, Stage 3: 5 iterations
 */

module binary_srt_divider_pipelined_v2 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [15:0] dividend,
    input  logic [7:0]  divisor,
    output logic [15:0] quotient,
    output logic [7:0]  remainder,
    output logic        div_by_zero
);

    // Stage 1 signals
    logic signed [9:0] s1_A;
    logic [15:0] s1_Q;
    logic signed [15:0] s1_Q_signed;
    logic signed [9:0] s1_divisor_ext;
    logic s1_div_by_zero;
    
    // Stage 1 -> Stage 2 registers
    logic signed [9:0] s1_A_reg;
    logic [15:0] s1_Q_reg;
    logic signed [15:0] s1_Q_signed_reg;
    logic signed [9:0] s1_divisor_ext_reg;
    logic s1_div_by_zero_reg;
    
    // Stage 2 signals
    logic signed [9:0] s2_A;
    logic [15:0] s2_Q;
    logic signed [15:0] s2_Q_signed;
    
    // Stage 2 -> Stage 3 registers
    logic signed [9:0] s2_A_reg;
    logic [15:0] s2_Q_reg;
    logic signed [15:0] s2_Q_signed_reg;
    logic signed [9:0] s2_divisor_ext_reg;
    logic s2_div_by_zero_reg;
    
    // Stage 3 signals
    logic signed [9:0] s3_A;
    logic [15:0] s3_Q;
    logic signed [15:0] s3_Q_signed;
    
    //==========================================================================
    // Stage 1: Iterations 0-5 (6 iterations)
    //==========================================================================
    always_comb begin
        if (divisor == 8'b0) begin
            s1_div_by_zero = 1'b1;
            s1_A = 10'sb0;
            s1_Q = 16'hFFFF;
            s1_Q_signed = 16'sb0;
            s1_divisor_ext = 10'sb0;
        end else begin
            s1_div_by_zero = 1'b0;
            s1_A = 10'sb0;
            s1_Q = dividend;
            s1_Q_signed = 16'sb0;
            s1_divisor_ext = $signed({2'b00, divisor});
            
            for (int i = 0; i < 6; i++) begin
                s1_A = {s1_A[8:0], s1_Q[15]};
                s1_Q = {s1_Q[14:0], 1'b0};
                
                s1_Q_signed = s1_Q_signed << 1;
                if (s1_A >= s1_divisor_ext) begin
                    s1_A = s1_A - s1_divisor_ext;
                    s1_Q_signed = s1_Q_signed + 1;
                end else if (s1_A < -s1_divisor_ext) begin
                    s1_A = s1_A + s1_divisor_ext;
                    s1_Q_signed = s1_Q_signed - 1;
                end
            end
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_A_reg <= 10'sb0;
            s1_Q_reg <= 16'b0;
            s1_Q_signed_reg <= 16'sb0;
            s1_divisor_ext_reg <= 10'sb0;
            s1_div_by_zero_reg <= 1'b0;
        end else begin
            s1_A_reg <= s1_A;
            s1_Q_reg <= s1_Q;
            s1_Q_signed_reg <= s1_Q_signed;
            s1_divisor_ext_reg <= s1_divisor_ext;
            s1_div_by_zero_reg <= s1_div_by_zero;
        end
    end
    
    //==========================================================================
    // Stage 2: Iterations 6-10 (5 iterations)
    //==========================================================================
    always_comb begin
        s2_A = s1_A_reg;
        s2_Q = s1_Q_reg;
        s2_Q_signed = s1_Q_signed_reg;
        
        if (!s1_div_by_zero_reg) begin
            for (int i = 0; i < 5; i++) begin
                s2_A = {s2_A[8:0], s2_Q[15]};
                s2_Q = {s2_Q[14:0], 1'b0};
                
                s2_Q_signed = s2_Q_signed << 1;
                if (s2_A >= s1_divisor_ext_reg) begin
                    s2_A = s2_A - s1_divisor_ext_reg;
                    s2_Q_signed = s2_Q_signed + 1;
                end else if (s2_A < -s1_divisor_ext_reg) begin
                    s2_A = s2_A + s1_divisor_ext_reg;
                    s2_Q_signed = s2_Q_signed - 1;
                end
            end
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_A_reg <= 10'sb0;
            s2_Q_reg <= 16'b0;
            s2_Q_signed_reg <= 16'sb0;
            s2_divisor_ext_reg <= 10'sb0;
            s2_div_by_zero_reg <= 1'b0;
        end else begin
            s2_A_reg <= s2_A;
            s2_Q_reg <= s2_Q;
            s2_Q_signed_reg <= s2_Q_signed;
            s2_divisor_ext_reg <= s1_divisor_ext_reg;
            s2_div_by_zero_reg <= s1_div_by_zero_reg;
        end
    end
    
    //==========================================================================
    // Stage 3: Iterations 11-15 (5 iterations)
    //==========================================================================
    always_comb begin
        s3_A = s2_A_reg;
        s3_Q = s2_Q_reg;
        s3_Q_signed = s2_Q_signed_reg;
        
        if (!s2_div_by_zero_reg) begin
            for (int i = 0; i < 5; i++) begin
                s3_A = {s3_A[8:0], s3_Q[15]};
                s3_Q = {s3_Q[14:0], 1'b0};
                
                s3_Q_signed = s3_Q_signed << 1;
                if (s3_A >= s2_divisor_ext_reg) begin
                    s3_A = s3_A - s2_divisor_ext_reg;
                    s3_Q_signed = s3_Q_signed + 1;
                end else if (s3_A < -s2_divisor_ext_reg) begin
                    s3_A = s3_A + s2_divisor_ext_reg;
                    s3_Q_signed = s3_Q_signed - 1;
                end
            end
            
            // Final adjustment
            if (s3_A < 0) begin
                s3_A = s3_A + s2_divisor_ext_reg;
                s3_Q_signed = s3_Q_signed - 1;
            end
        end
    end
    
    //==========================================================================
    // Output registers
    //==========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quotient <= 16'b0;
            remainder <= 8'b0;
            div_by_zero <= 1'b0;
        end else begin
            if (s2_div_by_zero_reg) begin
                quotient <= 16'hFFFF;
                remainder <= 8'hFF;
                div_by_zero <= 1'b1;
            end else begin
                quotient <= s3_Q_signed[15:0];
                remainder <= s3_A[7:0];
                div_by_zero <= 1'b0;
            end
        end
    end

endmodule
