/*                                                                                                                                                                      
        David @InfinitelyManic                                                                                                                                          
        Based on the code dev by Kevin M. Thomas @ https://github.com/kevinmthomasse/controlled_input/blob/master/controlled_input.s                                    
        Start Date: 09/12/2016                                                                                                                                          
        compiled on:                                                                                                                                                    
        "Arch Linux ARM"                                                                                                                                                
        3.10.65-4-pine64-longsleep                                                                                                                                      
        as controlled_input.s -o controlled_input.o && ld controlled_input.o -o controlled_input                                                                        
        Last Revision: 09/18/2016 _001                                                                                                                                  
*/                                                                                                                                                                      
                                                                                                                                                                        
.bss                                                                                                                                                                    
        buffer:         .zero 4                 // fill n bytes w/ zeros                                                                                                
        .align                                                                                                                                                          
.data                                                                                                                                                                   
        prompt:         .asciz  "Enter ONLY 4 numbers: \n"                                                                                                              
        .equ            len.prompt,.-prompt                                                                                                                             
                                                                                                                                                                        
        result: .asciz  " is your result!\n"                                                                                                                            
        .equ            len.result,.-result                                                                                                                             
                                                                                                                                                                        
        .align                                                                                                                                                          
.text                                                                                                                                                                   
        .global _start                                                                                                                                                  
                                                                                                                                                                        
        .macro push2, xreg1, xreg2                                                                                                                                      
        .push2\@:                                                                                                                                                       
         stp     \xreg1, \xreg2, [sp, #-16]!                                                                                                                            
        .endm                                                                                                                                                           
                                                                                                                                                                        
        .macro  pop2, xreg1, xreg2                                                                                                                                      
        .pop2\@:                                                                                                                                                        
        ldp     \xreg1, \xreg2, [sp], #16                                                                                                                               
        .endm                                                                                                                                                           
                                                                                                                                                                        
        .align                                                                                                                                                          
                                                                                                                                                                        
                                                                                                                                                                        
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
                cmp w11, #0x30                                                                                                                                          
                blt .read_buffer        // is it < ASCII value for 0; if so then get more input                                                                         
                                                                                                                                                                        
                cmp w11, #0x39                                                                                                                                          
                bgt .read_buffer        // is it > ASCII value for 9                                                                                                    
                                                                                                                                                                        
        add x10, x10, #1             // increment counter                                                                                                               
        cmp x10, #3             // we only want to loop n times                                                                                                         
        ble 1b                                                                                                                                                          
                                                                                                                                                                        
        //bl close_fd                                                                                                                                                   
        bl write_int_result     // followed by the four (4) bytes.                                                                                                      
        bl write_result         // write the phrase                                                                                                                     
        bl flush                                                                                                                                                        
                                                                                                                                                                        
exit:                                                                                                                                                                   
        mov x8, #93                                                                                                                                                     
        mov x0, xzr                                                                                                                                                     
        svc 0                                                        
        
        write_prompt:                                                                                                                                                           
        push2 x29, x30                                                                                                                                                  
        mov x8, #64              // syscall write                                                                                                                       
        mov x0, #1              // fd dtdout                                                                                                                            
        ldr x1,=prompt                                                                                                                                                  
        mov x2, #len.prompt                                                                                                                                             
        svc #0                                                                                                                                                          
        pop2 x29, x30                                                                                                                                                   
        ret                                                                                                                                                             
                                                                                                                                                                        
                                                                                                                                                                        
read_buffer:                                                                                                                                                            
        push2 x29, x30                                                                                                                                                  
        mov x8, #63              // syscall read                                                                                                                        
        mov x0, #0              // fd stdin                                                                                                                             
        ldr x1,=buffer                                                                                                                                                  
        mov x2, #4              // arbitrary length                                                                                                                     
        svc #0                                                                                                                                                          
        pop2 x29, x30                                                                                                                                                   
        ret                                                                                                                                                             
                                                                                                                                                                        
                                                                                                                                                                        
write_result:                                                                                                                                                           
        push2 x29, x30                                                                                                                                                  
        mov x8, #64              // syscall write                                                                                                                       
        mov x0, #1              // fd stdout                                                                                                                            
        ldr x1,=result                                                                                                                                                  
        mov x2, #len.result                                                                                                                                             
        svc #0                                                                                                                                                          
        pop2 x29, x30                                                                                                                                                   
        ret                          
        
        write_int_result:                                                                                                                                                       
        push2 x29, x30                                                                                                                                                  
        mov x8, #64              // syscall write                                                                                                                       
        mov x0, #1              // fd stdout                                                                                                                            
        ldr x1,=buffer                                                                                                                                                  
        mov x2, #4              // bytes to write                                                                                                                       
        svc #0                                                                                                                                                          
        pop2 x29, x30                                                                                                                                                   
        ret                                                                                                                                                             
                                                                                                                                                                        
flush:                                                                                                                                                                  
        push2 x29, x30                                                                                                                                                  
        mov x8, #63              // syscall read                                                                                                                        
        mov x0, #2              // fd stderr                                                                                                                            
        ldr x1,=buffer                                                                                                                                                  
        mov x2, #(1 << 30)      // experiment with this                                                                                                                 
        svc #0                                                                                                                                                          
        pop2 x29, x30                                                                                                                                                   
        ret                         
        
        
