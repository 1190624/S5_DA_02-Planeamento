resultadosDasDistancias(Data, Final):- 
findall(Armazem, 
(entregaData(_,Data,_, Armazem,_,_), Armazem \== 5),
ListaArmazens), 
bestfsDistancia(ListaArmazens, ListaId), convertIdParaNome(ListaId, Final).

resultadosDaMassa(Data, Final):- 
findall(Armazem, 
(entregaData(_,Data,_, Armazem,_,_), Armazem \== 5),
ListaArmazens), 
bestfsMassa(ListaArmazens, Data, ListaId), convertIdParaNome(ListaId, Final).


resultadosCombinados(Data, Final):- 
findall(Armazem, 
(entregaData(_,Data,_, Armazem,_,_), Armazem \== 5),
ListaArmazens), 
bestfsMassaDistancia(ListaArmazens, Data, ListaId), convertIdParaNome(ListaId, Final).


convertIdParaNome(ListaId, ListaNome):- converter(ListaId, [], ListaNome).

converter([],Lista, ListaNome):- !,reverse(Lista, ListaNome).

converter(ListId, Lista, ListaNome):-
    ListId = [First|Res],
    armazemData(Nome, First), converter(Res, [Nome|Lista], ListaNome).

retornarEntregas(ListaArmazens, Data, ListaEntregas):-
ListaArmazens =[Armazem |_],
findall(Entrega, 
(entregaData(Entrega,Data,_, Armazem,_,_)),
ListaEntregas).

%HeuristcaMenorDistancia
bestfsDistancia(ListaArmazens, Final):- 
    armazemPrincipalID(ArmazemAtual),
    bestfs1(ListaArmazens, [ArmazemAtual], CaminhoFinal), 
    append(CaminhoFinal, [ArmazemAtual], Final).

bestfs1([],Cam, CaminhoFinal):-  !,
    reverse(Cam, CaminhoFinal).

bestfs1(ListaArmazens, Cam, CaminhoFinal):-
    Cam = [ArmazemAtual|_],
    findall((Dist,[ArmazemDest| Cam]), 
    (armazenDistData(ArmazemAtual,ArmazemDest,Dist), armazemData(_,ArmazemDest), member(ArmazemDest, ListaArmazens)),
    Novos),

    sort(Novos,NovosOrd),
   
    NovosOrd = [(_,[Atual|_])|_],
    
    delete(ListaArmazens, Atual, ArmazensRestantes),
    bestfs1(ArmazensRestantes, [Atual|Cam], CaminhoFinal).

%HeuristicaMaiorMassa
bestfsMassa(ListaArmazens, Data, Final):- ArmazemAtual is 5,
    bestfs2(ListaArmazens, Data, [ArmazemAtual], CaminhoFinal), 
    append(CaminhoFinal, [5], Final).

bestfs2([],_,Cam, CaminhoFinal):- !,
    reverse(Cam, CaminhoFinal).

bestfs2(ListaArmazens, Data, Cam, CaminhoFinal):-
    findall((Massa,[Armazem| Cam]), 
    (member(Armazem, ListaArmazens), entregaData(_,Data,Massa,Armazem,_,_), armazemData(_,Armazem)),
    Novos),


    %sort(+Key, +Order, +List, -Sorted)
    sort(0, @>=, Novos, NovosOrd),

    NovosOrd = [(_,[Atual|_])|_],
    delete(ListaArmazens, Atual, ArmazensRestantes),
    bestfs2(ArmazensRestantes, Data, [Atual|Cam], CaminhoFinal).


%HeuristicaMelhorRelacao
%MassaDividirDistancia

bestfsMassaDistancia(ListaArmazens, Data, Final):- ArmazemAtual is 5,
    bestfs3(ListaArmazens, Data, [ArmazemAtual], CaminhoFinal), 
    append(CaminhoFinal, [5], Final).


bestfs3([],_,Cam, CaminhoFinal):- !,
    reverse(Cam, CaminhoFinal).

bestfs3(ListaArmazens, Data, Cam, CaminhoFinal):-
    Cam = [ArmazemAtual|_],
    findall((Relacao,[ArmazemProximo| Cam]), 
    (armazenDistData(ArmazemAtual,ArmazemProximo,Distancia), member(ArmazemProximo, ListaArmazens), entregaData(_,Data,Massa,ArmazemProximo,_,_), armazemData(_,ArmazemProximo), Relacao is Massa/Distancia),
    Novos),

    sort(0, @>=, Novos, NovosOrd),
    NovosOrd = [(_,[Atual|_])|_],
    delete(ListaArmazens, Atual, ArmazensRestantes),
    bestfs3(ArmazensRestantes, Data, [Atual|Cam], CaminhoFinal).