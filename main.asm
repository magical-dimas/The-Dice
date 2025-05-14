format elf64
public _start

include 'func.asm'

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
msg1 db "Welcome to our humble casino, please, enjoy your stay!", 0xa, 0
msg2 db "Sadly, your balance has become zero and you are unable to continue playing. Please, come again later, when you have more money.", 0xa, 0
msg3_1 db "Thank you for visiting us. Your final balance is ", 0
msg3_2 db " points. Please, come again soon!", 0xa, 0
msg4_1 db "Your current balance is ", 0
msg4_2 db " points. Write anything to go back to the menu...", 0xa, 0
msg5_1 db "Place your bets! There are currently ", 0
msg5_2 db "-sided dice being rolled.", 0xa, 0
msg6_1 db "Hey, you have to place a proper bet! The one H.I.G.H.E.R. than zero~", 0xa, 0
msg6_2 db "Sorry, but you don't have enoutgh money on your balance for such a bet. Try something lower~", 0xa, 0
msg7 db "Money placed. Select the result to bet on.", 0xa, 0
msg11 db "Bets placed! Rolling the dice now...", 0xa, 0
msg8 db "The result of the dice roll is ", 0
msg9_1 db ". You win your bet!", 0xa, 0
msg9_2 db ". You lose your bet~", 0xa, 0
msg9_3 db ". Congratulations, you quadriple your bet!", 0xa, 0
msg9_4 db ". Congratulations, you quintiple your bet!", 0xa, 0
msg9_5 db ". Congratulations, you sextiple your bet!", 0xa, 0
msg10 db "Write anything to continue...", 0xa, 0
msg12 db "That bet is impossible. Please, choose a bet that fits.", 0xa, 0
msg13 db "Oh no, that was the last bit of your money!", 0xa, 0
msg14 db "Enter the word 'balance' to check your balance, 'bet' to place a bet, 'dice' to tweak the selected dice or 'exit' to quit the program.", 0xa, 0
msg15 db "This is not an available option~. Please, enter an existing command.", 0xa, 0
msg16_1 db "Currently, there are ", 0
msg16_2 db "-sided dice being rolled. Write 'dice' in order to change the type of dice used, 'amount' to change the number of dice and 'menu' to return to the main menu.", 0xa, 0
msg17 db "Input the amount of sides on the dice you desire. The available options are d6, d8, d10, d12 and d20 for the purpose of a fair game~", 0xa, 0
msg18 db "Input the amount of dice you desire. The number has to be even and range from 2 to 16 for the purpose of a fair game~", 0xa, 0
msg19 db "The available options are d6, d8, d10, d12 and d20...", 0xa, 0
msg20 db "The number has to be even and range from 2 to 16...", 0xa, 0
key1 db "balance", 0
key2 db "bet", 0
key3 db "dice", 0
key4 db "exit", 0
key5 db "amount", 0
key6 db "menu", 0

section '.text' executable

_start:
mov rsi, msg1
call print_str
mov rax, 2
mov rdi, f
mov rsi, 0o
syscall
mov [rand], rax
main_loop:

mov rsi, msg14
call print_str
main_input_loop:
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
mov rsi, msg15
call print_str
jmp main_input_loop

balance_check:

mov rsi, msg4_1
call print_str
xor rax, rax
mov rax, [balance]
mov rsi, output
call number_str
call print_str
mov rsi, msg4_2
call print_str

mov rsi, input
call input_keyboard

jmp main_loop

betting:

mov rsi, msg5_1
call print_str
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
mov rsi, msg5_2
call print_str

betting_loop:
mov rsi, input
call input_keyboard
call str_number
cmp rax, 0
jg check_balance
mov rsi, msg6_1
call print_str
jmp betting_loop
check_balance:
cmp rax, [balance]
jng selecting_bet
mov rsi, msg6_2
call print_str
jmp betting_loop

selecting_bet:
mov [bet], rax
mov rsi, msg7
call print_str
bet_selection_loop:
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
mov rsi, msg12
call print_str
jmp bet_selection_loop

playing:
mov [chosen_bet], rax
mov rsi, msg11
call print_str
mov rsi, input
call input_keyboard
mov rdx, [number_of_dice]
mov rsi, [dice_sides]
mov rdi, [rand]
mov r9, output
call roll_dice
mov rdi, rax
mov rsi, msg8
call print_str
mov rsi, output
call number_str
call print_str
mov rax, rdi
cmp rax, [chosen_bet]
je guessed
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
cmp [chosen_bet], rbx
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
mov rsi, msg9_2
call print_str
cmp [balance], 0
jg result
mov rsi, msg13
call print_str
jmp result

won_bet:
mov rsi, msg9_1
call print_str
mov rax, [bet]
add [balance], rax
jmp result

guessed:
cmp [dice_sides], 12
je quintiple
cmp [dice_sides], 20
je sextiple
mov rsi, msg9_3
call print_str
mov rax, [bet]
mov rbx, 4
mul rbx
add [balance], rax
jmp result
quintiple:
mov rsi, msg9_4
call print_str
mov rax, [bet]
mov rbx, 5
mul rbx
add [balance], rax
jmp result
sextiple:
mov rsi, msg9_5
call print_str
mov rax, [bet]
mov rbx, 6
mul rbx
add [balance], rax

result:
mov rsi, msg10
call print_str
mov rsi, input
call input_keyboard

mov rax, [balance]
cmp rax, 0
jg main_loop
jmp kicked_out

dice:

mov rsi, msg16_1
call print_str
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
mov rsi, msg16_2
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
je main_loop
mov rsi, msg15
call print_str
jmp dice_input_loop

tweak_amount:
mov rsi, msg18
call print_str
amount_loop:
mov rsi, input
call input_keyboard
mov rax, input
call str_number
cmp rax, 2
jl amount_error
cmp rax, 16
jg amount_error
mov rbx, rax
mov rcx, 2
div rcx
cmp rdx, 0
jne amount_error
mov [number_of_dice], rbx
jmp dice
amount_error:
mov rsi, msg20
call print_str
jmp amount_loop

tweak_type:
mov rsi, msg17
call print_str
type_loop:
mov rsi, input
call input_keyboard
mov rax, input
call str_number
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
mov rsi, msg19
call print_str
jmp type_loop
type_success:
mov [dice_sides], rax
jmp dice

kicked_out:

mov rsi, msg2
call print_str
call exit

exiting:

mov rsi, msg3_1
call print_str
xor rax, rax
mov rax, [balance]
mov rsi, output
call number_str
call print_str
mov rsi, msg3_2
call print_str
call exit