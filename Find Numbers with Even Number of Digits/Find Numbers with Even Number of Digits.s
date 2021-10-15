.data
    number_arry: .word 12, 345, 1771, 2, 6, 7896
    str: .string "The number of even digits numbers are "
.text
main:
    la s0, number_arry      #s0 save the address of number array
    mv t3, s0
    addi s1, s1, 6          #s0 always equals to 6
    addi s3, s3, 10         #always equals to 10
    jal ra, for_loop
    j end
    
for_loop:
    beq t0, s1, go_back
    addi t0, t0, 1          #t0 equals to i
    add s2, zero, zero      #set counter to zero
    lw a0, 0(s0)            #load data from array
    addi s0,s0,4            #addr + 4
    j div_10
    
div_10:
    beq a0, zero, div_by_2
    addi s2, s2, 1          #s2 equals to counter
    div a0, a0, s3          #a0 divide by 10
    j div_10
    
div_by_2:
    andi a1,s2,1            #check if can divide by 2
    beq a1, zero output_add
    j for_loop
output_add:
    addi t1, t1, 1          #t1 equals to output_add
    j for_loop
    
go_back:
    la a0, str
    li a7,4                 #tell system to print string
    ecall                   #print string in a0
    mv a0 t1 
    li a7,1                 #tell system to print integer
    ecall                   #print integer in a0
    jr ra
end:
    li a7 ,10               #tell system to end program 
    ecall                   #end program
