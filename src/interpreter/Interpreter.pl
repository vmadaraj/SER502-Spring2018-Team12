% @authors {Shirisha}, @version 1.0
% @authors {Divya Yadamreddi}, @version 1.1
% @authors {Venkata Akhil Madaraju}, @version 1.2
% @purpose Interpreter
% @date 04/22/2018

lookup(_,[],0).
lookup(X,[(X, V)|_],V).
lookup(X,[_|T],V) :- lookup(X,T,V).

update(X,V,[],[(X,V)]).
update(X,V,[(X,_)|T],[(X,V)|T]).
update(X,V,[H|T],[H|T1]) :- update(X,V,T,T1).


%interpreter(FileName) :- open(FileName, read, InStream), write("Open doc"), evalParser(InStream, [], EnvOut).
interpreter(FileName) :-  Env = [], evalParser(FileName, Env, EnvOut), write(FileName), write(" "), write(EnvOut), !.

evalParser(t_parser(K), EnvIn, EnvOut) :- evalProgram(K, EnvIn, EnvOut).

% Evaluate Programs
evalProgram(t_commentprog(_, Y), EnvIn, EnvOut) :- evalStatements(Y, EnvIn, EnvOut).
evalProgram(t_program(X), EnvIn, EnvOut) :- evalStatements(X, EnvIn, EnvOut).
%evalProgram(t_functionprog(X, Y), EnvIn, EnvOut) :- evalBlock(X, EnvIn, EnvIn2), evalFunction(Y, EnvIn2, EnvOut).
%evalProgram(t_commentFunProg(_, Y, Z), EnvIn, EnvOut) :- evalBlock(Y, EnvIn, EnvIn2), evalFunction(Z, EnvIn2, EnvOut).

evalStatements(t_multipleStatements(X,Y), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvIn2), evalStatements(Y, EnvIn2, EnvOut), !.
evalStatements(t_singleStatement(X), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvOut).

evalAllStatements(t_assign(X), EnvIn, EnvOut) :- evalAssign(X, EnvIn, EnvOut).
evalAllStatements(t_ifelseBlock(X), EnvIn, EnvOut) :- evalIfelse(X, EnvIn, EnvOut).
evalAllStatements(t_whileBlock(X), EnvIn, EnvOut) :- evalWhile(X, EnvIn, EnvOut).
evalAllStatements(t_printstatement(X), EnvIn, EnvOut) :- evalPrint(X, EnvIn, EnvOut).
evalAllStatements(t_commentStatement(_), EnvIn, EnvIn).
evalAllStatements(t_readstatement(X), EnvIn, EnvOut) :- evalRead(X, EnvIn, EnvOut).
evalAllStatements(t_declarationStatement(X), EnvIn, EnvOut) :- evalDeclaration(X, EnvIn, EnvOut).

evalDeclaration(t_singleDeclaration(X, Y, Z), EnvIn, EnvOut) :- evalDatatype(X, EnvIn, EnvIn1), evalIdentifier(Y, _, IdName, EnvIn1, EnvIn2),
														 evalData(Z, DataOutput, EnvIn3, EnvOut), update(IdName, DataOutput, EnvIn2, EnvIn3).

evalDeclaration(t_singleDeclaration(X, Y), EnvIn, EnvOut) :- evalDatatype(X, EnvIn, EnvIn1),
																														evalIdentifier(Y, _, IdName, EnvIn1, EnvIn2), update(IdName, 0, EnvIn2, EnvOut).

evalAssign(t_expAssignment(X,Y), EnvIn, EnvOut) :- evalIdentifier(X, _, IdName, EnvIn, EnvIn2),
																									evalExpression(Y, Output, EnvIn2, EnvIn3), update(IdName, Output, EnvIn3, EnvOut).

evalIfelse(t_if(X, Y), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(Y, EnvIn2, EnvOut)); EnvOut = EnvIn.
evalIfelse(t_ifelse(X, If, Else), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(If, EnvIn2, EnvOut));
																											evalStatements(Else, EnvIn, EnvOut).

evalWhile(t_while(X, While), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(While, EnvIn2, EnvIn3), evalWhile(t_while(X,While), EnvIn3, EnvOut));


																								EnvOut = EnvIn.


evalCondition(t_singlecond(X, Y, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																											 evalCompareEqual(Y),
                                                       evalExpression(Z, ExpOutput, EnvIn2, EnvOut),
																											 atom_string(IdOutput, Qstring),
																											 atom_number(Qstring, NIdOut),
																											 atom_string(ExpOutput, QExp),
																											 atom_number(QExp, NExp),
																											 ((NIdOut =:= NExp) -> !; !,false).
evalCondition(t_singlecond(X, Y, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																											 evalCompareLess(Y),
                                                       evalExpression(Z, ExpOutput, EnvIn2, EnvOut),
																											 atom_string(IdOutput, Qstring),
																											 atom_number(Qstring, NIdOut),
																											 atom_string(ExpOutput, QExp),
																											 atom_number(QExp, NExp),
																											 ((NIdOut < NExp) -> ! ; !,false).
evalCondition(t_singlecond(X, Y, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																											 evalCompareGreater(Y),
                                                       evalExpression(Z, ExpOutput, EnvIn2, EnvOut),
																											 atom_string(IdOutput, Qstring),
																											 atom_number(Qstring, NIdOut),
																											 atom_string(ExpOutput, QExp),
																											 atom_number(QExp, NExp),
																											 ((NIdOut > NExp) -> !; !,false).
evalCondition(t_singlecond(X, Y, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																											 evalCompareGE(Y),
                                                       evalExpression(Z, ExpOutput, EnvIn2, EnvOut),
																											 atom_string(IdOutput, Qstring),
																											 atom_number(Qstring, NIdOut),
																											 atom_string(ExpOutput, QExp),
																											 atom_number(QExp, NExp),
																											 ((NIdOut >= NExp) -> !; !,false).
evalCondition(t_singlecond(X, Y, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																											 evalCompareLE(Y),
                                                       evalExpression(Z, ExpOutput, EnvIn2, EnvOut),
																											 atom_string(IdOutput, Qstring),
																											 atom_number(Qstring, NIdOut),
																											 atom_string(ExpOutput, QExp),
																											 atom_number(QExp, NExp),
																											 ((NIdOut =< NExp) -> !; !,false).



