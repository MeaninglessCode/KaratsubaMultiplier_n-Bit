`timescale 1ns / 1ps

module KaratsubaMultiplier_nbit #(parameter WIDTH=64) (
        input[WIDTH - 1:0] a,
        input[WIDTH - 1:0] b,
        output[(WIDTH * 2) - 1:0] p
    );
    
    // Booth Multiplication Functions
    function [3:0] mult2(input[1:0] M, input[1:0] N);
        mult2 = M * N[0] + (M << 1) * N[1];
    endfunction
    
    function [5:0] mult3(input[2:0] M, input[2:0] N);
        mult3 = M * N[0] + (M << 1) * N[1] + (M << 2) * N[2];
    endfunction
    
    function [5:0] mult4_5(input[3:0] M_5, input[3:0] N_5);
        mult4_5 = M_5 * N_5[0] + (M_5 << 1) * N_5[1] + (M_5 << 2) * N_5[2] + (M_5 << 3) * N_5[3];
    endfunction
    
    // Karatsuba Multiplication Function
    virtual class Karatsuba #(parameter KARAT_WIDTH=16);
        static function [(KARAT_WIDTH * 2) - 1:0] multiply(input[KARAT_WIDTH - 1:0] X, input[KARAT_WIDTH - 1:0] Y);
            if (KARAT_WIDTH == 4) begin
                reg[3:0] z0 = mult2(X[1:0], Y[1:0]);
                reg[5:0] z1 = mult3(X[1:0] + X[3:2], Y[1:0] + Y[3:2]);
                reg[3:0] z2 = mult2(X[3:2], Y[3:2]);
            
               return (z2 << 4) + ((z1 - (z2 + z0)) << 2) + z0;
            end
            else if (KARAT_WIDTH == 5) begin
                reg[3:0] z0 = mult2(X[1:0], Y[1:0]);
                reg[7:0] z1 = mult4_5(X[1:0] + X[4:2], Y[1:0] + Y[4:2]);
                reg[5:0] z2 = mult3(X[4:2], Y[4:2]);
            
                return (z2 << 4) + ((z1 - (z2 + z0)) << 2) + z0;
            end
            if ((KARAT_WIDTH % 2) == 0) begin
                reg[KARAT_WIDTH - 1:0] z0 = Karatsuba#(KARAT_WIDTH / 2)::multiply(
                    X[(KARAT_WIDTH / 2) - 1:0],
                    Y[(KARAT_WIDTH / 2) - 1:0]
                );
                
                reg[KARAT_WIDTH + 1:0] z1 = Karatsuba#((KARAT_WIDTH / 2) + 1)::multiply(
                    X[KARAT_WIDTH - 1:KARAT_WIDTH / 2] + X[(KARAT_WIDTH / 2) - 1:0],
                    Y[KARAT_WIDTH - 1: KARAT_WIDTH / 2] + Y[(KARAT_WIDTH / 2) - 1:0]
                );
                
                reg[KARAT_WIDTH - 1:0] z2 = Karatsuba#(KARAT_WIDTH / 2)::multiply(
                    X[KARAT_WIDTH - 1:KARAT_WIDTH / 2],
                    Y[KARAT_WIDTH - 1:KARAT_WIDTH / 2]
                );
                
                return (z2 << KARAT_WIDTH) + ((z1 - (z2 + z0)) << (KARAT_WIDTH / 2)) + z0;
            end
            else if ((KARAT_WIDTH % 2) != 0) begin
                reg[KARAT_WIDTH - 2:0] z0 = Karatsuba#((KARAT_WIDTH / 2) + 1)::multiply(
                    X[(KARAT_WIDTH / 2) - 1:0], Y[(KARAT_WIDTH / 2) - 1:0]);
                
                reg[KARAT_WIDTH:0] z1 = Karatsuba#((KARAT_WIDTH / 2) + 1)::multiply(
                    X[KARAT_WIDTH - 1:KARAT_WIDTH / 2] + X[(KARAT_WIDTH / 2) - 1:0],
                    Y[KARAT_WIDTH - 1:KARAT_WIDTH / 2] + Y[(KARAT_WIDTH / 2) - 1:0]
                );
                
                reg[KARAT_WIDTH - 2:0] z2 = Karatsuba#((KARAT_WIDTH / 2) + 1)::multiply(
                    X[KARAT_WIDTH - 1:KARAT_WIDTH / 2],
                    Y[KARAT_WIDTH - 1:KARAT_WIDTH / 2]
                );
                
                return (z2 << (KARAT_WIDTH - 1)) + ((z1 - (z2 + z0)) << ((KARAT_WIDTH - 1) / 2)) + z0;
            end
            else begin
                return a * b;
            end
        endfunction
    endclass
    
    // Do the multiplication using the Karatsuba class's multiply method
    assign p = Karatsuba#(WIDTH)::multiply(a, b);
endmodule