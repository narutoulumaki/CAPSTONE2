`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: vedicdivider_dhwajank_pipelined_optimized
// Description: Optimized 3-Stage Pipelined BCD Division using Dhvajanka Sutra
// Optimizations:
// - Direct quotient calculation via comparison (no loop unrolling)
// - LUT-based BCD multiplication
// - Simplified adjustment logic
//////////////////////////////////////////////////////////////////////////////////

module vedicdivider_dhwajank_pipelined_optimized(
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

    //==========================================================================
    // OPTIMIZED BCD ARITHMETIC FUNCTIONS
    //==========================================================================
    
    // BCD Addition (unchanged - already efficient)
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
    
    // BCD Subtraction (unchanged)
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
    
    // BCD 12-bit Subtraction (unchanged)
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
    
    // OPTIMIZED: LUT-based BCD Multiplication (single digit × single digit)
    function automatic [7:0] bcd_multiply_lut(input [3:0] a, input [3:0] b);
        logic [7:0] product;
        
        // Use case statement with pre-computed BCD products
        case ({a, b})
            // a=0
            8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08, 8'h09: product = 8'h00;
            // a=1
            8'h10: product = 8'h00; 8'h11: product = 8'h01; 8'h12: product = 8'h02; 8'h13: product = 8'h03;
            8'h14: product = 8'h04; 8'h15: product = 8'h05; 8'h16: product = 8'h06; 8'h17: product = 8'h07;
            8'h18: product = 8'h08; 8'h19: product = 8'h09;
            // a=2
            8'h20: product = 8'h00; 8'h21: product = 8'h02; 8'h22: product = 8'h04; 8'h23: product = 8'h06;
            8'h24: product = 8'h08; 8'h25: product = 8'h10; 8'h26: product = 8'h12; 8'h27: product = 8'h14;
            8'h28: product = 8'h16; 8'h29: product = 8'h18;
            // a=3
            8'h30: product = 8'h00; 8'h31: product = 8'h03; 8'h32: product = 8'h06; 8'h33: product = 8'h09;
            8'h34: product = 8'h12; 8'h35: product = 8'h15; 8'h36: product = 8'h18; 8'h37: product = 8'h21;
            8'h38: product = 8'h24; 8'h39: product = 8'h27;
            // a=4
            8'h40: product = 8'h00; 8'h41: product = 8'h04; 8'h42: product = 8'h08; 8'h43: product = 8'h12;
            8'h44: product = 8'h16; 8'h45: product = 8'h20; 8'h46: product = 8'h24; 8'h47: product = 8'h28;
            8'h48: product = 8'h32; 8'h49: product = 8'h36;
            // a=5
            8'h50: product = 8'h00; 8'h51: product = 8'h05; 8'h52: product = 8'h10; 8'h53: product = 8'h15;
            8'h54: product = 8'h20; 8'h55: product = 8'h25; 8'h56: product = 8'h30; 8'h57: product = 8'h35;
            8'h58: product = 8'h40; 8'h59: product = 8'h45;
            // a=6
            8'h60: product = 8'h00; 8'h61: product = 8'h06; 8'h62: product = 8'h12; 8'h63: product = 8'h18;
            8'h64: product = 8'h24; 8'h65: product = 8'h30; 8'h66: product = 8'h36; 8'h67: product = 8'h42;
            8'h68: product = 8'h48; 8'h69: product = 8'h54;
            // a=7
            8'h70: product = 8'h00; 8'h71: product = 8'h07; 8'h72: product = 8'h14; 8'h73: product = 8'h21;
            8'h74: product = 8'h28; 8'h75: product = 8'h35; 8'h76: product = 8'h42; 8'h77: product = 8'h49;
            8'h78: product = 8'h56; 8'h79: product = 8'h63;
            // a=8
            8'h80: product = 8'h00; 8'h81: product = 8'h08; 8'h82: product = 8'h16; 8'h83: product = 8'h24;
            8'h84: product = 8'h32; 8'h85: product = 8'h40; 8'h86: product = 8'h48; 8'h87: product = 8'h56;
            8'h88: product = 8'h64; 8'h89: product = 8'h72;
            // a=9
            8'h90: product = 8'h00; 8'h91: product = 8'h09; 8'h92: product = 8'h18; 8'h93: product = 8'h27;
            8'h94: product = 8'h36; 8'h95: product = 8'h45; 8'h96: product = 8'h54; 8'h97: product = 8'h63;
            8'h98: product = 8'h72; 8'h99: product = 8'h81;
            default: product = 8'h00;
        endcase
        
        return product;
    endfunction
    
    // OPTIMIZED: Direct quotient calculation via comparison
    function automatic [11:0] bcd_divide_digit(input [7:0] dividend_part, input [7:0] divisor_val);
        logic [3:0] quotient_digit;
        logic [7:0] remainder_val;
        logic [7:0] div_multiples [0:9];
        
        // Pre-compute multiples of divisor (0-9 times)
        div_multiples[0] = 8'h00;
        div_multiples[1] = divisor_val;
        div_multiples[2] = bcd_add(divisor_val, divisor_val);
        div_multiples[3] = bcd_add(div_multiples[2], divisor_val);
        div_multiples[4] = bcd_add(div_multiples[2], div_multiples[2]);
        div_multiples[5] = bcd_add(div_multiples[4], divisor_val);
        div_multiples[6] = bcd_add(div_multiples[3], div_multiples[3]);
        div_multiples[7] = bcd_add(div_multiples[6], divisor_val);
        div_multiples[8] = bcd_add(div_multiples[4], div_multiples[4]);
        div_multiples[9] = bcd_add(div_multiples[8], divisor_val);
        
        // Find quotient digit via comparison
        if (dividend_part >= div_multiples[9])      quotient_digit = 9;
        else if (dividend_part >= div_multiples[8]) quotient_digit = 8;
        else if (dividend_part >= div_multiples[7]) quotient_digit = 7;
        else if (dividend_part >= div_multiples[6]) quotient_digit = 6;
        else if (dividend_part >= div_multiples[5]) quotient_digit = 5;
        else if (dividend_part >= div_multiples[4]) quotient_digit = 4;
        else if (dividend_part >= div_multiples[3]) quotient_digit = 3;
        else if (dividend_part >= div_multiples[2]) quotient_digit = 2;
        else if (dividend_part >= div_multiples[1]) quotient_digit = 1;
        else                                         quotient_digit = 0;
        
        // Calculate remainder
        remainder_val = bcd_sub(dividend_part, div_multiples[quotient_digit])[7:0];
        
        return {quotient_digit, remainder_val};
    endfunction

    //==========================================================================
    // STAGE 1: First Quotient Digit
    //==========================================================================
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
                logic [3:0] d1, d2, d3, d4, v1, v2;
                logic [7:0] div_compare, partial, div_operand;
                logic [3:0] next_idx, next_digit;
                logic [11:0] div_result;
                logic [3:0] temp_q;
                logic [7:0] temp_r;
                logic [11:0] gross_div;
                logic [15:0] actual_div;
                
                // Extract BCD digits
                d1 = dividend[15:12];
                d2 = dividend[11:8];
                d3 = dividend[7:4];
                d4 = dividend[3:0];
                v1 = divisor[7:4];
                v2 = divisor[3:0];
                
                divisor_s1_s2 <= divisor;
                v1_s1_s2 <= v1;
                v2_s1_s2 <= v2;
                d3_s1_s2 <= d3;
                d4_s1_s2 <= d4;
                
                if (divisor == 8'h00) begin
                    div_by_zero_s1_s2 <= 1;
                    partial_s1_s2 <= 0;
                    q1_s1_s2 <= 0;
                    digit_count_s1_s2 <= 0;
                end else begin
                    div_by_zero_s1_s2 <= 0;
                    
                    // Determine which digits to use
                    div_compare = (v1 != 0) ? {4'h0, v1} : divisor;
                    partial = {4'h0, d1};
                    next_idx = 2;
                    
                    if (partial < div_compare && next_idx == 2) begin
                        partial = {d1, d2};
                        next_idx = 3;
                    end
                    if (partial < div_compare && next_idx == 3) begin
                        partial = {partial[3:0], d3};
                        next_idx = 4;
                    end
                    if (partial < div_compare && next_idx == 4) begin
                        partial = {partial[3:0], d4};
                        next_idx = 5;
                    end
                    
                    case (next_idx)
                        2: digit_count_s1_s2 <= 3;
                        3: digit_count_s1_s2 <= 2;
                        default: digit_count_s1_s2 <= 1;
                    endcase
                    
                    // OPTIMIZED: Direct division calculation
                    div_operand = (v1 != 4'd0) ? {4'h0, v1} : divisor;
                    div_result = bcd_divide_digit(partial, div_operand);
                    temp_q = div_result[11:8];
                    temp_r = div_result[7:0];
                    
                    // Apply Dhvajanka correction if needed
                    if (next_idx <= 4) begin
                        case (next_idx)
                            2: next_digit = d2;
                            3: next_digit = d3;
                            4: next_digit = d4;
                            default: next_digit = 0;
                        endcase
                        
                        gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                        
                        if (v1 != 0) begin
                            actual_div = bcd_sub_12bit(gross_div, bcd_multiply_lut(temp_q, v2));
                        end else begin
                            actual_div = {4'h0, gross_div};
                        end
                        
                        // Single adjustment if needed
                        if (actual_div[15:12] == 4'b1111 && temp_q > 0) begin
                            temp_q = temp_q - 1;
                            temp_r = bcd_add(temp_r, div_operand);
                            gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                            if (v1 != 0) begin
                                actual_div = bcd_sub_12bit(gross_div, bcd_multiply_lut(temp_q, v2));
                            end else begin
                                actual_div = {4'h0, gross_div};
                            end
                        end
                        
                        partial_s1_s2 <= actual_div[7:0];
                    end else begin
                        partial_s1_s2 <= temp_r;
                    end
                    
                    q1_s1_s2 <= temp_q;
                end
            end
        end
    end
    
    //==========================================================================
    // STAGE 2: Second Quotient Digit
    //==========================================================================
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
                divisor_s2_s3 <= divisor_s1_s2;
                v1_s2_s3 <= v1_s1_s2;
                v2_s2_s3 <= v2_s1_s2;
                d4_s2_s3 <= d4_s1_s2;
                q1_s2_s3 <= q1_s1_s2;
                digit_count_s2_s3 <= digit_count_s1_s2;
                div_by_zero_s2_s3 <= div_by_zero_s1_s2;
                
                if (div_by_zero_s1_s2) begin
                    partial_s2_s3 <= 0;
                    q2_s2_s3 <= 0;
                end else if (digit_count_s1_s2 >= 2) begin
                    logic [7:0] div_operand;
                    logic [11:0] div_result;
                    logic [3:0] temp_q, next_digit;
                    logic [7:0] temp_r;
                    logic [11:0] gross_div;
                    logic [15:0] actual_div;
                    
                    // OPTIMIZED: Direct division
                    div_operand = (v1_s1_s2 != 4'd0) ? {4'h0, v1_s1_s2} : divisor_s1_s2;
                    div_result = bcd_divide_digit(partial_s1_s2, div_operand);
                    temp_q = div_result[11:8];
                    temp_r = div_result[7:0];
                    
                    if (digit_count_s1_s2 >= 2) begin
                        next_digit = (digit_count_s1_s2 == 3) ? d4_s1_s2 : d4_s1_s2;
                        gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                        
                        if (v1_s1_s2 != 0) begin
                            actual_div = bcd_sub_12bit(gross_div, bcd_multiply_lut(temp_q, v2_s1_s2));
                        end else begin
                            actual_div = {4'h0, gross_div};
                        end
                        
                        // Single adjustment
                        if (actual_div[15:12] == 4'b1111 && temp_q > 0) begin
                            temp_q = temp_q - 1;
                            temp_r = bcd_add(temp_r, div_operand);
                            gross_div = {temp_r[7:4], temp_r[3:0], next_digit};
                            if (v1_s1_s2 != 0) begin
                                actual_div = bcd_sub_12bit(gross_div, bcd_multiply_lut(temp_q, v2_s1_s2));
                            end else begin
                                actual_div = {4'h0, gross_div};
                            end
                        end
                        
                        partial_s2_s3 <= actual_div[7:0];
                    end else begin
                        partial_s2_s3 <= temp_r;
                    end
                    
                    q2_s2_s3 <= temp_q;
                end else begin
                    partial_s2_s3 <= partial_s1_s2;
                    q2_s2_s3 <= 0;
                end
            end
        end
    end
    
    //==========================================================================
    // STAGE 3: Third Quotient Digit & Output
    //==========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            quotient <= 0;
            remainder <= 0;
        end else begin
            valid_out <= valid_s2_s3;
            
            if (valid_s2_s3) begin
                if (div_by_zero_s2_s3) begin
                    quotient <= 12'h000;
                    remainder <= 8'h00;
                end else begin
                    logic [3:0] q1, q2, q3;
                    logic [7:0] final_remainder;
                    logic [7:0] div_operand;
                    logic [11:0] div_result;
                    
                    q1 = q1_s2_s3;
                    q2 = q2_s2_s3;
                    
                    if (digit_count_s2_s3 == 3) begin
                        // OPTIMIZED: Direct division for third digit
                        div_operand = (v1_s2_s3 != 4'd0) ? {4'h0, v1_s2_s3} : divisor_s2_s3;
                        div_result = bcd_divide_digit(partial_s2_s3, div_operand);
                        q3 = div_result[11:8];
                        final_remainder = div_result[7:0];
                        quotient <= {q1, q2, q3};
                    end else if (digit_count_s2_s3 == 2) begin
                        q3 = 0;
                        final_remainder = partial_s2_s3;
                        quotient <= {4'h0, q1, q2};
                    end else begin
                        q2 = 0;
                        q3 = 0;
                        final_remainder = partial_s2_s3;
                        quotient <= {4'h0, 4'h0, q1};
                    end
                    
                    remainder <= final_remainder;
                end
            end
        end
    end

endmodule
