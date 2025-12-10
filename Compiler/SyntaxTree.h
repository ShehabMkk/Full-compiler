#ifndef SYNTAXTREE_H
#define SYNTAXTREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Node Types */
typedef enum {
    NODE_PROGRAM,
    NODE_DECLARATION,
    NODE_ASSIGNMENT,
    NODE_IF_STATEMENT,
    NODE_EXPRESSION,
    NODE_BINARY_OP,
    NODE_INTEGER,
    NODE_IDENTIFIER,
    NODE_TYPE,
    NODE_SEMICOLON,
    NODE_COLON,
    NODE_CONDITION
} NodeType;

/* Tree Node Structure */
typedef struct TreeNode {
    NodeType type;
    char* value;
    int intValue;
    struct TreeNode* children[4];  /* Max 4 children */
    int childCount;
} TreeNode;

/* Symbol Table Entry */
typedef struct SymbolEntry {
    char* name;
    char* type;
    int value;
    int lineNumber;
    struct SymbolEntry* next;
} SymbolEntry;

/* Symbol Table */
typedef struct {
    SymbolEntry* head;
    int count;
} SymbolTable;

/* Function Declarations */

/* Tree Functions */
TreeNode* createNode(NodeType type, const char* value);
TreeNode* createIntNode(int value);
TreeNode* createBinaryOpNode(const char* op, TreeNode* left, TreeNode* right);
TreeNode* createDeclarationNode(TreeNode* typeNode, TreeNode* varNode, TreeNode* exprNode);
TreeNode* createIfNode(TreeNode* condition, TreeNode* body);
void addChild(TreeNode* parent, TreeNode* child);
void printTree(TreeNode* node, int level, FILE* output);
void printTreeToFile(TreeNode* node, const char* filename);
void freeTree(TreeNode* node);

/* Symbol Table Functions */
SymbolTable* createSymbolTable();
void insertSymbol(SymbolTable* table, const char* name, const char* type, int value, int lineNumber);
SymbolEntry* lookupSymbol(SymbolTable* table, const char* name);
void updateSymbolValue(SymbolTable* table, const char* name, int value);
void printSymbolTable(SymbolTable* table, FILE* output);
void freeSymbolTable(SymbolTable* table);

/* Global Symbol Table */
extern SymbolTable* symbolTable;

/* Global Root Node */
extern TreeNode* syntaxTreeRoot;

#endif /* SYNTAXTREE_H */
