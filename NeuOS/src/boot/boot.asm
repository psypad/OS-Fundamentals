ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

 times 33 db 0
 
start:
    jmp 0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    
; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:     ; CS SHOULD POINT TO THIS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x9a   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

; offset 0x10
gdt_data:      ; DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x100000

ata_lba_read:
    mov ebx, eax, ;LBA backup
    ;sending the highest 8 bits of lba to hdd controller
    shr eax, 24
    or eax, 0xE0
    mov dx, 0x1F6
    out dx, al
    ;Finished sending the highest 8 bits of the lba

    ; Send the total sectors to read'
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finished sending the total sectors to read

    ;send more bits of the LBA
    mov eax, ebx ;restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ;finished sending more bits of the LBA

    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx ;restore the backup of LBA
    shr eax, 8
    out dx, al
    ;finished sending more bits of the LBA

    ;send the upper bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx ;Restore the backup of LBA
    shr eax, 16
    out dx, al
    ;Finished sending upper 16 bits of LBA

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ;Read all sectors into memory
.next_sector:
    push ecx

;checking if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 9
    jz .try_again

;we need to read 256 words at a time 
    mov ecx, 456
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ;end of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55
