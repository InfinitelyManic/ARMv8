/*      David @InfinitelyManic
        Based on the code dev by Kevin M. Thomas @ https://github.com/kevinmthomasse/controlled_input/blob/master/controlled_input.s
        Start Date: 09/12/2016
        compiled on:
        Linux scw-cb8d4b 3.2.34-30 #17 SMP Mon Apr 13 15:53:45 UTC 2015 armv7l armv7l armv7l GNU/Linux
        Linux raspberrypi 4.4.11-v7+ #888 SMP Mon May 23 20:10:33 BST 2016 armv7l GNU/Linux
        Linux alarm 3.10.65-4-pine64-longsleep #16 SMP PREEMPT Sun Apr 3 10:56:40 CEST 2016 aarch64 GNU/Linux

        as controlled_input.s -o controlled_input.o && ld controlled_input.o -o controlled_input
        Last Revision: 10/02/2016 _004
*/

.bss
        buffer:         .zero 4                 // fill n bytes w/ zeros
.data
        prompt:         .asciz  "Enter ONLY 4 numbers: \n"
        .equ            len.prompt,.-prompt

        result: .asciz  " is your result!\n"
        .equ            len.result,.-result
.text
        .include "mymac_armv8.s"
        .global _start
_start:
        nop
        bl write_prompt

.read_buffer:                   // label for looping when input values are not between ASCII 0 and 9
        bl read_buffer

        // we only want ASCII number between 0 and 9 so reject anything else then redo read...
        ldr x9,=buffer
        mov x10, xzr                    // counter
        1:
                ldrb w11, [x9,x10]      // load one byte from buffer array at element n
                cmp x11, #0x30
                blt .read_buffer        // is it < ASCII value for 0; if so then get more input

                cmp x11, #0x39
                bgt .read_buffer        // is it > ASCII value for 9

        add x10,x10, #1             // increment counter n
        cmp x10, #3             // we only want to loop n times
        ble 1b

        bl write_int_result     // followed by the four (4) bytes.
        bl flush
        bl write_result         // write the phrase
exit:
        mov x0, xzr
        mov x8, #93
        svc 0

write_prompt:
        push2 x29, x30
        push2 x1, x2
        push2 x3, x4
        push2 x5, x6
        push2 x7, xzr
        mov x8, #64             // syscall write
        mov x0, #1              // fd dtdout
        ldr x1,=prompt
        mov x2, #len.prompt
        svc #0
        pop2 x7, xzr
        pop2 x5, x6
        pop2 x3, x4
        pop2 x1, x2
        pop2 x29, x30
        ret


read_buffer:
        push2 x29, x30
        push2 x1, x2
        push2 x3, x4
        push2 x5, x6
        push2 x7, xzr
        mov x8, #63             // syscall read
        mov x0, #0              // fd stdin
        ldr x1,=buffer
        mov x2, #4              // arbitrary length
        svc #0
        pop2 x7, xzr
        pop2 x5, x6
        pop2 x3, x4
        pop2 x1, x2
        pop2 x29, x30
        ret


write_result:
        push2 x29, x30
        push2 x1, x2
        push2 x3, x4
        push2 x5, x6
        push2 x7, xzr
        mov x8, #64             // syscall write
        mov x0, #1              // fd stdout
        ldr x1,=result
        mov x2, #len.result
        svc #0
        pop2 x7, xzr
        pop2 x5, x6
        pop2 x3, x4
        pop2 x1, x2
        pop2 x29, x30
        ret

write_int_result:
        push2 x29, x30
        push2 x1, x2
        push2 x3, x4
        push2 x5, x6
        push2 x7, xzr
        mov x8, #64             // syscall write
        mov x0, #1              // fd stdout
        ldr x1,=buffer
        mov x2, #4              // bytes to write
        svc #0
        pop2 x7, xzr
        pop2 x5, x6
        pop2 x3, x4
        pop2 x1, x2
        pop2 x29, x30
        ret

flush:
        push2 x29, x30
        push2 x1, x2
        push2 x3, x4
        push2 x5, x6
        push2 x7, xzr
        mov x8, #63             // syscall read
        mov x0, #2              // fd stderr
        ldr x1,=buffer
        mov x2, #(1 << 30)      // 0x40000000  = 1,073,741,824 bytes; this works but stream spillover will over
        svc #0
        pop2 x7, xzr
        pop2 x5, x6
        pop2 x3, x4
        pop2 x1, x2
        pop2 x29, x30
        ret
