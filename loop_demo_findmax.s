////////////////////////
//                    //
//       main         // // searches for max in a list and outputs og list and the max element
//                    //
////////////////////////

//initialization stuff??

    lda x0, array 
    lda x1, arraySize // copy data from memory location to accumulator (??)
	ldur x1, [x1, #0]
    bl printList // print initial list from data
    
    lda x0, array  // ??
    lda x1, arraySize // ??
    ldur x1, [x1, #0] // ??

//where the actual stuff happens
    
	ldur x2, [x0, #0] // x2 for max element
	addi x3, xzr, #1 // x3 as iterator // increment by 1, initialized = 0
loop:
	cmp x3, x1 // subs xzr, x3, x1 (compare x3 and x1)
	b.eq loopend //compare of increment and arraysize are the same (if same -> go to loopend)
	//shift x3 left by 3 bits(??) and store shifted address into x4
	lsl x4, x3, #3 // x4 address of array[x3]; alternative: addi x8, xzr, #8  mul x4, x3, x8 //
	add x4, x0, x4 // have x4 hold address of element array[x3(iterator)]
	ldur x5, [x4, #0] // x5 = array[x3]
	cmp x5, x2 //compare current element (x5) with current max (x2)
	b.lt ifend //if current less than current max, go to ifend (aka go through loop again)
	mov x2, x5 // add x2, x5, xzr // set current element to current max (current max = current element)
ifend:
	addi x3, x3, #1 //increment iterator through array
	b loop // go through loop again
loopend:
	putint x2 //prints the max element
	stop // end main??
    
    
////////////////////////
//                    //
//     printList      // // never called in this sample program (just for reference??)
//                    //
////////////////////////
printList:
    // x0: base address
    // x1: length of the array

	mov x2, xzr
	addi x5, xzr, #32
	addi x6, xzr, #10
printList_loop:
    cmp x2, x1 //compare increment with length of array
    b.eq printList_loopEnd //if increment = length of array, end loop
    lsl x3, x2, #3 // ??
    add x3, x3, x0 //increment through array itself
	ldur x4, [x3, #0] // load value of array into x4
    putint x4 // print array value
    putchar x5 //??? print space??
    addi x2, x2, #1 //increment the increment
    b printList_loop // go through loop again
printList_loopEnd:    
    putchar x6 // ??
    br lr