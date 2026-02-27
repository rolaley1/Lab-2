.section .data
prompt1:    .ascii "Enter first string: "
prompt1_len = . - prompt1

prompt2:    .ascii "Enter second string: "
prompt2_len = . - prompt2

outmsg:     .ascii "Hamming distance: "
outmsg_len  = . - outmsg

newline:    .ascii "\n"
newline_len = . - newline

.section .bss
    .lcomm buf1, 256
    .lcomm buf2, 256
    .lcomm numbuf, 32

.section .text
.global _start

_start:
    # write(prompt1)
    mov $1, %rax
    mov $1, %rdi
    mov $prompt1, %rsi
    mov $prompt1_len, %rdx
    syscall

    # read(buf1, 256)
    mov $0, %rax
    mov $0, %rdi
    mov $buf1, %rsi
    mov $256, %rdx
    syscall
    mov %rax, %r12        # bytes read buf1

    # write(prompt2)
    mov $1, %rax
    mov $1, %rdi
    mov $prompt2, %rsi
    mov $prompt2_len, %rdx
    syscall

    # read(buf2, 256)
    mov $0, %rax
    mov $0, %rdi
    mov $buf2, %rsi
    mov $256, %rdx
    syscall
    mov %rax, %r13        # bytes read buf2

    # -----------------------------
    # len1 up to '\n' or bytes read
    # r14 = len1
    # -----------------------------
    xor %r14, %r14
len1_loop:
    cmp %r12, %r14        # if len1 >= bytes_read -> done
    jae len1_done
    movzbq buf1(,%r14,1), %rax
    cmp $10, %al
    je len1_done
    inc %r14
    jmp len1_loop
len1_done:

    # -----------------------------
    # len2 up to '\n' or bytes read
    # r15 = len2
    # -----------------------------
    xor %r15, %r15
len2_loop:
    cmp %r13, %r15        # if len2 >= bytes_read -> done
    jae len2_done
    movzbq buf2(,%r15,1), %rax
    cmp $10, %al
    je len2_done
    inc %r15
    jmp len2_loop
len2_done:

    # minlen in rbx
    mov %r14, %rbx
    cmp %r15, %rbx
    jbe have_min
    mov %r15, %rbx
have_min:

    # total in r8, i in r9
    xor %r8, %r8
    xor %r9, %r9

char_loop:
    cmp %rbx, %r9         # if i >= minlen -> done
    jae done_hamming

    movzbq buf1(,%r9,1), %rax
    movzbq buf2(,%r9,1), %rcx

    xor %cl, %al          # al = buf1[i] XOR buf2[i]
    mov %al, %dl          # dl = xor byte

    mov $8, %r10
bit_loop:
    test $1, %dl
    jz no_add
    inc %r8
no_add:
    shr $1, %dl
    dec %r10
    jnz bit_loop

    inc %r9
    jmp char_loop

done_hamming:
    # print outmsg
    mov $1, %rax
    mov $1, %rdi
    mov $outmsg, %rsi
    mov $outmsg_len, %rdx
    syscall

    # convert r8 to decimal into numbuf (backwards)
    lea numbuf(%rip), %rsi
    add $31, %rsi
    movb $0, (%rsi)

    mov %r8, %rax
    cmp $0, %rax
    jne conv_loop

    dec %rsi
    movb $'0', (%rsi)
    jmp conv_done

conv_loop:
    xor %rdx, %rdx
    mov $10, %rdi
    div %rdi              # rax=quot, rdx=rem
    add $'0', %dl
    dec %rsi
    mov %dl, (%rsi)
    cmp $0, %rax
    jne conv_loop

conv_done:
    lea numbuf(%rip), %rcx
    add $31, %rcx
    sub %rsi, %rcx        # length

    # write(number)
    mov $1, %rax
    mov $1, %rdi
    mov %rcx, %rdx
    syscall

    # newline
    mov $1, %rax
    mov $1, %rdi
    mov $newline, %rsi
    mov $newline_len, %rdx
    syscall

    # exit(0)
    mov $60, %rax
    xor %rdi, %rdi
    syscall
    t