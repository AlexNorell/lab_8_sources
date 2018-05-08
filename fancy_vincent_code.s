main: addi $t1, $0, 1 # $t1 = 1
  addi $t0, $0, 0x0F # $t0 = 0x0F (NOP addi $t1)
  NOP # (NOP addi $t1)
  
  sll $t4, $t1, 4 # $t4 = $t1 << 4

fact: lw $t2, 0x0900($0) # read switches
  NOP # (NOP lw $t2)
  NOP # (NOP lw $t2)
  and $t3, $t2, $t0 # get input data n
  NOP # (NOP and $t3)
  sw $t1, 0x0804($0) # write control Go bit # (NOP lw $t2)
  sw $t3, 0x0800($0) # write input data n

poll: lw $t5, 0x0808($0) # read status Done bit
  NOP # (NOP lw $t5)
  NOP # (NOP lw $t5)
  
  beq $t5, $0, poll # wait until Done == 1
  NOP # (NOP poll)

  srl $t5, $t5, 1 # $t5 = $t5 >> 1
  NOP # (NOP srl $t5)
  and $t3, $t2, $t4 # get display Select # (NOP srl $t5)
  and $t5, $t5, $t1 # get status Error bit
  NOP # (NOP and $t5)
  NOP # (NOP and $t5)
  or $t3, $t3, $t5 # combine Sel and Err 
  
  lw $t5, 0x080C($0) # read result data nf
  NOP # (NOP lw $t5)
  sw $t3, 0x0908($0) # display Sel and Err (NOP lw $t5)
  sw $t5, 0x090C($0) # display result nf

done: j fact # repeat fact loop
  NOP # (NOP j fact