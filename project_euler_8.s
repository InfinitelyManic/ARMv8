/*
        David @InfinitelyManic
        https://projecteuler.net/problem=8
        Find the thirteen adjacent digits in the 1000-digit number that have the greatest product. What is the value of this product?
*/
.bss
        array:          .space 1000,0
.data
        fmt:            .asciz  "%d %d %d %d %d %d %d %d %d %d %d %d %d %llu %llu Pos:%d\n"               //
        c_array:        .ascii  "73167176531330624919225119674426574742355349194934"
                        .ascii  "96983520312774506326239578318016984801869478851843"
                        .ascii  "85861560789112949495459501737958331952853208805511"
                        .ascii  "12540698747158523863050715693290963295227443043557"
                        .ascii  "66896648950445244523161731856403098711121722383113"
                        .ascii  "62229893423380308135336276614282806444486645238749"
                        .ascii  "30358907296290491560440772390713810515859307960866"
                        .ascii  "70172427121883998797908792274921901699720888093776"
                        .ascii  "65727333001053367881220235421809751254540594752243"
                        .ascii  "52584907711670556013604839586446706324415722155397"
                        .ascii  "53697817977846174064955149290862569321978468622482"
                        .ascii  "83972241375657056057490261407972968652414535100474"
                        .ascii  "82166370484403199890008895243450658541227588666881"
                        .ascii  "16427171479924442928230863465674813919123162824586"
                        .ascii  "17866458359124566529476545682848912883142607690042"
                        .ascii  "24219022671055626321111109370544217506941658960408"
                        .ascii  "07198403850962455444362981230987879927244284909188"
                        .ascii  "84580156166097919133875499200524063689912560717606"
                        .ascii  "05886116467109405077541002256983155200055935729725"
                        .ascii  "71636269561882670428252483600823257530420752963450"
        .equ    len_c_array,.-c_array
.text
        .global main
        .include "mymac_armv8.s"
main:
        .align
        nop
        // convert ascii array to decimal array
        mov w19, 0x30
        ldr x20,=c_array
        mov x21, #len_c_array
        sub x21, x21, 1
        ldr x22,=array

        mov x23, xzr
        1:
                ldrb w1, [x20,x23]      // get ascii char
                sub w1, w1, w19         // 0x30 - ascii value - assumes ascii number chars only
                strb w1, [x22,x23]      // store byte into n_array element
                //bl write
                //bl write
        add x23, x23, 1
        cmp x23, x21
        b.le 1b

.stop0:
        nop
        ldr x20,=array                  // array pointer
        mov x22, 1                      // for the insertion of ones into vector for mask
        mov x23, xzr                    // init positon counter
        mov x24, 123                    // init for max number
        1:
                ld1 {v0.16b}, [x20]     //load 16 single byte elements.

                ins v0.b[13], w22       //mask last three elements by replacing zeros w/ ones
                ins v0.b[14], w22       //mask last three elements by replacing zeros w/ ones
                ins v0.b[15], w22       //mask last three elements by replacing zeros w/ ones

                uminv b1, v0.16b        //get min value from vector and place into byte vector in v1
                umov w0, v1.16b[0]      //mov scalar to reg wn to test flags; research flag instructions in simd
                cmp x0, #0              // if any elements of the vector == 0 then branch...
                b.eq .skip

                // This is just for printing purposes so I can see the elements that make up the solution
                umov w1,v0.16b[0]
                umov w2,v0.16b[1]
                umov w3,v0.16b[2]
                umov w4,v0.16b[3]
                umov w5,v0.16b[4]
                umov w6,v0.16b[5]
                umov w7,v0.16b[6]
                umov w8,v0.16b[7]
                umov w9,v0.16b[8]
                umov w10,v0.16b[9]
                umov w11,v0.16b[10]
                umov w12,v0.16b[11]
                umov w13,v0.16b[12]
                umov w13,v0.16b[12]
.stop1:
                nop

                ext v1.16b, v0.16b, v0.16b, 8           // bitwise extract begin @ element #8; abcd|efgh 1234|5678 --> 1234|5678 abcd|efgh
                mul v2.16b, v1.16b, v0.16b              // mul 1234|5678 x abcd|efgh = 1a 2b 3c 4d | 5e 6f 7g 8h; (4-bit x 4-bit) = 8-bit form;

                ext v3.16b, v2.16b, v2.16b, 4           // bitwise extract begin @ element #4 since we need 1a(5e) 2b(6f) 3c(7g) 4d(8h)
                umull v4.8h, v2.8b, v3.8b               // 8-bit form x 8-bit form = 16-bit form

                ext v5.8b, v4.8b, v4.8b, 4              // bitwise extract begin @ element #4 since we need 1a(5e) 2b(6f) * 3c(7g) 4d(8h)
                umull v6.4s, v4.4h, v5.4h               // 16-bit form x 16-bit form = 32-bit form = single == 1a(5e) 2b(6f) * 3c(7g) 4d(8h)

                umov w25, v6.s[0]                       // mov 1a(5e) 2b(6f)
                umov w26, v6.s[1]                       // mov 3c(7g) 4d(8h)
                mul x14, x25, x26                       // mul final pair 1a(5e)2b(6f)* 3c(7g) 4d(8h)

                cmp x14, x24
                csel x24, x14, x24, gt                  // if new calc > old max then new calc else keep old max

                bl write
.skip:
        add x20, x20, 1                                 // advance to next position in array
        add x23, x23, 1                                 // increment counter
        cmp x23, x21
        b.le 1b

_exit
write:
        push2 x29, x30
        push2 x20,x21
        push2 x22, x23
        // ----------
        push2 x23,xzr
        push2 x14, x24
        push2 x12, x13
        push2 x10, x11
        push2 x8, x9
        ldr x0,=fmt
        bl printf
        pop2 x8, x9
        pop2 x10, x11
        pop2 x12, x13
        pop2 x14, x24
        pop2 x23,xzr
        // ----------
        pop2 x22, x23
        pop2 x20,x21
        pop2 x29, x30
        ret
