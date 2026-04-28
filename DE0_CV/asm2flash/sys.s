li sp, 0x1fc

main:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      s0, 8(sp)
    addi    s0, sp, 16
    li      t4, 10
    li      t5, 3
    mv      a5, t4
    mv      a4, t5
    mv      a1, a4
    mv      a0, a5
    call    c
    mv      a5, a0
    mv      t6, a5

.L2:
    j       .L2

c:
    addi    sp, sp, -64
    sw      ra, 60(sp)
    sw      s0, 56(sp)
    addi    s0, sp, 64
    sw      a0, -52(s0)
    sw      a1, -56(s0)
    lw      a4, -52(s0)
    lw      a5, -56(s0)
    sub     a5, a4, a5
    sw      a5, -40(s0)
    lw      a5, -52(s0)
    sw      a5, -20(s0)
    lw      a5, -52(s0)
    sw      a5, -24(s0)
    lw      a5, -56(s0)
    sw      a5, -44(s0)
    lw      a5, -52(s0)
    addi    a5, a5, -1
    sw      a5, -28(s0)
    j       .L4

.L5:
    lw      a5, -24(s0)
    addi    a5, a5, -1
    sw      a5, -24(s0)
    lw      a4, -20(s0)
    lw      a5, -24(s0)
    mul     a5, a4, a5
    sw      a5, -20(s0)
    lw      a5, -28(s0)
    addi    a5, a5, -1
    sw      a5, -28(s0)

.L4:
    lw      a4, -28(s0)
    lw      a5, -40(s0)
    bgt     a4, a5, .L5
    lw      a5, -56(s0)
    sw      a5, -32(s0)
    sw      zero, -36(s0)
    j       .L6

.L7:
    lw      a4, -20(s0)
    lw      a5, -32(s0)
    div     a5, a4, a5
    sw      a5, -20(s0)
    lw      a5, -32(s0)
    addi    a5, a5, -1
    sw      a5, -32(s0)
    lw      a5, -36(s0)
    addi    a5, a5, 1
    sw      a5, -36(s0)

.L6:
    lw      a4, -36(s0)
    lw      a5, -44(s0)
    blt     a4, a5, .L7
    lw      a5, -20(s0)
    mv      a0, a5
    lw      ra, 60(sp)
    lw      s0, 56(sp)
    addi    sp, sp, 64
    jr      ra