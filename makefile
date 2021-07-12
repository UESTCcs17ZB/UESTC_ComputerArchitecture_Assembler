all: asm
asm: assembler.l assembler.y
	lex -o lex_asm.c assembler.l
	yacc -d -o yacc_asm.c assembler.y
	g++ -o asm lex_asm.c yacc_asm.c
clean: 
	rm lex* yacc* asm