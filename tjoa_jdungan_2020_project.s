////////////////////////
//                    //
// Project Submission //
//                    //
////////////////////////

// Partner1: Tiffany Joa, A14599896
// Partner2: Jeffrey Dungan, A16116213

//test data file contents:
//.long
//arraySize: 8, array: 2, 5, 7, 6, 8, 1, 3, 4

////////////////////////
//                    //
//       main         //
//                    //
////////////////////////

    lda x0, array // x0 = base address of array
    lda x1, arraySize // x1 = address of arraysize
	ldur x1, [x1, #0] // load value at address of arraysize into x1
    bl printList //print init (given) list
    
    lda x0, array
    lda x1, arraySize
    ldur x1, [x1, #0]
    //bl BLueRecursion //<- THE ONLY THING THAT SHOULD BE CALLED IN FINAL CODE
    //bl RedLoop //(WORKS!)
    bl RedRecursion //(WORKS!)
    //bl BLueLoop //(WORKS!)
    //bl ATTEMPTBLUERECUR

    lda x0, array
    lda x1, arraySize
    ldur x1, [x1, #0]
    bl printList //print final (ordered) list
	stop

//GIVEN MAIN IS BELOW
    //lda x0, array
    //lda x1, arraySize
	//ldur x1, [x1, #0]
    //bl printList // prints og list
    
    //lda x0, array
    //lda x1, arraySize
    //ldur x1, [x1, #0]
    //bl BLueRecursion    //calls BLueRecursion!!

    //lda x0, array
    //lda x1, arraySize
    //ldur x1, [x1, #0]
    //bl printList // prints sorted list
	//stop


////////////////////////
//                    //
//      RedLoop       //
//                    //
////////////////////////
RedLoop: // tested and it works :)
    // x0: base address of the (sub)list
    // x1: size of the (sub)list

    //set iterator = 0
    mov x3, xzr

    //divides size of list by 2 and stores in x7
    addi x2, xzr, #2
    udiv x7, x1, x2 //x7 is size of half list

//reach end of first half of list
smolredloop:
    //check loop condition
	cmp x3, x7 // compare iterator and half arraysize
	b.eq endredloop //if iterator + half arraysize the same -> go to loopend

    lsl x4, x3, #3 //shift left by 3 bits = mult by 8 // mult x3 (the iterator) by 8 (bc 1 space is 8 bytes) = # of spaces away from base address (aka earlier value's posit)
	add x4, x0, x4  //x4 = address of array[x3] (earlier value)
	ldur x5, [x4, #0] // x5 = array[x3] (earlier value), load value at x4 into x5

    //parallel code to have x9 "point" to value that is size/2 away
    add x12, x3, x7 //x12 = x3(iterator) + half listsize (x7)
    lsl x9, x12, #3 //x9 = (iterator+half listsize) * 8 // the later value's posit
    add x9, x0, x9 //x9 = address of array[x9] (later value)
    ldur x10, [x9, #0] //x10 = array[x9] (later value) // load value at x9 into x10

    //compare current val with current max+update current max (if needed)
    cmp x5, x10 //compare current (earlier) element (x5) with (later) element half listsize away (x10)
	b.le repeatredsmol //if earlier <= later, go to repeatredsmol
    
    //execute following if need to swap elements
    add x11, x5, xzr //save earlier (bigger) value into temp register
    mov x5, x10 // early element = later (smaller) element
    mov x10, x11 // later element = earlier (bigger) element
    stur x5, [x4, #0] // store updated earlier element back into list (x4 has address of early elem)
    stur x10, [x9, #0] // store updated later element back into list (x9 has address of later elem)

repeatredsmol:
	addi x3, x3, #1 //increment iterator
	b smolredloop // go through loop again

endredloop:
    //END OF MY INSERTED CODE
	br lr //was given


////////////////////////
//                    //
//    RedRecursion    //
//                    //
////////////////////////
RedRecursion: //YAY THIS WORKS ^___^ (is tested)
    // x0: base address of the (sub)list
    // x1: size of the (sub)list

    cmp x19, xzr //detect if first time running redrecur
    b.eq redsetup
    b.ne dothis //this line is necessary! (logically bc redsetup is following line)

redsetup:
    lsl x2, x1, #3 //mult list size by 8
    add x6, x2, x0 //x6 = last element address

//ALLOCATE MEMORY TO STORE OG LR (X30)
subi sp, sp, #32 //allocate stack frame
stur fp, [sp, #0] // save old frame pointer
addi fp, sp, #24 //set new frame pointer
stur lr, [fp, #-16] //save the return address
stur x0, [fp, #0] //save argument x0 (base address of list)
stur x1, [fp, #-8] //save argument x1 (size of list)

    cmpi x1, #1 //check listsize > 1
    b.le redrecurend

	//whole list
    bl RedLoop

addi x19, xzr, #1 //update detector (NEED THIS??)

dothis:
    ldur x0, [fp, #0]

    //first half of the list
    addi x3, xzr, #2
    udiv x1, x1, x3 //size = size/2

here:
    cmpi x1, #1 //check listsize > 1
    b.le redrecurend
    bl RedLoop

    //second half of the list
    lsl x4, x1, #3
    add x0, x0, x4 //address = a[size/2]
    bl RedLoop

    //IF REACH END OF LIST, RESTORE X0
    lsl x4, x1, #3 //restore value of x4
    add x5, x0, x4 //address = a+a[size/2] //find address of last elem in current sublist
    cmp x5, x6 //compare actual last element address with last element in current sublist
    b.eq RedRecursion //RECURSIVE CALL

    //if not reach end of list (ELSE)
    lsl x4, x1, #3
    add x0, x0, x4 //address = a[size/2]
    b here

redrecurend:

//DEALLOCATE MEMORY
ldur x0, [fp, #0] //restore og base list address
ldur x1, [fp, #-8] //restore og listsize
ldur lr, [fp, #-16] //restore return address
ldur fp, [fp, #-24] //restore old frame pointer
addi sp, sp, #32 //deallocate stack frame

mov x19, xzr //restore the detector

    br lr //return to caller


////////////////////////
//                    //
//      BLueLoop      //
//                    //
////////////////////////
BLueLoop: //tested and it works :)
    // x0: base address of the (sub)list
    // x1: size of the (sub)list

    // INSERT YOUR CODE HERE

    //set iterator = 0
    mov x3, xzr

    //divides size of list by 2 and stores in x7 (assume list is even size?)
    addi x12, xzr, #2
    udiv x7, x1, x12 //x7 is size of half list

//reach end of first half of list
smolblueloop:
    //check loop condition
	cmp x3, x7 // subs xzr, x3, x7 (compare iterator and half arraysize)
	b.eq endblueloop //(if iterator+arraysize the same -> go to loopend)

    lsl x4, x3, #3 //shift left by 3 bits = mult by 8 // mult x3 (the iterator) by 8 (bc 1 space is 8 bytes) = # of spaces away from base address (aka earlier value's posit)
    add x4, x0, x4  //x4 = address of array[x3] (earlier value)
    ldur x5, [x4, #0] // x5 = array[x3] (earlier value), load value at x4 into x5

//for debug
//putint x5 //first int compared

    //parallel code to have x9 "point" to value that is at size - i -1
    sub x2, x1, x3 //x2 = listsize - iterator
    subi x2, x2, #1 //x2 = x2 - 1
    lsl x9, x2, #3 //shift left by 3 bits = mult by 8 //# of spaces away from base address (aka later value's posit)
    add x9, x0, x9 //x9 = address of array[x2] (later value)
    ldur x10, [x9, #0] //load value at x9 into x10 (x10 now holds later value)

//for debug
//putint x10 //second int being compared

    //compare current val with current max+update current max (if needed)
    cmp x5, x10 //compare current element (x5) with element at size - i - 1 (x10)
	b.le repeatbluesmol //if earlier elem <= later elem, go to repeatbluesmol

    //execute following if need to swap elements
    add x11, x5, xzr //save earlier (bigger) value into temp register
    mov x5, x10 // early element = later (smaller) element (early element <- later element)
    mov x10, x11 // later element = earlier (bigger) element
    stur x5, [x4, #0] // store updated earlier element back into list
    stur x10, [x9, #0] // store updated later element back into list

repeatbluesmol:
	addi x3, x3, #1 //increment iterator
	b smolblueloop // go through loop again

endblueloop:
    //END OF MY INSERTED CODE
	br lr 


////////////////////////
//                    //
//    BLueRecursion   //
//                    //
////////////////////////
BLueRecursion:
    // x0: base address of the (sub)list
    // x1: size of the (sub)list

    cmp x25, xzr //detect if first time running redrecur
    b.eq thebluesetup
    b.ne youcando //this line is necessary! (logically bc thebluesetup is following line)

thebluesetup: //only run once (TOTAL)!!!
   subi x2, x1, #1
   lsl x11, x2, #3 //mult list size by 8
   add x21, x11, x0 //x21 = last element address

    addi x3, xzr, #2
    udiv x5, x1, x3
    subi x5, x5, #1
    lsl x7, x5, #3
    add x24, x0, x7 //x24 = address of last elem of first part of list
    add x22, xzr, x1 //keep copy of og size
    add x20, xzr, x0 //keep copy of og head address

    addi x25, xzr, #1

youcando:
//ALLOCATE MEMORY (LIKE RED RECUR)
subi sp, sp, #32 //allocate stack frame
stur fp, [sp, #0] // save old frame pointer
addi fp, sp, #24 //set new frame pointer
stur lr, [fp, #-16] //save the return address
stur x0, [fp, #0] //save argument x0 (base address of og list)
stur x1, [fp, #-8] //save argument x1 (size of og list)

addi x3, xzr, #2 //have x3 just store value of 2

cmpi x1, #2
b.le label1
udiv x1, x1, x3
bl BLueRecursion // <--- PC

comeback: // <--- PC+4 (X30)

bl BLueLoop

addi x3, xzr, #2 //have x3 just store value of 2
mov x23, x1 //save listsize for this section
mov x26, x0 //save head address for this section
//keep value of x0 (a)
udiv x1, x1, x3 // x1 <- x1/ 2 (store half list size in x1) //updates x1
bl RedRecursion

//keep x1 (listsize)
lsl x4, x1, #3 //x4 address of array[updated x1(half list size)]
add x0, x0, x4 //updates x0
bl RedRecursion

//x24 = address of last element in first half
//x21 = last element address
//x23 = listsize for this

subi x15, x23, #1
lsl x14, x15, #3 //x14 = (sublist size-1)(8)
add x13, x26, x14 //x13 = address of last element in sublist

cmp x13, x21 //compare last sublist elem and actual end
b.eq donehere //if reach end of list (actual end)

cmp x13, x24 //compare last sublist elem and actual middle
b.eq donehere //if reach middle (actual middle)

lsl x6, x23, #3
add x0, x26, x6 //move ptr to next list section
mov x1, x23 //restore section listsize
b comeback

//RUNNING CASE WHEN FULL SIZE (big blue loop, red recursion for two halves)??


label1:

addi x3, xzr, #2
udiv x10, x22, x3 //x1 = half og listsize
subi x9, x10, #1
lsl x4, x9, #3
add x9, x0, x4 //x9 = end of first list section

cmp x9, x21 //compare ptr and address of last elem
b.eq donehere //if equal

udiv x1, x22, x3 //x1 = half og listsize //CORRECT (KEEP)
lsl x4, x1, #3
add x0, x0, x4 //x4 = a[listsize/2] //move ptr to beginning of next list section //CORRECT (KEEP)

b BLueRecursion //if haven't reached end of list, go back and allocate values for second half

donehere:
//DEALLOCATE MEMORY
ldur x0, [fp, #0] //restore og base list address
ldur x1, [fp, #-8] //restore og listsize
ldur lr, [fp, #-16] //restore return address
ldur fp, [fp, #-24] //restore old frame pointer
addi sp, sp, #32 //deallocate stack frame

mov x25, xzr //restore the detector

//compare x1 with x22 (og size) and if match, branch to final
cmp x22, x1
b.eq final

br lr


final:
//run big blue loop
//run two red recursions

cmpi x22, #4
b.eq theend

//cmpi x22, #2
//b.eq theend

bl BLueLoop

addi x3, xzr, #2 //have x3 just store value of 2

//x22 has og size
//x20 has og address
mov x1, x22
mov x0, x20

//keep value of x0 (a)
udiv x1, x22, x3 // x1 <- x1/ 2 (store half list size in x1) //updates x1
bl RedLoop

addi x3, xzr, #2 //have x3 just store value of 2

//can use x2
udiv x1, x1, x3
//change to half half
bl RedLoop

lsl x2, x1, #3
add x0, x2, x0
bl RedLoop

addi x3, xzr, #2 //have x3 just store value of 2
udiv x1, x22, x3 // x1 <- x1/ 2 (store half list size in x1) //updates x1
mov x0, x20
//keep x1 (listsize)
lsl x4, x1, #3 //x4 address of array[updated x1(half list size)]
add x0, x0, x4 //updates x0
bl RedLoop

addi x3, xzr, #2 //have x3 just store value of 2
udiv x1, x1, x3
//change to half half 2nd
bl RedLoop

lsl x2, x1, #3
add x0, x2, x0
bl RedLoop

mov x1, x22 //restore og listsize
mov x0, x20 //restore og address

ldur lr, [fp, #-16] //restore return address

theend:
br lr




////////////////////////
//                    //
//     printList      //
//                    //
////////////////////////
printList:
    // x0: base address
    // x1: length of the array

	mov x2, xzr
	addi x5, xzr, #32
	addi x6, xzr, #10
printList_loop:
    cmp x2, x1
    b.eq printList_loopEnd
    lsl x3, x2, #3
    add x3, x3, x0
	ldur x4, [x3, #0]
    putint x4
    putchar x5
    addi x2, x2, #1
    b printList_loop
printList_loopEnd:    
    putchar x6
    br lr