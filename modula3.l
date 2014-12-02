/* Implementacion de modula3 archivo de analizador lexico*/ 

%{


#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

#include "vectors.h"


/* y.tab.h ylwrap para renombres y otras cosas */
#include "modula3.tab.h"

extern int yyparse( void );
%}

%x comment

%pointer
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][a-zA_Z0-9_$]*
qstring  \"[^\"\n]*[\"\n]

%%

\(                      { return '('; }
\)                      { return ')'; }
"["                     { return '['; }
"]"                     { return ']'; }

";"                     { return ';'; }
":"                     { return ':'; }
","                     { return ','; }
"."                     { return '.'; }
".."                    { return RANGE; }

":="                    { return '='; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"<"                     { return '<'; }
">"                     { return '>'; }

<comment>"[*"           { BEGIN(comment); }
<comment>[^*\n]*        /* ignorar cualquier cosa que no sea '*' */
<comment>"*"+[^*/\n]*   /* ignorar '*' que no esten seguidos por '/' */
<comment>"\n"
<comment>"*]"           { BEGIN(INITIAL); }

"PROCEDURE"             { return K_PRO; }
"MODULE"                { return K_MOD; }
"VAR"                   { return K_VAR; }

"BEGIN"                 { return '{'; }
"END"                   { return '}'; }

"INTEGER"               { return K_INT; }
"CHAR"                  { return K_CHR; }
"BOOLEAN"               { return K_BOL; }
"ARRAY"                 { return K_ARY; }
"REAL"                  { return K_REA; }
"LONGREAL"              { return K_LRE: }

"AND"                   { return AND; }
"OR"                    { return OR; }
"NOT"                   { return NOT; }

"IF"                    { return IF; }
"THEN"                  { return THEN; }
"ELSE"                  { return ELSE; }
"FOR"                   { return FOR; }
"TO"                    { return TO; }
"DO"                    { return '{'; }
"LOOP"                  { return LOOP; }
"EXIT"                  { return EXIT; }
"OF"                    { return OF; }

"TRUE"                  { yylval.node = build_int_cst (boolean_type_node, 1);
                          return s_TRUE;
                        }
"FALSE"                 { yylval.node = build_int_cst (boolean_type_node, 0);
                          return s_FALSE;
                        }

{ID}                    {
                          yylval.node = build_identifier_node (cm_strdup(yytext));
                          return IDENTIFIER;
                        }

{DIGIT}+                {
                          long val = strtol (yytext, (char**)NULL, 10);
                          yylval.node = build_int_cst (integer_type_node, val);
                          return INTEGER;
                        }

[\n]                    ;
.                       ;

%%

int yywrap( void )
{
  return 1;
}

int cm_parse_file( const char * in )
{
  int retval = 1;
  FILE * fd = fopen (in, "rb");
  debug("trying to open <%s>!\n", in);
  if( fd )
    {
      yyin = fd;
      retval = yyparse( );
      fclose( fd );
      // yylex_destroy( );
    }
  else
    {
      fprintf(stderr, "error opening <%s>!\n", in );
      retval = 0;
    }
  return retval;
}
