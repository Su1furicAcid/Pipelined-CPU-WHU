/*
中断测试代码
addi x30, x0, 0xd
slli x30, x30, 28
addi x6, x0, 0x10
sw x6, 0(x30)

addi x31, x0, 0xe
slli x18, x31, 28
addi x7, x0, 0x1
sw x7, 0(x18)
jalr x0, 16(x0)

addi x0, x0, 0x0
addi x0, x0, 0x0
addi x31, x0, 0xe
slli x18, x31, 28
addi x7, x0, 0x20
sw x7, 0(x18)
addi x0, x0, 0x0
addi x0, x0, 0x0
addi x0, x0, 0x0
addi x0, x0, 0x0
mret
*/