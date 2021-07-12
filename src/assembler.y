%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<vector>
#include<string>
#include<fstream>
using namespace std;
extern FILE *yyin;
extern int yylineno;
extern "C" {
	void yyerror(const char *);
	int yylex();
}
vector<string> output_binary;
vector<string> output_hex;
// 将int转化为码长len的二进制表示
string toBinary(int num, int len, bool is_signed = false) {
	if(is_signed) {
		if(num >= pow(2,len-1) || num < -pow(2,len-1)){
			printf("line %d: number %d overflowed\n", yylineno, num);
			exit(1);
		}
	} else {
		if(num >= pow(2,len)) {
			printf("line %d: number %d overflowed\n", yylineno, num);
			exit(1);
		}
	}
	string code;
	for(int i = 1<<(len-1); i!=0; i>>=1){
		if(num&i){
			code += '1';
		}else{
			code += '0';
		}
	}
	return code;
}
int immToInt(const char *immediate) {
	int isPositive=1;
	if(immediate[0]=='-'){
		isPositive=-1;
		immediate+=1;
	}
	int len = strlen(immediate);
	if(len > 2) {
		if(immediate[1]=='x'||immediate[1]=='X'){
			return isPositive*stoi(immediate+2,0,16);
		}
		if(immediate[1]=='b'||immediate[1]=='B'){
			return isPositive*stoi(immediate+2,0,2);
		}
	}
	return isPositive*stoi(immediate);
}
%}
%error-verbose
%union {
	char *str;
}
%token <str> immediate
%token <str> register_num
%token literal_add
%token literal_and
%token literal_or
%token literal_xor
%token literal_srl
%token literal_sll
%token literal_addi
%token literal_andi
%token literal_ori
%token literal_xori
%token literal_load
%token literal_store
%token literal_beq
%token literal_bne
%token literal_jump
%token literal_nop
%type Statement
%type Statements
%type Add_stmt
%type And_stmt
%type Or_stmt
%type Xor_stmt
%type Srl_stmt
%type Sll_stmt
%type Addi_stmt
%type Andi_stmt
%type Ori_stmt
%type Xori_stmt
%type Load_stmt
%type Store_stmt
%type Beq_stmt
%type Bne_stmt
%type Jump_stmt
%type Nop_stmt

%%
start:
	Statements {
	}
;
Statements:
	Statement { }
	| Statements Statement { }
;
Statement: 
	Add_stmt { }
	| And_stmt { }
	| Or_stmt { }
	| Xor_stmt { }
	| Srl_stmt { }
	| Sll_stmt { }
	| Addi_stmt { }
	| Andi_stmt { }
	| Ori_stmt { }
	| Xori_stmt { }
	| Load_stmt { }
	| Store_stmt { }
	| Beq_stmt { }
	| Bne_stmt { }
	| Jump_stmt { }
	| Nop_stmt { }
;
Add_stmt:
	literal_add register_num ',' register_num ',' register_num { 
		// add rd, rs, rt; rd=rs+rt
		string instruction = "000000";	// opcode
		instruction += "000001"; // function
		instruction += "00000";
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($6+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
And_stmt:
	literal_and register_num ',' register_num ',' register_num { 
		// and rd, rs, rt; rd=rs&rt
		string instruction = "000001";	// opcode
		instruction += "000001"; // function
		instruction += "00000";
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($6+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Or_stmt:
	literal_or register_num ',' register_num ',' register_num { 
		// or rd, rs, rt; rd=rs|rt
		string instruction = "000001";	// opcode
		instruction += "000010"; // function
		instruction += "00000";
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($6+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Xor_stmt:
	literal_xor register_num ',' register_num ',' register_num { 
		// xor rd, rs, rt; rd=rs^|rt
		string instruction = "000001";	// opcode
		instruction += "000100"; // function
		instruction += "00000";
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($6+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Srl_stmt:
	literal_srl register_num ',' register_num ',' immediate { 
		// srl rd, rt, shift; rd=rt>>shift
		if($6[0]=='-') {
			printf("line %d: 你搁这卡bug呢?\n",yylineno);
			exit(1);
		}
		string instruction = "000010";	// opcode
		instruction += "000010"; // function
		instruction += toBinary(immToInt($6), 5); // shift amount
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += "00000";
		instruction += toBinary(stoi($4+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Sll_stmt:
	literal_sll register_num ',' register_num ',' immediate { // sll rd, rt, shift; rd=rt<<shift
		if($6[0]=='-') {
			printf("line %d: 你搁这卡bug呢?\n",yylineno);
			exit(1);
		}
		string instruction = "000010";	// opcode
		instruction += "000011"; // function
		instruction += toBinary(immToInt($6), 5); // shift amount
		instruction += toBinary(stoi($2+1), 5); // rd
		instruction += "00000";
		instruction += toBinary(stoi($4+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Addi_stmt:
	literal_addi register_num ',' register_num ',' immediate { 
		// addi rt, rs, imm; rt=rs+SignExt(imm)
		string instruction = "000101"; // opcode
		instruction += toBinary(immToInt($6), 16, true); // immediate
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Andi_stmt:
	literal_andi register_num ',' register_num ',' immediate {
		// andi rt, rs, imm; rt=rs&ZeroExt(imm)
		if($6[0]=='-') {
			printf("line %d: Syntax error, only positive numbers are allowed in andi statement\n", yylineno);
			exit(1);
		}
		string instruction = "001001"; // opcode
		instruction += toBinary(immToInt($6), 16); // immediate
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Ori_stmt:
	literal_ori register_num ',' register_num ',' immediate {
		// ori rt, rs, imm; rt=rs|ZeroExt(imm)
		if($6[0]=='-') {
			printf("line %d: Syntax error, only positive numbers are allowed in ori statement\n", yylineno);
			exit(1);
		}
		string instruction = "001010"; // opcode
		instruction += toBinary(immToInt($6), 16); // immediate
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Xori_stmt:
	literal_xori register_num ',' register_num ',' immediate {
		// xori rt, rs, imm; rt=rs^|ZeroExt(imm)
		if($6[0]=='-') {
			printf("line %d: Syntax error, only positive numbers are allowed in xori statement\n", yylineno);
			exit(1);
		}
		string instruction = "001100"; // opcode
		instruction += toBinary(immToInt($6), 16); // immediate
		instruction += toBinary(stoi($4+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Load_stmt:
	literal_load register_num ',' immediate '(' register_num ')' {
		// load rt, offset(rs); rt = Mem[rs+SignedExt(offset)]
		string instruction = "001101"; // opcode
		instruction += toBinary(immToInt($4), 16, true); // offset
		instruction += toBinary(stoi($6+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Store_stmt:
	literal_store register_num ',' immediate '(' register_num ')' {
		// store rt, offset(rs); Mem[rs+SignedExt(offset)] = rt
		string instruction = "001110"; // opcode
		instruction += toBinary(immToInt($4), 16, true); // offset
		instruction += toBinary(stoi($6+1), 5); // rs
		instruction += toBinary(stoi($2+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Beq_stmt:
	literal_beq register_num ',' register_num ',' immediate {
		// beq rs, rt, offset; if(rs==rt) PC = PC + 4 + SignedExt(offset)<<2
		string instruction = "001111"; // opcode
		instruction += toBinary(immToInt($6), 16, true); // offset
		instruction += toBinary(stoi($2+1), 5); // rs
		instruction += toBinary(stoi($4+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Bne_stmt:
	literal_bne register_num ',' register_num ',' immediate {
		// bne rs, rt, offset; if(rs!=rt) PC = PC + 4 + SignedExt(offset)<<2
		string instruction = "010000"; // opcode
		instruction += toBinary(immToInt($6), 16, true); // offset
		instruction += toBinary(stoi($2+1), 5); // rs
		instruction += toBinary(stoi($4+1), 5); // rt
		free($2);
		free($4);
		free($6);
		output_binary.push_back(instruction);
	}
;
Jump_stmt:
	literal_jump immediate {
		// jump address; PC = (PC+4)[32:28] + address[26:0] + 00
		if($2[0]=='-') {
			printf("line %d: Syntax error, only positive numbers are allowed in jump statement\n", yylineno);
			exit(1);
		}
		string instruction = "010010"; // opcode
		instruction += toBinary(immToInt($2), 26); // address
		free($2);
		output_binary.push_back(instruction);
	}
;
Nop_stmt:
	literal_nop {
		output_binary.push_back(string(32,'0'));
	}
;
%%
void yyerror(const char *s) {
	printf("line %d: %s\n", yylineno, s);
	exit(1);
}
int main(int argc, const char *argv[]) {
	if(argc != 2) {
		printf("usage: %s filename\n", argv[0]);
		exit(1);
	}			
	if((yyin = fopen(argv[1], "r")) == NULL ) {
		printf("open file %s failed\n", argv[1]);
		exit(1);
	}
	yyparse();
	fclose(yyin);
	char buffer[9];
	buffer[8] = '\0';
	for(auto &v:output_binary) {
		int i = stoi(v, 0, 2);
		sprintf(buffer, "%08x", i);
		output_hex.push_back(buffer);
	}
	ofstream ofs(string("hex_")+argv[1]);
	for(auto &v:output_hex) {
		ofs << v << endl;
	}
	return 0;
}
