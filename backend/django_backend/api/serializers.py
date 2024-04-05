from django.contrib.auth import get_user_model
from rest_framework import serializers
from django.contrib.auth.models import User
# from rest_framework.validators import UniqueTogetherValidator

from .models import * # Import all the models in this app


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'password', 'email']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        # fields = ['id','st_name','email']
        # to add all fields use
        fields = '__all__'

class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = '__all__'

class ProgramSerializer(serializers.ModelSerializer):
    class Meta:
        model = Program
        fields = '__all__'

class GuardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Guard
        fields = '__all__'

class AdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = '__all__'
class AuthoritiesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Authorities
        # fields = ['id','st_name','email']
        # to add all fields use
        fields = '__all__'
class AdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        # fields = ['id','st_name','email']
        # to add all fields use
        fields = '__all__'

class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = '__all__'

class PersonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Person
        fields = '__all__'

class PasswordSerializer(serializers.ModelSerializer):
    class Meta:
        model = Password
        fields = '__all__'
        
class OTPSerializer(serializers.ModelSerializer):
    class Meta:
        model = OTP
        fields = '__all__'

class TicketTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketTable
        fields = '__all__'

class AuthoritiesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Authorities
        fields = '__all__'
        
class AuthoritiesTicketTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuthoritiesTicketTable
        fields = '__all__'
        
class StatusTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = StatusTable
        fields = '__all__'
        
class HostelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hostel
        fields = '__all__'

class VisitorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Visitor
        fields = '__all__'
    
class VisitorTicketTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = VisitorTicketTable
        fields = '__all__'

class NotificationTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationTable
        fields = '__all__'

class InviteRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = InviteRequest
        fields = '__all__'