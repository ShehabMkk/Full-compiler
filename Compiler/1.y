%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SyntaxTree.h"

int yylex(void);
void yyerror(char *);
extern int yylineno;
extern FILE* yyin;
extern FILE* yyout;
extern FILE* tokenFile;

FILE* yyError;
FILE* treeFile;

/* Global variables (defined in SyntaxTree.c) */
extern SymbolTable* symbolTable;
extern TreeNode* syntaxTreeRoot;
TreeNode* currentNode;
int errorCount = 0;
int conditionResult = 0;
%}

%union {
    int ival;
    float fval;
    char* sval;
    struct TreeNode* node;
}

/* Tokens */
%token <ival> INTEGER
%token <sval> IDENTIFIER
%token <sval> OP
%token <ival> BOOL_TRUE BOOL_FALSE
%token TYPE_INT TYPE_FLOAT
%token IF ELSE END
%token PRINT
%token ASSIGN COLON SEMICOLON
%token LPAREN RPAREN LBRACE RBRACE
%token PLUS MINUS MULT DIV
%token NEWLINE

/* Types */
%type <node> program statement_list statement
%type <node> declaration if_statement print_statement
%type <node> expr condition type terminator

/* Precedence */
%left PLUS MINUS
%left MULT DIV

%%

program:
    statement_list {
        syntaxTreeRoot = $1;
        $$ = $1;
    }
    ;

statement_list:
    statement_list statement {
        if ($1 && $2) {
            TreeNode* prog = createNode(NODE_PROGRAM, "program");
            addChild(prog, $1);
            addChild(prog, $2);
            $$ = prog;
        } else if ($2) {
            $$ = $2;
        } else {
            $$ = $1;
        }
    }
    | /* empty */ {
        $$ = NULL;
    }
    ;

terminator:
    SEMICOLON { $$ = NULL; }
    | NEWLINE { $$ = NULL; }
    ;

statement:
    declaration terminator {
        $$ = $1;
    }
    | if_statement {
        $$ = $1;
    }
    | print_statement terminator {
        $$ = $1;
    }
    | terminator {
        $$ = NULL;
    }
    ;

declaration:
    type IDENTIFIER ASSIGN expr {
        /* Create declaration tree */
        TreeNode* dec = createNode(NODE_DECLARATION, "dec");
        TreeNode* exprNode = createNode(NODE_EXPRESSION, "expr");
        TreeNode* innerExpr = createNode(NODE_EXPRESSION, "expr");
        
        addChild(innerExpr, $1);
        addChild(innerExpr, createNode(NODE_IDENTIFIER, $2));
        
        addChild(exprNode, innerExpr);
        addChild(exprNode, createNode(NODE_BINARY_OP, "="));
        addChild(exprNode, $4);
        
        TreeNode* semi = createNode(NODE_SEMICOLON, ";");
        addChild(dec, exprNode);
        addChild(dec, semi);
        
        /* Add to symbol table */
        char* typeName = ($1 && $1->value) ? $1->value : "int";
        int value = ($4 && $4->type == NODE_INTEGER) ? $4->intValue : 0;
        insertSymbol(symbolTable, $2, typeName, value, yylineno);
        
        /* Print to tree file */
        fprintf(treeFile, "      dec\n");
        fprintf(treeFile, "     /   \\\n");
        fprintf(treeFile, "   expr   ;\n");
        fprintf(treeFile, "  / | \\\n");
        fprintf(treeFile, "expr  =  %d\n", value);
        fprintf(treeFile, "/  \\\n");
        fprintf(treeFile, "%s  %s\n\n", typeName, $2);
        
        /* Output target code */
        fprintf(yyout, "STORE %s, %d\n", $2, value);
        
        $$ = dec;
    }
    ;

type:
    TYPE_INT {
        $$ = createNode(NODE_TYPE, "int");
    }
    | TYPE_FLOAT {
        $$ = createNode(NODE_TYPE, "float");
    }
    ;

if_statement:
    IF LPAREN condition RPAREN COLON statement_list END {
        /* Create if statement tree */
        TreeNode* dec = createNode(NODE_DECLARATION, "dec");
        TreeNode* ifStat = createNode(NODE_IF_STATEMENT, "if_stat");
        
        addChild(ifStat, createNode(NODE_IDENTIFIER, "if"));
        addChild(ifStat, createNode(NODE_IDENTIFIER, "("));
        addChild(ifStat, $3);
        addChild(ifStat, createNode(NODE_IDENTIFIER, ")"));
        
        addChild(dec, ifStat);
        addChild(dec, createNode(NODE_COLON, ":"));
        
        /* Print tree for if statement */
        fprintf(treeFile, "--------------------------------------------------------\n\n");
        fprintf(treeFile, "inside if /////////////////\n\n");
        
        fprintf(treeFile, "\nif true=1,false=0,result --> %d\n\n", conditionResult);
        fprintf(treeFile, "        dec\n");
        fprintf(treeFile, "       /   \\\n");
        fprintf(treeFile, "    if_stat  :\n");
        fprintf(treeFile, "   / / | \\\n");
        fprintf(treeFile, " if (  %d  )\n\n", conditionResult);
        
        /* Generate target code */
        fprintf(yyout, "IF_COND %d\n", conditionResult);
        if (conditionResult) {
            fprintf(yyout, "JUMP_TRUE if_body\n");
        } else {
            fprintf(yyout, "JUMP_FALSE end_if\n");
        }
        fprintf(yyout, "END_IF\n");
        
        $$ = dec;
    }
    ;

condition:
    expr OP expr {
        TreeNode* cond = createNode(NODE_CONDITION, "condition");
        addChild(cond, $1);
        addChild(cond, createNode(NODE_BINARY_OP, $2));
        addChild(cond, $3);
        
        int left = ($1 && ($1->type == NODE_INTEGER || $1->type == NODE_IDENTIFIER)) ? $1->intValue : 0;
        int right = ($3 && ($3->type == NODE_INTEGER || $3->type == NODE_IDENTIFIER)) ? $3->intValue : 0;
        
        /* Evaluate condition */
        if (strcmp($2, "==") == 0) {
            conditionResult = (left == right) ? 1 : 0;
        } else if (strcmp($2, ">=") == 0) {
            conditionResult = (left >= right) ? 1 : 0;
        } else if (strcmp($2, "<=") == 0) {
            conditionResult = (left <= right) ? 1 : 0;
        } else if (strcmp($2, ">") == 0) {
            conditionResult = (left > right) ? 1 : 0;
        } else if (strcmp($2, "<") == 0) {
            conditionResult = (left < right) ? 1 : 0;
        }
        
        cond->intValue = conditionResult;
        $$ = cond;
    }
    ;

print_statement:
    PRINT LPAREN expr RPAREN {
        TreeNode* printNode = createNode(NODE_EXPRESSION, "print");
        addChild(printNode, $3);
        
        /* Handle both integer and identifier cases */
        if ($3 && $3->type == NODE_IDENTIFIER) {
            /* Look up variable value */
            SymbolEntry* entry = lookupSymbol(symbolTable, $3->value);
            if (entry) {
                fprintf(yyout, "PRINT %s (%d)\n", $3->value, entry->value);
            } else {
                fprintf(yyError, "SEMANTIC ERROR: Undefined variable '%s' at line %d\n", $3->value, yylineno);
                fprintf(yyout, "PRINT %s (undefined)\n", $3->value);
                errorCount++;
            }
        } else {
            int value = ($3 && $3->type == NODE_INTEGER) ? $3->intValue : 0;
            fprintf(yyout, "PRINT %d\n", value);
        }
        
        $$ = printNode;
    }
    ;

expr:
    INTEGER {
        $$ = createIntNode($1);
    }
    | IDENTIFIER {
        TreeNode* node = createNode(NODE_IDENTIFIER, $1);
        SymbolEntry* entry = lookupSymbol(symbolTable, $1);
        if (entry) {
            node->intValue = entry->value;
        } else {
            fprintf(yyError, "SEMANTIC ERROR: Undefined variable '%s' at line %d\n", $1, yylineno);
            errorCount++;
        }
        $$ = node;
    }
    | expr PLUS expr {
        int left = ($1 && ($1->type == NODE_INTEGER || $1->type == NODE_IDENTIFIER)) ? $1->intValue : 0;
        int right = ($3 && ($3->type == NODE_INTEGER || $3->type == NODE_IDENTIFIER)) ? $3->intValue : 0;
        TreeNode* node = createBinaryOpNode("+", $1, $3);
        node->intValue = left + right;
        $$ = node;
    }
    | expr MINUS expr {
        int left = ($1 && ($1->type == NODE_INTEGER || $1->type == NODE_IDENTIFIER)) ? $1->intValue : 0;
        int right = ($3 && ($3->type == NODE_INTEGER || $3->type == NODE_IDENTIFIER)) ? $3->intValue : 0;
        TreeNode* node = createBinaryOpNode("-", $1, $3);
        node->intValue = left - right;
        $$ = node;
    }
    | expr MULT expr {
        int left = ($1 && ($1->type == NODE_INTEGER || $1->type == NODE_IDENTIFIER)) ? $1->intValue : 0;
        int right = ($3 && ($3->type == NODE_INTEGER || $3->type == NODE_IDENTIFIER)) ? $3->intValue : 0;
        TreeNode* node = createBinaryOpNode("*", $1, $3);
        node->intValue = left * right;
        $$ = node;
    }
    | expr DIV expr {
        int left = ($1 && ($1->type == NODE_INTEGER || $1->type == NODE_IDENTIFIER)) ? $1->intValue : 0;
        int right = ($3 && ($3->type == NODE_INTEGER || $3->type == NODE_IDENTIFIER)) ? $3->intValue : 0;
        TreeNode* node;
        if (right == 0) {
            fprintf(yyError, "SEMANTIC ERROR: Division by zero at line %d\n", yylineno);
            errorCount++;
            node = createBinaryOpNode("/", $1, $3);
            node->intValue = 0;
        } else {
            node = createBinaryOpNode("/", $1, $3);
            node->intValue = left / right;
        }
        $$ = node;
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(char *s) {
    fprintf(yyError, "PARSER ERROR: %s at line %d\n", s, yylineno);
    errorCount++;
}

int main(int argc, char* argv[]) {
    /* Open input file */
    yyin = fopen("in.txt", "r");
    if (!yyin) {
        printf("Error: Cannot open in.txt\n");
        return 1;
    }
    
    /* Open output files */
    yyout = fopen("out.txt", "w");
    yyError = fopen("outError.txt", "w");
    treeFile = fopen("tree.txt", "w");
    tokenFile = fopen("temp", "w");
    
    if (!yyout || !yyError || !treeFile || !tokenFile) {
        printf("Error: Cannot open output files\n");
        return 1;
    }
    
    /* Initialize symbol table */
    symbolTable = createSymbolTable();
    
    /* Print header to tree file */
    fprintf(treeFile, "========== SYNTAX TREE OUTPUT ==========\n\n");
    
    /* Print header to output file */
    fprintf(yyout, "========== TARGET CODE ==========\n\n");
    
    /* Parse */
    printf("Starting compilation...\n");
    yyparse();
    
    /* Print symbol table */
    printSymbolTable(symbolTable, treeFile);
    printSymbolTable(symbolTable, stdout);
    
    /* Print summary */
    fprintf(treeFile, "\n========== COMPILATION SUMMARY ==========\n");
    if (errorCount == 0) {
        fprintf(treeFile, "Compilation successful! No errors found.\n");
        fprintf(yyout, "\n========== COMPILATION SUCCESSFUL ==========\n");
        printf("\nCompilation successful!\n");
    } else {
        fprintf(treeFile, "Compilation failed with %d error(s).\n", errorCount);
        fprintf(yyout, "\n========== COMPILATION FAILED ==========\n");
        printf("\nCompilation failed with %d error(s). See outError.txt for details.\n", errorCount);
    }
    
    /* Cleanup */
    freeSymbolTable(symbolTable);
    if (syntaxTreeRoot) freeTree(syntaxTreeRoot);
    
    fclose(yyin);
    fclose(yyout);
    fclose(yyError);
    fclose(treeFile);
    fclose(tokenFile);
    
    printf("Output files generated:\n");
    printf("  - out.txt: Target code\n");
    printf("  - tree.txt: Syntax tree\n");
    printf("  - outError.txt: Error log\n");
    printf("  - temp: Token log\n");
    
    return 0;
}