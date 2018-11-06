all:
  bison -v -d --file-prefix=y mini_l.y
  flex mini_l.lex
	gcc -o parser ytab.c lex.yy.c -lfl
  
