from django.urls import path
from myauth.views import *

urlpatterns = [
    path('login',LoginView.as_view(),name='login'),
]