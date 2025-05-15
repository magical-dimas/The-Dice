format elf64
public _start

section '.bss' writable
f db "/dev/urandom",0
rand rq 1
output rb 100
input rb 100
dice_sides dq 6
number_of_dice dq 2
balance dq 100
bet dq 0
chosen_bet dq 0
msg_welcome db "Welcome to our humble casino, please, enjoy your stay!", 0xa, 0
msg_lost db "Sadly, your balance has become zero and you are unable to continue playing. Please, come again later, when you have more money.", 0xa, 0
msg_exit_1 db "Thank you for visiting us. Your final balance is ", 0
msg_exit_2 db " points. Please, come again soon!", 0xa, 0
msg_balance_1 db "Your current balance is ", 0
msg_balance_2 db " points. Write anything to go back to the menu...", 0xa, 0
msg_betting_1 db "Place your bets! There are currently ", 0
msg_betting_2 db "-sided dice being rolled.", 0xa, 0
msg_bet_error_1 db "Hey, you have to place a proper bet! The one H.I.G.H.E.R. than zero~", 0xa, 0
msg_bet_error_2 db "Sorry, but you don't have enoutgh money on your balance for such a bet. Try something lower~", 0xa, 0
msg_bet_choice db "Money placed. Select the result to bet on.", 0xa, 0
msg_bet_commence db "Bets placed! Rolling the dice now...", 0xa, 0
msg_bet_res db "The result of the dice roll is ", 0
msg_bet_res_win db ". You win your bet!", 0xa, 0
msg_bet_res_loss db ". You lose your bet~", 0xa, 0
msg_bet_jackpot_1 db ". Congratulations, you triple your bet!", 0xa, 0
msg_bet_jackpot_2 db ". Congratulations, you quadriple your bet!", 0xa, 0
msg_bet_jackpot_3 db ". Congratulations, you quintiple your bet!", 0xa, 0
msg_bet_jackpot_4 db ". Congratulations, you sextiple your bet!", 0xa, 0
msg_await db "Write anything to continue...", 0xa, 0
msg_bet_error_3 db "That bet is impossible. Please, choose a bet that fits.", 0xa, 0
msg_last_loss db "Oh no, that was the last bit of your money!", 0xa, 0
msg_menu db "Enter the word 'balance' to check your balance, 'bet' to place a bet, 'dice' to tweak the selected dice or 'exit' to quit the program.", 0xa, 0
msg_menu_error db "This is not an available option~. Please, enter an existing command.", 0xa, 0
msg_dice_1 db "Currently, there are ", 0
msg_dice_2 db "-sided dice being rolled. Write 'dice' in order to change the type of dice used, 'amount' to change the number of dice and 'menu' to return to the main menu.", 0xa, 0
msg_dice_type db "Input the amount of sides on the dice you desire. The available options are d4, d6, d8, d10, d12 and d20 for the purpose of a fair game~", 0xa, 0
msg_dice_amount db "Input the amount of dice you desire. The number has to be even and range from 2 to 20 for the purpose of a fair game~", 0xa, 0
msg_dice_type_error db "The available options are d4, d6, d8, d10, d12 and d20...", 0xa, 0
msg_dice_amount_error db "The number has to be even and range from 2 to 20...", 0xa, 0
key1 db "balance", 0
key2 db "bet", 0
key3 db "dice", 0
key4 db "exit", 0
key5 db "amount", 0
key6 db "menu", 0



section '.text' executable

_start:
mov rsi, msg_welcome
call print_str
mov rax, 2
mov rdi, f
mov rsi, 0o
syscall
mov [rand], rax


main_menu:

mov rsi, msg_menu
call print_str
menu_input:
mov rsi, input
call input_keyboard
mov rdx, input
mov rax, key1
call compare
cmp rax, 1
je balance_check
mov rax, key2
call compare
cmp rax, 1
je betting
mov rax, key3
call compare
cmp rax, 1
je dice
mov rax, key4
call compare
cmp rax, 1
je exiting
mov rsi, msg_menu_error
call print_str
jmp menu_input


balance_check:

mov rsi, msg_balance_1
call print_str
xor rax, rax
mov rax, [balance]
mov rsi, output
call number_str
call print_str
mov rsi, msg_balance_2
call print_str

mov rsi, input
call input_keyboard
jmp main_menu


betting:

mov rsi, msg_betting_1
call print_str
call print_settings
mov rsi, msg_betting_2
call print_str

bet_amount_input:

mov rsi, input
call input_keyboard
call str_number
cmp rax, 0
jg check_balance
mov rsi, msg_bet_error_1
call print_str
jmp bet_amount_input
check_balance:
cmp rax, [balance]
jng bet_choice
mov rsi, msg_bet_error_2
call print_str
jmp bet_amount_input

bet_choice:

mov [bet], rax
mov rsi, msg_bet_choice
call print_str
bet_choice_input:
mov rsi, input
call input_keyboard
call str_number
cmp rax, [number_of_dice]
jl incorrect_bet
push rax
mov rbx, [dice_sides]
mov rax, [number_of_dice]
mul rbx
mov rbx, rax
pop rax
cmp rax, rbx
jg incorrect_bet
jmp playing
incorrect_bet:
mov rsi, msg_bet_error_3
call print_str
jmp bet_choice_input

playing:

mov [chosen_bet], rax
mov rsi, msg_bet_commence
call print_str
mov rsi, input
call input_keyboard
mov rdx, [number_of_dice]
mov rsi, [dice_sides]
mov rdi, [rand]
mov r9, output
call roll_dice
mov rdi, rax
mov rsi, msg_bet_res
call print_str
mov rsi, output
call number_str
call print_str
mov rax, rdi
cmp rax, [chosen_bet]
je jackpot
push rax
mov rax, [number_of_dice]
mov rbx, [dice_sides]
mul rbx
mov rbx, [number_of_dice]
sub rax, rbx
mov rbx, 2
div rbx
add rax, [number_of_dice]
mov rbx, rax
pop rax
cmp [chosen_bet], rbx
jl lesser_bet
jg greater_bet
jmp lost_bet
lesser_bet:
cmp rax, rbx
jl won_bet
jnl lost_bet
greater_bet:
cmp rax, rbx
jg won_bet

lost_bet:

mov rax, [bet]
sub [balance], rax
mov rsi, msg_bet_res_loss
call print_str
cmp [balance], 0
jg result
mov rsi, msg_last_loss
call print_str
jmp result

won_bet:

mov rsi, msg_bet_res_win
call print_str
mov rax, [bet]
add [balance], rax
jmp result

jackpot:

cmp [dice_sides], 4
jne @f
mov rsi, msg_bet_jackpot_1
mov rbx, 3
jmp jackpot_common
@@:
cmp [dice_sides], 12
jne @f
mov rsi, msg_bet_jackpot_3
mov rbx, 5
jmp jackpot_common
@@:
cmp [dice_sides], 20
jne @f
mov rsi, msg_bet_jackpot_4
mov rbx, 6
jmp jackpot_common
@@:
mov rsi, msg_bet_jackpot_2
mov rbx, 4
jackpot_common:
call print_str
mov rax, [bet]
mul rbx
add [balance], rax

result:

mov rsi, msg_await
call print_str
mov rsi, input
call input_keyboard
mov rax, [balance]
cmp rax, 0
jg main_menu
jmp kicked_out


dice:

mov rsi, msg_dice_1
call print_str
call print_settings
mov rsi, msg_dice_2
call print_str
dice_input_loop:
mov rsi, input
call input_keyboard
mov rdx, input
mov rax, key3
call compare
cmp rax, 1
je tweak_type
mov rax, key5
call compare
cmp rax, 1
je tweak_amount
mov rax, key6
call compare
cmp rax, 1
je main_menu
mov rsi, msg_menu_error
call print_str
jmp dice_input_loop

tweak_amount:

mov rsi, msg_dice_amount
call print_str
dice_amount_input:
mov rsi, input
call input_keyboard
mov rax, input
call str_number
cmp rax, 2
jl amount_error
cmp rax, 20
jg amount_error
mov rbx, rax
mov rcx, 2
div rcx
cmp rdx, 0
jne amount_error
mov [number_of_dice], rbx
jmp dice
amount_error:
mov rsi, msg_dice_amount_error
call print_str
jmp dice_amount_input

tweak_type:

mov rsi, msg_dice_type
call print_str
dice_type_input:
mov rsi, input
call input_keyboard
mov rax, input
call str_number
cmp rax, 4
je type_success
cmp rax, 6
je type_success
cmp rax, 8
je type_success
cmp rax, 10
je type_success
cmp rax, 12
je type_success
cmp rax, 20
je type_success
mov rsi, msg_dice_type_error
call print_str
jmp dice_type_input
type_success:
mov [dice_sides], rax
jmp dice


kicked_out:

mov rsi, msg_lost
call print_str
call exit


exiting:

mov rsi, msg_exit_1
call print_str
xor rax, rax
mov rax, [balance]
mov rsi, output
call number_str
call print_str
mov rsi, msg_exit_2
call print_str
call exit



;the used functions

;finishes the program
exit:
mov rax, 3
mov rdi, [rand]
syscall
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

;prints current dice settings
print_settings:
mov rax, [number_of_dice]
mov rsi, output
call number_str
call print_str
mov [output], ' '
call print_str
mov rax, [dice_sides]
mov rsi, output
call number_str
call print_str
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