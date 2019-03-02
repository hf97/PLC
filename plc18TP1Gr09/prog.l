%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
FILE* f;
%}

%x cmd

%%
\{it\} {fprintf(f,"<i>"); }
\{fimit\} {fprintf(f,"</i>"); }
\{neg\} {fprintf(f,"<b>"); }
\{fimneg\} {fprintf(f,"</b>"); }
\{un\} {fprintf(f,"<u>"); }
\{fimun\} {fprintf(f,"</u>"); }
\{h1\} {fprintf(f,"<h1>"); }
\{fimh1\} {fprintf(f,"</h1>"); }
\{h2\} {fprintf(f,"<h2>"); }
\{fimh2\} {fprintf(f,"</h2>"); }
\{h3\} {fprintf(f,"<h3>"); }
\{fimh3\} {fprintf(f,"</h3>"); }
\{h4\} {fprintf(f,"<h4>"); }
\{fimh4\} {fprintf(f,"</h4>"); }
\{h5\} {fprintf(f,"<h5>"); }
\{fimh5\} {fprintf(f,"</h5>"); }
\{h6\} {fprintf(f,"<h6>"); }
\{fimh6\} {fprintf(f,"</h6>"); }
\{ol\} {fprintf(f,"<ol>"); }
\{fimol\} {fprintf(f,"</ol>"); }
\{ul\} {fprintf(f,"<ul>"); }
\{fimul\} {fprintf(f,"</ul>"); }
\{li\} {fprintf(f,"<li>"); }
\{fimli\} {fprintf(f,"</li>"); }
\{href\} {fprintf(f,"<img src="); }
\{fimhref\} {fprintf(f," height=150>"); }
(.|\n) {fprintf(f,"%s",yytext); }

%%

void printheader(){
	fprintf(f,"<!DOCTYPE html>\n");
	fprintf(f,"<html lang=%cpt%c>\n",34,34);
	fprintf(f,"<head>\n");
	fprintf(f,"<meta charset=%cutf-8%c>\n",34,34);
	fprintf(f,"</head>\n");
	fprintf(f,"<body>\n");
}



int yywrap(){
	return (1);
}

int main(){
	f=fopen("prog.html","w");
	printheader();
	yylex();
	fprintf(f,"</body>\n");
	fprintf(f,"</html>\n");
	fclose(f);
	return 0;
}