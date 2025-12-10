#include "SyntaxTree.h"

/* Global Variables */
SymbolTable* symbolTable = NULL;
TreeNode* syntaxTreeRoot = NULL;

/* ============== TREE FUNCTIONS ============== */

TreeNode* createNode(NodeType type, const char* value) {
    TreeNode* node = (TreeNode*)malloc(sizeof(TreeNode));
    node->type = type;
    node->value = value ? strdup(value) : NULL;
    node->intValue = 0;
    node->childCount = 0;
    for (int i = 0; i < 4; i++) {
        node->children[i] = NULL;
    }
    return node;
}

TreeNode* createIntNode(int value) {
    TreeNode* node = createNode(NODE_INTEGER, NULL);
    node->intValue = value;
    return node;
}

TreeNode* createBinaryOpNode(const char* op, TreeNode* left, TreeNode* right) {
    TreeNode* node = createNode(NODE_BINARY_OP, op);
    addChild(node, left);
    addChild(node, right);
    return node;
}

TreeNode* createDeclarationNode(TreeNode* typeNode, TreeNode* varNode, TreeNode* exprNode) {
    TreeNode* decNode = createNode(NODE_DECLARATION, "dec");
    
    /* Create expression node with type and variable */
    TreeNode* exprParent = createNode(NODE_EXPRESSION, "expr");
    
    /* Create inner expr for type and variable */
    TreeNode* innerExpr = createNode(NODE_EXPRESSION, "expr");
    addChild(innerExpr, typeNode);
    addChild(innerExpr, varNode);
    
    addChild(exprParent, innerExpr);
    addChild(exprParent, createNode(NODE_BINARY_OP, "="));
    addChild(exprParent, exprNode);
    
    /* Add semicolon */
    TreeNode* semicolon = createNode(NODE_SEMICOLON, ";");
    
    addChild(decNode, exprParent);
    addChild(decNode, semicolon);
    
    return decNode;
}

TreeNode* createIfNode(TreeNode* condition, TreeNode* body) {
    TreeNode* decNode = createNode(NODE_DECLARATION, "dec");
    TreeNode* ifStat = createNode(NODE_IF_STATEMENT, "if_stat");
    
    TreeNode* ifKeyword = createNode(NODE_IDENTIFIER, "if");
    TreeNode* openParen = createNode(NODE_IDENTIFIER, "(");
    TreeNode* closeParen = createNode(NODE_IDENTIFIER, ")");
    
    addChild(ifStat, ifKeyword);
    addChild(ifStat, openParen);
    addChild(ifStat, condition);
    addChild(ifStat, closeParen);
    
    TreeNode* colon = createNode(NODE_COLON, ":");
    
    addChild(decNode, ifStat);
    addChild(decNode, colon);
    
    return decNode;
}

void addChild(TreeNode* parent, TreeNode* child) {
    if (parent && child && parent->childCount < 4) {
        parent->children[parent->childCount++] = child;
    }
}

void printTreeIndent(int level, FILE* output) {
    for (int i = 0; i < level; i++) {
        fprintf(output, "     ");
    }
}

const char* getNodeTypeName(NodeType type) {
    switch (type) {
        case NODE_PROGRAM: return "program";
        case NODE_DECLARATION: return "dec";
        case NODE_ASSIGNMENT: return "assignment";
        case NODE_IF_STATEMENT: return "if_stat";
        case NODE_EXPRESSION: return "expr";
        case NODE_BINARY_OP: return "op";
        case NODE_INTEGER: return "num";
        case NODE_IDENTIFIER: return "id";
        case NODE_TYPE: return "type";
        case NODE_SEMICOLON: return ";";
        case NODE_COLON: return ":";
        case NODE_CONDITION: return "cond";
        default: return "unknown";
    }
}

void printTree(TreeNode* node, int level, FILE* output) {
    if (!node) return;
    
    printTreeIndent(level, output);
    
    /* Print node value or type */
    if (node->value) {
        fprintf(output, "%s\n", node->value);
    } else if (node->type == NODE_INTEGER) {
        fprintf(output, "%d\n", node->intValue);
    } else {
        fprintf(output, "%s\n", getNodeTypeName(node->type));
    }
    
    /* Print children connectors and recurse */
    if (node->childCount > 0) {
        printTreeIndent(level, output);
        
        /* Print branch lines */
        for (int i = 0; i < node->childCount; i++) {
            if (i == 0) fprintf(output, "/");
            else if (i == node->childCount - 1) fprintf(output, "   \\");
            else fprintf(output, "   |");
        }
        fprintf(output, "\n");
        
        /* Print children */
        for (int i = 0; i < node->childCount; i++) {
            printTree(node->children[i], level, output);
        }
    }
}

void printTreeFormatted(TreeNode* node, int level, int position, FILE* output) {
    if (!node) return;
    
    /* Print the node */
    for (int i = 0; i < position; i++) fprintf(output, " ");
    
    if (node->value) {
        fprintf(output, "%s", node->value);
    } else if (node->type == NODE_INTEGER) {
        fprintf(output, "%d", node->intValue);
    } else {
        fprintf(output, "%s", getNodeTypeName(node->type));
    }
    fprintf(output, "\n");
    
    /* If has children, print branch and children */
    if (node->childCount > 0) {
        for (int i = 0; i < position; i++) fprintf(output, " ");
        
        /* Print branch symbols */
        if (node->childCount == 1) {
            fprintf(output, "|\n");
        } else if (node->childCount == 2) {
            fprintf(output, "/   \\\n");
        } else if (node->childCount == 3) {
            fprintf(output, "/ | \\\n");
        } else {
            fprintf(output, "/ / | \\\n");
        }
        
        /* Print each child */
        for (int i = 0; i < node->childCount; i++) {
            printTreeFormatted(node->children[i], level + 1, position + (i * 4), output);
        }
    }
}

void printTreeToFile(TreeNode* node, const char* filename) {
    FILE* file = fopen(filename, "w");
    if (!file) {
        printf("Error: Cannot open %s for writing\n", filename);
        return;
    }
    
    fprintf(file, "========== SYNTAX TREE ==========\n\n");
    printTreeFormatted(node, 0, 6, file);
    fprintf(file, "\n================================\n");
    
    fclose(file);
}

void freeTree(TreeNode* node) {
    if (!node) return;
    
    for (int i = 0; i < node->childCount; i++) {
        freeTree(node->children[i]);
    }
    
    if (node->value) free(node->value);
    free(node);
}

/* ============== SYMBOL TABLE FUNCTIONS ============== */

SymbolTable* createSymbolTable() {
    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    table->head = NULL;
    table->count = 0;
    return table;
}

void insertSymbol(SymbolTable* table, const char* name, const char* type, int value, int lineNumber) {
    if (!table) return;
    
    /* Check if symbol already exists */
    SymbolEntry* existing = lookupSymbol(table, name);
    if (existing) {
        /* Update existing symbol */
        existing->value = value;
        return;
    }
    
    /* Create new entry */
    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    entry->name = strdup(name);
    entry->type = strdup(type);
    entry->value = value;
    entry->lineNumber = lineNumber;
    entry->next = table->head;
    table->head = entry;
    table->count++;
}

SymbolEntry* lookupSymbol(SymbolTable* table, const char* name) {
    if (!table) return NULL;
    
    SymbolEntry* current = table->head;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void updateSymbolValue(SymbolTable* table, const char* name, int value) {
    SymbolEntry* entry = lookupSymbol(table, name);
    if (entry) {
        entry->value = value;
    }
}

void printSymbolTable(SymbolTable* table, FILE* output) {
    fprintf(output, "\n========== SYMBOL TABLE ==========\n");
    fprintf(output, "| %-10s | %-6s | %-8s | %-4s |\n", "Name", "Type", "Value", "Line");
    fprintf(output, "|------------|--------|----------|------|\n");
    
    if (!table || !table->head) {
        fprintf(output, "| (empty)                              |\n");
    } else {
        SymbolEntry* current = table->head;
        while (current) {
            fprintf(output, "| %-10s | %-6s | %-8d | %-4d |\n", 
                    current->name, current->type, current->value, current->lineNumber);
            current = current->next;
        }
    }
    fprintf(output, "==================================\n\n");
}

void freeSymbolTable(SymbolTable* table) {
    if (!table) return;
    
    SymbolEntry* current = table->head;
    while (current) {
        SymbolEntry* next = current->next;
        free(current->name);
        free(current->type);
        free(current);
        current = next;
    }
    free(table);
}
