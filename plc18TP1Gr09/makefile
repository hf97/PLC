EXEC = prog
$(EXEC): $(EXEC).l 
	flex -o $(EXEC).c $(EXEC).l
	gcc -o $(EXEC) $(EXEC).c 
executa: $(EXEC)
	./$(EXEC) < texto.txt
	google-chrome prog.html


