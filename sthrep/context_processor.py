# enable this middleware in settings
def session(request):
    if hasattr(request, 'session'):
        return {'session': request.session}
    return {}