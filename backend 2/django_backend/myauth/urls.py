from django.urls import path
from myauth.views import *

urlpatterns = [
    path("login", LoginView.as_view(), name="login"),
    path("refresh_token",RefreshMyToken.as_view(),name='refresh_token'),
]
