from django.contrib import admin

# set default not to show an action with delete items as action.
if 'delete_selected' in admin.site.actions:
    admin.site.disable_action('delete_selected')
# it can be re-enabled for a specific changelist with actions = ['delete_selected',]


PAGING_SIZE = 15
