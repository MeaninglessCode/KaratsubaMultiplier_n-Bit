`timescale 1ns / 1ps

module KaratsubaMultiplier_nbit #(parameter WIDTH=64) (
        input[WIDTH - 1:0] a,
        input[WIDTH - 1:0] b,
        output[(WIDTH * 2) - 1:0] p
    );
    
    // Karatsuba Multiplication Function
    virtual class Karatsuba #(parameter KARAT_WIDTH=16);
        static function [(KARAT_WIDTH * 2) - 1:0] multiply(input[KARAT_WIDTH - 1:0] X, input[KARAT_WIDTH - 1:0] Y);
            if (KARAT_WIDTH < 5) begin
                return X * Y;
            end
            if ((KARAT_WIDTH % 2) == 0) begin
                reg[KARAT_WIDTH - 1:0] z0 = Karatsuba#((KARAT_WIDTH / 2))::multiply(
                    X[((KARAT_WIDTH / 2)) - 1:0],
                    Y[((KARAT_WIDTH / 2)) - 1:0]
                );
                
                reg[KARAT_WIDTH + 1:0] z1 = Karatsuba#(((KARAT_WIDTH / 2)) + 1)::multiply(
                    X[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)] + X[((KARAT_WIDTH / 2)) - 1:0],
                    Y[KARAT_WIDTH - 1: (KARAT_WIDTH / 2)] + Y[((KARAT_WIDTH / 2)) - 1:0]
                );
                
                reg[KARAT_WIDTH - 1:0] z2 = Karatsuba#((KARAT_WIDTH / 2))::multiply(
                    X[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)],
                    Y[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)]
                );
                
                return (z2 << KARAT_WIDTH) + ((z1 - (z2 + z0)) << ((KARAT_WIDTH / 2))) + z0;
            end
            else if ((KARAT_WIDTH % 2) != 0) begin
                reg[KARAT_WIDTH - 2:0] z0 = Karatsuba#(((KARAT_WIDTH / 2)) + 1)::multiply(
                    X[((KARAT_WIDTH / 2)) - 1:0], Y[((KARAT_WIDTH / 2)) - 1:0]);
                
                reg[KARAT_WIDTH:0] z1 = Karatsuba#(((KARAT_WIDTH / 2)) + 1)::multiply(
                    X[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)] + X[((KARAT_WIDTH / 2)) - 1:0],
                    Y[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)] + Y[((KARAT_WIDTH / 2)) - 1:0]
                );
                
                reg[KARAT_WIDTH - 2:0] z2 = Karatsuba#(((KARAT_WIDTH / 2)) + 1)::multiply(
                    X[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)],
                    Y[KARAT_WIDTH - 1:(KARAT_WIDTH / 2)]
                );
                
                return (z2 << (KARAT_WIDTH - 1)) + ((z1 - (z2 + z0)) << ((KARAT_WIDTH - 1) / 2)) + z0;
            end
        endfunction
    endclass
    
    // Do the multiplication using the Karatsuba class's multiply method
    assign p = Karatsuba#(WIDTH)::multiply(a, b);
endmodule