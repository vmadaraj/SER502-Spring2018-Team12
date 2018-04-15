% Read the program from a file and returns the list of tokens
tokenizer(FileName, Tokens) :- open(FileName, read, InStream),
                      readTokens(InStream, Tokens),
                      close(InStream).

% Return list of tokens to tokenizer
readTokens(InStream,[]) :- at_end_of_stream(InStream), !.
readTokens(InStream, [Token | RemTokens]) :- readToken(InStream, Token),
                                            readTokens(InStream, RemTokens).


% Returns one token at a time
readToken(InStream, Token) :- get_code(InStream, CharCode),
                        checkTokens(CharCode, TokenCode, InStream),
                        atom_codes(Token, TokenCode).

% Checks if next character is new line or space or end of file and returns token
% upto that point
checkTokens(10, [], _) :- !.
checkTokens(32, [], _) :- !.
checkTokens(end_of_file, [], _) :- !.
checkTokens(CharCode, [CharCode|TokenCode], InStream) :- get_code(InStream, NextCharCode),
                  checkTokens(NextCharCode, TokenCode, InStream).
