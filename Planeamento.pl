%pesoEntregas(+ListEntregasID, -ListPesos)
pesoEntregas(ListEntregasID, ListPesos):-
    pesoEntregasAcc(ListEntregasID, ListPesos, _).

%pesoEntregasAcc(+ListEntregasID, -ListPesos, +Acc)
pesoEntregasAcc([], [], 0).

pesoEntregasAcc([Head1|Tail1], [Acc|Tail2], Acc):-
    pesoEntregasAcc(Tail1, Tail2, TempVar),
    entregaData(Head1, _, Massa, _, _, _),
    Acc is TempVar + Massa.

%pesoTotal(+Tara, +ListPesos, -ListPesosTot)
pesoTotal(Tara, ListPesos, ListPesosTot):-
    pesoTotalAcc(Tara, ListPesos, ListPesosTot, _).

%pesoTotalAcc(+Tara, +ListPesos, -ListPesosTot, +Acc):-
pesoTotalAcc(Tara, [], [Tara], 0).

pesoTotalAcc(Tara, [Head1|Tail1], [PesoTot|Tail2], Acc):-
    pesoTotalAcc(Tara, Tail1, Tail2, AccTemp),
    TempVar is Tara + Head1,
    PesoTot is TempVar + AccTemp,
    Acc is Head1 + AccTemp.

%tempoRota(+NomeCamiao, +CurrBat, +Rota, +ListPesosTot, ListEntregasID, -Tempo)
tempoRota(_, _, [_|[]], [], [], 0).

tempoRota(NomeCamiao, CurrBat, [Head1A, Head1B|Tail1], [Head2|Tail2], [Head3|Tail3], Tempo):-
    camiaoData(NomeCamiao, Tara, CapCarga, CapBateria, _, TpsRecarregamento),
    CurrBat < CapCarga,
    camiaoTrajetoData(NomeCamiao, Head1A, Head1B, TempoMax, ConsumoMax, TempoAdd),
    calcMaxPeso(Tara, CapCarga, MaxPeso),
    calcConsumo(MaxPeso, Head2, ConsumoMax, ConsumoAtual),
    CurrBat - ConsumoAtual < (CapBateria * 20) / 100,
    EnergiaReq is ((CapBateria * 20) / 100) - CurrBat + ConsumoAtual,
    tempoRota(NomeCamiao, CurrBat + EnergiaReq - ConsumoAtual, [Head1B|Tail1], Tail2, Tail3, TempVar),
    calcTpsRecarregamento(CapBateria, EnergiaReq, TpsRecarregamento, TpsRecarregamentoAtual),
    calcTempo(MaxPeso, Head2, TempoMax, TempoAtual),
    Tempo is TempoAtual + TempoAdd + TpsRecarregamentoAtual + TempVar + Head3.

tempoRota(NomeCamiao, CurrBat, [Head1A, Head1B|Tail1], [Head2|Tail2], [Head3|Tail3], Tempo):-
    camiaoData(NomeCamiao, Tara, CapCarga, CapBateria, _, _),
    CurrBat < CapCarga,
    camiaoTrajetoData(NomeCamiao, Head1A, Head1B, TempoMax, ConsumoMax, TempoAdd),
    calcMaxPeso(Tara, CapCarga, MaxPeso),
    calcConsumo(MaxPeso, Head2, ConsumoMax, ConsumoAtual),
    CurrBat - ConsumoAtual >= (CapBateria * 20) / 100,
    tempoRota(NomeCamiao, CurrBat - ConsumoAtual, [Head1B|Tail1], Tail2, Tail3, TempVar),
    calcTempo(MaxPeso, Head2, TempoMax, TempoAtual),
    Tempo is TempoAtual + TempoAdd + TempVar + Head3.

tempoRota(NomeCamiao, CurrBat, [Head1A, Head1B|Tail1], [Head2|Tail2], [Head3|Tail3], Tempo):-
    camiaoData(NomeCamiao, Tara, CapCarga, _, _, _),
    CurrBat =:= CapCarga,
    camiaoTrajetoData(NomeCamiao, Head1A, Head1B, TempoMax, ConsumoMax, _),
    calcMaxPeso(Tara, CapCarga, MaxPeso),
    calcConsumo(MaxPeso, Head2, ConsumoMax, ConsumoAtual),
    tempoRota(NomeCamiao, CurrBat - ConsumoAtual, [Head1B|Tail1], Tail2, Tail3, TempVar),
    calcTempo(MaxPeso, Head2, TempoMax, TempoAtual),
    Tempo is TempoAtual + TempVar + Head3.

%calcMaxPeso(+Tara, +CapCarga, -MaxPeso)
calcMaxPeso(Tara, CapCarga, MaxPeso):-
    MaxPeso is Tara + CapCarga.

%calcTempo(+MaxPeso, +PesoAtual, +TempoMax, -TempoAtual)
calcTempo(MaxPeso, PesoAtual, TempoMax, TempoAtual):-
    TempoAtual is (PesoAtual * TempoMax) / MaxPeso.

%calcConsumo(+MaxPeso, +PesoAtual, +ConsumoMax, -ConsumoAtual)
calcConsumo(MaxPeso, PesoAtual, ConsumoMax, ConsumoAtual):-
    ConsumoAtual is (PesoAtual * ConsumoMax) / MaxPeso.

%calcTpsRecarregamento(?CapBateria, ?EnergiaReq, ?TpsRecarregamento, ?TpsRecarregamentoAtual)
calcTpsRecarregamento(CapBateria, EnergiaReq, TpsRecarregamento, TpsRecarregamentoAtual):-
    MinCapBateria is (CapBateria * 20) / 100,
    MaxCapBateria is (CapBateria * 80) / 100,
    TpsRecarregamentoAtual is (EnergiaReq * TpsRecarregamento) / (MaxCapBateria - MinCapBateria).

%calcArmazens(?ListEntregasID, ?ListArmazemID)
calcArmazens([], []).

calcArmazens([Head|Tail], ListArmazemID):-
    calcArmazens(Tail, TempList),
    entregaData(Head, _, _, ArmazemID, _, _),
    append([ArmazemID], TempList, ListArmazemID).

%calcRotas(+NomeCamiao, +ListEntregasID, -ListRotas)
calcRotas(NomeCamiao, ListEntregasID, ListRotas):-
    findall((Tempo, Rota), 
        (calcArmazens(ListEntregasID, ListArmazemID),
        pesoEntregas(ListEntregasID, ListPesos),
        camiaoData(NomeCamiao, Tara, _, CapBateria, _, _),
        pesoTotal(Tara, ListPesos, ListPesosTot),
        permutation(ListArmazemID, PermListArmazemID),
        armazemPrincipalID(ArmazemID),
        append([ArmazemID|PermListArmazemID], [ArmazemID], Rota),
        calcTempoRet(ListEntregasID, ListTempRet),
        tempoRota(NomeCamiao, CapBateria, Rota, ListPesosTot, ListTempRet, TempTempo),
        calcTempoTotalColoc(ListEntregasID, TempoTotal),
        Tempo is TempTempo + TempoTotal),
        ListRotas).

%calcTempoTotalColoc(?ListEntregasID, ?TempoTotal)
calcTempoTotalColoc([], 0).

calcTempoTotalColoc([Head|Tail], TempoTotal):-
    calcTempoTotalColoc(Tail, TempVar),
    entregaData(Head, _, _, _, TempoColoc, _),
    TempoTotal is TempoColoc + TempVar.

%calcTempoRet(?ListEntregasID, ?ListTempRet)
calcTempoRet([], [0]).

calcTempoRet([Head1|Tail1], ListTempRet):-
    calcTempoRet(Tail1, TempList),
    entregaData(Head1, _, _, _, _, TempoRet),
    append([TempoRet], TempList, ListTempRet).

%Dado um camião e uma lista de entregas, calculada a rota com menor tempo gasto para o serviço
rotaMaisRapida(NomeCamiao,ListEntregasID,Rota):-
    calcRotas(NomeCamiao, ListEntregasID, ListRotas),
    sort(ListRotas, TempList),
    TempList = [(_, Rota)|_].

%Calcular o tempo de execução da rota mais rápida tendo em conta o tamanho do input
tempoExecucao(NomeCamiao,ListEntregasID,Tempo):-
    get_time(Ti),
    calcRotas(NomeCamiao, ListEntregasID, _),
    get_time(Tf),
    Tempo is Tf-Ti.

%tempoRotaMaisRapida (apresenta o tempo que demora a percorrer a rota mais rapida)
tempoRotaMaisRapida(NomeCamiao,ListEntregasID,Rota,Tempo):-
    calcRotas(NomeCamiao, ListEntregasID, ListRotas),
    sort(ListRotas, TempList),
    TempList = [(Tempo, Rota)|_].
