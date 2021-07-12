%{
#include"yacc_asm.h"
#include<stdlib.h>
#include<stdio.h>
extern "C" {
    int yylex();
};
%}
%option yylineno
binary_digit [0-1]
decimal_digit [0-9]
hex_digit [0-9a-fA-F]

binary_lit ("0b"|"0B"){binary_digit}+
decimal_lit {decimal_digit}+
hex_lit ("0x"|"0X"){hex_digit}+

%%
("-")?({binary_lit}|{decimal_lit}|{hex_lit}) {
	yylval.str = strdup(yytext);
	return immediate;
}
("r"|"R"){decimal_lit} { 
	yylval.str = strdup(yytext);
	return register_num;
}

"add"|"ADD" { 
	return literal_add; 
}
"and"|"AND" {
	return literal_and;
}
"or"|"OR" {
	return literal_or;
}
"xor"|"XOR" {
	return literal_xor;
}
"srl"|"SRL" {
	return literal_srl;
}
"sll"|"SLL" {
	return literal_sll;
}
"addi"|"ADDI" {
	return literal_addi;
}
"andi"|"ANDI" {
	return literal_andi;
}
"ori"|"ORI" {
	return literal_ori;
}
"xori"|"XORI" {
	return literal_xori;
}
"load"|"LOAD" {
	return literal_load;
}
"store"|"STORE" {
	return literal_store;
}
"beq"|"BEQ" {
	return literal_beq;
}
"bne"|"BNE" {
	return literal_bne;
}
"jump"|"JUMP" {
	return literal_jump;
}
"nop"|"NOP" {
	return literal_nop;
}
","|"("|")" {return *yytext;}
[ \t\r\n";"] { }
"//" {  //单行注释
    char c;
    while((c=yyinput()) != '\n' && c != EOF);
    unput(c);
}
"/*" {  /*多行注释*/
    char c;
    bool need_star = true;
    while(true) {
        c = yyinput();
        if(c == EOF) {
            unput(c);
            break;
        }
        if(need_star) {
            if(c == '*') {
                need_star = false;  //进入等待'/'状态，之后再读入一个'/'可完成匹配
            }
        } else {
            if(c == '/') {
                break;
            } else if(c != '*') {  //若读入的不是星号，则回到需要星号的状态，否则留在这个状态
                need_star = true;
            }
        }
    }
}
. {
    printf("Lexical error: line %d: %s\n", yylineno,yytext);
	exit(0);
}
%%
int yywrap()
{
	return 1;
}
