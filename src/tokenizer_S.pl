%tokenize: breaks a list of character codes into a list of tokens.
%tokenize: Base Case.
tokenize([], []).

%char_type determines the type of a character code: alphanumerical, blank and other.
%tokenize: Skips the Blank Spaces.
tokenize([CharCode | RestCodes], Tokens) :- 
	char_type(CharCode, space),
	!,
	tokenize(RestCodes, Tokens).

%tokenize: Alphanumerical, it calls the make_word.
tokenize([CharCode | CharCodes], [Word | Tokens]) :- 
	char_type(CharCode, alnum), 
	!,
	make_word([CharCode | CharCodes], alnum, WordCodes, RestCodes),
	name(Word, WordCodes),
	tokenize(RestCodes, Tokens).

%tokenize: other symbols, it makes a single token out of it.
tokenize([CharCode | CharCodes], [Char | Tokens]) :- 
	!,
	name(Char, [CharCode]),
	tokenize(CharCodes, Tokens).

%make_word builds a word out of next letters or digits in the list.
make_word([CharCode1, CharCode2 | CharCodes], alnum, [CharCode1 | WordCodes], RestCodes) :- 
	char_type(CharCode2, alnum),
	!,
	make_word([CharCode2 | CharCodes], alnum, WordCodes, RestCodes).

make_word([CharCode | RestCodes], alnum, [CharCode], RestCodes).