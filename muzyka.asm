_code segment
assume  cs:_code, ds:_data, ss:_stack

start:	mov	ax,_data
	mov	ds,ax
	mov	ax,_stack
	mov	ss,ax
	mov	sp,offset top
        
; Format pliku: częstotliwosc czas
; jedna linia - jedna nuta
; pauza - częstotliwość równa 0
; czas - 16 to ok 1s


    lea dx, nazwaPliku   
    mov ah, 3dh         ; otwarcie pliku
    mov al, 0           ; tryb odczytu
    int 21h
    jnc otwarto
    jmp blad_otwierania
otwarto:
    mov uchwytPliku, ax 

czytajNute:
    call czytajZnak         ; odczytaj znak
    mov al, char
    cmp al, ' '             ; sprawdź, czy spacja (koniec odczytywania częstotliwości)
    je czytajCzas
    sub al, '0'
    mov ax, czestotliwosc
    mul mnoz_10
    add ax, cx
    mov czestotliwosc, ax
    jmp czytajNute

czytajCzas:
    call czytajZnak         ; odczytaj znak
    mov al, char
    cmp al, 0dh             ; sprawdź, czy koniec linii (CR - dla systemów Windows)
    je czytajCzas
    cmp al, 0ah             ; sprawdź, czy koniec linii (LF)
    je grajNute
    sub al, '0'
    mov ax, czas
    mul mnoz_10
    add ax, cx
    mov czas, ax
    jmp czytajCzas


czytajZnak:
    mov ah, 3Fh
    mov cx, 1           ; liczba bajtów do odczytu
    mov bx, uchwytPliku
    lea dx, char        ; zapisujemy odczytany znak do char
    int 21h
    cmp ax, 0           ; sprawdzenie, czy koniec pliku
    je koniec
    ret

grajNute:
    cmp czestotliwosc, 1
    jng pauza
    mov al, 182         
    out 43h, al
    mov ax, osc2
    mov dx, osc1
    div czestotliwosc   ; AX = DX:AX / czestotliwosc   
    out 42h, al         ; niższy bajt częstotliwości
    mov al, ah          ; wyższy bajt częstotliwości
    out 42h, al               
    in  al, 61h         ; odczyt stanu głośnika
    or  al, 00000011b   ; podłączenie głośnika do timera 2
    out 61h, al         ; włączamy głosńik
pauza:
    mov	cx, czas		; długość nuty (16 - około 1s)	
	mov	ah, 86h	    ; czekaj przez określony w cx czas
	int	15h	
    in 	al, 61h
	and	al, 11111100b	; wyłączenie głośnika
	out	61h, al
    mov czestotliwosc, 0
    mov czas, 0
    jmp czytajNute

brak_pliku:
    mov ah, 09h         
    lea dx, tekst_brak_pliku
    int 21h
    jmp koniec

blad_otwierania:
    mov ah, 09h
    lea dx, tekst_blad_otwierania
    int 21h
    jmp koniec

koniec:	
	mov	ah,4ch
	mov	al,0
	int	21h
_code ends

_data segment
	tekst_brak_pliku db "Nie podano nazwy pliku!$"
    tekst_blad_otwierania db "Blad otwierania pliku!$"
    tekst_blad_odczytu db "Blad odczytu z pliku!$"
    nazwaPliku db "przyklad.txt"
    uchwytPliku dw ?
    char db ?
    czestotliwosc dw 0
    czas dw 0
    mnoz_10 dw 10
    osc1 dw 18      ; starsza część częstotliwości oscylatora
    osc2 dw 13532   ; młodsza część częstotliwości oscylatora
_data ends

_stack segment stack
	dw	100h dup(0)
top	Label word
_stack ends

end start