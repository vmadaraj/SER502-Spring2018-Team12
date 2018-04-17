% @authors {Harshitha}, @version 1
% @authors {Divya}, @version 1.1
% @purpose Tokenizer with space, newline and end of file delimiters
% @date 04/16/2018

% Read the program from a file and returns the list of tokens
readProgram(FileName, Tokens) :- open(FileName, read, InStream),
                      readWords(InStream, TokenCodes),
                      tokenize(TokenCodes, Tokens),
                      close(InStream).

% Return list of tokens to tokenizer
readWords(InStream,[]) :- at_end_of_stream(InStream), !.
readWords(InStream, [TokenCode | RemTokens]) :- get_code(InStream, TokenCode),
                                            readWords(InStream, RemTokens).

% Returns one token at a time
tokenize([], []).
tokenize([CharCode | RestCodes], Tokens) :- char_type(CharCode, space), !,
    tokenize(RestCodes, Tokens).

tokenize([CharCode | CharCodes], [Word | Tokens]) :- char_type(CharCode, alnum), !,
    make_word([CharCode | CharCodes], alnum, WordCodes, RestCodes),
    name(Word, WordCodes),
    tokenize(RestCodes, Tokens).

tokenize([CharCode | CharCodes], [Char | Tokens]) :- !,
    name(Char, [CharCode]),
    tokenize(CharCodes, Tokens).

% Checks if next character is new line or space or end of file and returns token
% upto that point
make_word([CharCode1, CharCode2 | CharCodes], alnum, [CharCode1 | WordCodes], RestCodes) :-
    char_type(CharCode2, alnum),
    !,
    make_word([CharCode2 | CharCodes], alnum, WordCodes, RestCodes).

make_word([CharCode | RestCodes], alnum, [CharCode], RestCodes).
