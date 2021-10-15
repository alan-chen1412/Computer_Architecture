# Lab1: RV32I simualtor
###### tags: `110-1_RISC-V`
## Find Numbers with Even Number of Digits
Given an array nums of integers, return how many of them contain an even number of digits.

Array of numbers: `12,345,1771,2,6,7896`
:::info
As consequence, I use a for-loop and a while-loop to decide if it has even digits. The while-loop is used to count how many times the number can divide by 10, and after that I divide the counter by 2, to see whether it is power of 2, and then go back to for-loop until all numbers are calculated.
:::

**C code**
#### 
```c=
int main()
{
	int n,output=0;
	int number_array[6]={12,345,1771,2,6,7896};
	for(int i = 0;i<6;i++)
	{
		int counter=0;
		while(number_array[i]>0)
		{
			counter++;
			number_array[i]/=10;
		}
		if(counter%2==0)
			output++;
	}
	printf("The number of even digits are: %d\n",output);
	return 0;
}
```
**Assembly code**
```c=
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
```

## RISC-V assembly program
This program includes 6 parts
1. main
```c=
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
```
* Initial parameters
* set number of for-loop and divided number
2. for_loop
![](https://i.imgur.com/Uk74Oxn.png)
    * plus 1 to t0 per loop
    * set the counter to zero (s2)
    * load data from array address(store in s0)
    * increment array address by 4
3. div_10
```c=
div_10:
    beq a0, zero, div_by_2
    addi s2, s2, 1          #s2 equals to counter
    div a0, a0, s3          #a0 divide by 10
    j div_10
```
* conditional branch check if a0 is zero
* divide a0 by 10
* loop until a0 equals to zero

4. div_by_2
```c=
div_by_2:
    andi a1,s2,1            #check if can divide by 2
    beq a1, zero output_add
    j for_loop
```
* check if counter can divide by 2
* if could, then jump to ouput_add, if not, directly go back to next for-loop

5. output_add
```c=
output_add:
    addi t1, t1, 1          #t1 equals to output_add
    j for_loop
```
* this part means current number is even digits number, so output counter plus 1, and then go for next for-loop

6. go_back
```c=
go_back:
    la a0, str
    li a7,4                 #tell system to print string
    ecall                   #print string in a0
    mv a0 t1 
    li a7,1                 #tell system to print integer
    ecall                   #print integer in a0
    jr ra
```
![](https://i.imgur.com/tUWRLkE.png)
* use ecall to print out the result
## Five-stage description
* IF(Instruction Fetch)
    * Firstly, program counter will receive the instruction address, which comes from either last instruction address plus 4 or Arithmetic Logic Unit if there is a branch instruction or jump instruction
    * Secondly,the Instruction Memory will give you the according instruction,and save it to IF/ID register
![](https://i.imgur.com/kq6R5eK.png)
* ID(Instruction Decode)
    * Decoder will decode the instruction and tell other module what type of instruction is going to do
    * Other module will generate according data
![](https://i.imgur.com/RKTqq7E.png)
* EXE(Execute)
    * In this stage ALU will execute the instruction based on the opcode,and the branch condition also decided in this stage
![](https://i.imgur.com/gHJ4DjR.png)
* MEM(Memory)
    * It will access data memory based on opcode and decide to either read or write the memory
    * Hence, it will send address and data to memory and receive data from data memory too 
![](https://i.imgur.com/sb9Eb6W.png)
* WB(Write back)
    * Write the correct result into register file
![](https://i.imgur.com/coqoFvD.png)

## Pipeline Hazard
* There are three types of hazards in pipeline
    1. Structural hazard:
        - It occur when hardware resource is not enough in pipeline
    2. Data hazard:
        - Read after write(RAW)
        - Write after write(WAW)
        - Write aftre read(WAR)
        It occur when the source data of current instruction is come from previous instruction, but previous instruction has not yet write back to register file. As consequence, the current instruction will get incorrect data.It will result in huge problem in pipeline ,so it needed to be solved
```c=
andi a1,s2,1            
beq a1, zero output_add
j for_loop
```
* beq need to use result of andi instruction, so the **RAW** occur
* To deal with this problem, pipeline use forwarding technique
* Due to forwarding, we don't need to wait for `andi a1,s2,1` write back to register file, `beq a1, zero, output_add` can directly use data `0x00000000` from the previous instruction at the **EXE stage**
![](https://i.imgur.com/WRCCJZa.png)
3. Control Hazard:
    - The pipeline processor don't know the correct instruction flow, because Branch/Jump instruction won't get the result at the same time next instruction being fetched
    - If decide to take branch, the instructions in **IF, ID** stage are both wrong because we decide branch condition at **EXE** stage
    - Consequently, pipeline processor need to flush the wrong instruction
    - To flush wrong instruction, we replace the instruction at **IF,ID** with `nop`,as known as **No operation**
![](https://i.imgur.com/ewG2Rqy.png)
* 2 nop instructions are inserted between `beq a1, zero output_add` and `addi t1, t1, 1`

![](https://i.imgur.com/rX84yOq.png)
