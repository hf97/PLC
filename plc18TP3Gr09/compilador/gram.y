%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX 1024

   int yylex();
   int yyerror();
   int top = 0, topl = 0, i = 0;
   int nif[128] = {0}, apif = 0, nwhile[128] = {0}, apwhile = 0;
   int nf = 0, nelemf = 0, infunc = 0;
   FILE* out;
   char* typeFloat = "float";
   char* typeInt = "int";
   char* typeString = "string";

   typedef struct variable{
      char* type;
      char* desig;
      int posStack;
   } *Variable;

   typedef struct expression{
      char* type;
   } *Expression;

   typedef struct func{
      char* desig;
      char* types[128];
      int nt;
   } *Func;

   Variable v[MAX] = {0}, aux = NULL, vl[MAX] = {0};
   Func funcs[128] = {0}, funcx = NULL;
   int qt = 0, qtl = 0;
   char* types[128] = {0};

   int remVarDes (char* desig, Variable v[], int N){
      if(N==0) return -1;
      int a,b=0;
      for(a=0;a<MAX && b<N; a++){
         if(v[a]!=NULL) b++;
         if(strcmp(v[a]->desig, desig)==0){
            v[a]=NULL;
            return N--;
         }
      }
      return -1;
   }

   int insertVar (Variable var, Variable v[], int N){
      N=remVarDes(var->desig,v,N);
      if(N>=MAX) return -1;

      int c;
      for(c=0;c<MAX;c++){
         if(v[c]==NULL) break;
      }
      v[c]=var;
      return N++;
   }

   int remVar (Variable var, Variable v[], int N){
      if(N==0) return -1;
      int d, e=0;
      for(d=0;d<MAX && e<N;d++){
         if(v[d]!=NULL) e++;
         if(v[d]->posStack == var->posStack){
          v[d] = NULL;
          return N--;
         }
      }
      return -1;
   }

   Variable createVar (char* type, char* desig, int posStack){
      Variable var = (Variable)malloc(sizeof(struct variable));
      var->type = type;
      var->desig = desig;
      var->posStack = posStack;
      return var;
   }

   int isapont (char* t){
	    int i;
	    for (i=0; t[i]!='\0'; i++);
	    return t[i-1]=='*';
    }

    Variable searchDesig(char* desig, Variable v[], int N){
        int i , q = 0;
        for(i=0; q<N && i<MAX; i++){
            if(v[i]!=NULL) q++;
            if(strcmp(v[i]->desig,desig)==0){
                return v[i];
            }
        }
        return NULL;  
    }

   void push(Variable v){
      if(strcmp(v->type,"int")==0){
         fprintf(out,"pushi 0\n");
      }else if (strcmp(v->type,"float")==0){
         fprintf(out,"pushf 0.0\n");
      }else if (strcmp(v->type,"string")==0){
         fprintf(out,"pushs \"\"\n");
      }else {
         printf("ERROR: type doesnt exist");
      }
   }

   void pushtype(char* type){
      if(strcmp(type,"int")==0){
         fprintf(out,"pushi 0\n");  
      }else if (strcmp(type,"string")==0){
         fprintf(out,"pushs \"\"\n");
      }else if (strcmp(type,"float")==0){
         fprintf(out,"pushf 0.0\n");
      }else {
         printf("ERRO: type doesnt exist");   
      }

    }

   void store(Variable v){
      fprintf(out,"storeg %d\n",v->posStack);
   }

   void storel(Variable v){
        fprintf(out,"storel %d\n",v->posStack);
    }

   void insertfunc(Func func, Func funcs[], int nf){
        funcs[nf] = func;
    }
    
    Func createfunc(char* desig, char* types[], int nt){
        Func func = (Func)malloc(sizeof(struct func));
        func->desig = desig;
        int i;
        for(i=0;i<nt;i++){
            func->types[i] = types[i];
        }
        func->nt = nt;
        return func;
    }

    Func updatefunc(Func func, char* types[], int nt){
        int i;
        for (i=func->nt;i<func->nt+nt;i++){
            func->types[i] = types[i-func->nt];
        }
        func->nt += nt;
        return func;
    }

    Func searchfunc(char* desig, Func funcs[], int nf ){
        int i;
        for(i=0;i<nf;i++){
            if(strcmp(funcs[i]->desig,desig)==0){
                return funcs[i];
            }
        }
        return NULL;
    }

   void clear(Variable vl[], int qtl){
        Variable aux = NULL;
        int i = 0;
        while(i<qtl){
            if(vl[i]){
                aux = vl[i];
                vl[i] = NULL;
                free(aux);
                i++;
            }
        }
    }

%}

%union { char *vals; int vali; float valf; }

%token LE GE EQUALS NE OR AND IF ELSE WHILE STR VAR NUMI NUMF TYPE

%type <vals>STR VAR TYPE
%type <vali>NUMI
%type <valf>NUMF

%type<vals> Func Atrib
%type<vali> Cond
%type<vals> Expr Exp


%%

Prog    : Prog If                               { printf("if\n"); }
        | Prog While                            { printf("while\n"); }
        | Prog Atrib ';'                        { printf("initialize var\n"); }
        | Prog VAR '=' Expr ';'                 { printf("update var\n"); store(searchDesig($2,v,qt)); }
        | Prog Func ';'                         { printf("call func\n"); }
        |                                       { printf("beggining\n"); } 
        ;

Func  : VAR Expr                                { if(strcmp($1,"leri")==0){
                                                    fprintf(out,"read\natoi\n");
                                                    $$ = "int";
                                                  }else if(strcmp($1,"lerf")==0){
                                                    fprintf(out,"read\natof\n");
                                                    $$ = "float";
                                                  }else if(strcmp($1,"lers")==0){
                                                    fprintf(out,"read\n");
                                                    $$ = "string";
                                                  }else if(strcmp($1,"escreveri")==0){
                                                    fprintf(out,"writei\n");
                                                    $$ = "int";
                                                  }else if(strcmp($1,"escrevers")==0){
                                                    fprintf(out,"writes\n");
                                                    $$ = "string";
                                                  }else if(strcmp($1,"escreverf")==0){
                                                    fprintf(out,"writef\n");
                                                    $$ = "float";
                                                  }else if(strcmp($1,"atoi")==0){
                                                    fprintf(out,"atoi\n");
                                                    $$ = "int";
                                                  }else if(strcmp($1,"atof")==0){
                                                    fprintf(out,"atof\n");
                                                    $$ = "float";
                                                  }else if(strcmp($1,"ftoi")==0){
                                                    fprintf(out,"ftoi\n");
                                                    $$ = "int";
                                                  }else if(strcmp($1,"itof")==0){
                                                    fprintf(out,"itof\n");
                                                    $$ = "float";
                                                  }else if(strcmp($1,"stri")==0){
                                                    fprintf(out,"stri\n");
                                                    $$ = "string";
                                                  }else if(strcmp($1,"strf")==0){
                                                    fprintf(out,"strf\n");
                                                    $$ = "string";
                                                  }else{
                                                    funcx = searchfunc($1,funcs,nf);
                                                    if(!funcx){
                                                        printf("ERROR: function not found\n");
                                                    }else{
                                                        $$ = funcx->types[0];
                                                        pushtype(funcx->types[0]);
                                                        for(i=0;i<nelemf;i++){
                                                            fprintf(out,"pushl %d\n",top+nelemf-i-1);
                                                        }
                                                        fprintf(out,"pusha %s\ncall\nnop\npop %d\n",$1,nelemf);
                                                        for(i=0;i<nelemf;i++){
                                                           fprintf(out,"swap\npop 1\n");
                                                        }
                                                    }
                                                  }
                                                }
        ;


Atrib   : TYPE VAR                              { if(infunc){
                                                    aux = createVar($1,$2,topl++);
                                                    insertVar(aux, vl, qtl++);
                                                    push(aux); push(aux); storel(aux);
                                                  }
                                                  else{
                                                    aux = createVar($1,$2,top++);
                                                    insertVar(aux, v, qt++); 
                                                    push(aux); push(aux); store(aux);
                                                  } 
                                                } 
        
        | Equal                                 { ; }       
        ;

Equal   : TYPE VAR '='                          { if(infunc){
                                                    aux = createVar($1,$2,topl++);
                                                    insertVar(aux, vl, qtl++);
                                                    push(aux);
                                                  }
                                                  else{
                                                    aux = createVar($1,$2,top++); 
                                                    insertVar(aux, v, qt++);
                                                    push(aux);
                                                  }
                                                }
        | Equal Expr                            { if(infunc){
                                                    storel(aux);
                                                  }
                                                  else{
                                                    store(aux);
                                                  } 
                                                }
        ;


If      : IF Cond                               { fprintf(out, "jz endif%d\n",nif[apif]); apif++; nif[apif] = nif[apif-1]+1; }
        | IF '{' Prog '}' ELSE                  { apif--; fprintf(out, "jump endif%d\nendif%d:\n",nif[apif+1],nif[apif]);
                                                  nif[apif] = nif[apif+1]; apif++; nif[apif] = nif[apif-1]+1; 
                                                }
        | IF '{' Prog '}'                       { apif--; fprintf(out, "endif%d:\n",nif[apif]); nif[apif] = nif[apif+1]; }
        ;

While   : WHILE                                   { fprintf(out,"while%d:\n",nwhile[apwhile]); }
        | WHILE Cond                              { fprintf(out,"jz endwhile%d\n",nwhile[apwhile]); apwhile++; nwhile[apwhile] = nwhile[apwhile-1]+1; }
        | WHILE '{' Prog '}'                      { apwhile--; fprintf(out,"jump while%d\nendwhile%d:\n",nwhile[apwhile],nwhile[apwhile]); 
                                                  nwhile[apwhile]= nwhile[apwhile+1]; 
                                                }
        ;

Cond    : NUMI                                  { fprintf(out,"pushi %d\n",$1!=0); }
        | '(' Expr EQUALS Expr ')'              { fprintf(out,"equals\n"); }
        | '(' Expr NE Expr ')'                  { fprintf(out,"equals\npushi 0\nequals\n"); }
        | '(' Expr '<' Expr ')'                 { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                    fprintf(out,"inf\n");
                                                  }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                    fprintf(out,"finf\nftoi\n");
                                                  }else{
                                                    printf("ERROR: Can't compare different types nor String nor Func.\n");
                                                  }
                                                }
        | '(' Expr '>' Expr ')'                 { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                    fprintf(out,"sup\n");
                                                  }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                    fprintf(out,"fsup\nftoi\n");
                                                  }else{
                                                    printf("ERROR: Can't compare different types nor String nor Func.\n");
                                                  }
                                                }
        | '(' Expr LE Expr ')'                  { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                    fprintf(out,"infeq\n");
                                                  }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                    fprintf(out,"finfeq\nftoi\n");
                                                  }else{
                                                    printf("ERROR: Can't compare different types nor String nor Func.\n");
                                                  }
                                                }
        | '(' Expr GE Expr ')'                  { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                    fprintf(out,"supeq\n");
                                                  }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                    fprintf(out,"fsupeq\nftoi\n");
                                                  }else{
                                                    printf("ERROR: Can't compare different types nor String nor Func.\n");
                                                  }
                                                }
        | '(' Cond AND Cond ')'                 { fprintf(out,"mul\n"); }
        | '(' Cond OR Cond ')'                  { fprintf(out,"add\n"); }
        | '!' Cond                              { fprintf(out,"pushi 0\nequals\n"); }
        ;

Expr  : '(' Expr '+' Expr ')'               { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                    fprintf(out,"add\n");
                                                    $$ = $2;
                                                  }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                    fprintf(out,"fadd\n");
                                                    $$ = $2;
                                                  }else if(strcmp($2,"string")==0 && strcmp($4,"string")==0){
                                                    fprintf(out,"concat\n");
                                                    $$ = $2;
                                                  }else{
                                                    printf("ERROR: Operation can only be one type\n");
                                                  }
                                            }
      | '(' Expr '-' Expr ')'               { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                 fprintf(out,"sub\n");
                                                 $$ = $2;
                                               }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                 fprintf(out,"fsub\n");
                                                 $$ = $2;
                                               }else{
                                                 printf("ERROR: Operation can only be one type\n");
                                               } 
                                            }
      | '(' Expr '*' Expr ')'               { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                 fprintf(out,"mul\n");
                                                 $$ = $2;
                                               }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                 fprintf(out,"fmul\n");
                                                 $$ = $2;
                                               }else{
                                                 printf("ERROR: Operation can only be one type\n");
                                               } 
                                            }
      | '(' Expr '/' Expr ')'               { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                 fprintf(out,"div\n");
                                                 $$ = $2;
                                               }else if(strcmp($2,"float")==0 && strcmp($4,"float")==0){
                                                 fprintf(out,"fdiv\n");
                                                 $$ = $2;
                                               }else{
                                                 printf("ERROR: Operation can only be one type\n");
                                               } 
                                            }
      | '(' Expr '%' Expr ')'               { if(strcmp($2,"int")==0 && strcmp($4,"int")==0){
                                                 fprintf(out,"mod\n");
                                                 $$ = $2;
                                               }else{
                                                 printf("ERROR: Operation can only be one type\n");
                                               } 
                                            }
      | '(' Expr ')'                        { $$ = $2; }
      | Exp                                 { $$ = $1; }
      ;                                                

Exp   : NUMI           { fprintf(out,"pushi %d\n", $1); $$=typeInt; }
      | NUMF           { fprintf(out,"pushf %f\n", $1); $$=typeFloat; }
      | STR            { fprintf(out,"pushs %s\n", $1); $$=typeString; }
      | Func           { $$=$1; }
      ;

%%

#include "lex.yy.c"

int yyerror(char *s)
{
  fprintf(stderr, "NOT ACCEPTED: %s \n", s);
}

int main() {
  out = fopen("a.vm", "w");
  if (out==NULL){
     printf("Error when trying to open the file!\n");
     exit(1);
  }
  fprintf(out, "start\n");
  yyparse();
  fprintf(out, "stop\n");
  
  fclose(out);
  return(0);
}
