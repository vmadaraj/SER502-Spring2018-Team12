# SER502-Spring2018-Team12
Compiler and Virtual Machine for a Programming Language

The language is called 'arrow'. The link of the youtube video is ""

Project Structure
-----------------
The src (source folder) consists of the following folders - compiler and interpreter

compiler/-      consits of parsetreegen.pl which has a tokenizer to generate tokens for the given .arr code,
		            and these tokens are used to generate the parse tree which is output to the .ic file (intermediate code).
interpreter/-   consists of interpreter.pl which takes the input as .ic file and generates the output for the given .arr code.

Installation
--------------
Requires SWI-Prolog 7.6.4 to be installed on the computer

Runtime steps
----------------
1. Download the repository to your local system.
2. Copy the files parsetreegen.pl, interpreter.pl in the same folder where you have the sample programs.
3. Open the SWI-Prolog runtime environment.
4. Execute both the files parsetreegen.pl and interpreter.pl.
5. Run the predicate arrow('<INPUTFILEPATH>'). The .ic file is generated in the same directory.
6. Run the predicate runArrow('<.icfilepath>').

Requirements Addressed
------------------------
1. Implemented operators and primitive types boolean, int, string.
2. Support for Assigment statments and evaluation of expressions.
3. if-then-else construct to make decisions.
4. while statement to do iterative execution.
5. Generates intermediate code (parsetree) and saves it to a .ic file.
4. Interpreter takes .ic file as input and prints the ouput on the Prolog runtime environment.

Extra Features Added
---------------------
1. Single line comments can be made at the begining of the code using # .
2. Conditional operators 'and', 'or', 'not' are implemented.
3. Comparision operators ‘>’ | ‘<’ | ‘<=’ | ‘>=’ | ‘==’ are implemented.
4. Declaration of the variables can be done at any point in the code.
5. Print statements can be used as 
	a. "print '<ONLY_STRING>'" 
	b. "print <IDENTIFIER>" 
6. IFELSE
	a. Nested if-else can be used - if, elseif, else.
	b. Boolean values can be used in the conditions.
	c. Multiple conditions can be checked using and/or.
7. Reading the user inputs from the console.
 

Example Run
-------------
The input file name is 'factorial.arr' 
For Mac/Linux:
Sample input file path : '/Users/<USERNAME>/Arrow/factorial.arr'
1. ['/Users/<USERNAME>/Arrow/parsetreegen.pl'].
2. arrow('/Users/<USERNAME>/Arrow/factorial.arr').
3. ['/Users/<USERNAME>/Arrow/interpreter.pl'].
4. runArrow('/Users/<USERNAME>/Arrow/factorial.ic').

For Windows:
Sample input file path : 'D:/Arrow/factorial.arr'
Open SWI-Prolog runtime environment.
1. ['D:/Arrow/parsetreegen.pl'].
2. arrow('D:/Arrow/factorial.arr']  
3. ['D:/Arrow/interpreter.pl'].
4. runarrow('D:/Arrow/factorial.ic').

Restrictions on the code
--------------------------
1. Print statements cannot have Capital letters and only space.
2. No operations can be on string.
3. User input needs to be followed by a '.'.

Team Members
-------------
1. Harshitha Katpally 				  hkatpall@asu.edu
2. Divya Yadamreddi 				  dyadamre@asu.edu
3. Venkata Akhil Madaraju 			  vmadaraj@asu.edu
4. Venkata Sai Shirisha Kakarla 	          vkakarla@asu.edu 
