from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, AllowAny
from api.models import User
from rest_framework.response import Response
from rest_framework import status

# Create your views here.

"""
JWT implementation
New API Jayraj
"""


class LoginView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        user = User.objects.filter(email=email).first()
        if user is None:
            jsonresponse = {"ok": False, "error": "user not found"}
            return Response(jsonresponse, status=status.HTTP_400_BAD_REQUEST)

        if user is None or not user.check_password(password):
            jsonresponse={'ok':False,"error": "Invalid username or password"}
            return Response(
                jsonresponse,
                status=status.HTTP_401_UNAUTHORIZED,
            )

        refresh = RefreshToken.for_user(user)

        jsonresponse={
            "ok":True,
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh),
            "type":str(user.type),
            }
        print(jsonresponse)
        print(user.type)
        return Response(
            jsonresponse,
            status=status.HTTP_200_OK
        )
    
class RefreshMyToken(APIView):
    permission_classes = (AllowAny,)
    def post(self,request):
        refresh_token = request.data.get('refresh_token')

        if not refresh_token:
            return Response({'error': 'Refresh token is missing'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            token = RefreshToken(refresh_token)
            access_token = str(token.access_token)
            return Response({'access_token': access_token}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
