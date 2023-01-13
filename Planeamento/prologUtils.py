from swiplserver import *
import json 
def melhorRotaAlg(nomeCamiao, listEntregasID):
    with PrologMQI() as mqi:
        with mqi.create_thread() as prolog_thread:
            prolog_thread.query("set_prolog_flag(encoding,utf8).")
            prolog_thread.query("consult(\"./DataBase.pl\").")
            prolog_thread.query("consult(\"./Planeamento.pl\").")

            listEntregasIDPL = '[' + ', '.join(str(entregaID) for entregaID in listEntregasID) + ']'
            
            return prolog_thread.query("rotaMaisRapida('" + nomeCamiao + "', " + listEntregasIDPL + ", Rota)")




def heuristicas(heuristica, data):
    with PrologMQI() as mqi:
        with mqi.create_thread() as prolog_thread:
            prolog_thread.query("set_prolog_flag(encoding,utf8).")
            prolog_thread.query("consult(\"./DataBase.pl\").")
            prolog_thread.query("consult(\"./heuristica.pl\").")
            print("heuristica")
            #listArmazensIDPL = '[' + ', '.join(str(armazemID) for armazemID in listArmazensID) + ']'
        
            if heuristica == "distancia" :
                #bestfsDistancia(ListaArmazens, Final)
                #listaJson = prolog_thread.query("atribuirArmazensCamiao('" + nomeCamiao + "', " + str(data) + ", ListaArmazens)")
                #lista = json.dumps(listaJson)
                #caminho = 'lista.index(0)'
                #print(lista.index(0))
                #return prolog_thread.query("bestfsDistancia(" + caminho + ", CaminhoFinal)")
                print("distancia")
                return prolog_thread.query("resultadosDasDistancias(" + str(data) + ", CaminhoFinal)")
            
            if heuristica == "massa" :
                #bestfsMassa(ListaArmazens, Data, Final)
                #return prolog_thread.query("bestfsMassa(" + listArmazensIDPL + "," + str(data) + ", CaminhoFinal)")
                print("heuristica")
                return prolog_thread.query("resultadosDaMassa(" + str(data) + ", CaminhoFinal)")

            
            if heuristica == "combinada" :
                #bestfsDistancia(ListaArmazens, Final)
                #return prolog_thread.query("bestfsMassaDistancia(" + listArmazensIDPL + ", " + str(data) + ", CaminhoFinal)")
                return prolog_thread.query("resultadosCombinados(" + str(data) + ", CaminhoFinal)")



def atribuirArmazensCamiao(nomeCamiao, data):
    with PrologMQI() as mqi:
        with mqi.create_thread() as prolog_thread:
            prolog_thread.query("set_prolog_flag(encoding,utf8).")
            prolog_thread.query("consult(\"./heuristica.pl\").")

        return prolog_thread.query("atribuirArmazensCamiao('" + nomeCamiao + "', " + str(data) + ", ListaArmazens)")



