from django.shortcuts import render
from django.http import HttpResponse
from .prologUtils import melhorRotaAlg, heuristicas, atribuirArmazensCamiao

import json

def getMelhorRota(request):
    requestData = json.loads(request.body)
    listEntregasID = []

    for entregaID in requestData["ListaEntregasID"]:
        listEntregasID.append(entregaID["ID"])

    return HttpResponse(melhorRotaAlg(requestData["NomeCamiao"], listEntregasID))



def getHeuristicas(request):
    requestData = json.loads(request.body)


    return HttpResponse(heuristicas(requestData["Heuristica"], requestData["Data"]))

def getArmazens(request):
    requestData = json.loads(request.body)

    return HttpResponse(atribuirArmazensCamiao(requestData["Camiao"], requestData["Data"]))