# 🔧 Simple Language Compiler

A complete compiler implementation built with **Flex** (lexical analyzer) and **Bison** (parser generator). This project demonstrates fundamental compiler construction concepts including lexical analysis, parsing, syntax tree generation, symbol table management, and intermediate code generation.

---

## 📋 Table of Contents

- [Features](#-features)
- [Language Specification](#-language-specification)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Build Instructions](#-build-instructions)
- [Usage](#-usage)
- [Output Files](#-output-files)
- [Examples](#-examples)
- [Compiler Phases](#-compiler-phases)
- [Error Handling](#-error-handling)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Lexical Analysis** | Tokenizes source code with line number tracking |
| **Syntax Analysis** | Parses tokens using context-free grammar rules |
| **Syntax Tree** | Generates visual tree representation of parsed code |
| **Symbol Table** | Tracks variable declarations with types and values |
| **Semantic Analysis** | Detects undefined variables, division by zero |
| **Code Generation** | Produces intermediate target code |
| **Error Reporting** | Detailed error messages with line numbers |

---

## 📖 Language Specification

### Supported Data Types
```
int     → Integer type
float   → Floating-point type
```

### Variable Declaration
```
int x = 10;
float y = 20;
```

### Arithmetic Operators
| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |

### Comparison Operators
| Operator | Description |
|----------|-------------|
| `==` | Equal to |
| `<`  | Less than |
| `>`  | Greater than |
| `<=` | Less than or equal |
| `>=` | Greater than or equal |

### Control Flow
```
if (condition):
    statements
end
```

### Print Statement
```
print(expression);
print(variable);
```

### Keywords
`int`, `float`, `if`, `else`, `end`, `print`, `true`, `false`

---

## 📁 Project Structure

```
Full-compiler/
├── Compiler/
│   ├── 1.l              # Flex lexer specification
│   ├── 1.y              # Bison parser grammar
│   ├── SyntaxTree.h     # Syntax tree & symbol table headers
│   ├── SyntaxTree.c     # Syntax tree & symbol table implementation
│   ├── 1.tab.c          # Generated parser (from Bison)
│   ├── 1.tab.h          # Generated parser header
│   ├── lex.yy.c         # Generated lexer (from Flex)
│   ├── compiler.exe     # Compiled executable
│   ├── in.txt           # Input source file
│   ├── out.txt          # Output target code
│   ├── tree.txt         # Syntax tree visualization
│   ├── outError.txt     # Error log
│   ├── temp             # Token log
│   └── Commands.txt     # Build instructions
├── Examples/            # Example programs
└── README.md
```

---

## 🔧 Prerequisites

### Windows
- **WinFlexBison** - Windows port of Flex and Bison
  - Download from: https://github.com/lexxmark/winflexbison/releases
  - Extract to `win_flex_bison/` folder in the Compiler directory
- **GCC** (MinGW) - C compiler
  - Download from: https://winlibs.com/ or install via MSYS2

### Linux/macOS
```bash
# Ubuntu/Debian
sudo apt-get install flex bison gcc

# macOS (with Homebrew)
brew install flex bison gcc
```

---

## 🚀 Build Instructions

### Windows (PowerShell)

Navigate to the `Compiler/` directory and run:

```powershell
# Step 1: Generate parser from Bison grammar
bison -d 1.y

# Step 2: Generate lexer from Flex specification
flex 1.l

# Step 3: Compile all source files
gcc -o compiler.exe 1.tab.c lex.yy.c SyntaxTree.c
```

**Quick one-liner:**
```powershell
bison -d 1.y && flex 1.l && gcc -o compiler.exe 1.tab.c lex.yy.c SyntaxTree.c
```

### Linux/macOS

```bash
cd Compiler/

# Generate parser and lexer
bison -d 1.y
flex 1.l

# Compile
gcc -o compiler 1.tab.c lex.yy.c SyntaxTree.c
```

---

## 💻 Usage

1. **Write your source code** in `in.txt`:
   ```
   int x = 10;
   int y = 20;
   int z = x + y;
   print(z);
   ```

2. **Run the compiler:**
   ```powershell
   # Windows
   .\compiler.exe
   
   # Linux/macOS
   ./compiler
   ```

3. **Check output files** for results

---

## 📄 Output Files

| File | Description |
|------|-------------|
| `out.txt` | Generated intermediate/target code |
| `tree.txt` | Syntax tree visualization with symbol table |
| `outError.txt` | Compilation errors (scanner, parser, semantic) |
| `temp` | Token stream log from lexical analysis |

---

## 📝 Examples

### Example 1: Variable Declaration

**Input (`in.txt`):**
```
int x = 20;
```

**Token Log (`temp`):**
```
TOKEN: TYPE_INT (line 1)
TOKEN: IDENTIFIER = x (line 1)
TOKEN: ASSIGN (line 1)
TOKEN: INTEGER = 20 (line 1)
TOKEN: SEMICOLON (line 1)
```

**Syntax Tree (`tree.txt`):**
```
      dec
     /   \
   expr   ;
  / | \
expr  =  20
/  \
int  x
```

**Target Code (`out.txt`):**
```
STORE x, 20
```

---

### Example 2: Conditional Statement

**Input (`in.txt`):**
```
int x = 20;
if (3 > 4):
    int y = 20;
end
```

**Target Code (`out.txt`):**
```
STORE x, 20
STORE y, 20
IF_COND 0
JUMP_FALSE end_if
END_IF
```

**Symbol Table:**
```
| Name       | Type   | Value    | Line |
|------------|--------|----------|------|
| y          | int    | 20       | 3    |
| x          | int    | 20       | 1    |
```

---

### Example 3: Arithmetic Expressions

**Input (`in.txt`):**
```
int a = 10;
int b = 5;
int sum = a + b;
int product = a * b;
print(sum);
```

---

## ⚙️ Compiler Phases

```
┌─────────────────┐
│   Source Code   │  in.txt
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Lexical Analysis│  Flex (1.l)
│    (Scanner)    │  → Tokens
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Syntax Analysis │  Bison (1.y)
│    (Parser)     │  → Parse Tree
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Semantic        │  SyntaxTree.c
│ Analysis        │  → Symbol Table
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Code Generation │  → Intermediate Code
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Target Code    │  out.txt
└─────────────────┘
```

### Phase Details

1. **Lexical Analysis (Scanner)**
   - Reads source file character by character
   - Groups characters into tokens (keywords, identifiers, operators, literals)
   - Reports invalid characters
   - Tracks line numbers for error reporting

2. **Syntax Analysis (Parser)**
   - Validates token sequence against grammar rules
   - Builds abstract syntax tree
   - Reports syntax errors

3. **Semantic Analysis**
   - Type checking
   - Variable declaration verification
   - Division by zero detection
   - Symbol table management

4. **Code Generation**
   - Generates intermediate representation
   - Outputs target code instructions (`STORE`, `PRINT`, `IF_COND`, etc.)

---

## ❌ Error Handling

The compiler detects and reports three types of errors:

### Scanner Errors
```
SCANNER ERROR: Invalid character '@' at line 5
```

### Parser Errors
```
PARSER ERROR: syntax error at line 3
```

### Semantic Errors
```
SEMANTIC ERROR: Undefined variable 'z' at line 4
SEMANTIC ERROR: Division by zero at line 6
```

All errors are logged to `outError.txt` with line numbers for easy debugging.

---

## 🎯 Target Code Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `STORE var, value` | Store value in variable | `STORE x, 10` |
| `PRINT value` | Output a value | `PRINT 42` |
| `PRINT var (value)` | Output variable value | `PRINT x (10)` |
| `IF_COND result` | Condition result (0/1) | `IF_COND 1` |
| `JUMP_TRUE label` | Jump if condition true | `JUMP_TRUE if_body` |
| `JUMP_FALSE label` | Jump if condition false | `JUMP_FALSE end_if` |
| `END_IF` | End of if block | `END_IF` |

---

## 📚 Technical Details

### Grammar (Simplified BNF)
```
program       → statement_list
statement     → declaration | if_statement | print_statement
declaration   → type IDENTIFIER '=' expr ';'
type          → 'int' | 'float'
if_statement  → 'if' '(' condition ')' ':' statement_list 'end'
condition     → expr OP expr
print_statement → 'print' '(' expr ')' ';'
expr          → INTEGER | IDENTIFIER | expr ('+' | '-' | '*' | '/') expr | '(' expr ')'
```

### Operator Precedence
1. `*`, `/` (highest)
2. `+`, `-` (lowest)

---

## 📜 License

This project is for educational purposes as part of a Compiler Design course.

---

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

*Built with ❤️ using Flex & Bison*

