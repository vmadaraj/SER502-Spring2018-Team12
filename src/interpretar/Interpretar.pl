% @authors {Shirisha}, @version 1.0
% @authors {Shirisha}, @version 1.1
% @purpose Interpretar
% @date 04/22/2018


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