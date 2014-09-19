from django.shortcuts import render, render_to_response, redirect

__author__ = 'Rainer Hoerbe'


def bye(request):
    return render(request, 'bye.html')

def doc(request):
    return render(request, 'doc/doc.html')

def workflow(request):
    return render(request, 'doc/workflow.html')

def testplan(request):
    return render(request, 'doc/testplan.html')

def operation(request):
    return render(request, 'doc/operation.html')

