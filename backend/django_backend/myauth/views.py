from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated,AllowAny
from api.models import User
from rest_framework.response import Response

# Create your views here.

'''
JWT implementation
New API Jayraj
'''

class LoginView(APIView):
    permission_classes = (AllowAny,)
    def post(self,request):
        email = request.data.get('email')
        password = request.data.get('password')

        user = User.objects.filter(email=email).first()
        if user is None:
            return Response({'error':"user not found"},status=status.HTTP_400_BAD_REQUEST)

        if user is None or not user.check_password(password):
            return Response({'error': 'Invalid username or password'}, status=status.HTTP_401_UNAUTHORIZED)

        refresh = RefreshToken.for_user(user)
        return Response({
            'access_token': str(refresh.access_token),
            'refresh_token': str(refresh),
        })
