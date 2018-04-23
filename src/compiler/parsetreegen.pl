% @authors {Harshitha}, @version 1
% @authors {Divya}, @version 1.1
% @authors {Akhil}, @version 1.2
% @purpose Tokenizer to tokenize the program, and parser to generate the parse tree
% @date 04/17/2018

% Read the program from a file and returns the parse tree
parseTreeGen(FileName, ParseTree) :- open(FileName, read, InStream),
							   tokenCodes(InStream, TokenCodes),
                               tokenize(TokenCodes, Tokens),
                               parser(ParseTree, Tokens, []),
                               close(InStream).

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
program(t_commentprog(X, Y)) --> comment(X), ["begin"], block(Y), [";"], ["end"], !.
program(t_program(X)) --> ["begin"], block(X), [";"], ["end"].

block(t_block(X, Y)) --> allblocks(X), [";"], block(Y).
block(t_block(X)) --> allblocks(X).
allblocks(t_printblock(X)) --> printstatement(X).
allblocks(t_declarationblock(X)) --> declaration(X).
allblocks(t_statementsblock(X)) --> statements(X).

% Rules for statements
statements(t_statements(X, Y)) --> allstatements(X), [";"], statements(Y).
statements(t_statements(X)) --> allstatements(X).
allstatements(t_printstatement(X)) --> printstatement(X).
allstatements(t_assign(X)) --> assign(X).
allstatements(t_ifelseBlock(X)) --> ifelse(X).
allstatements(t_whileBlock(X)) --> while(X).

% Rules for declarations
declaration(t_declaration(X, Y)) --> declarationtemp(X), [";"], declaration(Y).
declaration(t_declaration(X)) --> declarationtemp(X).
declarationtemp(t_constant(X, Y, Z)) --> datatype(X), identifier(Y), ["="], data(Z).
declarationtemp(t_variable(X, Y)) --> datatype(X), identifier(Y).

% Rules for assignment and expressions
assign(t_assignment(X, Y)) --> identifier(X), ["="], expression(Y).

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
while(t_while(X,While)) --> ["while"], ["("],condition(X), [")"],
["{"] , statements(While), [";"], ["}"].

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
condop(t_condop(and)) --> ["and"].
condop(t_condop(or)) --> ["or"].
condnot(t_condnot(not)) -->["not"].

% Rules for print
printstatement(t_print(X)) --> [print], identifier(X), !.
printstatement(t_print(X)) --> [print], [X], {string(X)}, !.
printstatement(t_print(X, Y)) --> [print], [X], {string(X)}, ["+"], identifier(Y), !.

% Rule for comment
comment(t_comment(C)) --> ["#"], [C], {string(C)}.

% Rules for datatype
datatype(t_datatype(int)) --> ["int"].
datatype(t_datatype(float)) --> ["float"].
datatype(t_datatype(bool)) --> ["bool"].
datatype(t_datatype(string)) --> ["string"].

% Rules for identifiers
identifier(t_identifier(I)) --> [I], {string(I)}.

% Rules for numbers
data(t_integer(N)) --> [N], {re_match("^[0-9]+", N)}, !.
data(t_float(F)) --> [F], {re_match("^[0-9]+.[0-9]+", F)}, !.
data(t_string(S)) --> [S], {string(S)}.
data(t_bool(true)) --> ["true"].
data(t_bool(false)) --> ["false"].




