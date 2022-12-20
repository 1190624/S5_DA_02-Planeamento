from django.shortcuts import render
from django.http import HttpResponse
from .prologUtils import melhorRotaAlg

import json

def getMelhorRota(request):
    requestData = json.loads(request.body)
    listEntregasID = []

    for entregaID in requestData["ListaEntregasID"]:
        listEntregasID.append(entregaID["ID"])

    return HttpResponse(melhorRotaAlg(requestData["NomeCamiao"], listEntregasID))