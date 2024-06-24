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
    shr ecx, 1            ; Midpoint = size / 2

    ; Recursively sort the first half
    push ecx              ; size / 2
    push esi              ; array pointer
    call merge_sort
    add esp, 8

    ; Recursively sort the second half
    mov ebx, esi          ; array pointer
    add ebx, ecx          ; Move to second half
    push [ebp+12]         ; size
    sub dword [esp], ecx  ; size - size / 2
    push ebx              ; second half array pointer
    call merge_sort
    add esp, 8

    ; Merge sorted halves
    mov eax, esi          ; array pointer
    mov ebx, ecx          ; midpoint
    add eax, ebx          ; second half pointer
    mov edi, [ebp+8]      ; array pointer
    mov ecx, [ebp+12]     ; size

    ; Merge process
    mov edx, ebx          ; index of the second half
    xor ebx, ebx          ; index of the first half
    xor esi, esi          ; index of the temp array

.merge_loop:
    cmp ebx, edx          ; If first half is exhausted
    jge .copy_second_half

    cmp edx, ecx          ; If second half is exhausted
    jge .copy_first_half

    mov al, [edi+ebx]     ; Compare elements
    cmp al, [edi+ebx+ebx]
    jle .copy_first_half_element

    ; Copy element from second half
    mov al, [edi+ebx+ebx]
    mov [edi+esi], al
    inc edx
    jmp .increment_esi

.copy_first_half_element:
    ; Copy element from first half
    mov al, [edi+ebx]
    mov [edi+esi], al
    inc ebx

.increment_esi:
    inc esi
    cmp esi, ecx
    jl .merge_loop

.copy_first_half:
    ; Copy remaining elements from the first half
    cmp ebx, edx
    jge .merge_done

    mov al, [edi+ebx]
    mov [edi+esi], al
    inc ebx
    inc esi
    jmp .copy_first_half

.copy_second_half:
    ; Copy remaining elements from the second half
    cmp edx, ecx
    jge .merge_done

    mov al, [edi+edx]
    mov [edi+esi], al
    inc edx
    inc esi
    jmp .copy_second_half

.merge_done:
    ; Copy sorted elements back to the original array
    mov esi, [ebp+8]
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
