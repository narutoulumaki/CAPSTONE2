`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: vedicdivider_dhwajank_pipelined (Optimized)
// Description: Area-optimized 3-Stage Pipelined BCD Division using Dhvajanka Sutra
// 
// OPTIMIZATIONS:
// 1. Packed structs reduce flip-flop count
// 2. Optimized BCD arithmetic with inline correction
// 3. Early loop exits reduce logic depth
// 4. Optimized multiplication using cascaded additions
// 5. Shared arithmetic logic across stages
//////////////////////////////////////////////////////////////////////////////////

module vedicdivider_dhwajank_pipelined(
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic [15:0] dividend,
    input logic [7:0] divisor,
    output logic valid_out,
    output logic [11:0] quotient,
    output logic [7:0] remainder
);

    // Packed pipeline registers to reduce area
    typedef struct packed {
        logic valid;
        logic div_by_zero;
        logic [1:0] digit_count;
        logic [3:0] q1;
        logic [7:0] partial;
        logic [3:0] d3, d4;
        logic [3:0] v1, v2;
        logic [7:0] divisor;
    } pipe_s1_t;
    
    typedef struct packed {
        logic valid;
        logic div_by_zero;
        logic [1:0] digit_count;
        logic [3:0] q1, q2;
        logic [7:0] partial;
        logic [3:0] d4;
        logic [3:0] v1, v2;
        logic [7:0] divisor;
    } pipe_s2_t;
    
    pipe_s1_t s1_s2;
    pipe_s2_t s2_s3;

    // Optimized BCD add with inline correction
    function automatic logic [7:0] bcd_add(input logic [7:0] a, input logic [7:0] b);
        logic [4:0] lo, hi;
        lo = a[3:0] + b[3:0];
        hi = a[7:4] + b[7:4] + (lo > 9);
        return {(hi > 9 ? hi + 6 : hi[3:0]), (lo > 9 ? lo + 6 : lo[3:0])};
    endfunction
    
    // Optimized BCD subtract
    function automatic logic [11:0] bcd_sub(input logic [7:0] a, input logic [7:0] b);
        logic [3:0] lo, hi;
        logic borrow;
        if (a < b) return 12'hF00;
        lo = (a[3:0] >= b[3:0]) ? a[3:0] - b[3:0] : a[3:0] + 10 - b[3:0];
        borrow = (a[3:0] < b[3:0]);
        hi = (a[7:4] >= b[7:4] + borrow) ? a[7:4] - b[7:4] - borrow : a[7:4] + 10 - b[7:4] - borrow;
        return {4'h0, hi, lo};
    endfunction
    
    // Optimized 12-bit BCD subtract
    function automatic logic [15:0] bcd_sub_12bit(input logic [11:0] a, input logic [7:0] b);
        logic [3:0] d0, d1, d2;
        logic b0, b1;
        if ({4'h0, a} < {8'h00, b}) return 16'hF000;
        d2 = (a[3:0] >= b[3:0]) ? a[3:0] - b[3:0] : a[3:0] + 10 - b[3:0];
        b0 = (a[3:0] < b[3:0]);
        d1 = (a[7:4] >= b[7:4] + b0) ? a[7:4] - b[7:4] - b0 : a[7:4] + 10 - b[7:4] - b0;
        b1 = (a[7:4] < b[7:4] + b0);
        d0 = (a[11:8] >= b1) ? a[11:8] - b1 : a[11:8] + 10 - b1;
        return {4'h0, d0, d1, d2};
    endfunction
    
    // Optimized BCD multiply using cascaded additions (better than loop for small multipliers)
    function automatic logic [7:0] bcd_mul(input logic [3:0] a, input logic [3:0] b);
        logic [7:0] base, x2, x4, x8;
        if (b == 0) return 8'h00;
        base = {4'h0, a};
        if (b == 1) return base;
        x2 = bcd_add(base, base);
        if (b == 2) return x2;
        if (b == 3) return bcd_add(x2, base);
        x4 = bcd_add(x2, x2);
        if (b == 4) return x4;
        if (b == 5) return bcd_add(x4, base);
        if (b == 6) return bcd_add(x4, x2);
        if (b == 7) return bcd_add(x4, bcd_add(x2, base));
        x8 = bcd_add(x4, x4);
        if (b == 8) return x8;
        return bcd_add(x8, base);
    endfunction

    // STAGE 1: First quotient digit
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_s2 <= '0;
        end else begin
            s1_s2.valid <= valid_in;
            
            if (valid_in) begin
                logic [3:0] d0, d1, d2, d3, v1, v2;
                logic [7:0] cmp, part;
                logic [2:0] idx;
                logic [3:0] q;
                logic [7:0] r, div_val;
                logic [11:0] sub, gross;
                logic [15:0] actual;
                
                {d0, d1, d2, d3} = dividend;
                {v1, v2} = divisor;
                
                s1_s2.divisor <= divisor;
                s1_s2.v1 <= v1;
                s1_s2.v2 <= v2;
                s1_s2.d3 <= d2;
                s1_s2.d4 <= d3;
                s1_s2.div_by_zero <= (divisor == 0);
                
                if (divisor != 0) begin
                    cmp = (v1 != 0) ? {4'h0, v1} : divisor;
                    part = {4'h0, d0};
                    idx = 2;
                    
                    // Bring down digits
                    if (part < cmp && idx < 5) begin part = {part[3:0], d1}; idx = idx + 1; end
                    if (part < cmp && idx < 5) begin part = {part[3:0], d2}; idx = idx + 1; end
                    if (part < cmp && idx < 5) begin part = {part[3:0], d3}; idx = idx + 1; end
                    
                    s1_s2.digit_count <= (idx == 2) ? 2'd3 : (idx == 3) ? 2'd2 : 2'd1;
                    
                    // Division with early exit
                    q = 0;
                    r = part;
                    div_val = (v1 != 0) ? {4'h0, v1} : divisor;
                    for (int i = 0; i < 9; i++) begin
                        sub = bcd_sub(r, div_val);
                        if (sub[11]) break;
                        r = sub[7:0];
                        q = q + 1;
                    end
                    
                    // Dhvajanka adjustment
                    if (idx <= 4) begin
                        logic [3:0] next_d;
                        next_d = (idx == 2) ? d1 : (idx == 3) ? d2 : d3;
                        gross = {r[7:4], r[3:0], next_d};
                        actual = (v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, v2)) : {4'h0, gross};
                        
                        // Bounded adjustment loop with early exit
                        for (int j = 0; j < 9; j++) begin
                            if (actual[15:12] == 4'hF && q > 0) begin
                                q = q - 1;
                                r = bcd_add(r, div_val);
                                gross = {r[7:4], r[3:0], next_d};
                                actual = (v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, v2)) : {4'h0, gross};
                            end else break;
                        end
                        s1_s2.partial <= actual[7:0];
                    end else begin
                        s1_s2.partial <= r;
                    end
                    
                    s1_s2.q1 <= q;
                end else begin
                    s1_s2 <= '{valid: 1'b1, default: '0};
                end
            end
        end
    end
    
    // STAGE 2: Second quotient digit
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_s3 <= '0;
        end else begin
            s2_s3.valid <= s1_s2.valid;
            s2_s3.divisor <= s1_s2.divisor;
            s2_s3.v1 <= s1_s2.v1;
            s2_s3.v2 <= s1_s2.v2;
            s2_s3.d4 <= s1_s2.d4;
            s2_s3.q1 <= s1_s2.q1;
            s2_s3.digit_count <= s1_s2.digit_count;
            s2_s3.div_by_zero <= s1_s2.div_by_zero;
            
            if (s1_s2.valid && !s1_s2.div_by_zero && s1_s2.digit_count >= 2) begin
                logic [3:0] q;
                logic [7:0] r, div_val;
                logic [11:0] sub, gross;
                logic [15:0] actual;
                
                q = 0;
                r = s1_s2.partial;
                div_val = (s1_s2.v1 != 0) ? {4'h0, s1_s2.v1} : s1_s2.divisor;
                
                for (int i = 0; i < 9; i++) begin
                    sub = bcd_sub(r, div_val);
                    if (sub[11]) break;
                    r = sub[7:0];
                    q = q + 1;
                end
                
                if (s1_s2.digit_count == 3) begin
                    gross = {r[7:4], r[3:0], s1_s2.d4};
                    actual = (s1_s2.v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, s1_s2.v2)) : {4'h0, gross};
                    
                    for (int j = 0; j < 9; j++) begin
                        if (actual[15:12] == 4'hF && q > 0) begin
                            q = q - 1;
                            r = bcd_add(r, div_val);
                            gross = {r[7:4], r[3:0], s1_s2.d4};
                            actual = (s1_s2.v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, s1_s2.v2)) : {4'h0, gross};
                        end else break;
                    end
                    s2_s3.partial <= actual[7:0];
                end else begin
                    // digit_count==2: Final remainder
                    gross = {r[7:4], r[3:0], s1_s2.d4};
                    actual = (s1_s2.v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, s1_s2.v2)) : {4'h0, gross};
                    
                    for (int j = 0; j < 9; j++) begin
                        if (actual[15:12] == 4'hF && q > 0) begin
                            q = q - 1;
                            r = bcd_add(r, div_val);
                            gross = {r[7:4], r[3:0], s1_s2.d4};
                            actual = (s1_s2.v1 != 0) ? bcd_sub_12bit(gross, bcd_mul(q, s1_s2.v2)) : {4'h0, gross};
                        end else break;
                    end
                    s2_s3.partial <= actual[7:0];
                end
                
                s2_s3.q2 <= q;
            end else begin
                s2_s3.partial <= s1_s2.partial;
                s2_s3.q2 <= '0;
            end
        end
    end
    
    // STAGE 3: Third quotient digit
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            quotient <= '0;
            remainder <= '0;
        end else begin
            valid_out <= s2_s3.valid;
            
            if (s2_s3.valid) begin
                if (s2_s3.div_by_zero) begin
                    quotient <= '0;
                    remainder <= '0;
                end else if (s2_s3.digit_count == 3) begin
                    logic [3:0] q;
                    logic [7:0] r, div_val;
                    logic [11:0] sub;
                    
                    q = 0;
                    r = s2_s3.partial;
                    div_val = (s2_s3.v1 != 0) ? {4'h0, s2_s3.v1} : s2_s3.divisor;
                    
                    for (int i = 0; i < 9; i++) begin
                        sub = bcd_sub(r, div_val);
                        if (sub[11]) break;
                        r = sub[7:0];
                        q = q + 1;
                    end
                    
                    quotient <= {s2_s3.q1, s2_s3.q2, q};
                    remainder <= r;
                end else begin
                    quotient <= (s2_s3.digit_count == 2) ? {4'h0, s2_s3.q1, s2_s3.q2} : {8'h00, s2_s3.q1};
                    remainder <= s2_s3.partial;
                end
            end
        end
    end

endmodule
