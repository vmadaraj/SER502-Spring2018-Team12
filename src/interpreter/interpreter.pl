% @authors {Shirisha}, @version 1.0
% @purpose Interpretar
% @date 04/20/2018


evalAssign(t_assignment(X,Y), EnvIn, EnvOut) :- evalExpression(Y, Output, EnvIn, EnvOut), update(X, Output, EnvIn, EnvOut).



evalIfelse(t_if(X, Y), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvOut), evalStatements(Y, EnvIn, EnvOut).

evalIfelse(t_if(X, _), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), EnvOut is EnvIn.

evalIfelse(t_ifelse(X, If, _), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvOut), evalStatements(If, EnvIn, EnvOut).

evalIfelse(t_ifelse(X, _, Else), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), evalStatements(Else, EnvIn, EnvOut).



evalWhile(t_while(X, While), EnvIn, EnvOut) :- evalCondition(X, EnvIn, EnvIn2), evalStatements(While, EnvIn2, EnvIn3),

                                              evalWhile(t_while(X, While), EnvIn3, EnvOut).

evalWhile(t_while(X, _), EnvIn, EnvOut) :- /+ evalCondition(X, EnvIn, EnvOut), EnvOut is EnvIn.



