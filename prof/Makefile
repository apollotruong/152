all:
	bison -v -d	--file-prefix=y	mini_l.y
	flex mini_l.lex
	g++	-o parser y.tab.c lex.yy.c  -std=c++11 -lfl

clean:
	\rm lex.yy.c y.tab.c y.tab.h y.output
