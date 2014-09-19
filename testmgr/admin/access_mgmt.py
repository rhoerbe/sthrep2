# from django.contrib import admin
# from django.contrib.auth.admin import UserAdmin
# from django.contrib.auth.models import User
# from testmgr.models import *
# from testmgr.admin.common import *
#
# class UserProfileInline(admin.StackedInline):
#     model = UserProfile
#     list_per_page = PAGING_SIZE
#     filter_horizontal = ('testplan',)
#
#
# class CustomUserAdmin(UserAdmin):
#     #filter_horizontal = ('user_permissions', 'groups', 'ope')
#     list_per_page = PAGING_SIZE
#     save_on_top = True
#     list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'last_login')
#     inlines = [UserProfileInline]
#
#
# admin.site.unregister(User)
# admin.site.register(User, CustomUserAdmin)
