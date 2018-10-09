%{
#include <iostream>

%}

letter		[a-zA-Z]
number		[0-9]
digit		{number}+
identifier	{letter}({letter}|{digit}|[_](letter|digit)*

%%
"function"	{printf("FUNCTION \n");}
"beginparams"

%%

int main(int argc, char ** argv){
	



	return 0;

}
