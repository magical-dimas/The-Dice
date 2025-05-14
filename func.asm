exit:
mov rax, 0x3c
mov rdi, 0
syscall

;Function printing of string
;input rsi - place of memory of begin string
print_str:
push rax
push rdi
push rdx
push rcx
mov rax, rsi
call len_str
mov rdx, rax
mov rax, 1
mov rdi, 1
syscall
pop rcx
pop rdx
pop rdi
pop rax
ret


;The function finds the length of a string
;input rax - place of memory of begin string
;output rax - length of the string
len_str:
push rdx
mov rdx, rax
.iter:
cmp byte [rax], 0
je .next
inc rax
jmp .iter
.next:
sub rax, rdx
pop rdx
ret


;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
push rcx
push rbx

xor rax,rax
xor rcx,rcx
.loop:
xor rbx, rbx
mov bl, byte [rsi+rcx]
cmp bl, 48
jl .finished
cmp bl, 57
jg .finished

sub bl, 48
add rax, rbx
mov rbx, 10
mul rbx
inc rcx
jmp .loop

.finished:
cmp rcx, 0
je .restore
mov rbx, 10
div rbx

.restore:
pop rbx
pop rcx
ret

;The function converts the nubmer to string
;input rax - number
;rsi -address of begin of string
number_str:
push rbx
push rcx
push rdx
xor rcx, rcx
mov rbx, 10
.loop_1:
xor rdx, rdx
div rbx
add rdx, 48
push rdx
inc rcx
cmp rax, 0
jne .loop_1
xor rdx, rdx
.loop_2:
pop rax
mov byte [rsi+rdx], al
inc rdx
dec rcx
cmp rcx, 0
jne .loop_2
mov byte [rsi+rdx], 0   
pop rdx
pop rcx
pop rbx
ret


;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string 
input_keyboard:
push rax
push rdi
push rdx

mov rax, 0
mov rdi, 0
mov rdx, 100
syscall

xor rcx, rcx
.loop:
mov al, [rsi+rcx]
inc rcx
cmp rax, 0x0A
jne .loop
dec rcx
mov byte [rsi+rcx], 0
  
pop rdx
pop rdi
pop rax
ret

;Function comparing two strings
;input: rax, rdx - compared strings (their place in memory)
;output: rax - result, 1 if equal, 0 if not
compare:
push rbx
push rsi
push rdi
push rcx
mov rbx, rax
call len_str
mov rdi, rax
mov rax, rdx
call len_str
mov rcx, rax
cmp rcx, rdi
jne .notequal
mov rax, rbx
mov rsi, -1
xor rbx, rbx
.comp_loop:
inc rsi
cmp rsi, rdi
jnl .finished_c
mov bl, byte [rdx+rsi]
cmp byte [rax+rsi], bl
je .comp_loop
.notequal:
mov rax, 0
pop rcx
pop rdi
pop rsi
pop rbx
ret
.finished_c:
mov rax, 1
pop rcx
pop rdi
pop rsi
pop rbx
ret

;Function for getting a random result of a dice roll
;input: rdx - number of dice rolled
;rsi - amount of sides on each die
;rdi - address of the random number generator
;r9 - address of the buffer
;output: rax - result of a roll
roll_dice:
push rcx
push rbx
push r8

xor rcx, rcx
xor r8, r8
.roll:
push rdx
push rsi
push rcx
mov rax, 0
mov rsi, r9
mov rdx, 1
syscall
pop rcx
pop rsi
mov rax, [r9]
mov rbx, rsi
xor rdx, rdx
div rbx
mov rax, rdx
inc rax
add rcx, rax
inc r8
pop rdx
cmp r8, rdx
jl .roll

mov rax, rcx
pop r8
pop rbx
pop rcx
ret