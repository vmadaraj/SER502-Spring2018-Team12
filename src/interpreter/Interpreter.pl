% @authors {Shirisha}, @version 1.0
% @authors {Divya Yadamreddi}, @version 1.1
% @authors {Venkata Akhil Madaraju}, @version 1.2
% @purpose Interpreter
% @date 04/22/2018

%interpreter(FileName) :-  Env = [], write(FileName), evalParser(FileName, Env, EnvOut), write(" "), write(EnvOut), !.
runArrow(FileName) :- open(FileName, read, InStream), read(InStream, X),
 											   close(InStream), Env = [], evalParser(X, Env, EnvOut), write(X).

evalParser(t_parser(K), EnvIn, EnvOut) :- evalProgram(K, EnvIn, EnvOut).

% Look up the environment to find the value of a variable
lookup(_,[],0).
lookup(X,[(X, V)|_],V).
lookup(X,[_|T],V) :- lookup(X,T,V).

% Update the env with new values of variables
update(X,V,[],[(X,V)]).
update(X,V,[(X,_)|T],[(X,V)|T]).
update(X,V,[H|T],[H|T1]) :- update(X,V,T,T1).

% Rules to evaluate Programs.
evalProgram(t_commentprog(_, Y), EnvIn, EnvOut) :- evalStatements(Y, EnvIn, EnvOut).
evalProgram(t_program(X), EnvIn, EnvOut) :- evalStatements(X, EnvIn, EnvOut).

% Rules to evaluate statements.
evalStatements(t_multipleStatements(X,Y), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvIn2), evalStatements(Y, EnvIn2, EnvOut), !.
evalStatements(t_singleStatement(X), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvOut).

evalAllStatements(t_assign(X), EnvIn, EnvOut) :- evalAssign(X, EnvIn, EnvOut).
evalAllStatements(t_ifelseBlock(X), EnvIn, EnvOut) :- evalIfelse(X, EnvIn, EnvOut).
evalAllStatements(t_whileBlock(X), EnvIn, EnvOut) :- evalWhile(X, EnvIn, EnvOut).
evalAllStatements(t_printstatement(X), EnvIn, EnvOut) :- evalPrint(X, EnvIn, EnvOut).
evalAllStatements(t_commentStatement(_), EnvIn, EnvIn).
evalAllStatements(t_readstatement(X), EnvIn, EnvOut) :- evalRead(X, EnvIn, EnvOut).
evalAllStatements(t_declarationStatement(X), EnvIn, EnvOut) :- evalDeclaration(X, EnvIn, EnvOut).

% Rules to evaluate declaration statement.
evalDeclaration(t_singleDeclaration(X, Y, Z), EnvIn, EnvOut) :- evalDatatype(X, EnvIn, EnvIn1), evalIdentifier(Y, _, IdName, EnvIn1, EnvIn2),
														 																		evalData(Z, DataOutput, EnvIn3, EnvOut), update(IdName, DataOutput, EnvIn2, EnvIn3).
evalDeclaration(t_singleDeclaration(X, Y), EnvIn, EnvOut) :- evalDatatype(X, EnvIn, EnvIn1),
																														 evalIdentifier(Y, _, IdName, EnvIn1, EnvIn2), update(IdName, 0, EnvIn2, EnvOut).

% Rules to assign values to variables.
evalAssign(t_expAssignment(X,Y), EnvIn, EnvOut) :- evalIdentifier(X, _, IdName, EnvIn, EnvIn2),
																									evalExpression(Y, Output, EnvIn2, EnvIn3), update(IdName, Output, EnvIn3, EnvOut).

% Rules to evaluate if-else statements.
evalIfelse(t_if(X, Y), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(Y, EnvIn2, EnvOut)); EnvOut = EnvIn.
evalIfelse(t_ifelse(X, If, Else), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(If, EnvIn2, EnvOut));
																											evalStatements(Else, EnvIn, EnvOut).
evalIfelse(t_ifelseif(X, If, Y, Else), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(If, EnvIn2, EnvOut));
																												 (evalElseifLoop(Y, EnvIn, EnvOut), !);
																												 (evalStatements(Else, EnvIn, EnvOut)).

evalElseifLoop(t_elseifLoop(X), EnvIn, EnvOut) :- evalElseifLoop1(X, EnvIn, EnvOut).
evalElseifLoop(t_elseifLoop(X, Y), EnvIn, EnvOut) :- (evalElseifLoop1(X, EnvIn, EnvOut) -> !); evalElseifLoop(Y, EnvIn, EnvOut).
evalElseifLoop1(t_elseifSingle(X, Elseif), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(Elseif, EnvIn2, EnvOut)); !, false.
 																												 																											
% Rules to evaluate while loop.
evalWhile(t_while(X, While), EnvIn, EnvOut) :- (evalCondition(X, EnvIn, EnvIn2) -> evalStatements(While, EnvIn2, EnvIn3), evalWhile(t_while(X,While), EnvIn3, EnvOut));
																								EnvOut = EnvIn.

% Rules to evaluate conditions.
% Boolean conditions.
evalCondition(t_condition(true), EnvIn, EnvIn) :- true.
evalCondition(t_condition(false), EnvIn, EnvIn) :- false.

% Single conditions.
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

% not condition.																									 
evalCondition(t_notcondition(N, X, Z, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																														evalNot(N), evalCompareEqual(Z),
                                                            evalExpression(Y, ExpOutput, EnvIn2, EnvOut),
																														atom_string(IdOutput, Qstring),
		 																											  atom_number(Qstring, NIdOut),
		 																											  atom_string(ExpOutput, QExp),
		 																											  atom_number(QExp, NExp),
                                                            ((NIdOut \= NExp) -> !; !,false).
evalCondition(t_notcondition(N, X, Z, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																														evalNot(N), evalCompareGreater(Z),
                                                            evalExpression(Y, ExpOutput, EnvIn2, EnvOut),
																														atom_string(IdOutput, Qstring),
		 																											  atom_number(Qstring, NIdOut),
		 																											  atom_string(ExpOutput, QExp),
		 																											  atom_number(QExp, NExp),
                                                            ((NIdOut =< NExp) ->!; !,false).
evalCondition(t_notcondition(N, X, Z, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																														evalNot(N), evalCompareLess(Z),
                                                            evalExpression(Y, ExpOutput, EnvIn2, EnvOut),
																														atom_string(IdOutput, Qstring),
		 																											  atom_number(Qstring, NIdOut),
		 																											  atom_string(ExpOutput, QExp),
		 																											  atom_number(QExp, NExp),
                                                            ((NIdOut >= NExp) -> !; !,false).
evalCondition(t_notcondition(N, X, Z, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																														evalNot(N), evalCompareGE(Z),
                                                            evalExpression(Y, ExpOutput, EnvIn2, EnvOut),
																														atom_string(IdOutput, Qstring),
		 																											  atom_number(Qstring, NIdOut),
		 																											  atom_string(ExpOutput, QExp),
		 																											  atom_number(QExp, NExp),
                                                            ((NIdOut < NExp) -> !, !,false).
evalCondition(t_notcondition(N, X, Z, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																														evalNot(N), (evalCompareLE(Z) -> !),
                                                            evalExpression(Y, ExpOutput, EnvIn2, EnvOut),
																														atom_string(IdOutput, Qstring),
		 																											  atom_number(Qstring, NIdOut),
		 																											  atom_string(ExpOutput, QExp),
		 																											  atom_number(QExp, NExp),
                                                            ((NIdOut > NExp) -> !; !,false).


% Multiple conditions.
% with 'and'                                                                                                                   
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
																															 evalAnd(O), evalCompareGE(S),
																															 atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut >= NExp) -> evalCondition(Z, EnvIn3, EnvOut); !,false).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
																															 evalAnd(O), evalCompareLE(S),
																															 atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut =< NExp) -> evalCondition(Z, EnvIn3, EnvOut); !,false).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
																															 evalAnd(O), evalCompareEqual(S),
																															 atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut =:= NExp) -> evalCondition(Z, EnvIn3, EnvOut); !,false).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
																															 evalAnd(O), evalCompareGreater(S),
																															 atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut > NExp) -> evalCondition(Z, EnvIn3, EnvOut); !,false).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
																															 evalAnd(O), evalCompareLess(S),
																															 atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut < NExp) -> evalCondition(Z, EnvIn3, EnvOut); !,false).

% with 'or'                                                                                                                                   
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																															 evalOr(O), evalCompareLess(S),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
                                                               atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp), % write("id: "), write(NIdOut), write(" Exp: "), write(NExp), 
                                                               ((NIdOut < NExp) -> !, EnvOut = EnvIn; evalCondition(Z, EnvIn3, EnvOut)).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																															 evalOr(O), evalCompareLE(S),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
                                                               atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut =< NExp) -> !, EnvOut = EnvIn; evalCondition(Z, EnvIn3, EnvOut)).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																															 evalOr(O), evalCompareGreater(S),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
                                                               atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp), % write("id: "), write(NIdOut), write(" Exp: "), write(NExp),
                                                               ((NIdOut > NExp) -> !, EnvOut = EnvIn; evalCondition(Z, EnvIn3, EnvOut)).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																															 evalOr(O), evalCompareGE(S),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
                                                               atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut >= NExp) -> !, EnvOut = EnvIn; evalCondition(Z, EnvIn3, EnvOut)).
evalCondition(t_multiplecond(X, S, Y, O, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, _, EnvIn, EnvIn2),
																															 evalOr(O), evalCompareEqual(S),
                                                               evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),
                                                               atom_string(IdOutput, Qstring),
				 																											 atom_number(Qstring, NIdOut),
				 																											 atom_string(ExpOutput, QExp),
				 																											 atom_number(QExp, NExp),
                                                               ((NIdOut =:= NExp) -> !, EnvOut = EnvIn; evalCondition(Z, EnvIn3, EnvOut)).

% Rules to evaluate comparision tokens and logic operators.
evalCompareLE(t_lesserequal(<=)).
evalCompareGE(t_greaterequal(>=)).
evalCompareEqual(t_equal(==)).
evalCompareGreater(t_greater(>)).
evalCompareLess(t_lesser(<)).
evalNot(t_condnot(not)).
evalAnd(t_condand(and)).
evalOr(t_condor(or)). 															