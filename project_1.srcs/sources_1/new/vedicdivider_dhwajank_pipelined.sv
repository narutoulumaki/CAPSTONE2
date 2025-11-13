`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: vedicdivider_dhwajank_pipelined
// Description: 3-Stage Pipelined BCD Division using Dhvajanka Sutra
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

    // Stage 1→2 Pipeline Registers
    logic valid_s1_s2;
    logic [7:0] divisor_s1_s2;
    logic [3:0] v1_s1_s2, v2_s1_s2;
    logic [3:0] d3_s1_s2, d4_s1_s2;
    logic [7:0] partial_s1_s2;
    logic [3:0] q1_s1_s2;
    logic [3:0] digit_count_s1_s2;
    logic div_by_zero_s1_s2;
    
    // Stage 2→3 Pipeline Registers
    logic valid_s2_s3;
    logic [7:0] divisor_s2_s3;
    logic [3:0] v1_s2_s3, v2_s2_s3;
    logic [3:0] d4_s2_s3;
    logic [7:0] partial_s2_s3;
    logic [3:0] q1_s2_s3, q2_s2_s3;
    logic [3:0] digit_count_s2_s3;
    logic div_by_zero_s2_s3;

    // Stage 1 working variables (declare at module level)
    logic [3:0] s1_d1, s1_d2, s1_d3, s1_d4;
    logic [3:0] s1_v1, s1_v2;
    logic [7:0] s1_div_compare;
    logic [7:0] s1_partial;
    logic [3:0] s1_next_idx;
    logic [3:0] s1_temp_q;
    logic [7:0] s1_temp_r;
    logic [11:0] s1_sub_tmp;
    logic [11:0] s1_gross_div;
    logic [15:0] s1_actual_div;
    logic [3:0] s1_next_digit;
    
    // Stage 2 working variables
    logic [3:0] s2_temp_q;
    logic [7:0] s2_temp_r;
    logic [11:0] s2_sub_tmp;
    logic [11:0] s2_gross_div;
    logic [15:0] s2_actual_div;
    logic [3:0] s2_next_digit;
    
    // Stage 3 working variables
    logic [3:0] s3_q1, s3_q2, s3_q3;
    logic [7:0] s3_final_remainder;
    logic [3:0] s3_temp_q;
    logic [7:0] s3_temp_r;
    logic [11:0] s3_sub_tmp;
    
    // BCD Arithmetic Functions
    function automatic [7:0] bcd_add(input [7:0] a, input [7:0] b);
        logic [7:0] sum;
        logic [3:0] digit1, digit2;
        logic carry;
        logic [4:0] temp_sum;
        
        temp_sum = a[3:0] + b[3:0];
        digit2 = temp_sum[3:0];
        carry = 0;
        
        if (temp_sum > 9) begin
            digit2 = digit2 + 6;
            carry = 1;
        end
        
        temp_sum = a[7:4] + b[7:4] + carry;
        digit1 = temp_sum[3:0];
        
        if (temp_sum > 9) begin
            digit1 = digit1 + 6;
        end
            
        sum = {digit1, digit2};
        return sum;
    endfunction
    
    function automatic [11:0] bcd_sub(input [7:0] a, input [7:0] b);
        logic [7:0] diff;
        logic [3:0] digit1, digit2;
        logic borrow;
        logic is_negative;
        
        is_negative = 0;
        borrow = 0;
        
        if (a < b)
            is_negative = 1;
            
        if (!is_negative) begin
            if (a[3:0] < b[3:0] + borrow) begin
                digit2 = a[3:0] + 10 - b[3:0] - borrow;
                borrow = 1;
            end else begin
                digit2 = a[3:0] - b[3:0] - borrow;
                borrow = 0;
            end
            
            if (a[7:4] < b[7:4] + borrow) begin
                digit1 = a[7:4] + 10 - b[7:4] - borrow;
            end else begin
                digit1 = a[7:4] - b[7:4] - borrow;
            end
            
            diff = {digit1, digit2};
            return {4'b0000, diff};
        end else begin
            return {4'b1111, 8'h00};
        end
    endfunction
    
    function automatic [15:0] bcd_sub_12bit(input [11:0] a, input [7:0] b);
        logic [11:0] diff;
        logic [3:0] digit1, digit2, digit3;
        logic borrow;
        logic is_negative;
        
        is_negative = 0;
        borrow = 0;
        
        if ({4'h0, a[11:0]} < {8'h00, b})
            is_negative = 1;
            
        if (!is_negative) begin
            if (a[3:0] < b[3:0] + borrow) begin
                digit3 = a[3:0] + 10 - b[3:0] - borrow;
                borrow = 1;
            end else begin
                digit3 = a[3:0] - b[3:0] - borrow;
                borrow = 0;
            end
            
            if (a[7:4] < b[7:4] + borrow) begin
                digit2 = a[7:4] + 10 - b[7:4] - borrow;
                borrow = 1;
            end else begin
                digit2 = a[7:4] - b[7:4] - borrow;
                borrow = 0;
            end
            
            if (a[11:8] < borrow) begin
                digit1 = a[11:8] + 10 - borrow;
            end else begin
                digit1 = a[11:8] - borrow;
            end
            
            diff = {digit1, digit2, digit3};
            return {4'b0000, diff};
        end else begin
            return {4'b1111, 12'h000};
        end
    endfunction
    
    function automatic [7:0] bcd_multiply_digits(input [3:0] a, input [3:0] b);
        logic [7:0] product;
        logic [7:0] temp;
        
        product = 8'h00;
        
        for (int i = 0; i < b; i++) begin
            temp = product;
            product = bcd_add(temp, {4'h0, a});
        end
        
        return product;
    endfunction
    
    // STAGE 1
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_s1_s2 <= 0;
            divisor_s1_s2 <= 0;
            v1_s1_s2 <= 0;
            v2_s1_s2 <= 0;
            d3_s1_s2 <= 0;
            d4_s1_s2 <= 0;
            partial_s1_s2 <= 0;
            q1_s1_s2 <= 0;
            digit_count_s1_s2 <= 0;
            div_by_zero_s1_s2 <= 0;
        end else begin
            valid_s1_s2 <= valid_in;
            
            if (valid_in) begin
                // Extract BCD digits
                s1_d1 = dividend[15:12];
                s1_d2 = dividend[11:8];
                s1_d3 = dividend[7:4];
                s1_d4 = dividend[3:0];
                s1_v1 = divisor[7:4];
                s1_v2 = divisor[3:0];
                
                divisor_s1_s2 <= divisor;
                v1_s1_s2 <= s1_v1;
                v2_s1_s2 <= s1_v2;
                d3_s1_s2 <= s1_d3;
                d4_s1_s2 <= s1_d4;
                
                if (divisor == 8'h00) begin
                    div_by_zero_s1_s2 <= 1;
                    partial_s1_s2 <= 0;
                    q1_s1_s2 <= 0;
                    digit_count_s1_s2 <= 0;
                end else begin
                    div_by_zero_s1_s2 <= 0;
                    
                    s1_div_compare = (s1_v1 != 0) ? {4'h0, s1_v1} : divisor;
                    s1_partial = {4'h0, s1_d1};
                    s1_next_idx = 2;
                    
                    if (s1_partial < s1_div_compare && s1_next_idx == 2) begin
                        s1_partial = {s1_d1, s1_d2};
                        s1_next_idx = 3;
                    end
                    if (s1_partial < s1_div_compare && s1_next_idx == 3) begin
                        s1_partial = {s1_partial[3:0], s1_d3};
                        s1_next_idx = 4;
                    end
                    if (s1_partial < s1_div_compare && s1_next_idx == 4) begin
                        s1_partial = {s1_partial[3:0], s1_d4};
                        s1_next_idx = 5;
                    end
                    
                    case (s1_next_idx)
                        2: digit_count_s1_s2 <= 3;
                        3: digit_count_s1_s2 <= 2;
                        default: digit_count_s1_s2 <= 1;
                    endcase
                    
                    s1_temp_q = 0;
                    s1_temp_r = s1_partial;
                    
                    if (s1_v1 != 4'd0) begin
                        for (int i = 0; i < 9; i++) begin
                            s1_sub_tmp = bcd_sub(s1_temp_r, {4'h0, s1_v1});
                            if (!s1_sub_tmp[11]) begin
                                s1_temp_r = s1_sub_tmp[7:0];
                                s1_temp_q = s1_temp_q + 1;
                            end
                        end
                    end else begin
                        for (int i = 0; i < 9; i++) begin
                            s1_sub_tmp = bcd_sub(s1_temp_r, divisor);
                            if (!s1_sub_tmp[11]) begin
                                s1_temp_r = s1_sub_tmp[7:0];
                                s1_temp_q = s1_temp_q + 1;
                            end
                        end
                    end
                    
                    if (s1_next_idx <= 4) begin
                        case (s1_next_idx)
                            2: s1_next_digit = s1_d2;
                            3: s1_next_digit = s1_d3;
                            4: s1_next_digit = s1_d4;
                            default: s1_next_digit = 0;
                        endcase
                        
                        s1_gross_div = {s1_temp_r[7:4], s1_temp_r[3:0], s1_next_digit};
                        
                        if (s1_v1 != 0) begin
                            s1_actual_div = bcd_sub_12bit(s1_gross_div, bcd_multiply_digits(s1_temp_q, s1_v2));
                        end else begin
                            s1_actual_div = {4'h0, s1_gross_div};
                        end
                        
                        // Simple adjustment (one iteration for synthesis)
                        if (s1_actual_div[15:12] == 4'b1111 && s1_temp_q > 0) begin
                            s1_temp_q = s1_temp_q - 1;
                            if (s1_v1 != 0) begin
                                s1_temp_r = bcd_add(s1_temp_r, {4'h0, s1_v1});
                            end else begin
                                s1_temp_r = bcd_add(s1_temp_r, divisor);
                            end
                            s1_gross_div = {s1_temp_r[7:4], s1_temp_r[3:0], s1_next_digit};
                            if (s1_v1 != 0) begin
                                s1_actual_div = bcd_sub_12bit(s1_gross_div, bcd_multiply_digits(s1_temp_q, s1_v2));
                            end else begin
                                s1_actual_div = {4'h0, s1_gross_div};
                            end
                        end
                        
                        partial_s1_s2 <= s1_actual_div[7:0];
                    end else begin
                        partial_s1_s2 <= s1_temp_r;
                    end
                    
                    q1_s1_s2 <= s1_temp_q;
                end
            end
        end
    end
    
    // STAGE 2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_s2_s3 <= 0;
            divisor_s2_s3 <= 0;
            v1_s2_s3 <= 0;
            v2_s2_s3 <= 0;
            d4_s2_s3 <= 0;
            partial_s2_s3 <= 0;
            q1_s2_s3 <= 0;
            q2_s2_s3 <= 0;
            digit_count_s2_s3 <= 0;
            div_by_zero_s2_s3 <= 0;
        end else begin
            valid_s2_s3 <= valid_s1_s2;
            
            if (valid_s1_s2) begin
                // Pass through data from Stage 1
                divisor_s2_s3 <= divisor_s1_s2;
                v1_s2_s3 <= v1_s1_s2;
                v2_s2_s3 <= v2_s1_s2;
                d4_s2_s3 <= d4_s1_s2;
                q1_s2_s3 <= q1_s1_s2;
                digit_count_s2_s3 <= digit_count_s1_s2;
                div_by_zero_s2_s3 <= div_by_zero_s1_s2;
                
                // Handle division by zero
                if (div_by_zero_s1_s2) begin
                    partial_s2_s3 <= 0;
                    q2_s2_s3 <= 0;
                end else if (digit_count_s1_s2 >= 2) begin
                    // We need to compute a second quotient digit
                    logic [3:0] temp_q;
                    logic [7:0] temp_r;
                    logic [11:0] sub_tmp;
                    logic [11:0] gross_div;
                    logic [15:0] actual_div;
                    logic [3:0] next_digit;
                    
                    // Divide partial by v1
                    temp_q = 0;
                    temp_r = partial_s1_s2;
                    
                    if (v1_s1_s2 != 4'd0) begin
                        for (int i = 0; i < 9; i++) begin
                            sub_tmp = bcd_sub(temp_r, {4'h0, v1_s1_s2});
                            if (sub_tmp[11]) break;
                            temp_r = sub_tmp[7:0];
                            temp_q = temp_q + 1;
                        end
                    end else begin
                        for (int i = 0; i < 9; i++) begin
                            sub_tmp = bcd_sub(temp_r, divisor_s1_s2);
                            if (sub_tmp[11]) break;
                            temp_r = sub_tmp[7:0];
                            temp_q = temp_q + 1;
                        end
                    end
                    
                    // Apply Dhvajanka if we'll have more digits to process
                    if (digit_count_s1_s2 == 3) begin
                        // Will have a third quotient digit, bring down d4
                        next_digit = d4_s1_s2;
                        
                        // Gross dividend
                        gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                        
                        // Actual dividend
                        if (v1_s1_s2 != 0) begin
                            actual_div = bcd_sub_12bit(gross_div, bcd_multiply_digits(temp_q, v2_s1_s2));
                        end else begin
                            actual_div = {4'h0, gross_div};
                        end
                        
                        // Adjustment loop (bounded for synthesis)
                        for (int i = 0; i < 9; i++) begin
                            if (actual_div[15:12] == 4'b1111 && temp_q > 0) begin
                                temp_q = temp_q - 1;
                                if (v1_s1_s2 != 0) begin
                                    temp_r = bcd_add(temp_r, {4'h0, v1_s1_s2});
                                end else begin
                                    temp_r = bcd_add(temp_r, divisor_s1_s2);
                                end
                                gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                                if (v1_s1_s2 != 0) begin
                                    actual_div = bcd_sub_12bit(gross_div, bcd_multiply_digits(temp_q, v2_s1_s2));
                                end else begin
                                    actual_div = {4'h0, gross_div};
                                end
                            end
                        end
                        
                        partial_s2_s3 <= actual_div[7:0];
                    end else if (digit_count_s1_s2 == 2) begin
                        // This is the last quotient digit, bring down d4 for final remainder
                        next_digit = d4_s1_s2;
                        
                        // Gross dividend
                        gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                        
                        // Actual dividend
                        if (v1_s1_s2 != 0) begin
                            actual_div = bcd_sub_12bit(gross_div, bcd_multiply_digits(temp_q, v2_s1_s2));
                        end else begin
                            actual_div = {4'h0, gross_div};
                        end
                        
                        // Adjustment loop (bounded for synthesis)
                        for (int i = 0; i < 9; i++) begin
                            if (actual_div[15:12] == 4'b1111 && temp_q > 0) begin
                                temp_q = temp_q - 1;
                                if (v1_s1_s2 != 0) begin
                                    temp_r = bcd_add(temp_r, {4'h0, v1_s1_s2});
                                end else begin
                                    temp_r = bcd_add(temp_r, divisor_s1_s2);
                                end
                                gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                                if (v1_s1_s2 != 0) begin
                                    actual_div = bcd_sub_12bit(gross_div, bcd_multiply_digits(temp_q, v2_s1_s2));
                                end else begin
                                    actual_div = {4'h0, gross_div};
                                end
                            end
                        end
                        
                        // This is the final remainder
                        partial_s2_s3 <= actual_div[7:0];
                    end else begin
                        // Should not happen - digit_count is at least 2 in this branch
                        partial_s2_s3 <= temp_r;
                    end
                    
                    q2_s2_s3 <= temp_q;
                end else begin
                    // digit_count == 1, no second quotient digit needed
                    partial_s2_s3 <= partial_s1_s2;
                    q2_s2_s3 <= 0;
                end
            end
        end
    end
    
    // STAGE 3
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            quotient <= 0;
            remainder <= 0;
        end else begin
            valid_out <= valid_s2_s3;
            
            if (valid_s2_s3) begin
                // Handle division by zero
                if (div_by_zero_s2_s3) begin
                    quotient <= 12'h000;
                    remainder <= 8'h00;
                end else begin
                    logic [3:0] q1, q2, q3;
                    logic [7:0] final_remainder;
                    
                    q1 = q1_s2_s3;
                    q2 = q2_s2_s3;
                    
                    if (digit_count_s2_s3 == 3) begin
                        // Need to compute third quotient digit
                        logic [3:0] temp_q;
                        logic [7:0] temp_r;
                        logic [11:0] sub_tmp;
                        
                        // Divide partial by v1
                        temp_q = 0;
                        temp_r = partial_s2_s3;
                        
                        if (v1_s2_s3 != 4'd0) begin
                            for (int i = 0; i < 9; i++) begin
                                sub_tmp = bcd_sub(temp_r, {4'h0, v1_s2_s3});
                                if (sub_tmp[11]) break;
                                temp_r = sub_tmp[7:0];
                                temp_q = temp_q + 1;
                            end
                        end else begin
                            for (int i = 0; i < 9; i++) begin
                                sub_tmp = bcd_sub(temp_r, divisor_s2_s3);
                                if (sub_tmp[11]) break;
                                temp_r = sub_tmp[7:0];
                                temp_q = temp_q + 1;
                            end
                        end
                        
                        q3 = temp_q;
                        final_remainder = temp_r;
                        
                        // Assemble quotient: all 3 digits (q1, q2, q3)
                        quotient <= {q1, q2, q3};
                    end else if (digit_count_s2_s3 == 2) begin
                        // Only 2 quotient digits - partial_s2_s3 is already the remainder
                        q3 = 0;
                        final_remainder = partial_s2_s3;
                        
                        // Assemble quotient: right-aligned (0, q1, q2)
                        quotient <= {4'h0, q1, q2};
                    end else begin
                        // Only 1 quotient digit - partial_s2_s3 is already the remainder
                        q2 = 0;
                        q3 = 0;
                        final_remainder = partial_s2_s3;
                        
                        // Assemble quotient: right-aligned (0, 0, q1)
                        quotient <= {4'h0, 4'h0, q1};
                    end
                    
                    remainder <= final_remainder;
                end
            end
        end
    end

endmodule