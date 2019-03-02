%{
#include "y.tab.h"
%}

%%
[=\+\-\*\/%()<>!,;]      { return yytext[0]; }
[a-zA-Z][a-zA-Z0-9]*     { yylval.vals=strdup(yytext); return VAR; }
\"[^"]*\"                { yylval.vals=strdup(yytext); return STR; }
-?[0-9]+                 { yylval.vali=atoi(yytext); return NUMI; }
-?[0-9]+\.[0-9]+         { yylval.valf=atof(yytext); return NUMF; }                
while|WHILE              { return(WHILE); }
if|IF                    { return(IF); }
else|ELSE                { return(ELSE); }
[ ]+AND[ ]+              { return(AND); }
[ ]+OR[ ]+               { return(OR); }
\<=                      { return(LE); }
\>=                      { return(GE); }
==                       { return(EQUALS); }
!=                       { return(NE); }
[ \t\n]                  { ; }
.                        { printf("Error: caracter %c not valid\n", yytext[0]); }
%%

int yywrap() {
   return(1);
}
