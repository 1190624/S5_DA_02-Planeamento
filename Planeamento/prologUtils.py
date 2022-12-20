from swiplserver import *

def melhorRotaAlg(nomeCamiao, listEntregasID):
    with PrologMQI() as mqi:
        with mqi.create_thread() as prolog_thread:
            prolog_thread.query("set_prolog_flag(encoding,utf8).")
            prolog_thread.query("consult(\"./DataBase.pl\").")
            prolog_thread.query("consult(\"./Planeamento.pl\").")

            listEntregasIDPL = '[' + ', '.join(str(entregaID) for entregaID in listEntregasID) + ']'
            
            return prolog_thread.query("rotaMaisRapida('" + nomeCamiao + "', " + listEntregasIDPL + ", Rota)")