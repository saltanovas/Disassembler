.model small   
BufDydis EQU 9999 
.stack 100h  
.386     
.data
;-----------------  
        enteris      db 13, 10, '$'
        duomf        db 20 dup (0) 
        rezf         db 20 dup (0)  
        dHandle      dw ?
        rHandle      dw ?
        klaida1      db "neteisingai ivesti duomenys", 10, 13, '$'
        help         db "Aivaras Saltanovas, 1 kursas, 4 grupe. Disasembleris", 10, 13, "$"
        neatpazintas db "NEATPAZINTA"
        dvitaskis    db 58, 9
        tab          db 9, 9         
;-----------------     
        buferis      db BufDydis dup (0) 
        kiekis       dw 0 
;-----------------               
        adresas      dw 100h
        poslinkis    dw 0
        isvesti      db 0
           
        pirmasbaitas     db ?
        antrasbaitas     db ? 
        treciasbaitas    db ?
        ketvirtasbaitas  db ? 
        prefixas         db ?
        
        formato_nr   db ?   ; dabartines komandos formatas  
        prefixo_nr   db ?   ; 0 - nera  1 - ES  2 - CS  3 - SS  4 - DS
        
        reg_dalis    db ?
        rm_dalis     db ?
        mod_dalis    db ?
        d_dalis      db ?
        w_dalis      db ?
        sreg_dalis   db ?
        bojb_baitas  db ?
        bovb_baitas  db ?
;-------------------------        
        kablelis     db ', '
        pliusas      db ' + '
        kskliaustas  db '['
        dskliaustas  db ']'            
;-------------------------        
        k_MOV        db 'MOV', 9, '$'        
        k_PUSH       db 'PUSH', 9, '$'
        k_ADD        db 'ADD', 9, '$'
        k_SUB        db 'SUB', 9, '$' 
        k_DEC        db 'DEC', 9, '$'
        k_INC        db 'INC', 9, '$'
        k_POP        db 'POP', 9, '$'
        k_CMP        db 'CMP', 9, '$'
        k_MUL        db 'MUL', 9, '$'
        k_DIV        db 'DIV', 9, '$'
        k_CALL       db 'CALL', 9, '$'
        k_RET        db 'RET', 9, '$'
        k_RETF       db 'RETF', 9, '$'
        k_IRET       db 'IRET', 9, '$'
        
        k_JMP        db 'JMP', 9, '$'
        k_JO         db 'JO', 9, '$'
        k_JNO        db 'JNO', 9, '$'
        k_JNAE       db 'JNAE', 9, '$'
        k_JAE        db 'JAE', 9, '$'
        k_JE         db 'JE', 9, '$'
        k_JNE        db 'JNE', 9, '$'
        k_JBE        db 'JBE', 9, '$'
        k_JA         db 'JA', 9, '$'
        k_JS         db 'JS', 9, '$'
        k_JNS        db 'JNS', 9, '$'
        k_JP         db 'JP', 9, '$'
        k_JNP        db 'JNP', 9, '$'
        k_JL         db 'JL', 9, '$'
        k_JGE        db 'JGE', 9, '$'
        k_JLE        db 'JLE', 9, '$'
        k_JG         db 'JG', 9, '$'
        k_JCXZ       db 'JCXZ', 9, '$'
        
        k_LOOP       db 'LOOP', 9, '$'
        k_INT3       db 'INT', 9, '3', '$'
        k_INT        db 'INT', 9, '$' 
        k_INTO       db 'INTO', 9, '$'     
;-----------------         
        ea_rm000 db 'bx+si'
        ea_rm001 db 'bx+di'
        ea_rm010 db 'bp+si'
        ea_rm011 db 'bp+di'
        ea_rm100 db 'si'
        ea_rm101 db 'di'
        ea_rm110 db 'bp' ;kai mod=00 ir r/m = 110, tai tiesioginis
        ea_rm111 db 'bx'

        r_AX db 'AX'
        r_AL db 'AL'
        r_AH db 'AH'
        
        r_BX db 'BX'
        r_BL db 'BL'
        r_BH db 'BH'
    
        r_CX db 'CX'
        r_CL db 'CL'
        r_CH db 'CH'
    
        r_DX db 'DX'
        r_DL db 'DL'
        r_DH db 'DH'
    
        r_SP db 'SP'
        r_BP db 'BP'
        r_SI db 'SI'
        r_DI db 'DI'
        
        t_ES db 'ES:'
        t_CS db 'CS:'
        t_SS db 'SS:'
        t_DS db 'DS:'    
        
;-----------------------------------------------------------------------------------------
.code    
pradzia:
    mov ax, @data
    mov ds, ax  
    
    mov si, 81h
    mov di, offset duomf
    call parametruSkaitymas             
    mov di, offset rezf
    call parametruSkaitymas
    
atidaromDuomf:
    mov dx, offset duomf                           
    mov ah, 3dh
    mov al, 00
    int 21h
    jc klaida                 
    mov dHandle, ax 
                    
kuriamRezf:
    mov ah, 3ch
    mov cx, 0
    mov dx, offset rezf
    int 21h
    jnc neklaida
    jmp klaida
    neklaida:
    mov rHandle, ax 
    
atidaromRezf:
    mov ah, 3dh
    mov al, 1
    mov dx, offset rezf
    int 21h            
    mov rhandle, ax  
    
skaitomDuomf:    
    mov bx, dHandle
    call SkaitomBuf
    mov di, offset buferis

;--------------------------------------------------------------------------------------------------------
;PAGRINDINIS ALGORITMAS
;--------------------------------------------------------------------------------------------------------
ALGORITMAS:

    cmp kiekis, 0
    je baigti_programa
    
    mov ax, adresas
    call isvesti_adresa
    call isvesti_dvitaski 
        
    call get_byte           ;219
    mov byte ptr[pirmasbaitas], al
     
    call patikrinti_ar_prefixas
        cmp byte ptr[prefixo_nr], 0
            je prefixo_nera
                mov byte ptr[prefixas], al
                call isvesti_baita
                call get_byte
                mov byte ptr[pirmasbaitas], al  
     
    prefixo_nera:
    call gauti_formatas
    
    call spausdinti
    call isvesti_enter ;474 
        
    jmp ALGORITMAS  
    
;--------------------------------------------------------------------------------------------------------
get_byte: 
    mov al, byte ptr[di]
    inc di
    inc adresas  
    cmp kiekis, 0
    je baigti_programa
    dec kiekis
RET
     
;--------------------------------------------------------------------------------------------------------
;SUZINOMAS KOMANDOS FORMATAS
;--------------------------------------------------------------------------------------------------------
gauti_formatas:    
    
    pirmas: ;INC, DEC, PUSH ir POP zodinis tarp 40h-5Fh
        cmp byte ptr[pirmasbaitas], 40h
            jb antras
        cmp byte ptr[pirmasbaitas], 5Fh
            ja antras
        
        mov byte ptr[formato_nr], 1
    RET 
           
;---------------       
    antras:
        cmp byte ptr[pirmasbaitas], 0C3h ;ret
            je taip_antras
        cmp byte ptr[pirmasbaitas], 0CBh ;[retf iret]
            jb trecias
        cmp byte ptr[pirmasbaitas], 0CFh
            ja trecias 
        
    taip_antras:        
        mov byte ptr[formato_nr], 2
    RET
             
;---------------       
    trecias:
    trecias1: ;mov  
    cmp byte ptr[pirmasbaitas], 88h
        jge gal_trecias1
        jmp ne_trecias1
            gal_trecias1:
            cmp byte ptr[pirmasbaitas], 8Bh
                jng taip_trecias
                jmp ne_trecias1  
                
    ne_trecias1:
    trecias2: ;add
        cmp byte ptr[pirmasbaitas], 00h
            je taip_trecias
        cmp byte ptr[pirmasbaitas], 01h
            je taip_trecias
        cmp byte ptr[pirmasbaitas], 02h
            je taip_trecias
        cmp byte ptr[pirmasbaitas], 03h
            je taip_trecias           
    
    ne_trecias2:
    trecias3: ;sub
        cmp byte ptr[pirmasbaitas], 28h
            jge gal_trecias3
            jmp ne_trecias3
                gal_trecias3:
                cmp byte ptr[pirmasbaitas], 2Bh
                    jng taip_trecias
                    jmp ne_trecias3
                
    ne_trecias3:
    trecias4: ;cmp
        cmp byte ptr[pirmasbaitas], 38h
            jge gal_trecias4
            jmp ketvirtas
                gal_trecias4:
                cmp byte ptr[pirmasbaitas], 3Bh
                    jng taip_trecias
                    jmp ketvirtas    
    
    taip_trecias:        
        mov byte ptr[formato_nr], 3
    RET
                
;---------------    
    ketvirtas:
        cmp byte ptr[pirmasbaitas], 80h ;cmp, add, sub
            jb penktas
        cmp byte ptr[pirmasbaitas], 83h
            ja penktas
        
        mov byte ptr[formato_nr], 4
    RET
        
;---------------      
    penktas:
        cmp byte ptr[pirmasbaitas], 8Fh ;pop
            je taip_penktas
        cmp byte ptr[pirmasbaitas], 0FEh ;inc arba dec
            je taip_penktas 
        cmp byte ptr[pirmasbaitas], 0FFh ;inc, dec, jmp, call, push
            je taip_penktas
                jmp sestas  
              
    taip_penktas:               
        mov byte ptr[formato_nr], 5
    RET      
    
;---------------    
    sestas:
        cmp byte ptr[pirmasbaitas], 06h
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 0Eh
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 16h
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 1Eh
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 07h
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 0Fh
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 16h
            je taip_sestas
        cmp byte ptr[pirmasbaitas], 1Eh
            je taip_sestas
                jmp septintas    
            
    taip_sestas:               
        mov byte ptr[formato_nr], 6
    RET   
             
;---------------      
    septintas:
        cmp byte ptr[pirmasbaitas], 0F6h
            je taip_septintas
        cmp byte ptr[pirmasbaitas], 0F7h
            je taip_septintas
                jmp astuntas    
                
    taip_septintas:               
        mov byte ptr[formato_nr], 7
    RET 
    
;---------------
    astuntas:
        cmp byte ptr[pirmasbaitas], 0E2h ;loop
            je taip_astuntas
        cmp byte ptr[pirmasbaitas], 0E3h ;jcxz
            je taip_astuntas
        cmp byte ptr[pirmasbaitas], 0EBh ;;jmp
            je taip_astuntas
        cmp byte ptr[pirmasbaitas], 70h
            jb devintas
        cmp byte ptr[pirmasbaitas], 7Fh
            ja devintas  
            
    taip_astuntas:        
        mov byte ptr[formato_nr], 8
    RET 

;---------------
    devintas:
        cmp byte ptr[pirmasbaitas], 0C2h
            je taip_devintas
        cmp byte ptr[pirmasbaitas], 0C3h
            je taip_devintas
                jmp desimtas     
                
    taip_devintas:        
        mov byte ptr[formato_nr], 9
    RET 
        
;---------------
    desimtas:
        cmp byte ptr[pirmasbaitas], 04h
            je taip_desimtas
        cmp byte ptr[pirmasbaitas], 05h
            je taip_desimtas
        cmp byte ptr[pirmasbaitas], 2Ch
            je taip_desimtas
        cmp byte ptr[pirmasbaitas], 2Dh
            je taip_desimtas
        cmp byte ptr[pirmasbaitas], 3Ch
            je taip_desimtas
        cmp byte ptr[pirmasbaitas], 3Dh
            je taip_desimtas
                jmp vienuoliktas
                
    taip_desimtas:        
        mov byte ptr[formato_nr], 10
    RET
 
;---------------  
    vienuoliktas:
        cmp byte ptr[pirmasbaitas], 0A0h
            jb dvyliktas
        cmp byte ptr[pirmasbaitas], 0A3h
            ja dvyliktas
                        
        mov byte ptr[formato_nr], 11
     RET
    
;--------------- 
     dvyliktas:
        cmp byte ptr[pirmasbaitas], 9Ah
            je taip_dvyliktas
        cmp byte ptr[pirmasbaitas], 0EAh
            je taip_dvyliktas
                jmp tryliktas
                 
     taip_dvyliktas:           
        mov byte ptr[formato_nr], 12
     RET
     
;---------------
    tryliktas:
        cmp byte ptr[pirmasbaitas], 0E8h
            je taip_tryliktas
        cmp byte ptr[pirmasbaitas], 0E9h
            je taip_tryliktas
                jmp keturioliktas 
    
    taip_tryliktas:
        mov byte ptr[formato_nr], 13
    RET
    
;---------------   
    keturioliktas:
        cmp byte ptr[pirmasbaitas], 8Ch
            je taip_keturioliktas
        cmp byte ptr[pirmasbaitas], 8Eh
            je taip_keturioliktas
                jmp penkioliktas 
    
    taip_keturioliktas:
        mov byte ptr[formato_nr], 14
    RET
    
;---------------    
    penkioliktas:
        cmp byte ptr[pirmasbaitas], 0B0h
            jb sesioliktas
        cmp byte ptr[pirmasbaitas], 0BFh
            ja sesioliktas
        
        mov byte ptr[formato_nr], 15
    RET

;---------------
    sesioliktas:
        cmp byte ptr[pirmasbaitas], 0C6h
            je taip_sesioliktas
        cmp byte ptr[pirmasbaitas], 0C7h
            je taip_sesioliktas
                jmp neatpazinta 
    
    taip_sesioliktas:
        mov byte ptr[formato_nr], 16
    RET

;---------------
    neatpazinta:
        mov byte ptr[formato_nr], 0
    RET

;---------------------------------------------------------------------------------------------
;SPAUSDINAMA PAGAL FORMATA
;---------------------------------------------------------------------------------------------
spausdinti:

    cmp byte ptr[formato_nr], 1
        je spausdinti_pirma
    cmp byte ptr[formato_nr], 2
        je spausdinti_antra
    cmp byte ptr[formato_nr], 3
        je spausdinti_trecia
    cmp byte ptr[formato_nr], 4
        je spausdinti_ketvirta
    cmp byte ptr[formato_nr], 5
        je spausdinti_penkta
    cmp byte ptr[formato_nr], 6
        je spausdinti_sesta
    cmp byte ptr[formato_nr], 7
        je spausdinti_septinta
    cmp byte ptr[formato_nr], 8
        je spausdinti_astunta
    cmp byte ptr[formato_nr], 9
        je spausdinti_devinta
    cmp byte ptr[formato_nr], 10
        je spausdinti_desimta
    cmp byte ptr[formato_nr], 11
        je spausdinti_vienuolikta
    cmp byte ptr[formato_nr], 12
        je spausdinti_dvylikta
    cmp byte ptr[formato_nr], 13
        je spausdinti_trylikta
    cmp byte ptr[formato_nr], 14
        je spausdinti_keturiolikta
    cmp byte ptr[formato_nr], 15
        je spausdinti_penkiolikta
    cmp byte ptr[formato_nr], 16
        je spausdinti_sesiolikta

;--------------------------
spausdinti_nulini: 

    call isvesti_baita
    call isvesti_tab
    call isvesti_neatpazinta 
    
RET

;--------------------------
spausdinti_pirma:

        call gautiRM
        call isvesti_baita
        call isvesti_tab
        call spausdinti_pirma_komanda
        mov al, byte ptr[rm_dalis]
        mov byte ptr[w_dalis], 1
        call spausdinti_rm_mod11
RET

;-----
spausdinti_pirma_komanda:
    
    pirma_komanda_INC:
    cmp byte ptr[pirmasbaitas], 47h
        jg pirma_komanda_POP
                mov cx, 4
                mov dx, offset k_INC
                    jmp pabaiga_spausdinti_pirma_komanda
                    
     pirma_komanda_POP:
     cmp byte ptr[pirmasbaitas], 58h
        jb pirma_komanda_DEC
            mov cx, 4
            mov dx, offset k_POP
                jmp pabaiga_spausdinti_pirma_komanda
                                
    pirma_komanda_DEC:
    cmp byte ptr[pirmasbaitas], 4Fh
        jg pirma_komanda_PUSH
            mov cx, 4
            mov dx, offset k_DEC
                jmp pabaiga_spausdinti_pirma_komanda

                
    pirma_komanda_PUSH:
        mov cx, 5
        mov dx, offset k_PUSH  
            jmp pabaiga_spausdinti_pirma_komanda
         
pabaiga_spausdinti_pirma_komanda:
        mov ah, 40h
        mov bx, rHandle
        int 21h
RET

;--------------------------
spausdinti_antra:
        
        call isvesti_baita
        call spausdinti_antra_komanda
RET

;------
spausdinti_antra_komanda:
       
       antra_komanda_INT: 
        cmp byte ptr[pirmasbaitas], 0CDh
        jne antra_komanda_RETF
            call get_byte
            push ax
            call isvesti_baita
            call isvesti_tab
                 mov ah, 40h
                 mov bx, rHandle
                 mov cx, 4
                 mov dx, offset k_INT
                 int 21h
            pop ax
            call isvesti_baita 
        RET
        
    antra_komanda_RETF:
    cmp byte ptr[pirmasbaitas], 0CBh
        jne antra_komanda_INT3
         call isvesti_tab
            mov cx, 5
            mov dx, offset k_RETF
                                
    antra_komanda_INT3:
    cmp byte ptr[pirmasbaitas], 0CCh
        jne antra_komanda_INTO
         call isvesti_tab                   
            mov cx, 5
            mov dx, offset k_INT3
     
     antra_komanda_INTO:
        cmp byte ptr[pirmasbaitas], 0CEh
        jne antra_komanda_IRET 
         call isvesti_tab                   
            mov cx, 5
            mov dx, offset k_INTO

     antra_komanda_IRET:
     cmp byte ptr[pirmasbaitas], 0CCh
        jne antra_komanda_RET
         call isvesti_tab                   
            mov cx, 5
            mov dx, offset k_IRET
     
     antra_komanda_RET:
      call isvesti_tab                    
        mov cx, 4
        mov dx, offset k_RET 
        
baigti_spausdinti_antra_komanda:        
        mov ah, 40h
        mov bx, rHandle
        int 21h           
RET        
        
;--------------------------
spausdinti_trecia:
   
     call gautiD
     call gautiW
     call isvesti_baita
     
     call get_byte
     mov byte ptr[antrasbaitas], al
     call gautiMOD
     call gautiREG
     call gautiRM
     call isvesti_baita  
     
     call kiek_poslinkis
     call ar_tiesioginis_adresas
     call spausdinti_trecia_komanda 
     
        cmp d_dalis, 0h
            je reg_antras
        
     call isvesti_pagal_REG
     call isvesti_kableli
     call spausdinti_prefixa
     call isvesti_pagal_RM
        jmp pabaiga_spausdinti_trecia
        
     reg_antras:
     call spausdinti_prefixa
     call isvesti_pagal_RM
     call isvesti_kableli
     call isvesti_pagal_REG

pabaiga_spausdinti_trecia:     
RET          

;------
spausdinti_trecia_komanda:

    trecia_komanda_ADD:
        cmp byte ptr[pirmasbaitas], 03h
            ja trecia_komanda_MOV
                call isvesti_tab
                mov dx, offset k_ADD
                jmp pabaiga_spausdinti_trecia_komanda
            
    trecia_komanda_MOV:
        cmp byte ptr[pirmasbaitas], 88h
            jb trecia_komanda_CMP
            call isvesti_tab
                mov dx, offset k_MOV 
                jmp pabaiga_spausdinti_trecia_komanda      

   
   trecia_komanda_CMP:
        cmp byte ptr[pirmasbaitas], 38h
            jb trecia_komanda_SUB
            call isvesti_tab
                mov dx, offset k_CMP
                jmp pabaiga_spausdinti_trecia_komanda
        
   trecia_komanda_SUB:
        call isvesti_tab
        mov dx, offset k_SUB  
     
pabaiga_spausdinti_trecia_komanda:
    mov ah, 40h
    mov cx, 4
    mov bx, rHandle
    int 21h
RET           

;----------------------------------------------------------
spausdinti_ketvirta:

    call gautiD
    call gautiW
    call isvesti_baita  
    
    call get_byte
    mov byte ptr[antrasbaitas], al
    call gautiMOD
    call gautiREG
    call gautiRM
    call isvesti_baita 
      
    call kiek_poslinkis
    call ar_tiesioginis_adresas
    
    cmp byte ptr[d_dalis], 0b
        je spausdinti_ketvirta_2baitai
            jmp plesti_baita
    
    spausdinti_ketvirta_2baitai:
    cmp byte ptr[w_dalis], 0h
        je imti_viena
            call get_byte
            mov byte ptr[bojb_baitas], al
            call isvesti_baita
        imti_viena:
            call get_byte
            mov byte ptr[bovb_baitas], al
            call isvesti_baita
                jmp poslinkio_pabaiga
             
     plesti_baita:
        call get_byte
        mov byte ptr[poslinkis], al
        call isvesti_baita       
            cmp byte ptr[poslinkis], 80h
                jae poslinkio_pabaiga
                    mov ah, 00h
                    mov al, byte ptr[poslinkis]
                    mov word ptr[poslinkis], ax
                    call isvesti_tab
                    call isvesti_ketvirta_komanda
                        jmp toliau1
                    reikia_plesti_baita:
                        mov al, byte ptr[bojb_baitas]
                        mov ah, 0FFh
                        mov word ptr[poslinkis], ax
    
    poslinkio_pabaiga:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 1
    mov dx, offset tab
    int 21h 
    call isvesti_ketvirta_komanda
    
toliau1:

    call spausdinti_prefixa
                      
    cmp d_dalis, 0h
        je vienas

            call isvesti_pagal_RM
            call isvesti_kableli
            mov ax, word ptr[poslinkis]
            call isvesti_adresa
        RET                             
                                                                       
        vienas:
            call isvesti_pagal_RM
            call isvesti_kableli
            mov al, byte ptr[bovb_baitas]
            call isvesti_baita 
RET
    
;-----    
      isvesti_ketvirta_komanda:
        cmp byte ptr[reg_dalis], 0h
            jne isvesti_ketvirta_komanda_CMP
                mov dx, offset k_ADD
                    jmp pabaiga_isvesti_ketvirta_komanda
                 
        isvesti_ketvirta_komanda_CMP:
            cmp byte ptr[reg_dalis], 0111b
                jne isvesti_ketvirta_komanda_SUB
                    mov dx, offset k_CMP
                    jmp pabaiga_isvesti_ketvirta_komanda    
       
        isvesti_ketvirta_komanda_SUB:
            mov dx, offset k_SUB 
                   
pabaiga_isvesti_ketvirta_komanda:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 4
    int 21h

RET

;----------------------------------------------------------
spausdinti_penkta: 
    
    call gautiW
    call isvesti_baita
    
    call get_byte   
    mov byte ptr[antrasbaitas], al
    call gautiMOD
    call gautiREG
    call gautiRM
    call isvesti_baita 
    
    call kiek_poslinkis
    call ar_tiesioginis_adresas
    call isvesti_tab
    call spausdinti_penkta_komanda
    
    
    cmp byte ptr[reg_dalis], 0b                
        je isvesti_beadreso
    cmp byte ptr[reg_dalis], 1b
        je isvesti_beadreso
    cmp byte ptr[reg_dalis], 110b
        je isvesti_beadreso
    
    call spausdinti_prefixa
    
    isvesti_beadreso:
        call isvesti_pagal_RM
            jmp pabaiga_spausdinti_penkta 
            
    isvesti_netiesiogini:
        cmp byte ptr[mod_dalis], 11b
            jne mod_nelygus11
                call isvesti_pagal_RM
                    jmp pabaiga_spausdinti_penkta
    
    mod_nelygus11:
        mov ax, poslinkis
        call isvesti_adresa         
      
pabaiga_spausdinti_penkta:    
    
RET    
        
;----------------------------------------
spausdinti_penkta_komanda:
        
        spausdinti_penkta_komanda_POP:
        cmp byte ptr[pirmasbaitas], 8Fh
            jne isvesti_penkta_komanda_INC_ir_DEC
                mov cx, 4
                mov dx, offset k_ADD
                    jmp pabaiga_spausdinti_penkta_komanda
                 
        isvesti_penkta_komanda_INC_ir_DEC:
            cmp byte ptr[reg_dalis], 0b
                mov cx, 4
                mov dx, offset k_INC
                    je pabaiga_spausdinti_penkta_komanda
            cmp byte ptr[reg_dalis], 1b 
                mov cx, 4
                mov dx, offset k_DEC
                    je pabaiga_spausdinti_penkta_komanda
                    
        isvesti_penkta_komanda_CAll:
            cmp byte ptr[reg_dalis], 010b                
                jne isvesti_penkta_komanda_JMP
            cmp byte ptr[reg_dalis], 011b                
                jne isvesti_penkta_komanda_JMP
                    mov cx, 5        
                    mov dx, offset k_CALL
                        jmp pabaiga_spausdinti_penkta_komanda    
       
        isvesti_penkta_komanda_JMP:
           cmp byte ptr[reg_dalis], 100b                
                jne isvest_penkta_komanda_PUSH
           cmp byte ptr[reg_dalis], 101b                
                jne isvest_penkta_komanda_PUSH         
                    mov cx, 5        
                    mov dx, offset k_CALL
                        jmp pabaiga_spausdinti_penkta_komanda 
                   
        isvest_penkta_komanda_PUSH:
            mov cx, 5        
            mov dx, offset k_CALL 

pabaiga_spausdinti_penkta_komanda:
    mov ah, 40h
    mov bx, rHandle
    int 21h

RET
  
;----------------------------------------------------------
spausdinti_sesta:
    
    call isvesti_baita
    and al, 00011000b
    shr al, 3
    
    call isvesti_tab
       
    mov cx, 5
    mov dx, offset k_PUSH 
    
    cmp byte ptr[pirmasbaitas], 06h
        je spausdinti_sesta_komanda
    cmp byte ptr[pirmasbaitas], 0Eh
        je spausdinti_sesta_komanda
    cmp byte ptr[pirmasbaitas], 16h
        je spausdinti_sesta_komanda
    cmp byte ptr[pirmasbaitas], 1Eh
        je spausdinti_sesta_komanda
            
    mov cx, 4
    mov dx, offset k_POP

spausdinti_sesta_komanda:
    mov ah, 40h
    mov bx, rHandle
    int 21h
    
      cmp al, 00b
        mov dx, offset t_ES
            je spausdinti_segmenta
      cmp al, 01b
        mov dx, offset t_CS
            je spausdinti_segmenta
      cmp al, 10b
        mov dx, offset t_SS
            je spausdinti_segmenta
      mov dx, offset t_DS

spausdinti_segmenta:
    mov ah, 40h
    mov cx, 2
    mov bx, rHandle
    int 21h          
RET

;----------------------------------------------------------
spausdinti_septinta:

    call gautiW
    call isvesti_baita 
    
    call get_byte
    mov byte ptr[antrasbaitas], al
    call gautiMOD
    call gautiREG
    call gautiRM
    call isvesti_baita 
    
    call kiek_poslinkis
    call ar_tiesioginis_adresas
    call isvesti_tab
    call spausdinti_septinta_komanda
    
    call spausdinti_prefixa 
    call isvesti_pagal_RM
RET
    
;-----------
spausdinti_septinta_komanda:
    cmp byte ptr[reg_dalis], 100b
        mov dx, offset k_MUL
            je pabaiga_spausdinti_septinta_komanda
        mov dx, offset k_DIV
        
pabaiga_spausdinti_septinta_komanda:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 4
    int 21h
RET

;----------------------------------------------------------
spausdinti_astunta: 

    call isvesti_baita 
    call get_byte
    mov byte ptr[antrasbaitas], al
    call isvesti_baita   
    call isvesti_tab
    call isvesti_jump_varda   
    
    call skaiciuoti_poslinki_jumpui
    call isvesti_adresa 
        
RET
;-----        
  isvesti_jump_varda:        
     gal_JO:
        cmp byte ptr[pirmasbaitas], 70h
            jne gal_JNO             
                mov cx, 3
                mov dx, offset k_JO 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JNO:
        cmp byte ptr[pirmasbaitas], 71h 
            jne gal_JNAE     
                mov cx, 4
                mov dx, offset k_JNO 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JNAE:
        cmp byte ptr[pirmasbaitas], 72h
            jne gal_JAE       
                mov cx, 5
                mov dx, offset k_JNAE
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JAE:
        cmp byte ptr[pirmasbaitas], 73h 
            jne gal_JE      
                mov cx, 4
                mov dx, offset k_JAE 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JE:
        cmp byte ptr[pirmasbaitas], 74h
            jne gal_JNE
                mov cx, 3
                mov dx, offset k_JE 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JNE:
        cmp byte ptr[pirmasbaitas], 75h
            jne gal_JBE        
                mov cx, 4
                mov dx, offset k_JNE 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JBE:
        cmp byte ptr[pirmasbaitas], 76h
            jne gal_JA         
                mov cx, 4
                mov dx, offset k_JBE 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JA:
        cmp byte ptr[pirmasbaitas], 77h 
            jne gal_JS
                mov cx, 3
                mov dx, offset k_JA 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JS:
        cmp byte ptr[pirmasbaitas], 78h 
            jne gal_JNS                     
                mov cx, 3
                mov dx, offset k_JS 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JNS:
        cmp byte ptr[pirmasbaitas], 79h 
            jne gal_JP       
                mov cx, 4
                mov dx, offset k_JNS
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JP:
        cmp byte ptr[pirmasbaitas], 7Ah 
            jne gal_JNP  
                mov cx, 3
                mov dx, offset k_JP 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JNP:
        cmp byte ptr[pirmasbaitas], 7Bh 
            jne gal_JL                    
                mov cx, 4
                mov dx, offset k_JNP 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JL:
        cmp byte ptr[pirmasbaitas], 7Ch 
            jne gal_JGE   
                mov cx, 3
                mov dx, offset k_JL 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JGE:
        cmp byte ptr[pirmasbaitas], 7Dh 
            jne gal_JLE
                mov cx, 4
                mov dx, offset k_JGE 
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JLE:
        cmp byte ptr[pirmasbaitas], 7Eh 
            jne gal_JG                    
                mov cx, 4
                mov dx, offset k_JG
            jmp pabaiga_isvesti_jump_varda  
     
     gal_JG:
         cmp byte ptr[pirmasbaitas], 7Fh 
            jne gal_LOOP                    
                mov cx, 3
                mov dx, offset k_JG 
            jmp pabaiga_isvesti_jump_varda 
            
     gal_LOOP:
        cmp byte ptr[pirmasbaitas], 0E2h 
            jne gal_JCXZ
                mov cx, 5
                mov dx, offset k_LOOP
            jmp pabaiga_isvesti_jump_varda  
     
     gal_JCXZ:
        cmp byte ptr[pirmasbaitas], 0E3h 
            jne gal_JMP
                mov cx, 5
                mov dx, offset k_JCXZ
            jmp pabaiga_isvesti_jump_varda 
     
     gal_JMP: ;vidinis artimas
        mov cx, 4
        mov dx, offset k_JMP
         
pabaiga_isvesti_jump_varda:
    mov ah, 40h  
    mov bx, rHandle
    int 21h
RET
  
;----------------------------------------------------------  
spausdinti_devinta:
    
    call isvesti_baita
    call get_byte
    mov byte ptr[bojb_baitas], al
    call isvesti_baita
    call get_byte
    mov byte ptr[bovb_baitas], al
    call isvesti_baita
    call isvesti_tab
    
    cmp byte ptr[pirmasbaitas], 0C2h
        mov cx, 4
        mov dx, offset k_RET
            je spausdinti_devinta_komanda
                mov cx, 5
                mov dx, offset k_RETF
        
spausdinti_devinta_komanda:
    mov ah, 40h
    mov bx, rHandle
    int 21h
    
    mov al, byte ptr[bovb_baitas]
    call isvesti_baita
    mov al, byte ptr[bojb_baitas]
    call isvesti_baita 
RET

;----------------------------------------------------------
spausdinti_desimta:
        
        call gautiW
        call isvesti_baita
        call get_byte
        mov byte ptr[bojb_baitas], al
        call isvesti_baita
   
        cmp byte ptr[w_dalis], 0b
            je w_dalis_nuliss
                        call get_byte
                        mov byte ptr[bovb_baitas], al
                        mov ax, word ptr[bovb_baitas]
                        call isvesti_baita
                        call isvesti_tab    
                        call spausdinti_desimta_komanda
                                
                        call ax_ar_al
                        call isvesti_kableli
                        mov ax, word ptr[bovb_baitas]
                        call isvesti_baita
                        mov ax, word ptr[bojb_baitas]
                        call isvesti_baita                        
            RET 
             
            w_dalis_nuliss:
            call isvesti_tab 
            call spausdinti_desimta_komanda    
            call ax_ar_al
            call isvesti_kableli
            mov ax, word ptr[bojb_baitas]
            call isvesti_baita 
RET

spausdinti_desimta_komanda:
    
    komanda_desimta_ADD:
    cmp byte ptr[pirmasbaitas], 05h
        jg komanda_desimta_SUB
            mov dx, offset k_ADD
                jmp baigti_spausdinti_desimta_komanda
                
    komanda_desimta_SUB:
    cmp byte ptr[pirmasbaitas], 2Dh
        jg komanda_desimta_CMP
            mov dx, offset k_SUB
                jmp baigti_spausdinti_desimta_komanda
                
    komanda_desimta_CMP:                             
    mov dx, offset k_CMP
    
baigti_spausdinti_desimta_komanda:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 4
    int 21h

RET  
  
;-------------------------------------------------------------- 
spausdinti_vienuolikta:
    
    call gautiW
    call isvesti_baita
    call get_byte
    mov byte ptr[bojb_baitas], al
    call isvesti_baita
    call get_byte
    mov byte ptr[bovb_baitas], al
    call isvesti_baita
    call isvesti_tab
        mov ah, 40h
        mov bx, rHandle
        mov cx, 4
        mov dx, offset k_MOV
        int 21h  
    
    cmp byte ptr[pirmasbaitas], 0A2h
        jb akumuliatorius_pirmas
       
            call spausdinti_prefixa
            call spausdinti_vienuolikta_atmintis
            call isvesti_kableli
            call ax_ar_al
     RET
     
    akumuliatorius_pirmas:
        call ax_ar_al
        call isvesti_kableli  
        
        cmp byte ptr[prefixo_nr], 0
            je nebuvo_vienuoliktass
                call spausdinti_prefixa
        nebuvo_vienuoliktass:
        
        call spausdinti_vienuolikta_atmintis
    RET    
    
    
spausdinti_vienuolikta_atmintis:
          call isvesti_kskliausta
          mov ax, word ptr[bovb_baitas]
          call isvesti_baita
          mov ax, word ptr[bojb_baitas]
          call isvesti_baita
          call isvesti_dskliausta
RET  
  
;---------------------------------------------------  
spausdinti_dvylikta:  

    call isvesti_baita
    call get_byte
    mov byte ptr[pirmasbaitas], al
    call isvesti_baita
    call get_byte
    mov byte ptr[antrasbaitas], al
    call isvesti_baita
    call get_byte
    mov byte ptr[treciasbaitas], al
    call isvesti_baita
    call get_byte
    mov byte ptr[ketvirtasbaitas], al
    call isvesti_tab
        
    call isvesti_dvylikta_komanda
    
    mov al, byte ptr[ketvirtasbaitas]
    call isvesti_baita
    mov al, byte ptr[treciasbaitas]
    call isvesti_baita
        
        mov ah, 40h
        mov bx, rHandle
        mov cx, 1
        mov dx, offset dvitaskis
        int 21h
        
    mov al, byte ptr[antrasbaitas]
    call isvesti_baita
    mov al, byte ptr[pirmasbaitas]
    call isvesti_baita
RET

;-------    
isvesti_dvylikta_komanda:
    
    cmp byte ptr[pirmasbaitas], 0EAh
        je dvylikta_komanda_CALL
            mov cx, 4
            mov dx, offset k_JMP
                jmp pabaiga_isvesti_dvylikta_komanda 
                    
    dvylikta_komanda_CALL:
        mov cx, 5
        mov dx, offset k_CALL
        
pabaiga_isvesti_dvylikta_komanda:
    mov ah, 40h
    mov bx, rHandle
    int 21h
RET

;---------------------------------------------------
spausdinti_trylikta:

    call isvesti_baita
    call get_byte
    mov byte ptr[bojb_baitas], al
    call isvesti_baita      
    
    call get_byte
    mov byte ptr[bovb_baitas], al
    call isvesti_baita 
    
    call isvesti_tab        
    call spausdinti_dvylikta_komanda     
    
    mov bx, adresas
    mov al, byte ptr[bojb_baitas]
    mov ah, byte ptr[bovb_baitas]
    add ax, bx
    call isvesti_adresa
RET    
    
spausdinti_dvylikta_komanda:       
    cmp byte ptr[pirmasbaitas], 0E8h
        jne komanda_dvylikta_JMP
            mov cx, 5
            mov dx, offset k_CALL
                jmp baigti_spausdinti_dvylikta_komanda

    komanda_dvylikta_JMP:                
        mov cx, 4
        mov dx, offset k_JMP
    
baigti_spausdinti_dvylikta_komanda:
        mov ah, 40h
        mov bx, rHandle
        int 21h 
RET

;---------------------------------------------------  
spausdinti_keturiolikta:
    
    call gautiD
    call gautiW
    call isvesti_baita 
    
    call get_byte
    mov byte ptr[antrasbaitas], al
    call gautiMOD
    call gautiREG
    call gautiRM 
    call isvesti_baita
    
    call kiek_poslinkis
    call ar_tiesioginis_adresas 
    call isvesti_tab
    
        mov ah, 40h
        mov bx, rHandle
        mov cx, 4
        mov dx, offset k_MOV
        int 21h 
        
  cmp byte ptr[d_dalis], 0
    je pirmiau_atmintis
        jmp pirmiau_segmentas

 pirmiau_segmentas_pries:
    call isvesti_kableli
 
 pirmiau_segmentas:          
      cmp byte ptr[reg_dalis], 000b
        mov dx, offset t_ES
            je spausdinti_segmentaa
      cmp byte ptr[reg_dalis], 001b
        mov dx, offset t_CS
            je spausdinti_segmentaa
      cmp byte ptr[reg_dalis], 010b
        mov dx, offset t_SS
            je spausdinti_segmentaa
      mov dx, offset t_DS 
    
    spausdinti_segmentaa:
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2
        int 21h 
        
          cmp byte ptr[d_dalis], 0
            je pabaiga_keturioliktas
        
   call isvesti_kableli

pirmiau_atmintis:   
   call spausdinti_prefixa   
   call isvesti_pagal_RM
   
   cmp byte ptr[d_dalis], 0 
      je pirmiau_segmentas_pries

pabaiga_keturioliktas:
RET

;--------------------------------------------------- 
spausdinti_penkiolikta:
        
        call gautiRM ; is dalies cia reg dalis
        and al, 00001000b
        shr al, 3
        mov byte ptr[w_dalis], al
                
        mov ax, word ptr[pirmasbaitas]
        call isvesti_baita
        
        call get_byte
        mov byte ptr[bojb_baitas], al
        call isvesti_baita        
    
        cmp byte ptr[w_dalis], 0b
            je w_dalis_nulis
                        call get_byte
                        mov byte ptr[bovb_baitas], al
                        call isvesti_baita
                        call isvesti_tab
                            mov ah, 40h
                            mov bx, rHandle
                            mov cx, 4
                            mov dx, offset k_MOV
                            int 21h
                        mov al, byte ptr[rm_dalis]
                        call spausdinti_rm_mod11
                        call isvesti_kableli
                        mov ax, word ptr[bovb_baitas]
                        call isvesti_baita
                        mov ax, word ptr[bojb_baitas]
                        call isvesti_baita                        
             ret
             
            w_dalis_nulis:
                call isvesti_tab 
                mov ah, 40h
                mov bx, rHandle
                mov cx, 4
                mov dx, offset k_MOV
                int 21h
            mov al, byte ptr[rm_dalis]
            call spausdinti_rm_mod11
            call isvesti_kableli
            mov ax, word ptr[bojb_baitas]
            call isvesti_baita 
RET

;---------------------------------------------------
spausdinti_sesiolikta:
    
    call gautiD
    call gautiW
    call isvesti_baita    
    
    call get_byte
    mov byte ptr[antrasbaitas], al
    call gautiMOD
    call gautiREG
    call gautiRM 
    call isvesti_baita    
    
    call kiek_poslinkis
    call ar_tiesioginis_adresas

    cmp byte ptr[w_dalis], 0h
        je imti_vienaa
            call get_byte
            mov byte ptr[bojb_baitas], al
            call isvesti_baita
        imti_vienaa:
            call get_byte
            mov byte ptr[bovb_baitas], al
            call isvesti_baita  
              
    call isvesti_tab       
    
        mov ah, 40h
        mov bx, rHandle
        mov cx, 4
        mov dx, offset k_MOV
        int 21h 
    
    call spausdinti_prefixa    

    cmp w_dalis, 0h
        je vienass

            call isvesti_pagal_RM
            call isvesti_kableli
            mov ah, byte ptr[bovb_baitas]
            mov al, byte ptr[bojb_baitas]
            call isvesti_adresa
        RET                             
                                                                       
        vienass:
            call isvesti_pagal_RM
            call isvesti_kableli
            mov al, byte ptr[bovb_baitas]
            call isvesti_baita 
RET                                  
                                          
;--------------------------------------------------------------------------------------------------------------------                  
;BAITU IR ZENKLU ISVEDIMO FUNKCIJOS
;--------------------------------------------------------------------------------------------------------------------                                   

isvesti_adresa:  
    push ax    
        and ah, 11110000b 
        mov cl, 4
        shr ah, cl
        mov al, ah 
        call vesti    
    pop ax
    push ax
        and ah, 00001111b
        mov al, ah
        call vesti    
    pop ax
     
isvesti_baita:
    push ax
        and al, 11110000b
        mov cl, 4
        shr al, cl
        call vesti  
    pop ax
        and al, 00001111b
        call vesti
    RET
           
vesti:
    cmp al, 9
        ja isvesti_hex_raidyte
        jna isvesti_hex_skaiciu
        
isvesti_hex_skaiciu:
    add al, 48
    mov isvesti, al
        mov ah, 40h  
        mov bx, rHandle
        mov cx, 1
        mov dx, offset isvesti 
        int 21h
    RET
    
isvesti_hex_raidyte: 
    sub al, 0Ah
    add al, 'A'
    mov isvesti, al
        mov ah, 40h  
        mov bx, rHandle
        mov cx, 1
        mov dx, offset isvesti 
        int 21h
RET   
  
  
isvesti_TAB:
    push ax
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2
        mov dx, offset tab
        int 21h
    pop ax 
RET

isvesti_kableli:
    push ax
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2
        mov dx, offset kablelis
        int 21h
    pop ax 
RET
    
isvesti_dskliausta:
    push ax
        mov ah, 40h
        mov bx, rHandle
        mov cx, 1
        mov dx, offset dskliaustas
        int 21h 
    pop ax
RET     
    
isvesti_kskliausta:
    push ax    
        mov ah, 40h
        mov bx, rHandle
        mov cx, 1
        mov dx, offset kskliaustas
        int 21h 
    pop ax
RET

isvesti_pliusa:
    push ax    
        mov ah, 40h
        mov bx, rHandle
        mov cx, 3
        mov dx, offset pliusas
        int 21h 
    pop ax
RET 

isvesti_dvitaski: 
    push ax
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2 ;dvitaskis su tab
        mov dx, offset dvitaskis
        int 21h
    pop ax
RET 

isvesti_enter:
    push ax     
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2
        mov dx, offset enteris
        int 21h
    pop ax
RET 

isvesti_neatpazinta:  
    push ax          
        mov ah, 40h  
        mov bx, rHandle
        mov cx, 11
        mov dx, offset neatpazintas 
        int 21h
    pop ax
RET

;--------------------------------------------------------------------------------------------------------------------                  
;TIKRINAME PAGAL TURIMUS PARAMETRUS, KOKS TAI REGISTRAS
;--------------------------------------------------------------------------------------------------------------------                                         
isvesti_pagal_RM:
    mov al, byte ptr[antrasbaitas]
    cmp byte ptr[mod_dalis], 11b
            je atminties_nera
                    call isvesti_kskliausta
                    
          atminties_nera:
            call isvesti_pagal_mod
            cmp byte ptr[mod_dalis], 11b
                je pries_pabaiga_isvesti_pagal_RM
            cmp byte ptr[mod_dalis], 0h
                je pries_pabaiga_isvesti_pagal_RM
                    call isvesti_pliusa
                    mov ax, poslinkis  
                    call isvesti_adresa
                    
          pries_pabaiga_isvesti_pagal_RM:
            cmp byte ptr[mod_dalis], 11b
                je pabaiga_isvesti_pagal_RM          
                    call isvesti_dskliausta

pabaiga_isvesti_pagal_RM:
RET 

;------------------------------------------------------------------------------------------------------  
isvesti_pagal_mod:
    cmp byte ptr[mod_dalis], 11b
        je mod_11
            call spausdinti_rm_modxx
            ret
    
   mod_11:
    call spausdinti_rm_mod11
RET  

;------------------------------------------------------------------------------------------------------
; MOD = 11, w=0/w=1, r/m  == 000 - 111 
spausdinti_rm_mod11:       
    
    cmp byte ptr[rm_dalis], 000b 
        je rm_mod11_000    
    cmp byte ptr[rm_dalis], 001b
        je rm_mod11_001 
    cmp byte ptr[rm_dalis], 010b
        je rm_mod11_010 
    cmp byte ptr[rm_dalis], 011b
        je rm_mod11_011 
    cmp byte ptr[rm_dalis], 100b
        je rm_mod11_100 
    cmp byte ptr[rm_dalis], 101b
        je rm_mod11_101 
    cmp byte ptr[rm_dalis], 110b
        je rm_mod11_110 
    cmp byte ptr[rm_dalis], 111b
        je rm_mod11_111 

                rm_mod11_000:
                mov dx, offset r_AX
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_AL
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_001:
                mov dx, offset r_CX
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_CL
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_010:
                mov dx, offset r_DX
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_DL
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_011:
                mov dx, offset r_BX
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_BL
                jmp baigti_spausdinti_rm_mod11
                ;----
                rm_mod11_100:
                mov dx, offset r_SP
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_AH
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_101:
                mov dx, offset r_BP
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_CH
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_110:
                mov dx, offset r_SI
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_DH
                jmp baigti_spausdinti_rm_mod11

                rm_mod11_111:
                mov dx, offset r_DI
                cmp byte ptr[w_dalis], 1
                je baigti_spausdinti_rm_mod11
                mov dx, offset r_BH
                jmp baigti_spausdinti_rm_mod11

    baigti_spausdinti_rm_mod11:    
    mov ah, 40h
    mov bx, rHandle
    mov cx, 2
    int 21h

RET

;------------------------------------------------------------------------------------------------------
; MOD = 00, 01, 10, r/m  = 000 - 111
spausdinti_rm_modxx:

    cmp byte ptr[rm_dalis], 000b 
        je rm_modxx_000    
    cmp byte ptr[rm_dalis], 001b
        je rm_modxx_001 
    cmp byte ptr[rm_dalis], 010b
        je rm_modxx_010 
    cmp byte ptr[rm_dalis], 011b
        je rm_modxx_011 
    cmp byte ptr[rm_dalis], 100b
        je rm_modxx_100 
    cmp byte ptr[rm_dalis], 101b
        je rm_modxx_101 
    cmp byte ptr[rm_dalis], 110b
        je rm_modxx_110        
    cmp byte ptr[rm_dalis], 111b
        je rm_modxx_111 
        
                rm_modxx_000:
                mov cx, 5
                mov dx, offset ea_rm000
                jmp rm_modxx_spausdinti

                rm_modxx_001:
                mov cx, 5
                mov dx, offset ea_rm001
                jmp rm_modxx_spausdinti

                rm_modxx_010:
                mov cx, 5
                mov dx, offset ea_rm010
                jmp rm_modxx_spausdinti

                rm_modxx_011:
                mov cx, 5
                mov dx, offset ea_rm011
                jmp rm_modxx_spausdinti
                ;----
                rm_modxx_100:
                mov cx, 2
                mov dx, offset ea_rm100
                jmp rm_modxx_spausdinti

                rm_modxx_101:
                mov cx, 2
                mov dx, offset ea_rm101
                jmp rm_modxx_spausdinti

                rm_modxx_110:
                cmp byte ptr[mod_dalis], 0
                jne rm_modxx_110_netiesioginis
                mov ax, poslinkis
                call isvesti_adresa
                ret
                            rm_modxx_110_netiesioginis:
                            mov cx, 2
                            mov dx, offset ea_rm110
                            jmp rm_modxx_spausdinti             

                rm_modxx_111:
                mov cx, 2
                mov dx, offset ea_rm111
                jmp rm_modxx_spausdinti

    rm_modxx_spausdinti:
    mov ah, 40h
    mov bx, rHandle
    int 21h

RET

;------------------------------------------------------------------------------------------------------ 
; REG, w = 0 arba w = 1
isvesti_pagal_REG:
    
    cmp byte ptr[reg_dalis], 000b 
        je reg_000    
    cmp byte ptr[reg_dalis], 001b
        je reg_001 
    cmp byte ptr[reg_dalis], 010b
        je reg_010 
    cmp byte ptr[reg_dalis], 011b
        je reg_011 
    cmp byte ptr[reg_dalis], 100b
        je reg_100 
    cmp byte ptr[reg_dalis], 101b
        je reg_101 
    cmp byte ptr[reg_dalis], 110b
        je reg_110 
    cmp byte ptr[reg_dalis], 111b
        je reg_111 

                reg_000:
                mov dx, offset r_AX
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_AL
                jmp isvesti_reg

                reg_001:
                mov dx, offset r_CX
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_CL
                jmp isvesti_reg

                reg_010:
                mov dx, offset r_DX
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_DL
                jmp isvesti_reg

                reg_011:
                mov dx, offset r_BX
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_BL
                jmp isvesti_reg
                ;----
                reg_100:
                mov dx, offset r_SP
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_AH
                jmp isvesti_reg

                reg_101:
                mov dx, offset r_BP
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_CH
                jmp isvesti_reg

                reg_110:
                mov dx, offset r_SI
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_DH
                jmp isvesti_reg

                reg_111:
                mov dx, offset r_DI
                cmp byte ptr[w_dalis], 1
                je isvesti_reg
                mov dx, offset r_BH
                jmp isvesti_reg

    isvesti_reg:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 2
    int 21h

RET 
    
;-----------------------------------------------------------------------    
;PACIOS IVAIRIAUSIOS FUNKCIJOS
;------------------------------------------------------------------------    
gautiD:
    push ax 
    and al, 00000010b
    shr al, 1
    mov byte ptr[d_dalis], al
    pop ax
RET
              
gautiW:
    push ax
    and al, 00000001b
    mov byte ptr[w_dalis], al
    pop ax
RET   

gautiMOD:
    push ax                       
    and al, 11000000b
    shr al, 6
    mov byte ptr[mod_dalis], al 
    pop ax
RET

gautiReg:
    push ax
    and al, 00111000b
    shr al, 3
    mov byte ptr[reg_dalis], al
    pop ax
RET


gautiRM:
    push ax
    and al, 00000111b
    mov byte ptr[rm_dalis], al
    pop ax
RET 

gautiSreg: ; xxxs rxxx
    push ax
    and al, 00011000b
    shr al, 3
    pop ax
RET 

;------------------------------------------------------------------------------------------------------
patikrinti_ar_prefixas:
    mov al, byte ptr[pirmasbaitas]
 
    cmp al, 26h
        je prefixas_ES
    cmp al, 2Eh
        je prefixas_CS
    cmp al, 36h
        je prefixas_SS
    cmp al, 3Eh
        je prefixas_DS  
    
    mov byte ptr[prefixo_nr], 0
        jmp pabaiga_patikrinti_ar_prefixas
 
    prefixas_ES:
    mov byte ptr[prefixo_nr], 1
        jmp pabaiga_patikrinti_ar_prefixas
    
    prefixas_CS:
    mov byte ptr[prefixo_nr], 2
        jmp pabaiga_patikrinti_ar_prefixas
    
    prefixas_SS:
    mov byte ptr[prefixo_nr], 3
        jmp pabaiga_patikrinti_ar_prefixas
    
    prefixas_DS:
    mov byte ptr[prefixo_nr], 4
        jmp pabaiga_patikrinti_ar_prefixas
    
    pabaiga_patikrinti_ar_prefixas:
RET   
     
     
spausdinti_prefixa: 
    cmp byte ptr[prefixo_nr], 0
        je spausdinti_prefixa_nereikia
    cmp byte ptr[prefixas], 26h
        je spausdinti_prefixa_ES
    cmp byte ptr[prefixas], 2Eh
        je spausdinti_prefixa_CS
    cmp byte ptr[prefixas], 36h
        je spausdinti_prefixa_SS
    cmp byte ptr[prefixas], 3Eh
        je spausdinti_prefixa_DS  
 
 spausdinti_prefixa_ES:
    mov dx, offset t_ES
        jmp pabaiga_spausdinti_prefixa
    
  spausdinti_prefixa_CS:
    mov dx, offset t_CS
        jmp pabaiga_spausdinti_prefixa
    
  spausdinti_prefixa_SS:
    mov dx, offset t_SS
        jmp pabaiga_spausdinti_prefixa
    
  spausdinti_prefixa_DS:
    mov dx, offset t_DS
        jmp pabaiga_spausdinti_prefixa
    
  pabaiga_spausdinti_prefixa:
    mov ah, 40h
    mov bx, rHandle
    mov cx, 3
    int 21h                 
    
spausdinti_prefixa_nereikia:
RET

;------------------------------------------------------------------------------------------------------
skaiciuoti_poslinki_jumpui:
    cmp byte ptr[antrasbaitas], 80h
        jae reikia_plesti
            mov ah, 00h
            mov al, byte ptr[antrasbaitas]
            add ax, adresas
            ret
    reikia_plesti:
    mov al, antrasbaitas
    mov ah, 0FFh
    add ax, adresas 
RET
 
;------------------------------------------------------------------------------------------------------  
ar_tiesioginis_adresas:
    push ax

    cmp byte ptr [mod_dalis], 0b
        jne netiesioginis

    gal_tiesioginis:
        cmp byte ptr[rm_dalis], 110b
            jne netiesioginis
                mov ah, byte ptr[ketvirtasbaitas]
                mov al, byte ptr[treciasbaitas]
                mov poslinkis, ax

netiesioginis:
    pop ax
RET 

;------------------------------------------------------------------------------------------------------ 
kiek_poslinkis:     
     cmp byte ptr[mod_dalis], 11b
        je pabaiga_kiek_poslinkis ;poslinkio nera 
        
     cmp byte ptr[mod_dalis], 00h
        jne gal_mod10
            cmp byte ptr[rm_dalis], 110b
                je poslinkis_2baitai
                    jmp pabaiga_kiek_poslinkis
                 
     gal_mod10:     
     cmp byte ptr[mod_dalis], 10b ;kokio ilgio baitas bus
        je poslinkis_2baitai
            call get_byte
            mov byte ptr[poslinkis], al
            mov byte ptr[treciasbaitas], al
            call isvesti_baita
                jmp pabaiga_kiek_poslinkis
               
            poslinkis_2baitai:
                call get_byte
                mov byte ptr[treciasbaitas], al
                call isvesti_baita
                call get_byte
                mov byte ptr[ketvirtasbaitas], al
                call isvesti_baita
                mov al, byte ptr [treciasbaitas]
                mov ah, byte ptr [ketvirtasbaitas]
                mov poslinkis, ax
                        
pabaiga_kiek_poslinkis:
RET 
 
;------------------------------------------------------------------------------------------------------ 
ax_ar_al:
    cmp byte ptr[w_dalis], 0
        je spausdinti_al
           mov dx, offset r_AX
           jmp baigti_ax_ar_al
           
     spausdinti_al:    
        mov dx, offset r_AL 
        
    baigti_ax_ar_al:
        mov ah, 40h
        mov bx, rHandle
        mov cx, 2
        int 21h
RET 
          
;*************************************************************************************
;PAGRINDINIO KODO PABAIGA
;PRASIDEDA IVAIRUS PRANESIMAI, DARBO SU FAILAIS FUNKCIJOS
;-------------------------------------------------------------------------------------    
baigti_programa:
    mov ah, 4ch
    int 21h
    
klaida:
    mov dx, offset klaida1
    mov ah, 09h
    int 21h
    jmp baigti_programa
        
pagalba:
    mov dx, offset help
    mov ah, 09h
    int 21h
    jmp baigti_programa    
  
parametruSkaitymas:   
kelione:      
    mov ax, es:[si] 
    inc si      
    cmp al, 0dh     
    je klaida
    cmp al, 20h
    je kelione     
    cmp ax, "?/"
    jne skaitom
    mov ax, es:[si]
    cmp ah, 0dh
    je pagalba
        
skaitom:  
    mov byte ptr[di], al 
    inc di
    mov ax, es:[si]
    inc si
    cmp al, 0
    je uzteks
    cmp al, 0dh
    je uzteks
    cmp al, 20h  
    jne skaitom
          
uzteks:
RET
        
SkaitomBuf: 
    mov ah, 3fh  
    mov dx, offset buferis
    mov cx, BufDydis
    int 21h 
    mov kiekis, ax      
    jc klaida 
RET
     
END pradzia   
