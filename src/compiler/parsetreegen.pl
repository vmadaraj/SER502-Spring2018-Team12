% @authors {Harshitha}, @version 1
% @authors {Divya}, @version 1.1
% @authors {Akhil}, @version 1.2
% @purpose Tokenizer to tokenize the program, and parser to generate the parse tree
% @date 04/17/2018

% Read the program from a file and returns the parse tree
arrow(FileName) :- open(FileName, read, InStream),
							   tokenCodes(InStream, TokenCodes),
                 tokenize(TokenCodes, Tokens),
                 parser(ParseTree, Tokens, []),
                 close(InStream),
							   open('/Users/harshithareddy/Harshitha/SER 502/project/output.ic',write, OutStream),
							   write(OutStream, ParseTree),
								 write(OutStream, '.'),
							   close(OutStream).


% Return list of token codes to tokenizer
tokenCodes(InStream,[]) :- at_end_of_stream(InStream), !.
tokenCodes(InStream, [TokenCode | RemTokens]) :- get_code(InStream, TokenCode),
                                                 tokenCodes(InStream, RemTokens).

% Returns one token at a time
tokenize([], []).
tokenize([CharCode | RemCodes], Tokens) :- char_type(CharCode, space), !,
										   tokenize(RemCodes, Tokens).
tokenize([CharCode | CharCodes], [WordString | Tokens]) :- char_type(CharCode, alnum), !,
													 getWord([CharCode | CharCodes], alnum, WordCodes, RemCodes),
													 name(Word, WordCodes), atom_string(Word, WordString),
													 tokenize(RemCodes, Tokens).
tokenize([CharCode | CharCodes], [CharString | Tokens]) :- !, name(Char, [CharCode]),
                                                           atom_string(Char, CharString),
													       tokenize(CharCodes, Tokens).

% Checks if next character is new line or space or end of file and returns token
% upto that point
getWord([CharCode1, CharCode2 | CharCodes], alnum, [CharCode1 | WordCodes], RemCodes) :-
				char_type(CharCode2, alnum),
				!,
				getWord([CharCode2 | CharCodes], alnum, WordCodes, RemCodes).
getWord([CharCode | RemCodes], alnum, [CharCode], RemCodes).


%====================================================================================================================
% Parser which parses the tokens which are generated from the tokenizer
% and returns a parse tree

parser(t_parser(X)) --> program(X).
program(t_commentprog(X, Y)) --> comment(X), [";"], ["begin"], statements(Y), [";"], ["end"], !.
program(t_program(X)) --> ["begin"], statements(X), [";"], ["end"].

block(t_blockstatements(X, Y)) --> allblocks(X), [";"], block(Y).
block(t_block(X)) --> allblocks(X).
allblocks(t_printblock(X)) --> printstatement(X).
allblocks(t_readblock(X)) --> readstatement(X).
allblocks(t_declarationblock(X)) --> declaration(X).
allblocks(t_statementsblock(X)) --> statements(X).

% Rules for statements
statements(t_multipleStatement(X, Y)) --> allstatements(X), [";"], statements(Y).
statements(t_singleStatements(X)) --> allstatements(X).
allstatements(t_printstatement(X)) --> printstatement(X).
allstatements(t_readstatement(X)) --> readstatement(X).
allstatements(t_declarationstatement(X)) --> declaration(X).
allstatements(t_assign(X)) --> assign(X).
allstatements(t_ifelseBlock(X)) --> ifelse(X).
allstatements(t_whileBlock(X)) --> whileloop(X).
allstatements(t_returnBlock(X)) --> returnstatement(X).
allstatements(t_functioncallstatement(X)) --> functioncall(X).


% Rules for declarations
declaration(t_multipleDeclarations(X, Y)) --> declarationtemp(X), [";"], declaration(Y).
declaration(t_singleDeclaration(X)) --> declarationtemp(X).
declarationtemp(t_constant(X, Y, Z)) --> datatype(X), identifier(Y), ["="], data(Z).
declarationtemp(t_variable(X, Y)) --> datatype(X), identifier(Y).

% Rules for assignment
assign(t_multipleAssignments(X, Y)) --> allassign(X), [";"], assign(Y).
assign(t_singleAssignment(X)) --> allassign(X).
allassign(t_expAssignment(X, Y)) --> identifier(X), ["="], expression(Y).
allassign(t_funAssignment(X, Y)) --> identifier(X), ["="], functioncall(Y).

% Rules for expressions
expression(t_add(X, Y)) --> term(X), ["+"], expression(Y).
expression(t_sub(X, Y)) --> term(X), ["-"], expression(Y).
expression(t_exp(X)) --> term(X).

term(t_mul(X, Y)) --> factor(X), ["*"], term(Y).
term(t_div(X, Y)) --> factor(X), ["/"], term(Y).
term(t_exp(X)) --> factor(X).

factor(t_bracket(X)) --> ["("], expression(X), [")"].
factor(t_id(X)) --> identifier(X).
factor(t_data(X)) --> data(X).

% Rules for if-else
ifelse(t_if(X, If)) --> ["if"], ["("], condition(X), [")"],
["{"], statements(If), [";"], ["}"].
ifelse(t_ifelse(X,If,Else)) --> ["if"], ["("], condition(X), [")"],
["{"], statements(If), [";"], ["}"],
["else"], ["{"], statements(Else), [";"], ["}"].

% Rules for while
whileloop(t_while(X,While)) --> ["while"], ["("],condition(X), [")"],
["{"] , statements(While), [";"], ["}"].

% Rules for function call
functioncall(t_functioncall(X, Y)) --> identifier(X), ["("], parameters(Y), [")"].

% Rules for function declaration
function(t_function(X, Y, Z, P)) --> ["function"], datatype(X), identifier(Y), ["("],
															  arguments(Z), [")"], ["{"], statements(P), ["}"].

% Rule for return statements
returnstatement(t_return(X)) --> ["return"], identifier(X).

% Rules for arguments
arguments(t_arguments(X, Y)) --> allarguments(X), [","], arguments(Y).
arguments(t_arguments(X)) --> allarguments(X).
allarguments(t_allarguments(X, Y)) --> datatype(X), identifier(Y).

% Rules for parameters
parameters(t_parameters(X, Y)) --> allparameters(X), [","], parameters(Y).
parameters(t_parameters(X)) --> allparameters(X).
allparameters(t_allparameters(X)) --> identifier(X).
allparameters(t_allparameters(X)) --> data(X).

% Rules for condition
condition(t_singlecond(X, Y, Z)) --> identifier(X), comparision(Y), expression(Z).
condition(t_multiplecond(X, Y, Z, P, Q)) --> identifier(X), comparision(Y), expression(Z),
condop(P), condition(Q).
condition(t_notcondition(X, Y, Z, P)) --> condnot(X), identifier(Y),
comparision(Z), expression(P).
condition(t_condition(true)) --> ["true"].
condition(t_condition(false)) --> ["false"].

% Rules for comparision
comparision(t_compare(>)) --> [">"].
comparision(t_compare(<)) --> ["<"].
comparision(t_compare(>=)) --> [">"], ["="].
comparision(t_compare(<=)) --> ["<"], ["="].
comparision(t_compare(==)) --> ["="], ["="].

% Rules for conditional operators
condop(t_condand(and)) --> ["and"].
condop(t_condor(or)) --> ["or"].
condnot(t_condnot(not)) -->["not"].

% Rules for print
printstatement(t_printComb(X, Y)) --> ["print"], ["'"], fullPrint(X), ["'"], ["+"], identifier(Y), !.
printstatement(t_printString(X)) --> ["print"], ["'"], fullPrint(X), ["'"], !.
printstatement(t_printIdentifier(X)) --> ["print"], identifier(X), !.

fullPrint(t_fullPrint(X)) --> singlePrint(X).
fullPrint(t_fullPrint(X, Y)) --> singlePrint(X), fullPrint(Y).
singlePrint(t_singlePrint(X)) --> [X], {string(X)}, !.

% Rules for read
readstatement(t_read(X)) --> identifier(X), ["="], ["read"].

% Rule for comment
comment(t_comment(C)) --> ["#"], fullComment(C).
fullComment(t_fullComment(X, Y)) --> singleComment(X), fullComment(Y).
fullComment(t_fullComment(X)) --> singleComment(X).
singleComment(t_singleComment(X)) --> [X], {string(X)}.

% Rules for identifiers
identifier(t_identifier(I)) --> [I], {re_match("^[a-z]+", I)}.

% Rules for datatype
datatype(t_datatype(int)) --> ["int"].
datatype(t_datatype(float)) --> ["float"].
datatype(t_datatype(bool)) --> ["bool"].
datatype(t_datatype(string)) --> ["string"].

% Rules for numbers
data(t_integer(N)) --> [N], {re_match("^[0-9]+", N)}.
data(t_float(F)) --> [F], {re_match("^[0-9]*[.][0-9]+", F)}.
data(t_string(S)) --> ["'"], [S], {string(S)}, ["'"], !.
data(t_bool(true)) --> ["true"].
data(t_bool(false)) --> ["false"].
