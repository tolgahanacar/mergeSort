section .data
    ; Array to be sorted
    array db 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    ; Size of the array
    array_size equ 10

section .bss
    temp resb array_size  ; Temporary array for merge operation

section .text
    global _start

_start:
    ; Initialize the array pointers and size
    mov esi, array        ; Source array
    mov edi, temp         ; Temp array
    mov ecx, array_size   ; Number of elements

    ; Call merge sort
    push ecx
    push esi
    call merge_sort

    ; Exit program
    mov eax, 1            ; sys_exit
    xor ebx, ebx          ; Return code 0
    int 0x80

merge_sort:
    ; Parameters: [esp+4] - ptr to array
    ;             [esp+8] - size of array
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx

    mov esi, [ebp+8]      ; Array pointer
    mov ecx, [ebp+12]     ; Array size

    cmp ecx, 1            ; If size <= 1, return
    jle .done

    ; Find midpoint
    mov ebx, ecx
    shr ebx, 1            ; Midpoint = size / 2

    ; Recursively sort the first half
    push ebx              ; size / 2
    push esi              ; array pointer
    call merge_sort
    add esp, 8

    ; Recursively sort the second half
    lea esi, [esi+ebx]    ; Move to second half
    push ecx              ; size
    sub dword [esp], ebx  ; size - size / 2
    push esi              ; second half array pointer
    call merge_sort
    add esp, 8

    ; Merge sorted halves
    mov esi, [ebp+8]      ; array pointer
    lea edi, [esi+ebx]    ; second half pointer
    mov ecx, ebx          ; midpoint
    mov edx, [ebp+12]     ; array size
    sub edx, ecx          ; size - midpoint

    xor ebx, ebx          ; index of the first half
    xor esi, esi          ; index of the temp array

.merge_loop:
    cmp ebx, ecx          ; If first half is exhausted
    jge .copy_second_half

    cmp esi, edx          ; If second half is exhausted
    jge .copy_first_half

    mov al, [array + ebx]
    mov ah, [temp + esi]
    cmp al, ah
    jle .copy_first_half_element

    ; Copy element from second half
    mov [temp + esi], ah
    inc esi
    inc edx
    jmp .merge_loop

.copy_first_half_element:
    ; Copy element from first half
    mov [temp + esi], al
    inc esi
    inc ebx
    jmp .merge_loop

.copy_second_half:
    ; Copy remaining elements from the second half
    mov ah, [array + edx]
    mov [temp + esi], ah
    inc esi
    inc edx
    cmp esi, [ebp+12]     ; check if all elements are merged
    jl .copy_second_half

.copy_first_half:
    ; Copy remaining elements from the first half
    mov al, [array + ebx]
    mov [temp + esi], al
    inc esi
    inc ebx
    cmp esi, [ebp+12]     ; check if all elements are merged
    jl .copy_first_half

    ; Copy sorted elements back to the original array
    mov esi, array
    mov edi, temp
    mov ecx, [ebp+12]

.copy_back:
    mov al, [edi]
    mov [esi], al
    inc esi
    inc edi
    loop .copy_back

.done:
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret
