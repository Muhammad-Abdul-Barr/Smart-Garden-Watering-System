.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"
.include "1602_LCD_Macros.inc"

.def A = r20
.def AH = r21
.equ Red_LED = PB5                ; Red LED is connected to Digital Pin 13
.def inpt = r22

.cseg
.org 0x0000
	
hello_string: .db "Moisture Sensor",0
len: .equ string_len = (2 * (len - hello_string)) - 1

hello_string2: .db "Section C CS-22",0
len2: .equ string_len2 = (2 * (len2 - hello_string2)) - 1

high_string : .db "     HIGH",0
len3: .equ string_len3 = (2 * (len3 - high_string)) - 1

low_string : .db "     LOW ",0
len4: .equ string_len4 = (2 * (len4 - low_string)) - 1

    Serial_Begin

    ; Setting Up LCD
    LCD_init
    LCD_backlight_OFF
    delay 500
    LCD_backlight_ON

    ; Prints Welcome Note on Screen
        LDI ZL, LOW (2 * hello_string)
        LDI ZH, HIGH (2 * hello_string)
        LDI R20, string_len
        LCD_send_a_string
        LCD_send_a_command 0xC0
        LDI ZL, LOW (2 * hello_string2)
        LDI ZH, HIGH (2 * hello_string2)
        LDI R20, string_len2
        LCD_send_a_string
        delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
       

    ; ADC Configuration
        LDI A, 0b11000111 ; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
        STS ADCSRA, A
        LDI A, 0b01100000 ; [REFS1 REFS0 ADLAR � MUX3 MUX2 MUX1 MUX0]
        STS ADMUX, A ; Select ADC0 (PC0) pin
        SBI PORTC, PC0 ; Enable Pull-up Resistor

    mainloop:
			
			LCD_send_a_command 0x01
		    LCD_send_a_character 0x4D ; 'M'
		    LCD_send_a_character 0x4F ; 'O'
		    LCD_send_a_character 0x49 ; 'I'
		    LCD_send_a_character 0x53 ; 'S'
		    LCD_send_a_character 0x54 ; 'T'
		    LCD_send_a_character 0x55 ; 'U'
		    LCD_send_a_character 0x52 ; 'R'
		    LCD_send_a_character 0x45 ; 'E'
		    LCD_send_a_character 0x20 ; ' '
		    LCD_send_a_character 0x4C ; 'L'
		    LCD_send_a_character 0x45 ; 'E'
		    LCD_send_a_character 0x56 ; 'V'
		    LCD_send_a_character 0x45 ; 'E'
		    LCD_send_a_character 0x4C ; 'L'
			LCD_send_a_command 0xC0 ; move cursor to the next line

		    ; Reads and Convert Reading From Sensor
		    LDS A, ADCSRA ; Start Analog to Digital Conversion
		    ORI A, (1 << ADSC)
		    STS ADCSRA, A
		
		wait_conversion:
		    LDS A, ADCSRA ; wait for conversion to complete
		    sbrc A, ADSC
		    rjmp wait_conversion
		
		    LDS A, ADCL ; Must Read ADCL before ADCH
		    LDS AH, ADCH
		    delay 100 ; delay 100ms

		    ; Read soil moisture sensor

		    ;Reads if Input From MQTT
			Serial_read r16
			CPI r16, 0x41 ; 'F'
			BREQ TURN_OFF_LED
			CPI r16, 0x42 ; 'O'
			BREQ TURN_ON_LED

		    CPI AH, 2 ; Compare the high byte with 2 (500 / 256)
		    BRGE TURN_ON_LED ; If the value is greater than or equal to 500, turn on the LED
		    RJMP TURN_OFF_LED ;
		
		TURN_OFF_LED:
			Serial_writeChar 'L'
		    SBI PORTB, Red_LED
			LDI ZL, LOW (2 * low_string)
			LDI ZH, HIGH (2 * low_string)
			LDI R20, string_len4
			delay 250
			delay 250
		    jmp continue
		TURN_ON_LED:
		    Serial_writeChar 'H'	
		    CBI PORTB, Red_LED
			LDI ZL, LOW (2 * high_string)
			LDI ZH, HIGH (2 * high_string)
			LDI R20, string_len3
			delay 250
			delay 250
		    jmp continue

		continue:
			LCD_send_a_string
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250
		delay 250

		    jmp mainloop
		


