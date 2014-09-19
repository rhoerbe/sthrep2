def get_teaser(longtext, textlen=50):
    '''
    return the leading part of a long text field, breaking at word boundaries (blank)
    '''
    if longtext == '' or longtext is None:
        return ''
    else:
        if len(str(longtext)) <= (textlen + 1):
            return str(longtext)[0:textlen]
        else:
            lastblank = longtext[0:textlen-5].rfind(' ')
            if lastblank > textlen/2:
                return str(longtext)[0:lastblank] + ' (...)'
