`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: vedicdivider_dhwajank_hybrid
// Description: Hybrid BCD-Binary Division using Dhvajanka Sutra (Vedic Mathematics)
//              - BCD inputs/outputs for decimal compatibility
//              - Binary core for FPGA efficiency
//              Divides a 4-digit BCD dividend by a 2-digit BCD divisor
//              Produces a 3-digit BCD quotient and 2-digit BCD remainder
//////////////////////////////////////////////////////////////////////////////////

module vedicdivider_dhwajank_hybrid(
    input logic [15:0] dividend_bcd,  // 4 digit BCD number (0000-9999)
    input logic [7:0] divisor_bcd,    // 2 digit BCD number (00-99)
    output logic [11:0] quotient_bcd, // 3 digit BCD number (000-999)
    output logic [7:0] remainder_bcd  // 2 digit BCD number (00-99)
    );

    // Binary intermediate values
    logic [13:0] dividend_bin;   // Max 9999 needs 14 bits
    logic [6:0] divisor_bin;     // Max 99 needs 7 bits
    logic [13:0] quotient_bin;   // Binary quotient
    logic [6:0] remainder_bin;   // Binary remainder (max 98, needs 7 bits)
    
    //////////////////////////////////////////////////////////////////////////////////
    // BCD to Binary Conversion Functions
    //////////////////////////////////////////////////////////////////////////////////
    
    // Convert 4-digit BCD to binary (0-9999)
    function automatic [13:0] bcd4_to_binary(input [15:0] bcd);
        logic [13:0] result;
        logic [3:0] d3, d2, d1, d0;  // Digits from MSB to LSB
        
        d3 = bcd[15:12];
        d2 = bcd[11:8];
        d1 = bcd[7:4];
        d0 = bcd[3:0];
        
        // result = d3*1000 + d2*100 + d1*10 + d0
        result = (d3 * 14'd1000) + (d2 * 14'd100) + (d1 * 14'd10) + d0;
        return result;
    endfunction
    
    // Convert 2-digit BCD to binary (0-99)
    function automatic [6:0] bcd2_to_binary(input [7:0] bcd);
        logic [6:0] result;
        logic [3:0] d1, d0;
        
        d1 = bcd[7:4];
        d0 = bcd[3:0];
        
        // result = d1*10 + d0
        result = (d1 * 7'd10) + d0;
        return result;
    endfunction
    
    //////////////////////////////////////////////////////////////////////////////////
    // Binary to BCD Conversion Functions
    //////////////////////////////////////////////////////////////////////////////////
    
    // Convert binary to 4-digit BCD using double dabble algorithm
    function automatic [15:0] binary_to_bcd4(input [13:0] bin);
        logic [29:0] shift_reg;  // 14 bits binary + 16 bits BCD
        integer i;
        
        shift_reg = {16'b0, bin};
        
        for (i = 0; i < 14; i = i + 1) begin
            // Add 3 to any BCD digit > 4 before shifting
            if (shift_reg[17:14] > 4) shift_reg[17:14] = shift_reg[17:14] + 3;
            if (shift_reg[21:18] > 4) shift_reg[21:18] = shift_reg[21:18] + 3;
            if (shift_reg[25:22] > 4) shift_reg[25:22] = shift_reg[25:22] + 3;
            if (shift_reg[29:26] > 4) shift_reg[29:26] = shift_reg[29:26] + 3;
            
            // Shift left
            shift_reg = shift_reg << 1;
        end
        
        return shift_reg[29:14];
    endfunction
    
    // Convert binary to 2-digit BCD using bounded loop
    function automatic [7:0] binary_to_bcd2(input [6:0] bin);
        logic [3:0] tens, ones;
        logic [6:0] temp;
        integer i;
        
        temp = bin;
        tens = 4'd0;
        
        // Max 99 requires at most 9 subtractions of 10
        for (i = 0; i < 10; i = i + 1) begin
            if (temp >= 10) begin
                temp = temp - 7'd10;
                tens = tens + 4'd1;
            end
        end
        
        ones = temp[3:0];
        return {tens, ones};
    endfunction
    
    //////////////////////////////////////////////////////////////////////////////////
    // Binary Vedic Division Core (Dhvajanka Algorithm - Binary Version)
    // Applies Vedic Dhvajanka principle to binary division:
    // 1. Divide high bits by divisor high bits (flag technique)
    // 2. Compute gross dividend by appending next bits
    // 3. Compute actual dividend by subtracting flag × quotient_bit
    // 4. Adjust if result goes negative
    //
    // For binary: flag = high bit of divisor, quotient bits = 0 or 1
    // This maps to standard restoring division but follows Vedic structure
    //////////////////////////////////////////////////////////////////////////////////
    function automatic [20:0] vedic_divide_binary(input [13:0] dividend, input [6:0] divisor);
        logic [13:0] quotient;
        logic [7:0] remainder;  // 8 bits to handle up to 99
        integer i;
        
        quotient = 14'd0;
        remainder = 8'd0;
        
        // Dhvajanka in binary: Process digit-by-digit (bit-by-bit)
        // For each bit position from MSB to LSB:
        //   1. Bring down next bit to form gross dividend (shift + append)
        //   2. Trial division: Can we subtract divisor?
        //   3. If yes: quotient bit = 1, actual dividend = gross - divisor
        //   4. If no: quotient bit = 0, actual dividend = gross (no adjustment needed)
        
        for (i = 13; i >= 0; i = i - 1) begin
            // Step 1: Gross dividend = (remainder << 1) | next_bit
            remainder = {remainder[6:0], dividend[i]};
            
            // Step 2 & 3: Dhvajanka trial division and adjustment
            if (remainder >= {1'b0, divisor}) begin
                // Can subtract: quotient bit = 1
                remainder = remainder - {1'b0, divisor};  // Actual dividend
                quotient[i] = 1'b1;
            end else begin
                // Cannot subtract: quotient bit = 0, no adjustment
                quotient[i] = 1'b0;
            end
        end
        
        return {remainder[6:0], quotient};
    endfunction
    
    //////////////////////////////////////////////////////////////////////////////////
    // Main Logic: BCD → Binary → Vedic Division → BCD
    //////////////////////////////////////////////////////////////////////////////////
    always_comb begin
        logic [20:0] div_result;
        
        // Step 1: Convert BCD inputs to binary
        dividend_bin = bcd4_to_binary(dividend_bcd);
        divisor_bin = bcd2_to_binary(divisor_bcd);
        
        // Step 2: Perform binary Vedic division
        if (divisor_bin == 0) begin
            // Division by zero protection
            quotient_bin = 14'd0;
            remainder_bin = 7'd0;
        end else begin
            div_result = vedic_divide_binary(dividend_bin, divisor_bin);
            quotient_bin = div_result[13:0];
            remainder_bin = div_result[20:14];
        end
        
        // Step 3: Convert binary results back to BCD
        quotient_bcd = binary_to_bcd4(quotient_bin);
        remainder_bcd = binary_to_bcd2(remainder_bin);
    end

endmodule
