`timescale 1ns / 1ps
// LED positions inside 7-segment
// A
// F B
// G
// E C
// D DP
// digit positions on Basys3 :
// in3(left), in2, in1, in0(right)
module SevSeg_4digit(
input clk, blink,
input [3:0] in0, in1, in2, in3, // 4 values for 4 digits (hexadecimal value)
output a, b, c, d, e, f, g, dp, //individual LED output for the 7-segmentalong with the digital point
output [3:0] an); // anode: 4-bit enable signal (active low)
// divide system clock (100Mhz for Basys3) by 2^N using a counter, which allows us to multiplex at lower speed
    reg clk_adj;
    reg flash;
    clk_adjuster adj( clk, 'b1, 'd25_000_000, clk_adj);
    localparam N = 18;
    logic [N-1:0] count = {N{1'b0}}; //initial value 
    always@ (posedge clk)begin
        count <= count + 1;
            if(clk_adj)begin flash <= 1; end
            else begin flash <=0; end
    end
logic [3:0]digit_val; // 7-bit register to hold the current data on output
logic [3:0]digit_en; //register for enable vector 

always_comb
begin
    digit_en = 4'b1111; //default
    digit_val = in0; //default
    case(count[N-1:N-2]) //using only the 2 MSB's of the counter
    2'b00 : //select first 7Seg.
        begin
digit_val = in0;
digit_en = 4'b1110;
end
2'b01: //select second 7Seg.
begin
digit_val = in1;
digit_en = 4'b1101;
end
2'b10: //select third 7Seg.
begin
digit_val = in2;
digit_en = 4'b1011;
end
2'b11: //select forth 7Seg.
begin
digit_val = in3;
digit_en = 4'b0111;
end
endcase
end
//continues on next page
//Convert digit number to LED vector. LEDs are active low.
logic [6:0] sseg_LEDs;
always_comb
begin
sseg_LEDs = 7'b1111111; //default
case(blink)
    'b1: case(flash)
        'b1: sseg_LEDs = 7'b1111111;
        'b0: case(digit_val)
            4'h0 : sseg_LEDs = 7'b1000000; //to display 0
            4'h1 : sseg_LEDs = 7'b1111001; //to display 1
            4'h2 : sseg_LEDs = 7'b0100100; //to display 2
            4'h3 : sseg_LEDs = 7'b0110000; //to display 3
            4'h4 : sseg_LEDs = 7'b0011001; //to display 4
            4'h5 : sseg_LEDs = 7'b0010010; //to display 5
            4'h6 : sseg_LEDs = 7'b0000010; //to display 6
            4'h7 : sseg_LEDs = 7'b1111000; //to display 7
            4'h8 : sseg_LEDs = 7'b0000000; //to display 8
            4'h9 : sseg_LEDs = 7'b0010000; //to display 9
            4'ha : sseg_LEDs = 7'b0001000; //to display a
            4'hb : sseg_LEDs = 7'b0000011; //to display b
            4'hc : sseg_LEDs = 7'b1000110; //to display c
            4'hd : sseg_LEDs = 7'b0100001; //to display d
            4'he : sseg_LEDs = 7'b0000110; //to display e
            4'hf : sseg_LEDs = 7'b0001110; //to display f
        endcase
     endcase
    'b0: case(digit_val)
        4'h0 : sseg_LEDs = 7'b1000000; //to display 0
        4'h1 : sseg_LEDs = 7'b1111001; //to display 1
        4'h2 : sseg_LEDs = 7'b0100100; //to display 2
        4'h3 : sseg_LEDs = 7'b0110000; //to display 3
        4'h4 : sseg_LEDs = 7'b0011001; //to display 4
        4'h5 : sseg_LEDs = 7'b0010010; //to display 5
        4'h6 : sseg_LEDs = 7'b0000010; //to display 6
        4'h7 : sseg_LEDs = 7'b1111000; //to display 7
        4'h8 : sseg_LEDs = 7'b0000000; //to display 8
        4'h9 : sseg_LEDs = 7'b0010000; //to display 9
        4'ha : sseg_LEDs = 7'b0001000; //to display a
        4'hb : sseg_LEDs = 7'b0000011; //to display b
        4'hc : sseg_LEDs = 7'b1000110; //to display c
        4'hd : sseg_LEDs = 7'b0100001; //to display d
        4'he : sseg_LEDs = 7'b0000110; //to display e
        4'hf : sseg_LEDs = 7'b0001110; //to display f
    default : sseg_LEDs = 7'b0111111; //dash
    endcase
    endcase
end
assign an =  digit_en;
assign {g, f, e, d, c, b, a} = sseg_LEDs;
assign dp = 1'b1; //turn dp off
endmodule