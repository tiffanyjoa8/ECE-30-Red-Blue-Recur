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

    lda x0, array // x0 = base address of x0
    lda x1, arraySize // x1 = address of arraysize
	ldur x1, [x1, #0] // load value of arraysize into x1
    bl printList //print init (given) list)
    
    lda x0, array
    lda x1, arraySize
    ldur x1, [x1, #0]
    //bl BLueRecursion <- THE ONLY THING THAT SHOULD BE CALLED IN FINAL CODE
    //bl RedLoop
    //bl RedRecursion
    bl BLueLoop

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

    // INSERT YOUR CODE HERE

    //set iterator = 0
    mov x3, xzr

    //divides size of list by 2 and stores in x7 (assume list is even size?)
    addi x14, xzr, #2
    udiv x7, x1, x14 //x7 is size of half list

//reach end of first half of list
smolredloop:
    //check loop condition
	cmp x3, x7 // compare iterator and half arraysize
	b.eq endredloop //if iterator + half arraysize the same -> go to loopend

    lsl x4, x3, #3 //shift left by 3 bits = mult by 8 // mult x3 (the iterator) by 8 (bc 1 space is 8 bytes) = # of spaces away from base address (aka earlier value's posit)
	add x4, x0, x4  //x4 = address of array[x3] (earlier value)
	ldur x5, [x4, #0] // x5 = array[x3] (earlier value), load value at x4 into x5 
	
//for debug
//addi x16, xzr, #9
//putint x16 //start of compared numbers (#9)
//putint x5 //first int compared

    //parallel code to have x9 "point" to value that is size/2 away
    add x12, x3, x7 //x12 = x3(iterator) + half listsize (x7)
    lsl x9, x12, #3 //x9 = (iterator+half listsize) * 8 // the later value's posit
    add x9, x0, x9 //x9 = address of array[x9] (later value)
    ldur x10, [x9, #0] //x10 = array[x9] (later value) // load value at x9 into x10

//for debug
//putint x10 //second int being compared
//putint x16 //end of compared pair of numbers (#9)

    //compare current val with current max+update current max (if needed)
    cmp x5, x10 //compare current (earlier) element (x5) with (later) element half listsize away (x10)
	b.lt repeatredsmol //if earlier < later, go to repeatredsmol
    
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
RedRecursion: //still broken :(
    // x0: base address of the (sub)list
    // x1: size of the (sub)list

    // INSERT YOUR CODE HERE

//debug
//putint x0 //print base address
//putint x1 //print list size

//SETUP (saves fp, return address, x0, x1)
subi sp, sp, #32 //allocate stack frame
stur fp, [sp, #0] // save old frame pointer
addi fp, sp, #24 //set new frame pointer
stur lr, [fp, #-16] //save the return address
stur x0, [fp, #0] //save argument x0 (base address of list)
stur x1, [fp, #-24] //save argument x1 (size of list)

    addi x3, xzr, #2 //have x3 just store value of 2

    subis xzr, x1, #1 //test x1 < 1
    //b.le endredrecursion //end red recursion if size <=1
    b.le label1 //if x1 <= 1, go to label1
    //if size > 1, execute red recursion
    bl RedLoop //a, size

    //ldur x0, [fp, #0]

ldur x1, [fp, #-24] //load x1 value
udiv x1, x1, x3 //size = size/2

    bl RedRecursion //a, size/2

ldur x0, [fp, #0] //load x0 value
b done

//draft #1 (ISSUE #2)
    lsl x19, x1, #3 //x19 address of array[updated x1(half list size)] //???
    //x19 has address of array[updated x1(half list size)]
    add x0, x0, x19 //updates x0
//size is already updated???
    bl RedRecursion //a/2, size/2
ldur x0, [fp, #0]
    b done

label1:
    addi x22, xzr, #1 //return 1 //????

done:
    ldur lr, [fp, #-16] //restore return address
    ldur fp, [fp, #-24] //restore old frame pointer
    addi sp, sp, #32 //deallocate stack frame

    br lr //return to caller


//(ISSUE #1: following code never gets called)
//debug
//addi x20, xzr, #9
//putint x20



    //keep value of x0 (a)
    //udiv x1, x1, x3 // x1 <- x1/ 2 (store half list size in x1) //updates x1
    //b.gt RedRecursion //run for first half of list //correctly recursively calls RedRecursion

    //debug
    //addi x21, xzr, #8
    //putint x21

//draft #1 (ISSUE #2)
    //lsl x19, x1, #3 //x19 address of array[updated x1(half list size)] //???
    //x19 has address of array[updated x1(half list size)]
    //add x0, x0, x19 //updates x0

//following code is never called bc br lr just goes back to main instead of functioncall+4
//debug
//addi x21, xzr, #8
//putint x21

//draft #2 (ISSUE #2)
    //or is it just this:
    //add x0, x0, x1 // x0 = x0 + half list size //updates x0

    //keep value of updated x1 (half of size)
    //b.gt RedRecursion //run for second half of list

//endredrecursion:
	//END OF MY INSERTED CODE
	//br lr


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
    addi x14, xzr, #2
    udiv x7, x1, x14 //x7 is size of half list

//reach end of first half of list
smolblueloop:
    //check loop condition
	cmp x3, x7 // subs xzr, x3, x7 (compare iterator and half arraysize)
	b.eq endblueloop //(if iterator+arraysize the same -> go to loopend)

    lsl x4, x3, #3 //shift left by 3 bits = mult by 8 // mult x3 (the iterator) by 8 (bc 1 space is 8 bytes) = # of spaces away from base address (aka earlier value's posit)
    add x4, x0, x4  //x4 = address of array[x3] (earlier value)
    ldur x5, [x4, #0] // x5 = array[x3] (earlier value), load value at x4 into x5

//for debug
//addi x16, xzr, #9
//putint x16 //start of compared numbers (#9)
//putint x5 //first int compared

    //parallel code to have x9 "point" to value that is at size - i -1
    sub x2, x1, x3 //x2 = listsize - iterator
    subi x2, x2, #1 //x2 = x2 - 1
    lsl x9, x2, #3 //shift left by 3 bits = mult by 8 //# of spaces away from base address (aka later value's posit)
    add x9, x0, x9 //x9 = address of array[x2] (later value)
    ldur x10, [x9, #0] //load value at x9 into x10 (x10 now holds later value)

//for debug
//putint x10 //second int being compared
//putint x16 //end of compared pair of numbers (#9)

    //compare current val with current max+update current max (if needed)
    cmp x5, x10 //compare current element (x5) with element at size - i - 1 (x10)
	b.lt repeatbluesmol //if earlier elem < later elem, go to repeatbluesmol

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

    // INSERT YOUR CODE HERE
    cmp x1, x23 //initially x23 is
    b.eq keepblueinitial

    //following wouldn't work bc x0 and x1 would just keep being updated?
    keepblueinitial:
        add x24, xzr, x0 //keep copy of og base address
        add x25, xzr, x1 //keep copy of og size

//debug
//putint x0 //print base address
//putint x1 //print list size
//putint x22 //og base address??
//putint x23 //og list size??

    addi x3, xzr, #2 //have x3 just store value of 2
    addi x2, xzr, #1 //have x2 just store value of 1 (min list size)
    cmp x1, x2 //compare list size and 1
    b.le endbluerecursion //end red recursion if size <=1

    //keep x0
    udiv x1, x1, x3 // x1 = half of listsize
    b.gt BLueRecursion

//draft #1 or draft #2 updates x0

//draft #1 (ISSUE #2)
    lsl x19, x1, #3 //x19 address of array[updated x1(half list size)] //???
    //x19 has address of array[updated x1(half list size)]
    add x0, x0, x19 //updates x0

//draft #2 (ISSUE #2)
    //or is it just this:
    //add x0, x0, x1 // x0 = x0 + half list size //updates x0

    //keep x1
    b.gt BLueRecursion

    //need to restore original values of x0 and x1??
    mul x1, x1, x3
    b.gt BlueLoop //(ISSUE #1: after finishing red loop, program just returns to main instead of back here??)

//(ISSUE #1: following code never gets called)
//debug
addi x20, xzr, #9
putint x20

    //keep value of x0 (a)
    udiv x1, x1, x3 // x1 <- x1/ 2 (store half list size in x1) //updates x1
    b.gt RedRecursion //run for first half of list (should be bl RedRecursion) //correctly recursively calls RedRecursion

    //debug
    addi x21, xzr, #8
    putint x21

//draft #1 (ISSUE #2)
    lsl x19, x1, #3 //x19 address of array[updated x1(half list size)] //???
    //x19 has address of array[updated x1(half list size)]
    add x0, x0, x19 //updates x0

//following code is never called
//debug
addi x21, xzr, #8
putint x21

//draft #2 (ISSUE #2)
    //or is it just this:
    //add x0, x0, x1 // x0 = x0 + half list size //updates x0

    //keep value of updated x1 (half of size)
    b.gt RedRecursion //run for second half of list (should be bl RedRecursion)

endbluerecursion:
	//END OF MY INSERTED CODE
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