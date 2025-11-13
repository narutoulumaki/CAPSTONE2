`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: vedicdivider_dhwajank
// Description: BCD Division using Dhvajanka Sutra (Vedic Mathematics)
//              Divides a 4-digit BCD dividend by a 2-digit BCD divisor
//              Produces a 3-digit BCD quotient and 2-digit BCD remainder
//////////////////////////////////////////////////////////////////////////////////

module vedicdivider_dhwajank(
    input logic [15:0] dividend,  // 4 digit BCD number (0000-9999)
    input logic [7:0] divisor,    // 2 digit BCD number (00-99)
    output logic [11:0] quotient, // 3 digit BCD number (000-999)
    output logic [7:0] remainder  // 2 digit BCD number (00-99)
    );

    // Internal variables for BCD digits
    logic [3:0] d1, d2, d3, d4;  // Dividend digits
    logic [3:0] v1, v2;          // Divisor digits (v1=first, v2=flag)
    logic [3:0] q1, q2, q3;      // Quotient digits
    logic [3:0] r1, r2;          // Remainder digits
    
    logic [7:0] partial_dividend;  // Current partial dividend (2 BCD digits)
    logic [11:0] gross_dividend;   // Gross dividend (3 BCD digits)
    logic [15:0] actual_dividend;  // Actual dividend (flag + 3 BCD digits)
    logic [3:0] temp_q;            // Temporary quotient digit
    logic [7:0] temp_r;            // Temporary remainder
    logic [7:0] divisor_bcd;       // Full divisor
    
    //////////////////////////////////////////////////////////////////////////////////
    // BCD Addition Function
    // Adds two 2-digit BCD numbers
    //////////////////////////////////////////////////////////////////////////////////
    function automatic [7:0] bcd_add(input [7:0] a, input [7:0] b);
        logic [7:0] sum;
        logic [3:0] digit1, digit2;
        logic carry;
        logic [4:0] temp_sum;
        
        // Add lower nibble
        temp_sum = a[3:0] + b[3:0];
        digit2 = temp_sum[3:0];
        carry = 0;
        
        if (temp_sum > 9) begin
            digit2 = digit2 + 6;  // Add 6 to adjust BCD (same as subtracting 10 and adding 16)
            carry = 1;
        end
        
        // Add upper nibble
        temp_sum = a[7:4] + b[7:4] + carry;
        digit1 = temp_sum[3:0];
        
        if (temp_sum > 9) begin
            digit1 = digit1 + 6;  // Add 6 to adjust BCD
        end
            
        sum = {digit1, digit2};
        return sum;
    endfunction
    
    //////////////////////////////////////////////////////////////////////////////////
    // BCD Subtraction Function (8-bit)
    // Subtracts two 2-digit BCD numbers
    // Returns {4'b0000, result} if positive, {4'b1111, 8'h00} if negative
    //////////////////////////////////////////////////////////////////////////////////
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
    
    //////////////////////////////////////////////////////////////////////////////////
    // BCD Subtraction Function (12-bit)
    // Subtracts an 8-bit BCD number from a 12-bit BCD number
    // Returns {4'b0000, 12-bit result} if positive, {4'b1111, 12'h000} if negative
    //////////////////////////////////////////////////////////////////////////////////
    function automatic [15:0] bcd_sub_12bit(input [11:0] a, input [7:0] b);
        logic [11:0] diff;
        logic [3:0] digit1, digit2, digit3;
        logic borrow;
        logic is_negative;
        
        is_negative = 0;
        borrow = 0;
        
        // Compare a and b (considering a is 12-bit and b is 8-bit)
        if ({4'h0, a[11:0]} < {8'h00, b})
            is_negative = 1;
            
        if (!is_negative) begin
            // Subtract digit 2 (rightmost)
            if (a[3:0] < b[3:0] + borrow) begin
                digit3 = a[3:0] + 10 - b[3:0] - borrow;
                borrow = 1;
            end else begin
                digit3 = a[3:0] - b[3:0] - borrow;
                borrow = 0;
            end
            
            // Subtract digit 1 (middle)
            if (a[7:4] < b[7:4] + borrow) begin
                digit2 = a[7:4] + 10 - b[7:4] - borrow;
                borrow = 1;
            end else begin
                digit2 = a[7:4] - b[7:4] - borrow;
                borrow = 0;
            end
            
            // Subtract digit 0 (leftmost) - only borrow, no subtraction from b
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
    
    //////////////////////////////////////////////////////////////////////////////////
    // BCD Multiplication Function
    // Multiplies two single BCD digits using repeated addition
    //////////////////////////////////////////////////////////////////////////////////
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
    
    //////////////////////////////////////////////////////////////////////////////////
    // Main Dhvajanka Division Algorithm
    //////////////////////////////////////////////////////////////////////////////////
    always_comb begin
        logic [11:0] sub_tmp;
        int i;
        logic [7:0] div_compare;
        logic [3:0] q_digits[3];  // Array to store quotient digits dynamically
        int digit_count = 0;  // Count how many quotient digits we computed
        int next_digit_idx;  // Track which digit to bring down next (2=d2, 3=d3, 4=d4)
        logic [3:0] next_digit;  // The next digit to bring down
        int quotient_count;  // How many quotient digits we actually computed
        
        // Extract BCD digits from dividend and divisor
        d1 = dividend[15:12];
        d2 = dividend[11:8];
        d3 = dividend[7:4];
        d4 = dividend[3:0];
        v1 = divisor[7:4];   // First digit (divide by this)
        v2 = divisor[3:0];   // Second digit (flag for Dhvajanka)
        divisor_bcd = divisor;
        
        // Set comparison value based on divisor type
        div_compare = (v1 != 0) ? {4'h0, v1} : divisor_bcd;
        
        // Handle division by zero
        if (divisor == 8'h00) begin
            q1 = 0; q2 = 0; q3 = 0;
            r1 = 0; r2 = 0;
        end else begin
            // Initialize variables
            quotient_count = 0;
            q_digits[0] = 0;
            q_digits[1] = 0;
            q_digits[2] = 0;
            next_digit_idx = 2;  // Start with d2
            
            // Start with first digit d1
            partial_dividend = {4'h0, d1};
            
            //////////////////////////////////////////////////////////////////////////////////
            // Bring down digits until partial_dividend >= divisor (or first digit of divisor)
            //////////////////////////////////////////////////////////////////////////////////
            if (partial_dividend < div_compare && next_digit_idx == 2) begin
                partial_dividend = {d1, d2};
                next_digit_idx = 3;
            end
            if (partial_dividend < div_compare && next_digit_idx == 3) begin
                partial_dividend = {partial_dividend[3:0], d3};
                next_digit_idx = 4;
            end
            if (partial_dividend < div_compare && next_digit_idx == 4) begin
                partial_dividend = {partial_dividend[3:0], d4};
                next_digit_idx = 5;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // STEP 1: Compute first quotient digit
            //////////////////////////////////////////////////////////////////////////////////
            
            // Divide partial_dividend by v1 (or full divisor if v1=0)
            temp_q = 0;
            temp_r = partial_dividend;
            
            if (v1 != 4'd0) begin
                for (int i = 0; i < 10; i++) begin
                    sub_tmp = bcd_sub(temp_r, {4'h0, v1});
                    if (sub_tmp[11]) break;
                    temp_r = sub_tmp[7:0];
                    temp_q = temp_q + 1;
                end
            end else begin
                for (int i = 0; i < 10; i++) begin
                    sub_tmp = bcd_sub(temp_r, divisor_bcd);
                    if (sub_tmp[11]) break;
                    temp_r = sub_tmp[7:0];
                    temp_q = temp_q + 1;
                end
            end
            
            // Dhvajanka: Compute gross and actual dividend (if there's a next digit to bring down)
            if (next_digit_idx <= 4) begin
                // Determine which digit to bring down next
                case (next_digit_idx)
                    2: next_digit = d2;
                    3: next_digit = d3;
                    4: next_digit = d4;
                    default: next_digit = 0;
                endcase
                
                // Gross dividend = (remainder from division) + (next digit)
                gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                
                // Actual dividend = gross dividend - (flag × quotient)
                if (v1 != 0) begin
                    actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                end else begin
                    actual_dividend = {4'h0, gross_dividend};
                end
                
                // Adjustment loop: If actual dividend is negative, reduce quotient and recalculate
                for (int adj = 0; adj < 3; adj++) begin
                    if (actual_dividend[15:12] == 4'b1111 && (temp_q > 0)) begin
                        temp_q = temp_q - 1;
                        if (v1 != 0) begin
                            temp_r = bcd_add(temp_r, {4'h0, v1});
                        end else begin
                            temp_r = bcd_add(temp_r, divisor_bcd);
                        end
                        gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                        if (v1 != 0) begin
                            actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                        end else begin
                            actual_dividend = {4'h0, gross_dividend};
                        end
                    end
                end
                
                // Extract the lower 2 BCD digits from the 12-bit result
                partial_dividend[7:4] = actual_dividend[7:4];
                partial_dividend[3:0] = actual_dividend[3:0];
                
                next_digit_idx = next_digit_idx + 1;
                
                // Store quotient digit only if we used a digit from dividend
                q_digits[quotient_count] = temp_q;
                quotient_count = quotient_count + 1;
            end else begin
                // No more digits to bring down, use temp_r as final remainder
                partial_dividend = temp_r;
                
                // Store last quotient digit
                q_digits[quotient_count] = temp_q;
                quotient_count = quotient_count + 1;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // STEP 2: Compute second quotient digit (if more digits remain)
            //////////////////////////////////////////////////////////////////////////////////
            if (next_digit_idx <= 4) begin
                temp_q = 0;
                temp_r = partial_dividend;
            
                if (v1 != 4'd0) begin
                    for (int i = 0; i < 10; i++) begin
                        sub_tmp = bcd_sub(temp_r, {4'h0, v1});
                        if (sub_tmp[11]) break;
                        temp_r = sub_tmp[7:0];
                        temp_q = temp_q + 1;
                    end
                end else begin
                    for (int i = 0; i < 10; i++) begin
                        sub_tmp = bcd_sub(temp_r, divisor_bcd);
                        if (sub_tmp[11]) break;
                        temp_r = sub_tmp[7:0];
                        temp_q = temp_q + 1;
                    end
                end
                
                // Compute gross and actual dividend (if there's a next digit)
                if (next_digit_idx <= 4) begin
                    case (next_digit_idx)
                        2: next_digit = d2;
                        3: next_digit = d3;
                        4: next_digit = d4;
                        default: next_digit = 0;
                    endcase
                    
                    gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                    if (v1 != 0) begin
                        actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                    end else begin
                        actual_dividend = {4'h0, gross_dividend};
                    end
                    
                    for (int adj = 0; adj < 3; adj++) begin
                        if (actual_dividend[15:12] == 4'b1111 && (temp_q > 0)) begin
                            temp_q = temp_q - 1;
                            if (v1 != 0) begin
                                temp_r = bcd_add(temp_r, {4'h0, v1});
                            end else begin
                                temp_r = bcd_add(temp_r, divisor_bcd);
                            end
                            gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                            if (v1 != 0) begin
                                actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                            end else begin
                                actual_dividend = {4'h0, gross_dividend};
                            end
                        end
                    end
                    partial_dividend = actual_dividend[7:0];
                    next_digit_idx = next_digit_idx + 1;
                    
                    // Store quotient digit
                    q_digits[quotient_count] = temp_q;
                    quotient_count = quotient_count + 1;
                end else begin
                    // No more digits to bring down
                    partial_dividend = temp_r;
                    
                    // Store last quotient digit
                    q_digits[quotient_count] = temp_q;
                    quotient_count = quotient_count + 1;
                end
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // STEP 3: Compute third quotient digit (if more digits remain)
            //////////////////////////////////////////////////////////////////////////////////
            if (next_digit_idx <= 4) begin
                temp_q = 0;
                temp_r = partial_dividend;
            
                if (v1 != 4'd0) begin
                    for (int i = 0; i < 10; i++) begin
                        sub_tmp = bcd_sub(temp_r, {4'h0, v1});
                        if (sub_tmp[11]) break;
                        temp_r = sub_tmp[7:0];
                        temp_q = temp_q + 1;
                    end
                end else begin
                    for (int i = 0; i < 10; i++) begin
                        sub_tmp = bcd_sub(temp_r, divisor_bcd);
                        if (sub_tmp[11]) break;
                        temp_r = sub_tmp[7:0];
                        temp_q = temp_q + 1;
                    end
                end
                
                // Compute gross and actual dividend (if there's a next digit)
                if (next_digit_idx <= 4) begin
                    case (next_digit_idx)
                        2: next_digit = d2;
                        3: next_digit = d3;
                        4: next_digit = d4;
                        default: next_digit = 0;
                    endcase
                    
                    gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                    if (v1 != 0) begin
                        actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                    end else begin
                        actual_dividend = {4'h0, gross_dividend};
                    end
                    
                    for (int adj = 0; adj < 3; adj++) begin
                        if (actual_dividend[15:12] == 4'b1111 && (temp_q > 0)) begin
                            temp_q = temp_q - 1;
                            if (v1 != 0) begin
                                temp_r = bcd_add(temp_r, {4'h0, v1});
                            end else begin
                                temp_r = bcd_add(temp_r, divisor_bcd);
                            end
                            gross_dividend = {temp_r[7:4], temp_r[3:0], next_digit};
                            if (v1 != 0) begin
                                actual_dividend = bcd_sub_12bit(gross_dividend, bcd_multiply_digits(temp_q, v2));
                            end else begin
                                actual_dividend = {4'h0, gross_dividend};
                            end
                        end
                    end
                    partial_dividend = actual_dividend[7:0];
                end else begin
                    // No more digits to bring down
                    partial_dividend = temp_r;
                end
                
                // Store quotient digit
                q_digits[quotient_count] = temp_q;
                quotient_count = quotient_count + 1;
            end
            
            //////////////////////////////////////////////////////////////////////////////////
            // Map quotient digits to output (right-aligned based on count)
            //////////////////////////////////////////////////////////////////////////////////
            case (quotient_count)
                1: begin
                    q1 = 0;
                    q2 = 0;
                    q3 = q_digits[0];
                end
                2: begin
                    q1 = 0;
                    q2 = q_digits[0];
                    q3 = q_digits[1];
                end
                3: begin
                    q1 = q_digits[0];
                    q2 = q_digits[1];
                    q3 = q_digits[2];
                end
                default: begin
                    q1 = 0;
                    q2 = 0;
                    q3 = 0;
                end
            endcase
            
            // Final remainder
            r1 = partial_dividend[7:4];
            r2 = partial_dividend[3:0];
        end
        
        quotient = {q1, q2, q3};
        remainder = {r1, r2};
    end
endmodule