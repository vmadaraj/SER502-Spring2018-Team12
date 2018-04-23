% @authors {Shirisha}, @version 1.0
% @authors {Divya Yadamreddi}, @version 1.1
% @purpose Interpreter
% @date 04/22/2018

lookup(_,[],0).

lookup(X,[(X, V)|_],V).

lookup(X,[_|T],V) :- lookup(X,T,V).



update(X,V,[],[(X,V)]).

update(X,V,[(X,_)|T],[(X,V)|T]).

update(X,V,[H|T],[H|T1]) :- update(X,V,T,T1).



evalParser(t_parser(K), EnvIn, EnvOut) :- evalProgram(K, EnvIn, EnvOut).



evalProgram(t_commentprog(_, Y), EnvIn, EnvOut) :- evalBlock(Y, EnvIn, EnvOut).

evalProgram(t_program(X), EnvIn, EnvOut) :- evalBlock(X, EnvIn, EnvOut).



evalBlock(t_block(X), EnvIn, EnvOut) :- evalDeclaration(X, EnvIn, EnvOut).

evalBlock(t_blockstatements(X, Y), EnvIn, EnvOut) :- evalDeclaration(X, EnvIn, EnvOut), evalStatements(Y, EnvIn, EnvOut).



evalDeclaration(t_declaration(X), EnvIn, EnvOut) :- evalDeclarationTemp(X, EnvIn, EnvOut).

evalDeclaration(t_declaration(X, Y), EnvIn, EnvOut) :- evalDeclarationTemp(X, EnvIn, EnvOut), evalDeclaration(Y).

evalDeclarationTemp(t_constant(_,Y,Z), EnvIn, EnvOut) :- update(Y, Z, EnvIn, EnvOut).

evalDeclarationTemp(t_variable(_), EnvIn, EnvOut).



evalStatements(t_statements(X), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvOut).

evalStatements(t_statements(X,Y), EnvIn, EnvOut) :- evalAllStatements(X, EnvIn, EnvOut), evalStatements(Y, EnvIn, EnvOut).

evalAllStatements(t_assign(X), EnvIn, EnvOut) :- evalAssign(X, EnvIn, EnvOut).

evalAllStatements(t_ifelseBlock(X), EnvIn, EnvOut) :- evalIfelse(X, EnvIn, EnvOut).

evalAllStatements(t_whileBlock(X), EnvIn, EnvOut) :- evalWhile(X, EnvIn, EnvOut).
evalAssign(t_assignment(X,Y), EnvIn, EnvOut) :- evalExpression(Y, Output, EnvIn, EnvOut), update(X, Output, EnvIn, EnvOut).



evalIfelse(t_if(X, Y), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvOut), evalStatements(Y, EnvIn, EnvOut).

evalIfelse(t_if(X, _), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), EnvOut is EnvIn.

evalIfelse(t_ifelse(X, If, _), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvOut), evalStatements(If, EnvIn, EnvOut).

evalIfelse(t_ifelse(X, _, Else), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), evalStatements(Else, EnvIn, EnvOut).



evalWhile(t_while(X, While), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvIn2), evalStatements(While, EnvIn2, EnvIn3),

                                              evalWhile(t_while(X, While), EnvIn3, EnvOut).

evalWhile(t_while(X, _), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), EnvOut is EnvIn.



evalCondition(t_singlecond(X, >, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                      evalExpression(Z, ExpOutput, EnvIn, EnvOut),

                                                      IdOutput > ExpOut.

evalCondition(t_singlecond(X, <, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                      evalExpression(Z, ExpOutput, EnvIn, EnvOut),

                                                      IdOutput < ExpOut.

evalCondition(t_singlecond(X, >=, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                      evalExpression(Z, ExpOutput, EnvIn, EnvOut),

                                                      IdOutput >= ExpOut.

evalCondition(t_singlecond(X, <=, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                      evalExpression(Z, ExpOutput, EnvIn, EnvOut),

                                                      IdOutput <= ExpOut.

evalCondition(t_singlecond(X, ==, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                      evalExpression(Z, ExpOutput, EnvIn, EnvOut),

                                                      IdOutput =:= ExpOut.

evalCondition(t_notcondition(not, X, >, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                              evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                              IdOutput <= ExpOutput.

evalCondition(t_notcondition(not, X, <, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                              evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                              IdOutput >= ExpOutput.

evalCondition(t_notcondition(not, X, >=, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                              evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                              IdOutput < ExpOutput.

evalCondition(t_notcondition(not, X, <=, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                              evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                              IdOutput > ExpOutput.

evalCondition(t_notcondition(not, X, ==, Y), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                              evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                              IdOutput /= ExpOutput.

evalCondition(t_multiplecond(X, >, Y, and, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput > ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, <, Y, and, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput < ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, >=, Y, and, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput >= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, <=, Y, and, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput <= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, ==, Y, and, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput =:= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, >, Y, or, _), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                                IdOutput > ExpOutput.

evalCondition(t_multiplecond(X, >, Y, or, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput <= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, <, Y, or, _), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                                IdOutput < ExpOutput.

evalCondition(t_multiplecond(X, <, Y, or, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput >= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, >=, Y, or, _), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                                IdOutput >= ExpOutput.

evalCondition(t_multiplecond(X, >=, Y, or, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput < ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, <=, Y, or, _), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                                IdOutput <= ExpOutput.

evalCondition(t_multiplecond(X, <=, Y, or, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput > ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).

evalCondition(t_multiplecond(X, ==, Y, or, _), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvOut),

                                                                IdOutput =:= ExpOutput.

evalCondition(t_multiplecond(X, ==, Y, or, Z), EnvIn, EnvOut) :- evalIdentifier(X, IdOutput, EnvIn, EnvIn2),

                                                                evalExpression(Y, ExpOutput, EnvIn2, EnvIn3),

                                                                IdOutput /= ExpOutput,

                                                                evalCondition(Z, EnvIn3, EnvOut).



evalIdentifier(t_identifier(X), Output, EnvIn, EnvIn) :- lookup(X, EnvIn, Output).
