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
program(t_program(X, Y)) --> comment(X), ["begin"], block(Y), ["end"], !.
program(t_program(X)) --> ["begin"], block(X), ["end"].

block(t_block(X)) --> declaration(X),[";"].
block(t_block(X, Y)) --> declaration(X), [";"], statements(Y), [";"].

% Rules for statements
statements(t_statements(X, Y)) --> allstatements(X), [";"], statements(Y).
statements(t_statements(X)) --> allstatements(X).
allstatements(t_allstatements(X)) --> assign(X).

% Rules for declarations
declaration(t_declaration(X, Y)) --> declarationtemp(X), [";"], declaration(Y).
declaration(t_declaration(X)) --> declarationtemp(X).
declarationtemp(t_constant(X, Y, Z)) --> datatype(X), identifier(Y), ["="], data(Z).
declarationtemp(t_variable(X, Y)) --> datatype(X), identifier(Y).

% Rules for assignment and expressions
assign(t_assignment(X, Y)) --> identifier(X), ["="], expression(Y).

expression(t_exp(X, Y)) --> term(X), ["+"], expression(Y).
expression(t_exp(X, Y)) --> term(X), ["-"], expression(Y).
expression(t_exp(X)) --> term(X).

term(t_exp(X, Y)) --> factor(X), ["*"], term(Y).
term(t_exp(X, Y)) --> factor(X), ["/"], term(Y).
term(t_exp(X)) --> factor(X).

factor(t_exp(X)) --> ["("], expression(X), [")"].
factor(t_exp(X)) --> identifier(X).
factor(t_exp(X)) --> data(X).

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
data(t_integer(N)) --> [N], {re_match("^[0-9]+$", N)}, !.
data(t_float(F)) --> [F], {re_match("^[0-9]+.[0-9]+$", F)}, !.
data(t_string(S)) --> [S], {string(S)}.
data(t_bool(true)) --> ["true"].
data(t_bool(false)) --> ["false"].





