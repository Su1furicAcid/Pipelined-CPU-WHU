// LED 输出设备 F0000000/FFFFFF00
// Switch, Button 输入设备 F0000000/FFFFFF00
// 7-Segment 显示设备 E0000000/FFFFFE00
/*
示例程序：

addi x31, x0, 0xe
slli x18, x31, 28
addi x31, x0, 0xf
slli x19, x31, 28

lw x6, 0(x19)
addi x31, x0, 0xff
slli x31, x31, 8
and x10, x6, x31
srli x10, x10, 8
and x7, x7, x0
addi x28, x0, 1
addi x7, x7, 1

loop:
blt x10, x28, done
mul x7, x7, x28
addi x28, x28, 1
jal x0, loop

done:
sw x7, 0(x18)
*/

int main() {
    unsigned int address = 0xF0000000;
    unsigned int data = *(unsigned int *)address;

    // 提取A、B和操作符编号
    int a = (data & 0x00000007);          // 低三位
    int b = (data & 0x00000038) >> 3;     // 接着三位
    int op_code = (data & 0x000000C0) >> 6; // 最后两位
    int result;

    // 执行四则运算
    switch ( op_code ) {
        case 0:
            result = a + b;
            break;
        case 1:
            result = a - b;
            break;
        case 2:
            result = a * b;
            break;
        default:
            result = 0; // 无效的操作符编号
    }

    // 打印结果
    unsigned int output_address = 0xE0000000;
    *(unsigned int *)output_address = result;

    return 0;
}
