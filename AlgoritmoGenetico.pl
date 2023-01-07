%gera
initAlgGen(NumGens, DimPop, Valor1, Valor2, TempoIdeal, TempoExec, NumGensPrev, DataEntrega):-
	(retract(geracoes(_)), !; true), asserta(geracoes(NumGens)),
	(retract(populacao(_)), !; true), asserta(populacao(DimPop)),
	ProbCruz is Valor1 / 100,
	(retract(prob_cruzamento(_)), !; true), asserta(prob_cruzamento(ProbCruz)),
	ProbMuta is Valor2 / 100,
	(retract(prob_mutacao(_)), !; true), asserta(prob_mutacao(ProbMuta)),
	(retract(tempoIdeal(_)), !; true), asserta(tempoIdeal(TempoIdeal)),
	(retract(maxTempoExec(_)), !; true), asserta(maxTempoExec(TempoExec)),
	(retract(numGensPrev(_)), !; true), asserta(numGensPrev(NumGensPrev)),
	(retract(dataEntrega(_)), !; true), asserta(dataEntrega(DataEntrega)),
	get_time(InitTempoExec),
	(retract(initTempoExec(_)), !; true), asserta(initTempoExec(InitTempoExec)),
	dataEntrega(Data),
	findall(ArmazemID, entregaData(_, Data, _, ArmazemID, _, _), ListaTemp),
	armazemPrincipalID(ArmazemID),
	removeElemLista(ArmazemID, ListaTemp, ListaArmazens),
	length(ListaArmazens, NumElem),
	(retract(numEntregas(_)), !; true), asserta(numEntregas(NumElem)),
	geraPopulacao(Pop),
	write('Pop='),write(Pop),nl,
	avaliacaoPopulacao(Pop,PopAv),
	write('PopAv='),write(PopAv),nl,
	ordenaPopulacao(PopAv,PopOrd),
	geracoes(NG),
	geraGeracao(0,NG,PopOrd,[PopOrd]).

%geraPopulacao(-Lista)
geraPopulacao(Pop):-
	populacao(TamPop),
	findall(ArmazemID, entregaData(_, _, _, ArmazemID, _, _), ListaTemp),
	armazemPrincipalID(ArmazemID),
	removeElemLista(ArmazemID, ListaTemp, ListaArmazens),
	length(ListaArmazens, NumElem),
	geraPopulacaoRec(TamPop,ListaArmazens,NumElem,Pop).

%removeElemLista(+Elem, +Lista, -NovaLista)
removeElemLista(_, [], []).

removeElemLista(Elem, [Elem|Tail], NovaLista):-
	!,
	removeElemLista(Elem, Tail, NovaLista).

removeElemLista(Elem, [Head|Tail1], [Head|Tail2]):-
	removeElemLista(Elem, Tail1, Tail2).

%geraPopulacaoRec(+TamPop, +Lista, +NumElem, -Pop)
geraPopulacaoRec(2,ListaArmazens,_,Lista):-
	!,
	bestfsDistancia(ListaArmazens, ListaTemp1),
	dataEntrega(Data),
	bestfsMassa(ListaArmazens, Data, ListaTemp2),
	removeElemLista(ArmazemID,ListaTemp1, ListaTemp3),
	removeElemLista(ArmazemID,ListaTemp2, ListaTemp4),
	not(igual(ListaTemp3, ListaTemp4)),
	append([ListaTemp3], [ListaTemp4], Lista).

geraPopulacaoRec(2, ListaArmazens, _, Lista):-
	!,
	bestfsDistancia(ListaArmazens, ListaTemp1),
	dataEntrega(Data),
	bestfsMassa(ListaArmazens, Data, ListaTemp2),
	armazemPrincipalID(ArmazemID),
	removeElemLista(ArmazemID,ListaTemp1, ListaTemp3),
	removeElemLista(ArmazemID,ListaTemp2, ListaTemp4),
	igual(ListaTemp3, ListaTemp4),
	reverse(ListaTemp4, ListaTemp5),
	append([ListaTemp4], [ListaTemp5], Lista).

geraPopulacaoRec(TamPop,ListaArmazens,NumElem,[Head|Tail]):-
	TamPop1 is TamPop-1,
	geraPopulacaoRec(TamPop1,ListaArmazens,NumElem,Tail),
	geraIndividuo(ListaArmazens,NumElem,Head),
	not(member(Head,Tail)).

%igual(?Elem1, ?Elem2)
igual(Elem, Elem).

%geraIndividuo(+Lista, +NumElem, -Lista)
geraIndividuo([G],1,[G]):-!.

geraIndividuo(ListaArmazens,NumT,[G|Resto]):-
	NumTemp is NumT + 1,
	random(1,NumTemp,N),
	retira(N,ListaArmazens,G,NovaLista),
	NumT1 is NumT-1,
	geraIndividuo(NovaLista,NumT1,Resto).

%retira(+PosElem, +Lista, -Elem, -Tail)
retira(1,[G|Resto],G,Resto):-!.

retira(N,[G1|Resto],G,[G1|Resto1]):-
	N1 is N-1,
	retira(N1,Resto,G,Resto1).

%avaliacaoPopulacao(+Pop, -AvalInd)
avaliacaoPopulacao([],[]):-!.

avaliacaoPopulacao([Head|Tail1],[Head*Aval|Tail2]):-
	calcTempoRota(Head, Aval),
	avaliacaoPopulacao(Tail1,Tail2).

%calcTempoRota(+Rota, -Tempo)
calcTempoRota([_|[]], 0):-!.

calcTempoRota([Head1, Head2|Tail], Tempo):-
	calcTempoRota([Head2|Tail], VarTemp),
	distancia(Head1, Head2, TempoMax),
	Tempo is VarTemp + TempoMax.

%ordenaPopulacao(+PopAval, -PopAvalOrd)
ordenaPopulacao(PopAval,PopAvalOrd):-
	bsort(PopAval,PopAvalOrd).

%bsort(+Lista, -ListaOrd)
bsort([X],[X]):-!.

bsort([X|Xs],Ys):-
	bsort(Xs,Zs),
	btroca([X|Zs],Ys).

%btroca(+Lista, -ListaOrd)
btroca([X],[X]):-!.

btroca([X*VX,Y*VY|L1],[Y*VY|L2]):-
	VX>VY,!,
	btroca([X*VX|L1],L2).

btroca([X|L1],[X|L2]):-btroca(L1,L2).

%geraGeracao(+Cnt, +NumGera, +PopOrd)
geraGeracao(G,G,Pop, _):-!,
	write('Geracao '), write(G), write(':'), nl, write(Pop), nl.

geraGeracao(N,G,Pop,PrevGens):-
	numGensPrev(NumGensPrev),
	not(verificarCondTerm(Pop, PrevGens, N, NumGensPrev)),
	random_permutation(Pop, PopPerm),
	cruzamento(PopPerm,PopCruz),
	mutacao(PopCruz,GenPop),
	removeElemDuplicados(GenPop, Pop, GenPopFinal),
	avaliacaoPopulacao(GenPopFinal,GenPopAval),
	append(GenPopAval, Pop, PopFinal),
	ordenaPopulacao(PopFinal,PopFinalOrd),
	populacao(TamPop),
	NumInd is (TamPop * 30) // 100,
	melhoresIndividuos(0,NumInd,PopFinalOrd,ListaMelhoresInd,RestoPop),
	selecaoInd(RestoPop, IndSelec, TamPop - NumInd),
	append(ListaMelhoresInd, IndSelec, NovaGen),
	ordenaPopulacao(NovaGen, NovaGenOrd),
	N >= NumGensPrev,
	!,
	retira(1,PrevGens, _, ListaTemp),
	append(ListaTemp, NovaGenOrd, NovaPrevLista),
	N1 is N+1,
	write('Geracao '), write(N), write(':'), nl, write(Pop), nl,
	geraGeracao(N1,G,NovaGenOrd, NovaPrevLista).

geraGeracao(N,G,Pop,PrevGens):-
	numGensPrev(NumGensPrev),
	not(verificarCondTerm(Pop, PrevGens, N, NumGensPrev)),
	random_permutation(Pop, PopPerm),
	cruzamento(PopPerm,PopCruz),
	mutacao(PopCruz,GenPop),
	removeElemDuplicados(GenPop, Pop, GenPopFinal),
	avaliacaoPopulacao(GenPopFinal,GenPopAval),
	append(GenPopAval, Pop, PopFinal),
	ordenaPopulacao(PopFinal,PopFinalOrd),
	populacao(TamPop),
	NumInd is (TamPop * 30) // 100,
	melhoresIndividuos(0,NumInd,PopFinalOrd,ListaMelhoresInd,RestoPop),
	selecaoInd(RestoPop, IndSelec, TamPop - NumInd),
	append(ListaMelhoresInd, IndSelec, NovaGen),
	ordenaPopulacao(NovaGen, NovaGenOrd),
	N < NumGensPrev,
	!,
	append(PrevGens, NovaGenOrd, NovaPrevGens),
	N1 is N+1,
	write('Geracao '), write(N), write(':'), nl, write(Pop), nl,
	geraGeracao(N1,G,NovaGenOrd, NovaPrevGens).

geraGeracao(N,_,Pop,PrevGens):-
	!,
	numGensPrev(NumGensPrev),
	verificarCondTerm(Pop, PrevGens, N, NumGensPrev).

%verificarCondTerm(+Pop)
verificarCondTerm(Pop, PrevGens, N, NumGensPrev):-
	verificarCondTempoIdeal(Pop);
	verificarCondTpsExec;
	N >= NumGensPrev,
	verificarCondEstab(Pop, PrevGens).

verificarCondTempoIdeal(Pop):-
	tempoIdeal(TempoIdeal),
	indTempoIdeal(Pop, TempoIdeal).
	
verificarCondTpsExec:-
	get_time(TpsExecAtual),
	initTempoExec(InitTempoExec),
	maxTempoExec(MaxTempoExec),
	InitTempoExec - TpsExecAtual >= MaxTempoExec.

verificarCondEstab(Pop, PrevGens):-
	verificarCondEstabRec(Pop, PrevGens).

verificarCondEstabRec(_, []):-
    !.

verificarCondEstabRec(Pop, [Pop|Tail]):-
	verificarCondEstabRec(Pop, Tail).

%indTempoIdeal(+Pop, +TempoIdeal)
indTempoIdeal([_*Aval|_], TempoIdeal):-
	Aval =< TempoIdeal.

indComTpsIdeal([_*Aval|Tail], TempoIdeal):-
	Aval >= TempoIdeal,
	indComTpsIdeal(Tail, TempoIdeal).

%removeElemDuplicados(+Lista1, +Lista2, -Lista3)
removeElemDuplicados([], _, []).

removeElemDuplicados([Head|Tail], Lista, NovaLista):-
	removeElemDuplicados(Tail, Lista, ListaTemp),
	not(member(Head, Lista)),
	append([Head], ListaTemp, NovaLista).

removeElemDuplicados([Head|Tail], Lista, NovaLista):-
	removeElemDuplicados(Tail, Lista, NovaLista),
	member(Head, Lista).

%melhoresIndividuos(+Cnt, +NumInd, +ListaOrd, -ListaNElem, -RestoLista)
melhoresIndividuos(Cnt, Cnt, [_|Tail], [], Tail):-!.

melhoresIndividuos(Cnt, NumInd, [Head|Tail1], [Head|Tail2], RestoLista):-
	Cnt1 is Cnt+1,
	melhoresIndividuos(Cnt1, NumInd, Tail1, Tail2, RestoLista).

%selecaoInd(+Pop, -IndSelec, +NumInd)
selecaoInd(Pop, IndSelec, NumInd):-
	calcRandAval(Pop, RandAvalPop),
	ordenaPopulacao(RandAvalPop, PopOrd),
	findall(Ind*Aval, (nth0(Cnt, PopOrd, Ind*_), Cnt < NumInd, recupAval(Pop, Ind, Aval)), IndSelec).

%calcRandAval(+Pop, -RandAvalPop)
calcRandAval([], []).

calcRandAval([Head*Aval|Tail1], [Head*NewAval|Tail2]):-
	random(0.0, 1.0, Valor),
	NewAval is Aval * Valor,
	calcRandAval(Tail1, Tail2).

%recupAval(+Pop, +Ind, -Aval)
recupAval([Ind*Aval|_], Ind, Aval):-
	!.

recupAval([_*_|Tail], Ind, Aval):-
	recupAval(Tail, Ind, Aval).

gerar_pontos_cruzamento(P1,P2):-
	gerar_pontos_cruzamento1(P1,P2).

gerar_pontos_cruzamento1(P1,P2):-
	numEntregas(NumElem),
	NTemp is NumElem+1,
	random(1,NTemp,P11),
	random(1,NTemp,P21),
	P11\==P21,!,
	((P11<P21,!,P1=P11,P2=P21);(P1=P21,P2=P11)).
gerar_pontos_cruzamento1(P1,P2):-
	gerar_pontos_cruzamento1(P1,P2).

cruzamento([],[]).
cruzamento([Ind*_],[Ind]).
cruzamento([Ind1*_,Ind2*_|Resto],[NInd1,NInd2|Resto1]):-
	gerar_pontos_cruzamento(P1,P2),
	prob_cruzamento(Pcruz),random(0.0,1.0,Pc),
	((Pc =< Pcruz,!,
        cruzar(Ind1,Ind2,P1,P2,NInd1),
	  cruzar(Ind2,Ind1,P1,P2,NInd2))
	;
	(NInd1=Ind1,NInd2=Ind2)),
	cruzamento(Resto,Resto1).

preencheh([],[]).

preencheh([_|R1],[h|R2]):-
	preencheh(R1,R2).


sublista(L1,I1,I2,L):-
	I1 < I2,!,
	sublista1(L1,I1,I2,L).

sublista(L1,I1,I2,L):-
	sublista1(L1,I2,I1,L).

sublista1([X|R1],1,1,[X|H]):-!,
	preencheh(R1,H).

sublista1([X|R1],1,N2,[X|R2]):-!,
	N3 is N2 - 1,
	sublista1(R1,1,N3,R2).

sublista1([_|R1],N1,N2,[h|R2]):-
	N3 is N1 - 1,
	N4 is N2 - 1,
	sublista1(R1,N3,N4,R2).

rotate_right(L,K,L1):-
	numEntregas(N),
	T is N - K,
	rr(T,L,L1).

rr(0,L,L):-!.

rr(N,[X|R],R2):-
	N1 is N - 1,
	append(R,[X],R1),
	rr(N1,R1,R2).


elimina([],_,[]):-!.

elimina([X|R1],L,[X|R2]):-
	not(member(X,L)),!,
	elimina(R1,L,R2).

elimina([_|R1],L,R2):-
	elimina(R1,L,R2).

insere([],L,_,L):-!.
insere([X|R],L,N,L2):-
	numEntregas(T),
	((N>T,!,N1 is N mod T);N1 = N),
	insere1(X,N1,L,L1),
	N2 is N + 1,
	insere(R,L1,N2,L2).


insere1(X,1,L,[X|L]):-!.
insere1(X,N,[Y|L],[Y|L1]):-
	N1 is N-1,
	insere1(X,N1,L,L1).

cruzar(Ind1,Ind2,P1,P2,NInd11):-
	sublista(Ind1,P1,P2,Sub1),
	numEntregas(NumT),
	R is NumT-P2,
	rotate_right(Ind2,R,Ind21),
	elimina(Ind21,Sub1,Sub2),
	P3 is P2 + 1,
	insere(Sub2,Sub1,P3,NInd1),
	eliminah(NInd1,NInd11).

eliminah([],[]).

eliminah([h|R1],R2):-!,
	eliminah(R1,R2).

eliminah([X|R1],[X|R2]):-
	eliminah(R1,R2).

mutacao([],[]).
mutacao([Ind|Rest],[NInd|Rest1]):-
	prob_mutacao(Pmut),
	random(0.0,1.0,Pm),
	((Pm < Pmut,!,mutacao1(Ind,NInd));NInd = Ind),
	mutacao(Rest,Rest1).

mutacao1(Ind,NInd):-
	gerar_pontos_cruzamento(P1,P2),
	mutacao22(Ind,P1,P2,NInd).

mutacao22([G1|Ind],1,P2,[G2|NInd]):-
	!, P21 is P2-1,
	mutacao23(G1,P21,Ind,G2,NInd).
mutacao22([G|Ind],P1,P2,[G|NInd]):-
	P11 is P1-1, P21 is P2-1,
	mutacao22(Ind,P11,P21,NInd).

mutacao23(G1,1,[G2|Ind],G2,[G1|Ind]):-!.
mutacao23(G1,P,[G|Ind],G2,[G|NInd]):-
	P1 is P-1,
	mutacao23(G1,P1,Ind,G2,NInd).