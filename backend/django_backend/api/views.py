# from .models import Student
# from .serializers import StudentSerializer
# Import all the models and serializers
import base64
import csv
import json
import os
import random
import traceback
from datetime import date, datetime, timedelta
from unicodedata import category
from django.contrib.auth.backends import BaseBackend
from django.utils import timezone
from rest_framework.views import APIView

from django.conf import settings
from django.core import serializers
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import *
from django.contrib.auth.models import User
from django.core.files.base import ContentFile
from django.core.mail import send_mail
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.decorators import (
    api_view,
    permission_classes,
    authentication_classes,
)
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny, BasePermission, IsAuthenticated
from rest_framework.renderers import JSONRenderer, TemplateHTMLRenderer
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import AccessToken
import jwt
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login
from functools import wraps
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.authentication import SessionAuthentication, BasicAuthentication

from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated, AllowAny
from .permissions import IsStudent


from .models import *
from .serializers import *
from .thread import *

from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from django.contrib.auth.models import update_last_login

# Password storing work
# encrypted = make_password("Vasu")
# check_password("Vasu", encrypted)


headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": True,
    "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
}
_Response = Response


def Response(*arg, **kwarg):
    return _Response(*arg, **kwarg, headers=headers)


initial_data = "initial_data"
blank_value = "None"
THREAD_ACTIVATED = False

# @api_view(['GET', 'POST'])
# def thread_functions(request):
#     try:
#         global THREAD_ACTIVATED
#         if THREAD_ACTIVATED == False:
#             THREAD_ACTIVATED = True
#             AutomaticExitThread().start()
#         return Response(status = status.HTTP_200_OK)
#     except:
#         return Response(status = status.HTTP_500_INTERNAL_SERVER_ERROR)

# commented by jayraj

# def jwt_auth_middleware(view_func):
#     def wrapper(request, *args, **kwargs):
#         # Check if the Authorization header is present in the request
#         if 'Authorization' not in request.headers:
#             return Response({'error': 'Authorization header missing'}, status=401)

#         # Extract the token from the Authorization header
#         auth_header = request.headers['Authorization']
#         _, token = auth_header.split(' ')

#         # Verify the token using the TokenVerifyView
#         try:
#             TokenVerifyView.as_view()(request)
#             # Set the user as authenticated if the token is valid
#             request.user.is_authenticated = True
#         except Exception as e:
#             return Response({'error': str(e)}, status=401)

#         # Call the original view function with the modified request object
#         return view_func(request, *args, **kwargs)

#     return wrapper


# @api_view(['GET'])
# @jwt_auth_middleware
# def protected_view(request):
#     # If the token is valid, return the protected data
#     return Response({'message': 'Hello, world!'})


def get_token(user):
    token = AccessToken.for_user(user)
    return str(token)


# class CustomTokenObtainPairView(TokenObtainPairView):
#     def post(self, request, *args, **kwargs):
#         response = super().post(request, *args, **kwargs)
#         if response.status_code == status.HTTP_200_OK:
#             user = request.user
#             token = get_token(user)
#             response.data['token'] = token
#         return response


# @api_view(['GET'])
# @permission_classes([IsAuthenticated])
# def protect_route(request):
#     return Response({"data": "You are inside protected route"}, status=status.HTTP_200_OK)


@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def protected_endpoint(request):
    # Your API endpoint logic here
    return Response({"message": "You are authenticated"})

@api_view(['POST'])
def register_user(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#end

@api_view(('POST',))
def delete_student(request):
    data = request.data
    res = {"output": "ok"}
    for student in data:
        email = student["email"]
        Student.objects.filter(email=email).update(is_present=False)
        Person.objects.filter(email=email).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_guard(request):
    data = request.data
    res = {"output": "ok"}
    for guard in data:
        email = guard["email"]
        Guard.objects.filter(email=email).update(is_present=False)
        Person.objects.filter(email=email).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_authority(request):
    data = request.data
    res = {"output": "ok"}
    for authority in data:
        email = authority["email"]
        Authorities.objects.filter(email=email).update(is_present=False)
        Person.objects.filter(email=email).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_location_web(request):
    data = request.data
    res = {"output": "ok"}
    print(data)
    for location in data:
        id = location.get("location_id", None)
        if id is not None:
            Location.objects.filter(location_id=id).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_hostel_web(request):
    data = request.data
    res = {"output": "ok"}
    print(data)
    for hostel in data:
        id = hostel.get("hostel_id", None)
        if id is not None:
            Hostel.objects.filter(hostel_id=id).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_department_web(request):
    data = request.data
    res = {"output": "ok"}
    print(data)
    for department in data:
        id = department.get("dept_id", None)
        if id is not None:
            Department.objects.filter(dept_id=id).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


@api_view(("POST",))
def delete_program_web(request):
    data = request.data
    res = {"output": "ok"}
    print(data)
    for program in data:
        id = program.get("degree_id", None)
        if id is not None:
            Program.objects.filter(degree_id=id).update(is_present=False)
    return Response(res, status=status.HTTP_200_OK)


# def authenticate(email, password):

#     try:
#         # email = data['email']
#         # password = data['password']
#         queryset_password = Password.objects.get(email=email)
#         print(queryset_password)
#         serializer_password = PasswordSerializer(queryset_password, many=False)
#         encrypted_password = serializer_password.data['password']

#         queryset_person = Admin.objects.filter(email=email, is_present=True)
#         serializer_person = PersonSerializer(queryset_person, many=True)
#         person_not_present = len(queryset_person) == 0

#         if person_not_present:
#             res = {
#                 "message": "Invalid Email",
#                 "person_type": "NA",
#             }
#             print("User not Found")
#             return Response(res, status=status.HTTP_200_OK)

#             person_type = serializer_person.data[0]['person_type']

#             if check_password(password, encrypted_password):
#                 res = {
#                     "message": "Login Successful",
#                     "person_type": person_type,
#                 }
#                 print("Password Matched")
#                 return Response(res, status=status.HTTP_200_OK)

#             else:
#                 res = {
#                     "message": "Invalid Password",
#                     "person_type": "NA"
#                 }
#                 print("Password Different")
#                 return Response(res, status=status.HTTP_200_OK)

#     except Exception as e:
#         print("Exception in login user")
#         print(e)
#         res = {
#             "message": "Error: An error occured while logging in",
#             "person_type": "NA"
#         }

#         return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)




@api_view(['POST'])
def login_admin_test(request):
    data = request.data
    try:
        email = data['email']
        password = data['password']
        user = authenticate(email=email, password=password)
        print(user)
        if user is not None:
            refresh = RefreshToken.for_user(user)
            res = {
                "message": "Login Successful",
                "refresh_token": str(refresh),
                "access_token": str(refresh.access_token),
            }
            return Response(res, status=status.HTTP_200_OK)
        else:
            res = {
                "message": "Invalid email or password",
            }
            return Response(res, status=status.HTTP_401_UNAUTHORIZED)
    except Exception as e:
        print("Exception in login user")
        print(e)
        res = {
            "message": "Error: An error occured while logging in",
        }
        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(("GET",))
def testReact(request):
    res = {"message": "Hello msg from backend"}
    return Response(res, status=status.HTTP_200_OK)


@api_view(["GET", "POST"])
def init_db(request):
    Department.objects.create(
        dept_name=initial_data,
    )

    Program.objects.create(
        degree_name=initial_data,
        degree_duration=0,
    )

    Hostel.objects.create(
        hostel_name=initial_data,
    )

    Location.objects.create(
        location_name=initial_data,
    )

    Authorities.objects.create(
        authority_name=initial_data,
        authority_designation=initial_data,
        email=initial_data,
    )

    Student.objects.create(
        st_name=initial_data,
        entry_no=initial_data,
        email=initial_data,
        gender=initial_data,
        dept_id=Department.objects.get(dept_name=initial_data),
        degree_id=Program.objects.get(degree_name=initial_data),
        hostel_id=Hostel.objects.get(hostel_name=initial_data),
        room_no=initial_data,
    )

    AuthoritiesTicketTable.objects.create(
        auth_id=Authorities.objects.get(authority_name=initial_data),
        entry_no=Student.objects.get(entry_no=initial_data),
        # date_time = date.today().strftime("%d/%m/%Y"),
        location_id=Location.objects.get(location_name=initial_data),
        ticket_type=initial_data,
        authority_message=initial_data,
        is_approved=initial_data,
    )

    #  to add dummy foreign key in TicketTable use this query
    # ref_id = AuthoritiesTicketTable.objects.get(authority_message = initial_data)

    return Response(status=status.HTTP_200_OK)


@api_view(["GET", "POST"])
def clear_db(request):
    StatusTable.objects.all().delete()
    TicketTable.objects.all().delete()
    AuthoritiesTicketTable.objects.all().delete()
    Authorities.objects.all().delete()
    Student.objects.all().delete()
    Guard.objects.all().delete()
    Location.objects.all().delete()
    Hostel.objects.all().delete()
    Program.objects.all().delete()
    Department.objects.all().delete()
    Person.objects.all().delete()
    Password.objects.all().delete()
    Admin.objects.all().delete()
    OTP.objects.all().delete()
    User.objects.all().delete()
    return Response(status=status.HTTP_200_OK)



# @api_view(['POST'])
# def login_user(request):
#     data = request.data
#     print("ashish\n\n\n\n", data)
#     try:
#         email = data['email']

    #     password = data['password']
    #     queryset_password = Password.objects.get(email=email)
    #     print(queryset_password)
    #     serializer_password = PasswordSerializer(queryset_password, many=False)
    #     encrypted_password = serializer_password.data['password']
    #     password = data['password']
    #     queryset_password = Password.objects.get(email=email)
    #     print(queryset_password)
    #     serializer_password = PasswordSerializer(queryset_password, many=False)
    #     encrypted_password = serializer_password.data['password']

    #     queryset_person = Person.objects.filter(email=email, is_present=True)
    #     serializer_person = PersonSerializer(queryset_person, many=True)
    #     person_not_present = len(queryset_person) == 0
    #     queryset_person = Person.objects.filter(email=email, is_present=True)
    #     serializer_person = PersonSerializer(queryset_person, many=True)
    #     person_not_present = len(queryset_person) == 0

    #     if person_not_present:
    #         res = {
    #             "message": "Invalid Email",
    #             "person_type": "NA",
    #         }
    #         print("User not Found")
    #         return Response(res, status=status.HTTP_200_OK)
    #     if person_not_present:
    #         res = {
    #             "message": "Invalid Email",
    #             "person_type": "NA",
    #         }
    #         print("User not Found")
    #         return Response(res, status=status.HTTP_200_OK)

    #     person_type = serializer_person.data[0]['person_type']
    #     person_type = serializer_person.data[0]['person_type']

    #     if check_password(password, encrypted_password):
    #         res = {
    #             "message": "Login Successful",
    #             "person_type": person_type,
    #         }
    #         print("Password Matched")
    #         return Response(res, status=status.HTTP_200_OK)
    #     if check_password(password, encrypted_password):
    #         res = {
    #             "message": "Login Successful",
    #             "person_type": person_type,
    #         }
    #         print("Password Matched")
    #         return Response(res, status=status.HTTP_200_OK)

    #     else:
    #         res = {
    #             "message": "Invalid Password",
    #             "person_type": "NA"
    #         }
    #         print("Password Different")
    #         return Response(res, status=status.HTTP_200_OK)
    #     else:
    #         res = {
    #             "message": "Invalid Password",
    #             "person_type": "NA"
    #         }
    #         print("Password Different")
    #         return Response(res, status=status.HTTP_200_OK)

    # except Exception as e:
    #     print("Exception in login user")
    #     print(e)
    #     res = {
    #         "message": "Error: An error occured while logging in",
    #         "person_type": "NA"
    #     }

    #     return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    #     return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def forgot_password(request):
    data = request.data
    try:
        email = data["email"]

        op = int(data["op"])

        # print("op")
        # print(type(op))
        # print(op)

        if op == 1:

            is_not_present = len(User.objects.filter(email=email)) == 0

            if is_not_present:
                response_str = "User email not found in database"
                res = {
                    "message": response_str,
                }
                print(response_str)
                return Response(res, status=status.HTTP_400_BAD_REQUEST)

            subject = "Your Account verification OTP for MyGateApp is ..."

            otp = 111111
            otp = random.randint(100000, 999999)

            message = f"Your OTP is {otp}"

            email_from = settings.EMAIL_HOST

            send_mail(subject, message, email_from, [email])

            print("email sent")

            print(f"OTP sent={otp}")

            is_not_present = len(OTP.objects.filter(email=email)) == 0
            if is_not_present:
                OTP.objects.create(email=email, otp=otp)
            else:
                OTP.objects.filter(email=email).update(otp=otp)

            response_str = "OTP sent to email"
            res = {
                "message": response_str,
            }
            print(response_str)
            return Response(res, status=status.HTTP_200_OK)

        elif op == 2:

            queryset_otp = OTP.objects.get(email=email)

            serializer_otp = OTPSerializer(queryset_otp, many=False)

            db_otp = serializer_otp.data["otp"]

            entered_otp = int(data["entered_otp"])

            # print("entered_otp")
            # print(entered_otp)
            is_not_present = len(User.objects.filter(email=email)) == 0

            if is_not_present:
                response_str = "User email not found in database"
                res = {
                    "message": response_str,
                }
                print(response_str)
                return Response(res, status=status.HTTP_400_BAD_REQUEST)
            user=User.objects.get(email=email)
            

            if entered_otp == db_otp:
                token = default_token_generator.make_token(user)
                uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
                response_str = "OTP Matched"
                res = {
                    "message": response_str,
                    "uidb64": uidb64,
                    "token": token
                }
                print(response_str)
                OTP.objects.filter(email=email).update(otp=-1)
                return Response(res, status=status.HTTP_200_OK)
            else:
                response_str = "OTP Did not Match"
                res = {
                    "message": response_str,
                }
                print(response_str)
                return Response(res, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        print(e)
        response_str = "Exception in forgot password"
        res = {
            "message": response_str,
        }
        print(response_str)
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def reset_password(request):
    try:
        
        password = request.data.get("password")
        uidb64 = request.data.get('uidb64')
        token = request.data.get('token')

        if not (uidb64 and token and password):
            raise Exception("Please provide UID, token, password, and confirm_password.")

        
        uid = str(urlsafe_base64_decode(uidb64),'utf-8')
        user = User.objects.get(pk=uid)

        if user is not None and default_token_generator.check_token(user, token): 
            # Set the new password
            user.set_password(password)
            user.save()
            response_str = "Password RESET Successful"

            res = {
                "message": response_str,
            }
            return Response(res, status=status.HTTP_200_OK)
        else:
            raise Exception("No valid user found")

    except Exception as e:
        response_str = "Password RESET Failed"

        print("Exception in reset_password: " + str(e))

        res = {
            "message": response_str,
        }

        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Adding data from file
"""
Note: send the file as a form-data file with attribute name as 'file' in postman
"""


@api_view(["POST"])
def add_departments_from_file(request):
    upFile = request.FILES.get("file")
    """ print(request.data) """
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    print()
    file_data_list = file_data.split("\n")
    """ print("\n\n\n\n\n\n\n",file_data_list) """
    print("\n\n\n\n\n\n\n", type(file_data_list))
    csvreader = csv.reader(file_data_list)

    """ print(csvreader,"\n\n\n\n\n") """
    data = list(csvreader)
    """ print("\n\n\n\n\n\n\n",data) """
    for i in range(1, len(data)):
        curr_department = data[i]
        if len(curr_department):
            is_department_present = (
                len(Department.objects.filter(dept_name=curr_department[0])) != 0
            )
            if is_department_present:
                Department.objects.filter(dept_name=curr_department[0]).update(
                    is_present=True
                )
            else:
                Department.objects.create(dept_name=curr_department[0])
    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def add_programs_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_program = data[i]
        if len(curr_program):
            is_program_present = (
                len(Program.objects.filter(degree_name=curr_program[0])) != 0
            )
            if is_program_present:
                Program.objects.filter(degree_name=curr_program[0]).update(
                    degree_duration=curr_program[1], is_present=True
                )
            else:
                Program.objects.create(
                    degree_name=curr_program[0], degree_duration=curr_program[1]
                )

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def add_hostels_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_hostel = data[i]
        if len(curr_hostel):
            is_hostel_present = (
                len(Hostel.objects.filter(hostel_name=curr_hostel[0])) != 0
            )
            if is_hostel_present:
                Hostel.objects.filter(hostel_name=curr_hostel[0]).update(
                    is_present=True
                )
            else:
                Hostel.objects.create(hostel_name=curr_hostel[0])

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def add_locations_from_file(request):
    try:
        upFile = request.FILES.get("file")
        context = {}
        if upFile.multiple_chunks():
            context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (
                upFile.size,
            )
            return Response(
                context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        else:
            context["uploadedFile"] = upFile.read()
        file_data = context["uploadedFile"].decode("UTF-8")
        file_data_list = file_data.split("\n")
        csvreader = csv.reader(file_data_list)
        data = list(csvreader)

        for i in range(1, len(data)):
            curr_location = data[i]
            if len(curr_location):
                location_already_exists = (
                    len(Location.objects.filter(location_name=curr_location[0])) != 0
                )

                _pre_approval_required = True
                if curr_location[2] == "No":
                    _pre_approval_required = False

                _automatic_exit_required = True
                if curr_location[3] == "No":
                    _automatic_exit_required = False

                _parent_id = -1
                if curr_location[1] != "None":
                    try:
                        queryset_location_table = Location.objects.get(
                            location_name=curr_location[1]
                        )
                        location_serializer = LocationSerializer(
                            queryset_location_table, many=False
                        )
                        _parent_id = location_serializer.data["location_id"]
                    except:
                        pass

                if location_already_exists:
                    Location.objects.filter(location_name=curr_location[0]).update(
                        parent_id=_parent_id,
                        pre_approval_required=_pre_approval_required,
                        automatic_exit_required=_automatic_exit_required,
                        is_present=True,
                    )
                else:
                    Location.objects.create(
                        location_name=curr_location[0],
                        parent_id=_parent_id,
                        pre_approval_required=_pre_approval_required,
                        automatic_exit_required=_automatic_exit_required,
                        is_present=True,
                    )

                # For this location, mark the status of all the students in the student table as out

                queryset_student = Student.objects.all()
                queryset_location_table = Location.objects.get(
                    location_name=curr_location[0]
                )

                for each_queryset_student in queryset_student:
                    serializer = StudentSerializer(each_queryset_student, many=False)
                    entry_no = serializer.data["entry_no"]

                    # If it is not a dummy student
                    if entry_no != initial_data:
                        query_set_location_curr = Location.objects.get(
                            location_name=curr_location[0]
                        )

                        status_table_entry_not_present = (
                            len(
                                StatusTable.objects.filter(
                                    location_id=query_set_location_curr,
                                    entry_no=each_queryset_student,
                                )
                            )
                            == 0
                        )

                        if status_table_entry_not_present:
                            StatusTable.objects.create(
                                entry_no=each_queryset_student,
                                location_id=queryset_location_table,
                                current_status="out",
                            )
                        else:
                            StatusTable.objects.filter(
                                location_id=query_set_location_curr,
                                entry_no=each_queryset_student,
                            ).update(is_present=True, current_status="out")

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in add_locations_from_file: " + e)
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def add_authorities_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_authority = data[i]
        if len(curr_authority):
            # checking for all the three parameters as two authority can have same name, authority can get promoted, and hence his/her email will be changed in that case
            authority_not_present = (
                len(Authorities.objects.filter(email=curr_authority[2])) == 0
            )
            if authority_not_present:
                Authorities.objects.create(
                    authority_name=curr_authority[0],
                    authority_designation=curr_authority[1],
                    email=curr_authority[2],
                )
            else:
                Authorities.objects.filter(email=curr_authority[2]).update(
                    authority_name=curr_authority[0],
                    authority_designation=curr_authority[1],
                    is_present=True,
                )
            
            user = User.objects.filter(email=curr_authority[2], type="Authority").first()

            if user is None:
                print(f"## {curr_authority}")
                User.objects.create_user(email=curr_authority[2], type="Authority")
            else:
                print(f"**")
                User.objects.filter(email=curr_authority[2], type="Authority").update_user()


    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def add_guards_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_guard = data[i]
        if len(curr_guard):
            guard_not_present = len(Guard.objects.filter(email=curr_guard[2])) == 0
            if guard_not_present:
                Guard.objects.create(
                    guard_name=curr_guard[0],
                    location_id=Location.objects.get(location_name=curr_guard[1]),
                    email=curr_guard[2],
                )
            else:
                query_set_location_table = Location.objects.get(
                    location_name=curr_guard[1]
                )
                query_set_location_table_serializer = LocationSerializer(
                    query_set_location_table, many=False
                )
                _location_id = query_set_location_table_serializer.data["location_id"]
                Guard.objects.filter(email=curr_guard[2]).update(
                    guard_name=curr_guard[0], location_id=_location_id, is_present=True
                )
            user = User.objects.filter(email=curr_guard[2], type="Guard").first()

            if user is None:
                print(f"## {curr_guard}")
                User.objects.create_user(email=curr_guard[2], type="Guard")
            else:
                print(f"**")
                User.objects.filter(email=curr_guard[2], type="Guard").update_user()
            
    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def add_students_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()

    file_data = context["uploadedFile"].decode("UTF-8")
    """ print("\n\n\n\n\n\n\n\n") """
    file_data_list = file_data.split("\n")
    """ print(file_data_list,"\n\n\n\n\n\n\n\n") """
    csvreader = csv.reader(file_data_list)
    """ print(csvreader,"\n\n\n\n\n\n\n\n") """
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_student = data[i]
        # print(curr_student)
        """ print(curr_student, len(curr_student)) """

        if len(curr_student):

            user = User.objects.filter(email=curr_student[2], type="Student").first()

            if user is None:
                print(f"## {curr_student}")
                User.objects.create_user(email=curr_student[2], type="Student")
            else:
                print(f"**")
                User.objects.filter(email=curr_student[2], type="Student").update_user()

            is_student_present = (
                len(Student.objects.filter(entry_no=curr_student[1])) != 0
            )

            print("inside insert student data")
            print(
                f"{curr_student[0]} {curr_student[1]} {curr_student[2]} {curr_student[3]} {curr_student[4]} {curr_student[5]} {curr_student[6]} {curr_student[7]} {curr_student[8]}"
            )

            if is_student_present:
                Student.objects.filter(entry_no=curr_student[1]).update(
                    st_name=curr_student[0],
                    entry_no=curr_student[1],
                    email=curr_student[2],
                    gender=curr_student[3],
                    dept_id=Department.objects.get(dept_name=curr_student[4]),
                    degree_id=Program.objects.get(degree_name=curr_student[5]),
                    hostel_id=Hostel.objects.get(hostel_name=curr_student[6]),
                    room_no=curr_student[7],
                    year_of_entry=curr_student[8],
                    is_present=True,
                )
            else:
                Student.objects.create(
                    st_name=curr_student[0],
                    entry_no=curr_student[1],
                    email=curr_student[2],
                    gender=curr_student[3],
                    dept_id=Department.objects.get(dept_name=curr_student[4]),
                    degree_id=Program.objects.get(degree_name=curr_student[5]),
                    hostel_id=Hostel.objects.get(hostel_name=curr_student[6]),
                    room_no=curr_student[7],
                    year_of_entry=curr_student[8],
                )

                # update the status table accordingly
                queryset_location_table = Location.objects.all()
                queryset_entry_no = Student.objects.get(entry_no=curr_student[1])

                for each_queryset_location_table in queryset_location_table:
                    queryset_location_table_serializer = LocationSerializer(
                        each_queryset_location_table, many=False
                    )
                    queryset_location_table_location_name = (
                        queryset_location_table_serializer.data["location_name"]
                    )
                    if queryset_location_table_location_name != initial_data:
                        queryset_status_table = StatusTable.objects.create(
                            entry_no=queryset_entry_no,
                            location_id=each_queryset_location_table,
                        )

            # password_not_present = len(
            #     Password.objects.filter(email=curr_student[2])) == 0
            # if password_not_present:
            #     Password.objects.create(
            #         email=curr_student[2]
            #     )
            # else:
            #     Password.objects.filter(
            #         email=curr_student[2]).update(is_present=True)

    return Response(status=status.HTTP_200_OK)


# Deleting data from file


@api_view(["POST"])
def delete_departments_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_department = data[i]
        if len(curr_department):
            Department.objects.filter(dept_name=curr_department[0]).update(
                is_present=False
            )

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_programs_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_program = data[i]
        if len(curr_program):
            Program.objects.filter(
                degree_name=curr_program[0], degree_duration=curr_program[1]
            ).update(is_present=False)

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_hostels_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_hostel = data[i]
        if len(curr_hostel):
            Hostel.objects.filter(hostel_name=curr_hostel[0]).update(is_present=False)

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_locations_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)

    for i in range(1, len(data)):
        curr_location = data[i]
        if len(curr_location):

            _pre_approval_required = True
            if curr_location[2] == "No":
                _pre_approval_required = False

            _automatic_exit_required = True
            if curr_location[3] == "No":
                _automatic_exit_required = False

            _parent_id = -1
            if curr_location[1] != "None":
                queryset_location_table = Location.objects.get(
                    location_name=curr_location[1]
                )
                location_serializer = LocationSerializer(
                    queryset_location_table, many=False
                )
                _parent_id = location_serializer.data["location_id"]

            Location.objects.filter(
                location_name=curr_location[0],
                parent_id=_parent_id,
                pre_approval_required=_pre_approval_required,
                automatic_exit_required=_automatic_exit_required,
            ).update(is_present=False)

            queryset_location_table = Location.objects.get(
                location_name=curr_location[0]
            )
            StatusTable.objects.filter(location_id=queryset_location_table).update(
                is_present=False
            )

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_authorities_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_authority = data[i]
        if len(curr_authority):
            # checking for all the three parameters as two authority can have same name, authority can get promoted, and hence his/her email will be changed in that case
            Authorities.objects.filter(email=curr_authority[2]).update(is_present=False)
            User.objects.filter(
                email=curr_authority[2], type="Authority"
            ).delete()

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_guards_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_guard = data[i]
        if len(curr_guard):
            Guard.objects.filter(email=curr_guard[2]).delete()
            User.objects.filter(email=curr_guard[2], type="Guard").delete()
    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def delete_students_from_file(request):
    upFile = request.FILES.get("file")
    context = {}
    if upFile.multiple_chunks():
        context["uploadError"] = "Uploaded file is too big (%.2f MB)." % (upFile.size,)
        return Response(
            context["uploadError"], status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    else:
        context["uploadedFile"] = upFile.read()
    file_data = context["uploadedFile"].decode("UTF-8")
    file_data_list = file_data.split("\r\n")
    csvreader = csv.reader(file_data_list)
    data = list(csvreader)
    for i in range(1, len(data)):
        curr_student = data[i]
        # print(curr_student, len(curr_student))
        if len(curr_student):
            is_student_present = (
                len(Student.objects.filter(entry_no=curr_student[1])) != 0
            )
            if is_student_present:
                Student.objects.filter(entry_no=curr_student[1]).update(
                    is_present=False
                )
                StatusTable.objects.filter(entry_no=curr_student[1]).update(
                    is_present=False
                )
                User.objects.filter(
                    email=curr_student[2], type="Student"
                ).delete()
                

    return Response(status=status.HTTP_200_OK)


# add data using form
@api_view(["POST"])
def add_guard_form(request):
    data = request.data

    try:
        _name = data["name"]
        _email = data["email"]
        _location_name = data["location_name"]

        query_set_location = Location.objects.get(location_name=_location_name)
        _location_id = LocationSerializer(query_set_location).data["location_id"]

        is_guard_present = len(Guard.objects.filter(email=_email)) != 0
        if is_guard_present:
            # check the is_present attribute of the guard
            query_set_guard = Guard.objects.get(email=_email)
            serializer = GuardSerializer(query_set_guard, many=False)
            is_present = serializer.data["is_present"]
            if is_present:
                response_str = "A Guard Already Exists with this email id"
                return Response(response_str, status.HTTP_200_OK)
            else:
                Guard.objects.filter(email=_email).update(
                    guard_name=_name,
                    email=_email,
                    location_id=_location_id,
                    is_present=True,
                )

                User.objects.filter(email=_email,type='Guard' ).update()
                response_str = "Guard Created Sucessfully"
                return Response(response_str, status.HTTP_200_OK)
        else:
            Guard.objects.create(
                guard_name=_name, location_id=query_set_location, email=_email
            )
            User.objects.create(email=_email, type="Guard")
            response_str = "Guard Created Sucessfully"
            return Response(response_str, status.HTTP_200_OK)

    except Exception as e:
        print("Exception raised in add_guard_form function")
        print("The exception is " + str(e))
        response_str = "Error in creating guard"
        return Response(response_str, status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def add_admin_form(request):
    data = request.data

    try:
        admin_name = data["name"]

        email = data["email"]

        Admin.objects.create(email=email, admin_name=admin_name)

        User.objects.create(email=email, type="Admin")

        response_str = "Admin created successfully"

        res = {"message": response_str}

        return Response(res, status.HTTP_200_OK)

    except Exception as e:
        print("Exception raised in add_admin_form function")

        print("The exception is " + str(e))

        response_str = "Error in creating admin"

        res = {"message": response_str}
        return Response(res, status.HTTP_500_INTERNAL_SERVER_ERROR)


# modify data using form


@api_view(["POST"])
def modify_guard_form(request):
    data = request.data
    # _name = data['name']
    _email = data["email"]
    _location_name = data["location_name"]

    query_set_location = Location.objects.get(location_name=_location_name)
    _location_id = LocationSerializer(query_set_location).data["location_id"]

    is_guard_present = len(Guard.objects.filter(email=_email, is_present=True)) != 0
    if is_guard_present:
        Guard.objects.filter(email=_email).update(
            location_id=_location_id, is_present=True
        )

        User.objects.filter(email=_email,type="Guard").update()

        response_str = "Guard updated sucessfully"
        return Response(response_str, status.HTTP_200_OK)

    response_str = "No guard exists with this email id"
    return Response(response_str, status.HTTP_200_OK)


# delete data using  form


@api_view(["POST"])
def delete_guard_form(request):
    data = request.data
    # _name = data['name']
    _email = data["email"]

    is_guard_present = len(Guard.objects.filter(email=_email, is_present=True)) != 0
    if is_guard_present:
        Guard.objects.filter(email=_email).update(is_present=False)
        User.objects.filter(email=_email).delete()

        response_str = "Guard Deleted sucessfully"
        return Response(response_str, status.HTTP_200_OK)

    response_str = "No guard exists with this email id"
    return Response(response_str, status.HTTP_200_OK)


# statistics
check_status = "in"


@api_view(["POST"])
def get_statistics_data_by_location(request):
    # print(request.data)
    data = request.data
    _location_name = data["location"]
    _filter = data["filter"]
    check_status = data["status"]
    print("Location Name: " + _location_name)
    if _filter == "Gender":
        category_list = {}

        query_set_status_table = StatusTable.objects.filter(
            location_id=Location.objects.get(location_name=_location_name),
            current_status=check_status,
            is_present=True,
        )
        print(f"shaurya bhai={query_set_status_table.__sizeof__}")
        for each_query_set in query_set_status_table:
            serializer = StatusTableSerializer(each_query_set, many=False)
            entry_no = serializer.data["entry_no"]
            # now I need to find out their gender
            is_student_present = (
                len(Student.objects.filter(entry_no=entry_no, is_present=True)) != 0
            )
            if is_student_present:
                student = Student.objects.get(entry_no=entry_no, is_present=True)
                student_serializer = StudentSerializer(student, many=False)
                gender = student_serializer.data["gender"]
                # print("Student Name: " + student_serializer.data['st_name'])
                if gender in category_list:
                    category_list[gender] += 1
                else:
                    category_list[gender] = 1

        res = []
        for key in category_list:
            StatisticsResultObj = {"category": key, "count": category_list[key]}
            res.append(StatisticsResultObj)

        return Response({"output": res}, status.HTTP_200_OK)

    elif _filter == "Department":
        # first retrieve the list of departments
        total_departments = len(Department.objects.filter(is_present=True))
        category_list = {}
        if total_departments == 0:
            res = []
            return Response({"output": res}, status.HTTP_200_OK)
        else:
            departments_query_set = Department.objects.filter(is_present=True)

            for each_department_query_set in departments_query_set:
                department_serializer = DepartmentSerializer(
                    each_department_query_set, many=False
                )
                dept_name = department_serializer.data["dept_name"]
                if dept_name != initial_data:
                    category_list[dept_name] = 0

            query_set_status_table = StatusTable.objects.filter(
                location_id=Location.objects.get(location_name=_location_name),
                current_status=check_status,
                is_present=True,
            )
            for each_query_set in query_set_status_table:
                serializer = StatusTableSerializer(each_query_set, many=False)
                entry_no = serializer.data["entry_no"]
                # now I need to find out their gender
                is_student_present = (
                    len(Student.objects.filter(entry_no=entry_no, is_present=True)) != 0
                )
                if is_student_present:
                    student = Student.objects.get(entry_no=entry_no, is_present=True)
                    student_serializer = StudentSerializer(student, many=False)
                    dept_id = student_serializer.data["dept_id"]

                    department_not_present = (
                        len(Department.objects.filter(dept_id=dept_id, is_present=True))
                        == 0
                    )
                    if department_not_present:
                        res = []
                        print("Department not present")
                        return Response({"output": res}, status.HTTP_200_OK)
                    else:
                        # get name of the department
                        department_query_set = Department.objects.get(dept_id=dept_id)
                        dept_name = DepartmentSerializer(
                            department_query_set, many=False
                        ).data["dept_name"]
                        # print("Student Name: " + student_serializer.data['st_name'])
                        # print("Department: " + str(dept_name))
                        category_list[dept_name] += 1
            res = []
            for key in category_list:
                StatisticsResultObj = {"category": key, "count": category_list[key]}
                res.append(StatisticsResultObj)
            return Response({"output": res}, status.HTTP_200_OK)

    elif _filter == "Program":
        total_programs = len(Program.objects.filter(is_present=True))
        category_list = {}
        if total_programs == 0:
            res = []
            return Response({"output": res}, status.HTTP_200_OK)
        else:
            program_query_set = Program.objects.filter(is_present=True)

            for each_program_query_set in program_query_set:
                program_serializer = ProgramSerializer(
                    each_program_query_set, many=False
                )
                degree_name = program_serializer.data["degree_name"]
                if degree_name != initial_data:
                    category_list[degree_name] = 0

            query_set_status_table = StatusTable.objects.filter(
                location_id=Location.objects.get(location_name=_location_name),
                current_status=check_status,
                is_present=True,
            )
            for each_query_set in query_set_status_table:
                serializer = StatusTableSerializer(each_query_set, many=False)
                entry_no = serializer.data["entry_no"]
                # now I need to find out their gender
                is_student_present = (
                    len(Student.objects.filter(entry_no=entry_no, is_present=True)) != 0
                )
                if is_student_present:
                    student = Student.objects.get(entry_no=entry_no, is_present=True)
                    student_serializer = StudentSerializer(student, many=False)
                    degree_id = student_serializer.data["degree_id"]

                    Program_not_present = (
                        len(
                            Program.objects.filter(degree_id=degree_id, is_present=True)
                        )
                        == 0
                    )
                    if Program_not_present:
                        res = []
                        print("Program not present")
                        return Response({"output": res}, status.HTTP_200_OK)
                    else:
                        # get name of the department
                        Program_query_set = Program.objects.get(degree_id=degree_id)
                        degree_name = ProgramSerializer(
                            Program_query_set, many=False
                        ).data["degree_name"]
                        # print("Student Name: " + student_serializer.data['st_name'])
                        # print("Program: " + str(degree_name))
                        category_list[degree_name] += 1
            res = []
            for key in category_list:
                StatisticsResultObj = {"category": key, "count": category_list[key]}
                res.append(StatisticsResultObj)
            return Response({"output": res}, status.HTTP_200_OK)

    elif _filter == "Year":
        category_list = {}
        query_set_status_table = StatusTable.objects.filter(
            location_id=Location.objects.get(location_name=_location_name),
            current_status=check_status,
            is_present=True,
        )
        for each_query_set in query_set_status_table:
            serializer = StatusTableSerializer(each_query_set, many=False)
            entry_no = serializer.data["entry_no"]
            # now I need to find out their gender
            is_student_present = (
                len(Student.objects.filter(entry_no=entry_no, is_present=True)) != 0
            )
            if is_student_present:
                student = Student.objects.get(entry_no=entry_no, is_present=True)
                student_serializer = StudentSerializer(student, many=False)
                year_of_entry = str(student_serializer.data["year_of_entry"])

                print("Student Name: " + student_serializer.data["st_name"])
                print("Year of Entry: " + str(year_of_entry))
                if year_of_entry in category_list:
                    category_list[year_of_entry] += 1
                else:
                    category_list[year_of_entry] = 1
        res = []
        for key in category_list:
            StatisticsResultObj = {"category": key, "count": category_list[key]}
            res.append(StatisticsResultObj)
        return Response({"output": res}, status.HTTP_200_OK)

    return Response(status.HTTP_200_OK)


_ticket_type = "enter"


@api_view(["POST"])
#
def get_piechart_statistics_by_location(request):
    print(request.data)
    data = request.data
    _location_name = data["location"]
    _filter = data["filter"]
    _start_date = data["start_date"]
    _end_date = data["end_date"]
    category_list = {}

    no_tickets = (
        len(
            TicketTable.objects.filter(
                location_id=Location.objects.get(location_name=_location_name),
                ticket_type=_ticket_type,
                is_approved="Approved",
            )
        )
        == 0
    )
    if no_tickets:
        res = []
        return Response({"output": res}, status.HTTP_200_OK)

    all_tickets = TicketTable.objects.filter(
        location_id=Location.objects.get(location_name=_location_name),
        ticket_type=_ticket_type,
        is_approved="Approved",
    )

    if _filter == "Hourly":
        for query_set in all_tickets:
            serializer = TicketTableSerializer(query_set, many=False)
            date_time = serializer.data["date_time"]
            _date = date_time.split("T")[0]
            _time = (date_time.split("T")[-1]).split(".")[0]
            _hour = _time.split(":")[0]
            key = _hour + ":00\n" + _date
            if _date <= _end_date and _date >= _start_date:
                if key in category_list:
                    category_list[key] += 1
                else:
                    category_list[key] = 1
        res = []
        for key in category_list:
            StatisticsResultObj = {"category": key, "count": category_list[key]}
            res.append(StatisticsResultObj)
        return Response({"output": res}, status.HTTP_200_OK)

    elif _filter == "Daily":
        for query_set in all_tickets:
            serializer = TicketTableSerializer(query_set, many=False)
            date_time = serializer.data["date_time"]
            _date = date_time.split("T")[0]
            if _date <= _end_date and _date >= _start_date:
                if _date in category_list:
                    category_list[_date] += 1
                else:
                    category_list[_date] = 1
        res = []
        for key in category_list:
            StatisticsResultObj = {"category": key, "count": category_list[key]}
            res.append(StatisticsResultObj)

        return Response({"output": res}, status.HTTP_200_OK)

    elif _filter == "Monthly":
        for query_set in all_tickets:
            serializer = TicketTableSerializer(query_set, many=False)
            date_time = serializer.data["date_time"]
            _date = date_time.split("T")[0]
            l = _date.split("-")
            _month = "-".join(l[:-1])
            if _date <= _end_date and _date >= _start_date:
                if _month in category_list:
                    category_list[_month] += 1
                else:
                    category_list[_month] = 1
        res = []
        for key in category_list:
            StatisticsResultObj = {"category": key, "count": category_list[key]}
            res.append(StatisticsResultObj)

        return Response({"output": res}, status.HTTP_200_OK)

    return Response(status.HTTP_200_OK)


########################################################################


@api_view(["GET"])
def get_students(request):
    queryset = Student.objects.all()
    serializer = StudentSerializer(queryset, many=True)
    print(serializer.data)
    return Response(serializer.data)


@api_view(["GET", "POST"])
def get_all_students(request):
    res = []
    print(request.data)
    try:
        queryset = Student.objects.filter(is_present=True)

        serializer = StudentSerializer(queryset, many=True)

        for each_student in serializer.data:
            if each_student["st_name"] == initial_data:
                continue
            entry_no = each_student["entry_no"]

            _dept_id = each_student["dept_id"]

            query_set_department = Department.objects.get(dept_id=_dept_id)

            dept_name = DepartmentSerializer(query_set_department, many=False).data[
                "dept_name"
            ]

            _degree_id = each_student["degree_id"]

            query_set_program = Program.objects.get(degree_id=_degree_id)

            degree_name = ProgramSerializer(query_set_program, many=False).data[
                "degree_name"
            ]

            _hostel_id = each_student["hostel_id"]

            query_set_hostel = Hostel.objects.get(hostel_id=_hostel_id)

            hostel_name = HostelSerializer(query_set_hostel, many=False).data[
                "hostel_name"
            ]

            item = {
                "name": each_student["st_name"],
                "entry_no": each_student["entry_no"],
                "email": each_student["email"],
                "gender": each_student["gender"],
                "department": dept_name,
                "degree_name": degree_name,
                "hostel": hostel_name,
                "room_no": each_student["room_no"],
                "year_of_entry": str(each_student["year_of_entry"]),
                "mobile_no": each_student["mobile_no"],
                "profile_img": each_student["profile_img"],
                "degree_duration": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }

            res.append(item)

        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def delete_student_by_id(request):
    print("req body = ", request.body)
    # queryset = Student.objects.get(entry_no = entry_no)
    # serializer = StudentSerializer(queryset, many=False)
    return Response(status=status.HTTP_200_OK)


@api_view(["GET"])
def get_student_by_entry_no(request, entry_no):
    queryset = Student.objects.get(entry_no=entry_no)
    serializer = StudentSerializer(queryset, many=False)
    return Response(serializer.data)


@api_view(["POST"])
def get_welcome_message(request):
    try:
        data = request.data

        email = data["email"]

        name = ""

        user = User.objects.get(email=email)
        

        

        person_type = user.type

        if person_type == "Student":
            queryset = Student.objects.get(email=email, is_present=True)
            serializer = StudentSerializer(queryset, many=False)
            name = serializer.data["st_name"]

        elif person_type == "Guard":
            queryset = Guard.objects.get(email=email, is_present=True)
            serializer = GuardSerializer(queryset, many=False)
            name = serializer.data["guard_name"]

        elif person_type == "Authority":
            queryset = Authorities.objects.get(email=email, is_present=True)
            serializer = AuthoritiesSerializer(queryset, many=False)
            name = serializer.data["authority_name"]

        elif person_type == "Admin":
            queryset = Admin.objects.get(email=email, is_present=True)
            serializer = AdminSerializer(queryset, many=False)
            name = serializer.data["admin_name"]

        welcome_message = name

        res = {
            "welcome_message": welcome_message,
        }

        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in get_student_by_email: " + str(e))

        welcome_message = "Welcome"

        res = {
            "welcome_message": welcome_message,
        }

        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class get_student_by_email(APIView):
    permission_classes = (IsAuthenticated,)
    def post(self,request):
        try:
            data = request.data
            print(request.data)
            email_ = data["email"]

            queryset = Student.objects.get(email=email_)

            serializer = StudentSerializer(queryset, many=False)

            _dept_id = serializer.data["dept_id"]

            query_set_department = Department.objects.get(dept_id=_dept_id)

            dept_name = DepartmentSerializer(query_set_department, many=False).data[
                "dept_name"
            ]

            _degree_id = serializer.data["degree_id"]

            query_set_department = Program.objects.get(degree_id=_degree_id)

            degree_name = ProgramSerializer(query_set_department, many=False).data[
                "degree_name"
            ]

            image_path = serializer.data["profile_img"]
            print("0000000000000000000000000000000000000000000000000000000000000000000")
            with open(str(settings.BASE_DIR) + image_path, "rb") as image_file:
                encoded_image = base64.b64encode(image_file.read()).decode("utf-8")

            res = {
                "name": serializer.data["st_name"],
                "email": serializer.data["email"],
                "gender": serializer.data["gender"],
                "year_of_entry": str(serializer.data["year_of_entry"]),
                "department": dept_name,
                "mobile_no": serializer.data["mobile_no"],
                "profile_img": encoded_image,
                "image_path": image_path,
                "degree": degree_name,
            }
            print("------------------------------------------------")
            return Response(res, status=status.HTTP_200_OK)

        except Exception as e:
            print("Exception in get_student_by_email: " + str(e))
            return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_student_by_id(request):
    try:
        data = request.data
        print(data)
        if "id" in data and "id" in data["id"]:
            _entry_no = data["id"]["id"]
            # rest of the code here
        else:
            res = {"error": "Invalid request data"}
            return Response(res, status=status.HTTP_400_BAD_REQUEST)
        print("le beta data = ", _entry_no)
        queryset = Student.objects.get(entry_no=_entry_no)

        serializer = StudentSerializer(queryset, many=False)

        _dept_id = serializer.data["dept_id"]

        query_set_department = Department.objects.get(dept_id=_dept_id)

        dept_name = DepartmentSerializer(query_set_department, many=False).data[
            "dept_name"
        ]

        _degree_id = serializer.data["degree_id"]

        query_set_department = Program.objects.get(degree_id=_degree_id)

        degree_name = ProgramSerializer(query_set_department, many=False).data[
            "degree_name"
        ]

        image_path = serializer.data["profile_img"]
        print("0000000000000000000000000000000000000000000000000000000000000000000")
        with open(str(settings.BASE_DIR) + image_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode("utf-8")

        res = {
            "name": serializer.data["st_name"],
            "email": serializer.data["email"],
            "gender": serializer.data["gender"],
            "year_of_entry": str(serializer.data["year_of_entry"]),
            "department": dept_name,
            "mobile_no": serializer.data["mobile_no"],
            "profile_img": encoded_image,
            "image_path": image_path,
            "degree": degree_name,
        }
        print("------------------------------------------------")
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in get_student_by_email: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def add_student(request):
    data = request.data

    try:
        st_name_ = data["st_name"]
        entry_no_ = data["entry_no"]
        email_ = data["email"]

        queryset_student = Student.objects.create(
            st_name=st_name_,
            entry_no=entry_no_,
            email=email_,
            # profile_img = data['profile_img'],
        )

        queryset_entry_no = Student.objects.get(entry_no=entry_no_)
        queryset_location_table = Location.objects.all()

        for each_queryset_location_table in queryset_location_table:
            queryset_status_table = StatusTable.objects.create(
                entry_no=queryset_entry_no,
                location_id=each_queryset_location_table,
            )

        response_str = "Student Added Successfully"
        return Response(response_str)

    except Exception as e:
        response_str = "Failed to add student due to exception\n" + str(e)
        return Response(response_str)


@api_view(["POST"])
def add_new_location(request):
    data = request.data

    try:
        new_location_name = data["new_location_name"]
        chosen_parent_location = data["chosen_parent_location"]
        chosen_pre_approval_needed = data["chosen_pre_approval_needed"]
        automatic_exit_required_str = data["automatic_exit_required"]

        approval_flag = False
        if chosen_pre_approval_needed == "Yes":
            approval_flag = True

        parent_id = -1
        if chosen_parent_location != "None":
            queryset_location_table = Location.objects.get(
                location_name=chosen_parent_location
            )
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            parent_id = serializer_location_table.data["location_id"]

        automatic_exit_required = False
        if automatic_exit_required_str == "Yes":
            automatic_exit_required = True

        location_already_exists = (
            len(Location.objects.filter(location_name=new_location_name)) != 0
        )

        if location_already_exists:
            Location.objects.filter(location_name=new_location_name).update(
                parent_id=parent_id,
                pre_approval_required=approval_flag,
                automatic_exit_required=automatic_exit_required,
                is_present=True,
            )

        else:
            Location.objects.create(
                location_name=new_location_name,
                parent_id=parent_id,
                pre_approval_required=approval_flag,
                automatic_exit_required=automatic_exit_required,
                is_present=True,
            )

        queryset_student = Student.objects.all()

        queryset_location_table = Location.objects.get(location_name=new_location_name)

        for each_queryset_student in queryset_student:
            StatusTable.objects.create(
                entry_no=each_queryset_student,
                location_id=queryset_location_table,
                current_status="out",
            )

        response_str = "New location added successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in adding new location")
        response_str = "Failed to add new location"
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def modify_locations(request):
    data = request.data

    try:
        chosen_modify_location = data["chosen_modify_location"]
        chosen_parent_location = data["chosen_parent_location"]
        chosen_pre_approval_needed = data["chosen_pre_approval_needed"]
        automatic_exit_required_str = data["automatic_exit_required"]

        approval_flag = False
        if chosen_pre_approval_needed == "Yes":
            approval_flag = True

        automatic_exit_required = False
        if automatic_exit_required_str == "Yes":
            automatic_exit_required = True

        if chosen_parent_location == "None":
            Location.objects.filter(location_name=chosen_modify_location).update(
                parent_id=-1,
                pre_approval_required=approval_flag,
                automatic_exit_required=automatic_exit_required,
            )

        else:
            queryset_location_table = Location.objects.get(
                location_name=chosen_modify_location
            )
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            chosen_modify_location_id = serializer_location_table.data["location_id"]
            # print("chosen_modify_location_id")
            # print(chosen_modify_location_id)

            queryset_location_table = Location.objects.get(
                location_name=chosen_parent_location
            )
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            chosen_parent_location_id = serializer_location_table.data["location_id"]
            new_parent_id = chosen_parent_location_id
            # print("new_parent_id")
            # print(new_parent_id)

            cycle_detected = False

            while True:
                queryset_location_table = Location.objects.get(
                    location_id=chosen_parent_location_id
                )
                serializer_location_table = LocationSerializer(
                    queryset_location_table, many=False
                )
                parent_location_id = serializer_location_table.data["parent_id"]

                # print("parent_location_id")
                # print(parent_location_id)

                if parent_location_id == -1:
                    # No cycle detected
                    break

                elif parent_location_id == chosen_modify_location_id:
                    # Cycle detected
                    cycle_detected = True
                    break

                else:
                    chosen_parent_location_id = parent_location_id

            if cycle_detected == False:
                Location.objects.filter(location_name=chosen_modify_location).update(
                    parent_id=new_parent_id,
                    pre_approval_required=approval_flag,
                    automatic_exit_required=automatic_exit_required,
                )

                response_str = "Location updated successfully"
                return Response(response_str, status=status.HTTP_200_OK)

            else:
                response_str = "Location data cannot be updated as a cycle is present"
                return Response(
                    response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )

    except Exception as e:
        print("Exception in updating location data")
        response_str = "Failed to update location data"
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def delete_location(request):
    data = request.data

    try:
        to_delete_location_name = data["chosen_delete_location"]

        Location.objects.filter(location_name=to_delete_location_name).update(
            is_present=False
        )

        StatusTable.objects.filter(
            location_id=Location.objects.get(location_name=to_delete_location_name),
        ).delete()

        response_str = "Location deleted successfully"

        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in delete location")
        print(e)
        response_str = "Failed to delete location"
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# @api_view(['GET'])
# def get_tickets_from_guard_ticket_table(request):
#     data = request.data

#     email_ = data['email']
#     queryset_entry_no = Student.objects.get(email = email_)
#     serializer_student_table = StudentSerializer(queryset_entry_no, many=False)
#     entry_no_ = str(serializer_student_table.data['entry_no'])

#     queryset_ticket_table = TicketTable.objects.filter(entry_no = queryset_entry_no)
#     serializer_ticket_table = TicketTableSerializer(queryset_ticket_table, many=True)
#     return Response(serializer_ticket_table.data)


@api_view(["POST"])
def get_tickets_for_student(request):
    data = request.data

    email_ = data["email"]
    queryset_entry_no = Student.objects.get(email=email_)

    location = data["location"]
    queryset_location_table = Location.objects.get(location_name=location)

    queryset_ticket_table = TicketTable.objects.filter(
        entry_no=queryset_entry_no, location_id=queryset_location_table
    )

    tickets_list = []

    for queryset_ticket in queryset_ticket_table:
        ticket = TicketTableSerializer(queryset_ticket, many=False)
        ResultObj = {}
        ResultObj["is_approved"] = ticket["is_approved"].value
        ResultObj["ticket_type"] = ticket["ticket_type"].value
        ResultObj["date_time"] = ticket["date_time"].value
        ResultObj["vehicle_number"] = ticket["vehicle_reg_num"].value
        location_id_ = ticket["location_id"].value
        queryset_location_table = Location.objects.get(location_id=location_id_)
        serializer_location_table = LocationSerializer(
            queryset_location_table, many=False
        )
        location_name = serializer_location_table.data["location_name"]
        ResultObj["location"] = location_name
        ResultObj["destination_address"] = ticket["destination_address"].value

        entry_no_ = ticket["entry_no"].value
        queryset_entry_no = Student.objects.get(entry_no=entry_no_)
        serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
        email_ = serializer_entry_no.data["email"]
        student_name = serializer_entry_no.data["st_name"]
        ResultObj["email"] = email_
        ResultObj["student_name"] = student_name

        ResultObj["authority_status"] = "NA"

        tickets_list.append(ResultObj)

    tickets_list.reverse()
    return Response(tickets_list)


@api_view(["POST"])
def get_authority_tickets_for_students(request):
    try:
        data = request.data

        email_ = data["email"]

        location = data["location"]

        queryset_entry_no = Student.objects.get(email=email_)

        queryset_location_table = Location.objects.get(location_name=location)

        queryset_ticket_table = AuthoritiesTicketTable.objects.filter(
            entry_no=queryset_entry_no, location_id=queryset_location_table
        )

        tickets_list = []

        for queryset_ticket in queryset_ticket_table:
            ticket = AuthoritiesTicketTableSerializer(queryset_ticket, many=False)

            ResultObj = {}

            ResultObj["is_approved"] = ticket["is_approved"].value

            ResultObj["ticket_type"] = ticket["ticket_type"].value

            ResultObj["date_time"] = ticket["date_time"].value

            location_id_ = ticket["location_id"].value
            queryset_location_table = Location.objects.get(location_id=location_id_)
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            location_name = serializer_location_table.data["location_name"]
            ResultObj["location"] = location_name

            entry_no_ = ticket["entry_no"].value
            queryset_entry_no = Student.objects.get(entry_no=entry_no_)
            serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
            email_ = serializer_entry_no.data["email"]
            student_name = serializer_entry_no.data["st_name"]

            ResultObj["email"] = email_
            ResultObj["student_name"] = student_name

            authority_status = ""

            try:
                # ref_id = ticket['ref_id'].value

                # queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.get(ref_id=ref_id)

                # serializer_authorities_ticket_table = AuthoritiesTicketTableSerializer(queryset_authorities_ticket_table, many=False)

                # auth_id = serializer_authorities_ticket_table.data['auth_id']

                auth_id = ticket["auth_id"].value

                queryset_authorities_table = Authorities.objects.get(auth_id=auth_id)

                serializer_authorities = AuthoritiesSerializer(
                    queryset_authorities_table, many=False
                )

                authority_name = serializer_authorities.data["authority_name"]

                authority_designation = serializer_authorities.data[
                    "authority_designation"
                ]

                authority_message = ticket["authority_message"].value

                is_approved = ticket["is_approved"].value

                authority_status = (
                    authority_name
                    + ", "
                    + authority_designation
                    + "\n"
                    + is_approved
                    + "\n"
                    + "authority_message: "
                    + authority_message
                )

            except:
                authority_status = "NA"

            ResultObj["authority_status"] = authority_status

            # Use if required
            ResultObj["student_message"] = ticket["student_message"].value

            tickets_list.append(ResultObj)

        tickets_list.reverse()

        return Response(tickets_list, status=status.HTTP_200_OK)

    except:
        res = []
        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_pending_tickets_for_guard(request):
    try:
        data = request.data

        location = data["location"]
        enter_exit = data["enter_exit"]

        queryset_location_table = Location.objects.get(location_name=location)
        # print(f'ashish={queryset_location_table},{enter_exit}')

        queryset_ticket_table = TicketTable.objects.filter(
            location_id=queryset_location_table,
            is_approved="Pending",
            ticket_type=enter_exit,
        )

        # queryset_ticket_table = TicketTable.objects.all()

        pending_tickets_list = []

        # print(f"queryset Ticket table={len(queryset_ticket_table)}")
        # print(type(queryset_ticket_table))

        for queryset_ticket in queryset_ticket_table:
            ticket = TicketTableSerializer(queryset_ticket, many=False)
            ResultObj = {}
            print(f"each ticket = {queryset_ticket}")
            ResultObj["is_approved"] = ticket["is_approved"].value
            ResultObj["ticket_type"] = ticket["ticket_type"].value
            ResultObj["date_time"] = ticket["date_time"].value
            location_id_ = ticket["location_id"].value
            queryset_location_table = Location.objects.get(location_id=location_id_)
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            location_name = serializer_location_table.data["location_name"]
            ResultObj["location"] = location_name
            ResultObj["destination_address"] = ticket["destination_address"].value

            entry_no_ = ticket["entry_no"].value
            queryset_entry_no = Student.objects.get(entry_no=entry_no_)
            serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
            email_ = serializer_entry_no.data["email"]
            student_name = serializer_entry_no.data["st_name"]
            ResultObj["email"] = email_
            ResultObj["student_name"] = student_name

            ref_id = ticket["ref_id"].value

            authority_status = ""

            try:

                queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.get(
                    ref_id=ref_id
                )

                serializer_authorities_ticket_table = AuthoritiesTicketTableSerializer(
                    queryset_authorities_ticket_table, many=False
                )

                auth_id = serializer_authorities_ticket_table.data["auth_id"]

                queryset_authorities_table = Authorities.objects.get(auth_id=auth_id)

                serializer_authorities = AuthoritiesSerializer(
                    queryset_authorities_table, many=False
                )

                authority_name = serializer_authorities.data["authority_name"]

                authority_designation = serializer_authorities.data[
                    "authority_designation"
                ]

                authority_message = serializer_authorities_ticket_table.data[
                    "authority_message"
                ]
                is_approved = serializer_authorities_ticket_table.data["is_approved"]

                authority_status = (
                    authority_name
                    + ", "
                    + authority_designation
                    + "\n"
                    + is_approved
                    + "\n"
                    + "authority_message: "
                    + authority_message
                )

            except:
                authority_status = "NA"

            ResultObj["authority_status"] = authority_status

            pending_tickets_list.append(ResultObj)

        pending_tickets_list.reverse()

        # print(f'Pending ticket list = {pending_tickets_list}')
        return Response(pending_tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        pending_tickets_list = []
        print("Exception in get_pending_tickets_for_guard: " + str(e))
        traceback.print_exc()
        return Response(
            pending_tickets_list, status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(["POST"])
def get_pending_tickets_for_visitors(request):
    try:
        data = request.data

        enter_exit = data["enter_exit"]
        queryset_visitor_ticket_table = VisitorTicketTable.objects.filter(
            ticket_type=enter_exit, guard_status="Pending"
        )

        serializer_visitor_ticket_table = VisitorTicketTableSerializer(
            queryset_visitor_ticket_table, many=True
        )

        pending_tickets_list = []

        for visitor_tickets in serializer_visitor_ticket_table.data:
            ResultObj = {}
            visitor_id = visitor_tickets["visitor_id"]
            queryset_visitor = Visitor.objects.get(visitor_id=visitor_id)
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)

            auth_id = visitor_tickets["auth_id"]
            # print(auth_id)
            if auth_id:
                queryset_authorities = Authorities.objects.get(auth_id=auth_id)
                serializer_authorities = AuthoritiesSerializer(
                    queryset_authorities, many=False
                )
                ResultObj["authority_name"] = serializer_authorities.data[
                    "authority_name"
                ]
                ResultObj["authority_email"] = serializer_authorities.data["email"]
                ResultObj["authority_designation"] = serializer_authorities.data[
                    "authority_designation"
                ]

            else:
                ResultObj["authority_name"] = ""
                ResultObj["authority_email"] = ""
                ResultObj["authority_designation"] = ""

            ResultObj["visitor_name"] = serializer_visitor.data["visitor_name"]
            ResultObj["mobile_no"] = serializer_visitor.data["mobile_no"]
            ResultObj["current_status"] = serializer_visitor.data["current_status"]
            ResultObj["car_number"] = visitor_tickets["car_number"]
            ResultObj["purpose"] = visitor_tickets["purpose"]
            ResultObj["authority_status"] = visitor_tickets["authority_status"]
            ResultObj["authority_message"] = visitor_tickets["authority_message"]
            ResultObj["date_time_of_ticket_raised"] = visitor_tickets[
                "date_time_of_ticket_raised"
            ]
            ResultObj["date_time_authority"] = visitor_tickets["date_time_authority"]
            ResultObj["date_time_guard"] = visitor_tickets["date_time_guard"]
            ResultObj["date_time_of_exit"] = visitor_tickets["date_time_of_exit"]
            ResultObj["guard_status"] = visitor_tickets["guard_status"]
            ResultObj["ticket_type"] = visitor_tickets["ticket_type"]
            ResultObj["visitor_ticket_id"] = visitor_tickets["visitor_ticket_id"]
            ResultObj["duration_of_stay"] = visitor_tickets["duration_of_stay"]
            ResultObj["num_additional"] = str(visitor_tickets["num_additional"])

            pending_tickets_list.append(ResultObj)

        pending_tickets_list.reverse()

        return Response(pending_tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        pending_tickets_list = []
        print("Exception in get_pending_tickets_for_visitors: " + str(e))
        return Response(
            pending_tickets_list, status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(["POST"])
def get_visitor_tickets(request):
    print("$$$")
    try:
        data = request.data
        is_approved = data["is_approved"]
        enter_exit = data["enter_exit"]
        print(is_approved)
        print(enter_exit)

        queryset_visitor_ticket_table = VisitorTicketTable.objects.filter(
            ticket_type=enter_exit, guard_status=str(is_approved)
        )

        serializer_visitor_ticket_table = VisitorTicketTableSerializer(
            queryset_visitor_ticket_table, many=True
        )

        tickets_list = []

        for visitor_tickets in serializer_visitor_ticket_table.data:
            ResultObj = {}
            visitor_id = visitor_tickets["visitor_id"]
            queryset_visitor = Visitor.objects.get(visitor_id=visitor_id)
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)

            auth_id = visitor_tickets["auth_id"]
            # print(auth_id)
            if auth_id:
                queryset_authorities = Authorities.objects.get(auth_id=auth_id)
                serializer_authorities = AuthoritiesSerializer(
                    queryset_authorities, many=False
                )
                ResultObj["authority_name"] = serializer_authorities.data[
                    "authority_name"
                ]
                ResultObj["authority_email"] = serializer_authorities.data["email"]
                ResultObj["authority_designation"] = serializer_authorities.data[
                    "authority_designation"
                ]

            else:
                ResultObj["authority_name"] = ""
                ResultObj["authority_email"] = ""
                ResultObj["authority_designation"] = ""

            ResultObj["visitor_name"] = serializer_visitor.data["visitor_name"]
            ResultObj["mobile_no"] = serializer_visitor.data["mobile_no"]
            ResultObj["current_status"] = serializer_visitor.data["current_status"]
            ResultObj["car_number"] = visitor_tickets["car_number"]
            ResultObj["purpose"] = visitor_tickets["purpose"]
            ResultObj["authority_status"] = visitor_tickets["authority_status"]
            ResultObj["authority_message"] = visitor_tickets["authority_message"]
            ResultObj["date_time_of_ticket_raised"] = visitor_tickets[
                "date_time_of_ticket_raised"
            ]
            ResultObj["date_time_authority"] = visitor_tickets["date_time_authority"]
            ResultObj["date_time_guard"] = visitor_tickets["date_time_guard"]
            ResultObj["date_time_of_exit"] = visitor_tickets["date_time_of_exit"]
            ResultObj["guard_status"] = visitor_tickets["guard_status"]
            ResultObj["ticket_type"] = visitor_tickets["ticket_type"]
            ResultObj["visitor_ticket_id"] = visitor_tickets["visitor_ticket_id"]
            ResultObj["duration_of_stay"] = visitor_tickets["duration_of_stay"]
            ResultObj["num_additional"] = str(visitor_tickets["num_additional"])

            tickets_list.append(ResultObj)
        print(tickets_list)
        tickets_list.reverse()

        return Response(tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        tickets_list = []
        print("Exception in get_visitor_tickets: " + str(e))
        return Response(tickets_list, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_pending_visitor_tickets_for_authorities(request):
    try:
        data = request.data

        authority_email = data["authority_email"]
        print("authority_email :" + authority_email)
        queryset_authorities_table = Authorities.objects.get(email=authority_email)

        serializer_authorities_table = AuthoritiesSerializer(
            queryset_authorities_table, many=False
        )

        auth_id = serializer_authorities_table.data["auth_id"]
        print("auth_id :", auth_id)
        queryset_visitor_ticket_table = VisitorTicketTable.objects.filter(
            auth_id=auth_id, authority_status="Pending"
        )

        serializer_visitor_ticket_table = VisitorTicketTableSerializer(
            queryset_visitor_ticket_table, many=True
        )
        print(serializer_visitor_ticket_table.data)
        pending_tickets_list = []
        for visitor_tickets in serializer_visitor_ticket_table.data:
            ResultObj = {}
            visitor_id = visitor_tickets["visitor_id"]
            queryset_visitor = Visitor.objects.get(visitor_id=visitor_id)
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)

            auth_id = visitor_tickets["auth_id"]
            queryset_authorities = Authorities.objects.get(auth_id=auth_id)
            serializer_authorities = AuthoritiesSerializer(
                queryset_authorities, many=False
            )

            ResultObj["visitor_name"] = serializer_visitor.data["visitor_name"]
            ResultObj["mobile_no"] = serializer_visitor.data["mobile_no"]
            ResultObj["current_status"] = serializer_visitor.data["current_status"]
            ResultObj["car_number"] = visitor_tickets["car_number"]
            ResultObj["authority_name"] = serializer_authorities.data["authority_name"]
            ResultObj["authority_email"] = serializer_authorities.data["email"]
            ResultObj["authority_designation"] = serializer_authorities.data[
                "authority_designation"
            ]
            ResultObj["purpose"] = visitor_tickets["purpose"]
            ResultObj["authority_status"] = visitor_tickets["authority_status"]
            ResultObj["authority_message"] = visitor_tickets["authority_message"]
            ResultObj["date_time_of_ticket_raised"] = visitor_tickets[
                "date_time_of_ticket_raised"
            ]
            ResultObj["date_time_authority"] = visitor_tickets["date_time_authority"]
            ResultObj["date_time_guard"] = visitor_tickets["date_time_guard"]
            ResultObj["date_time_of_exit"] = visitor_tickets["date_time_of_exit"]
            ResultObj["guard_status"] = visitor_tickets["guard_status"]
            ResultObj["ticket_type"] = visitor_tickets["ticket_type"]
            ResultObj["visitor_ticket_id"] = visitor_tickets["visitor_ticket_id"]
            ResultObj["duration_of_stay"] = visitor_tickets["duration_of_stay"]

            pending_tickets_list.append(ResultObj)
        pending_tickets_list.reverse()

        return Response(pending_tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        pending_tickets_list = []
        print("Exception in get_pending_visitor_tickets_for_authorities: " + str(e))
        return Response(
            pending_tickets_list, status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(["POST"])
def get_past_visitor_tickets_for_authorities(request):
    try:
        data = request.data

        authority_email = data["authority_email"]

        queryset_authorities_table = Authorities.objects.get(email=authority_email)

        serializer_authorities_table = AuthoritiesSerializer(
            queryset_authorities_table, many=False
        )

        auth_id = serializer_authorities_table.data["auth_id"]

        queryset_visitor_ticket_table = VisitorTicketTable.objects.filter(
            auth_id=auth_id
        ).exclude(authority_status="Pending")

        serializer_visitor_ticket_table = VisitorTicketTableSerializer(
            queryset_visitor_ticket_table, many=True
        )

        past_tickets_list = []
        for visitor_tickets in serializer_visitor_ticket_table.data:
            ResultObj = {}
            visitor_id = visitor_tickets["visitor_id"]
            queryset_visitor = Visitor.objects.get(visitor_id=visitor_id)
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)

            auth_id = visitor_tickets["auth_id"]
            queryset_authorities = Authorities.objects.get(auth_id=auth_id)
            serializer_authorities = AuthoritiesSerializer(
                queryset_authorities, many=False
            )

            ResultObj["visitor_name"] = serializer_visitor.data["visitor_name"]
            ResultObj["mobile_no"] = serializer_visitor.data["mobile_no"]
            ResultObj["current_status"] = serializer_visitor.data["current_status"]
            ResultObj["car_number"] = visitor_tickets["car_number"]
            ResultObj["authority_name"] = serializer_authorities.data["authority_name"]
            ResultObj["authority_email"] = serializer_authorities.data["email"]
            ResultObj["authority_designation"] = serializer_authorities.data[
                "authority_designation"
            ]
            ResultObj["purpose"] = visitor_tickets["purpose"]
            ResultObj["authority_status"] = visitor_tickets["authority_status"]
            ResultObj["authority_message"] = visitor_tickets["authority_message"]
            ResultObj["date_time_of_ticket_raised"] = visitor_tickets[
                "date_time_of_ticket_raised"
            ]
            ResultObj["date_time_authority"] = visitor_tickets["date_time_authority"]
            ResultObj["date_time_guard"] = visitor_tickets["date_time_guard"]
            ResultObj["date_time_of_exit"] = visitor_tickets["date_time_of_exit"]
            ResultObj["guard_status"] = visitor_tickets["guard_status"]
            ResultObj["ticket_type"] = visitor_tickets["ticket_type"]
            ResultObj["visitor_ticket_id"] = visitor_tickets["visitor_ticket_id"]
            ResultObj["duration_of_stay"] = visitor_tickets["duration_of_stay"]

            past_tickets_list.append(ResultObj)
        past_tickets_list.reverse()

        return Response(past_tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        past_tickets_list = []
        print("Exception in get_past_visitor_tickets_for_authorities: " + str(e))
        return Response(past_tickets_list, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_pending_tickets_for_authorities(request):
    try:
        data = request.data

        authority_email = data["authority_email"]

        queryset_authorities_table = Authorities.objects.get(email=authority_email)

        queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.filter(
            auth_id=queryset_authorities_table, is_approved="Pending"
        )

        pending_tickets_list = []

        for queryset_ticket in queryset_authorities_ticket_table:
            ticket = AuthoritiesTicketTableSerializer(queryset_ticket, many=False)

            ResultObj = {}

            ResultObj["is_approved"] = ticket["is_approved"].value

            ResultObj["ticket_type"] = ticket["ticket_type"].value

            ResultObj["date_time"] = ticket["date_time"].value

            location_id_ = ticket["location_id"].value
            queryset_location_table = Location.objects.get(location_id=location_id_)
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            location_name = serializer_location_table.data["location_name"]
            ResultObj["location"] = location_name

            entry_no_ = ticket["entry_no"].value
            queryset_entry_no = Student.objects.get(entry_no=entry_no_)
            serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
            email_ = serializer_entry_no.data["email"]
            student_name = serializer_entry_no.data["st_name"]

            ResultObj["email"] = email_

            ResultObj["student_name"] = student_name

            ResultObj["authority_message"] = ticket["authority_message"].value

            pending_tickets_list.append(ResultObj)

        # Thus the fields are [is_approved,ticket_type,date_time,location,email,student_name,authority_message]
        pending_tickets_list.reverse()

        return Response(pending_tickets_list, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in get_pending_tickets_for_guard: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_tickets_for_guard(request):
    try:
        data = request.data

        location = data["location"]
        enter_exit = data["enter_exit"]
        queryset_location_table = Location.objects.get(location_name=location)

        is_approved_ = data["is_approved"]

        queryset_ticket_table = TicketTable.objects.filter(
            location_id=queryset_location_table,
            is_approved=is_approved_,
            ticket_type=enter_exit,
        )

        tickets_list = []

        for queryset_ticket in queryset_ticket_table:
            ticket = TicketTableSerializer(queryset_ticket, many=False)
            ResultObj = {}
            ResultObj["is_approved"] = ticket["is_approved"].value
            ResultObj["ticket_type"] = ticket["ticket_type"].value
            ResultObj["date_time"] = ticket["date_time"].value
            location_id_ = ticket["location_id"].value
            queryset_location_table = Location.objects.get(location_id=location_id_)
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            location_name = serializer_location_table.data["location_name"]
            ResultObj["location"] = location_name
            ResultObj["destination_address"] = ticket["destination_address"].value

            entry_no_ = ticket["entry_no"].value
            queryset_entry_no = Student.objects.get(entry_no=entry_no_)
            serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
            email_ = serializer_entry_no.data["email"]
            student_name = serializer_entry_no.data["st_name"]
            ResultObj["email"] = email_
            ResultObj["student_name"] = student_name

            ref_id = ticket["ref_id"].value
            vehicle_number = ticket["vehicle_reg_num"].value

            authority_status = ""

            print()

            try:

                queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.get(
                    ref_id=ref_id
                )

                serializer_authorities_ticket_table = AuthoritiesTicketTableSerializer(
                    queryset_authorities_ticket_table, many=False
                )

                auth_id = serializer_authorities_ticket_table.data["auth_id"]

                queryset_authorities_table = Authorities.objects.get(auth_id=auth_id)

                serializer_authorities = AuthoritiesSerializer(
                    queryset_authorities_table, many=False
                )

                authority_name = serializer_authorities.data["authority_name"]

                authority_designation = serializer_authorities.data[
                    "authority_designation"
                ]

                authority_message = serializer_authorities_ticket_table.data[
                    "authority_message"
                ]
                is_approved = serializer_authorities_ticket_table.data["is_approved"]

                authority_status = (
                    authority_name
                    + ", "
                    + authority_designation
                    + "\n"
                    + is_approved
                    + "\n"
                    + "authority_message: "
                    + authority_message
                )

            except:
                authority_status = "NA"

            ResultObj["authority_status"] = authority_status
            ResultObj["vehicle_number"] = vehicle_number

            # print("ResultObj")
            # print(ResultObj)
            tickets_list.append(ResultObj)

        # json_str = json.dumps(tickets_list)
        # print(json_str)
        tickets_list.reverse()

        return Response(tickets_list)

    except Exception as e:
        print("Exception in get_tickets_for_guard: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_list_of_entry_numbers(request):
    try:
        queryset_student = Student.objects.filter(is_present=True)

        res = []
        serializer = StudentSerializer(queryset_student, many=True)

        for current_student in serializer.data:
            if current_student["st_name"] == initial_data:
                continue
            obj = {
                "entry_no": current_student["entry_no"],
                "st_name": current_student["st_name"],
                "email": current_student["email"],
            }
            res.append(obj)

        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        # print("Exception in get_tickets_for_guard: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_list_of_visitors(request):
    try:
        queryset_visitor = Visitor.objects.filter(is_present=True)

        res = []

        serializer = VisitorSerializer(queryset_visitor, many=True)

        for current_visitor in serializer.data:
            if current_visitor["visitor_name"] == initial_data:
                continue
            obj = {
                "visitor_name": current_visitor["visitor_name"],
                "mobile_no": current_visitor["mobile_no"],
                # 'current_status' : current_visitor['current_status'],
                # 'car_number' : current_visitor['car_number'],
                # 'authority_name' : current_visitor['authority_name'],
                # 'authority_email' : current_visitor['authority_email'],
                # 'authority_designation' : current_visitor['authority_designation'],
                # 'purpose' : current_visitor['purpose'],
                # 'authority_status' : current_visitor['authority_status'],
                # 'authority_message' : current_visitor['authority_message'],
                # 'date_time_of_ticket_raised' : current_visitor['date_time_of_ticket_raised'],
                # 'date_time_authority' : current_visitor['date_time_authority'],
                # 'date_time_guard' : current_visitor['date_time_guard'],
                # 'date_time_of_exit' : current_visitor['date_time_of_exit'],
                # 'guard_status' : current_visitor['guard_status'],
                # 'ticket_type' : current_visitor['ticket_type'],
                # 'visitor_ticket_id' : current_visitor['visitor_ticket_id'],
            }
            res.append(obj)

        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_tickets_for_authorities(request):
    try:
        data = request.data

        authority_email = data["authority_email"]

        queryset_authorities_table = Authorities.objects.get(email=authority_email)

        is_approved_ = data["is_approved"]

        queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.filter(
            auth_id=queryset_authorities_table, is_approved=is_approved_
        )

        tickets_list = []

        for queryset_ticket in queryset_authorities_ticket_table:
            ticket = AuthoritiesTicketTableSerializer(queryset_ticket, many=False)
            ResultObj = {}

            ResultObj["is_approved"] = ticket["is_approved"].value

            ResultObj["ticket_type"] = ticket["ticket_type"].value

            ResultObj["date_time"] = ticket["date_time"].value

            location_id_ = ticket["location_id"].value

            queryset_location_table = Location.objects.get(location_id=location_id_)
            serializer_location_table = LocationSerializer(
                queryset_location_table, many=False
            )
            location_name = serializer_location_table.data["location_name"]
            ResultObj["location"] = location_name

            entry_no_ = ticket["entry_no"].value
            queryset_entry_no = Student.objects.get(entry_no=entry_no_)
            serializer_entry_no = StudentSerializer(queryset_entry_no, many=False)
            email_ = serializer_entry_no.data["email"]
            student_name = serializer_entry_no.data["st_name"]

            ResultObj["email"] = email_
            ResultObj["student_name"] = student_name

            ResultObj["authority_message"] = ticket["authority_message"].value

            tickets_list.append(ResultObj)

        tickets_list.reverse()
        print(tickets_list)

        # Thus the fields are [is_approved, ticket_type, date_time, location, email, student_name, authority_message]
        return Response(tickets_list)

    except Exception as e:
        print("Exception in get_tickets_for_guard: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_student_status(request):
    try:
        email_ = request.data["email"]

        location_name_ = request.data["location"]

        # Finding current status of this student for the current location

        queryset_entry_no = Student.objects.get(email=email_)

        queryset_location_table = Location.objects.get(location_name=location_name_)

        serializer_location_table = LocationSerializer(
            queryset_location_table, many=False
        )

        current_location_id = serializer_location_table.data["location_id"]

        parent_id = serializer_location_table.data["parent_id"]

        queryset_status_table = StatusTable.objects.get(
            entry_no=queryset_entry_no, location_id=queryset_location_table
        )

        serializer_status_table = StatusTableSerializer(
            queryset_status_table, many=False
        )

        current_status = serializer_status_table.data["current_status"]

        # Find its parent location and thi status of the student for the parent location

        inside_parent_location = "true"

        if parent_id != -1:
            try:
                queryset_parent = Location.objects.get(location_id=parent_id)

                queryset_status_table = StatusTable.objects.get(
                    entry_no=queryset_entry_no,
                    location_id=queryset_parent,
                )

                serializer_status_table = StatusTableSerializer(
                    queryset_status_table, many=False
                )

                current_status_of_student_in_parent = serializer_status_table.data[
                    "current_status"
                ]

                if current_status_of_student_in_parent == "out":
                    inside_parent_location = "false"

            except:
                pass

        # Finding child location and the status of the student for the child location

        exited_all_children = "true"

        queryset_location_all = Location.objects.all()

        for each_location in queryset_location_all:

            serializer = LocationSerializer(each_location, many=False)

            potential_same_id = serializer.data["parent_id"]

            if current_location_id == potential_same_id:

                queryset_status_table = StatusTable.objects.get(
                    entry_no=queryset_entry_no,
                    location_id=each_location,
                )

                serializer_status_table = StatusTableSerializer(
                    queryset_status_table, many=False
                )

                current_status_of_student_in_child = serializer_status_table.data[
                    "current_status"
                ]

                if current_status_of_student_in_child == "in":

                    exited_all_children = "false"

                    break

        res = {}

        res["in_or_out"] = current_status

        res["inside_parent_location"] = inside_parent_location

        res["exited_all_children"] = exited_all_children

        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:

        print("Exception in get_student_status: " + str(e))

        res = {}

        res["in_or_out"] = "Invalid Status"

        res["inside_parent_location"] = ""

        res["exited_all_children"] = ""

        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def insert_in_guard_ticket_table(request):
    try:
        data = request.data
        email_ = data["email"]
        queryset_entry_no = Student.objects.get(email=email_)

        location_ = data["location"]
        queryset_location_table = Location.objects.get(location_name=location_)

        # queryset_ref_id = AuthoritiesTicketTable.objects.get(ref_id = 1)

        ticket_type_ = str(data["ticket_type"])

        date_time_ = str(data["date_time"])

        choosen_authority_ticket = str(data["choosen_authority_ticket"])

        address = str(data["address"])

        if choosen_authority_ticket == "" or choosen_authority_ticket == "None":
            queryset = TicketTable.objects.create(
                location_id=queryset_location_table,
                entry_no=queryset_entry_no,
                # ref_id = queryset_ref_id,
                ticket_type=ticket_type_,
                date_time=date_time_,
                destination_address=address,
            )

        else:
            ref_id = int(choosen_authority_ticket.split("\n")[3])

            queryset_ref_id = AuthoritiesTicketTable.objects.get(ref_id=ref_id)

            queryset = TicketTable.objects.create(
                location_id=queryset_location_table,
                entry_no=queryset_entry_no,
                ref_id=queryset_ref_id,
                ticket_type=ticket_type_,
                date_time=date_time_,
                destination_address=address,
            )

        # If the student has raised an entry ticket, then mark the status of student as "pending_entry"
        if ticket_type_ == "enter":
            queryset_status_table = StatusTable.objects.filter(
                entry_no=queryset_entry_no, location_id=queryset_location_table
            ).update(current_status="pending_entry")
            print("is status updated by insert into guard ticket table backend")
            print("Status Table")
            print(StatusTable.objects.all())

        elif ticket_type_ == "exit":
            queryset_status_table = StatusTable.objects.filter(
                entry_no=queryset_entry_no, location_id=queryset_location_table
            ).update(current_status="pending_exit")

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("insert into guard ticket table raised exception")
        print(e)
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def insert_in_authorities_ticket_table(request):
    try:
        data = request.data

        chosen_authority = data["chosen_authority"]
        ticket_type = data["ticket_type"]
        student_message = data["student_message"]
        email = data["email"]
        date_time = data["date_time"]
        location = data["location"]

        authority_email = str(chosen_authority.split("\n")[1])

        print("authority_email in backend printed: " + authority_email)

        queryset_entry_no = Student.objects.get(email=email)

        queryset_location_table = Location.objects.get(location_name=location)

        queryset_authorities_table = Authorities.objects.get(email=authority_email)

        queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.create(
            auth_id=queryset_authorities_table,
            entry_no=queryset_entry_no,
            date_time=date_time,
            location_id=queryset_location_table,
            ticket_type=ticket_type,
            student_message=student_message,
            is_approved="Pending",
        )

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("insert_in_authorities_ticket_table raised exception: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def accept_selected_tickets(request):
    try:
        list_data = request.data

        for data in list_data:
            # print(data)
            location = data["location"]
            is_approved_ = data["is_approved"]
            ticket_type_ = data["ticket_type"]
            date_time_ = data["date_time"]
            email_ = data["email"]
            queryset_location_table = Location.objects.get(location_name=location)
            queryset_entry_no = Student.objects.get(email=email_)

            queryset_ticket_table = TicketTable.objects.filter(
                entry_no=queryset_entry_no,
                location_id=queryset_location_table,
                date_time=date_time_,
            ).update(is_approved="Approved")

            # If the ticket is an entry ticket and the guard has pressed approved, then mark the current status of that person as "in"
            if ticket_type_ == "enter":
                queryset_status_table = StatusTable.objects.filter(
                    entry_no=queryset_entry_no, location_id=queryset_location_table
                ).update(current_status="in")
            # If the ticket is an exit ticket and the guard has pressed approved, then mark the current status of that person as "out"
            elif ticket_type_ == "exit":
                queryset_status_table = StatusTable.objects.filter(
                    entry_no=queryset_entry_no, location_id=queryset_location_table
                ).update(current_status="out")

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("accepted selected tickets raised exception: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def accept_selected_tickets_visitors(request):
    try:
        list_data = request.data
        # print(list_data)
        for data in list_data:

            visitor_name = data["visitor_name"]
            mobile_no = data["mobile_no"]
            current_status = data["current_status"]
            car_number = data["car_number"]
            authority_name = data["authority_name"]
            authority_email = data["authority_email"]
            authority_designation = data["authority_designation"]
            purpose = data["purpose"]
            authority_status = data["authority_status"]
            authority_message = data["authority_message"]
            date_time_of_ticket_raised = data["date_time_of_ticket_raised"]
            date_time_authority = data["date_time_authority"]
            date_time_guard = data["date_time_guard"]
            date_time_of_exit = data["date_time_of_exit"]
            guard_status = data["guard_status"]
            ticket_type = data["ticket_type"]
            visitor_ticket_id = data["visitor_ticket_id"]

            if authority_status == "Pending":
                continue

            queryset_visitor = Visitor.objects.get(
                visitor_name=visitor_name, mobile_no=mobile_no
            )
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)
            visitor_id = serializer_visitor.data["visitor_id"]

            # If the ticket is an entry ticket and the guard has pressed approved, then mark the current status of that person as "in" and thereafter change it to "pending_exit"
            if ticket_type == "enter":
                VisitorTicketTable.objects.filter(
                    visitor_ticket_id=visitor_ticket_id
                ).update(guard_status="Approved", date_time_guard=datetime.now())

                Visitor.objects.filter(visitor_id=visitor_id).update(
                    current_status="pending_exit"
                )

            # If the ticket is an exit ticket and the guard has pressed approved, then mark the current status of that person as "out"
            elif ticket_type == "exit":
                VisitorTicketTable.objects.filter(
                    visitor_ticket_id=visitor_ticket_id
                ).update(
                    guard_status="Approved",
                    # ticket_type = "enter",
                    date_time_guard=datetime.now(),
                )

                Visitor.objects.filter(visitor_id=visitor_id).update(
                    current_status="out"
                )

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("Accept selected tickets for visitors raised exception: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def accept_selected_tickets_authorities(request):
    try:
        list_data = request.data

        # Fields are [is_approved, ticket_type, date_time, location, email, student_name, authority_message]

        for data in list_data:
            location = data["location"]

            is_approved_ = data["is_approved"]

            ticket_type_ = data["ticket_type"]

            date_time_ = data["date_time"]

            email_ = data["email"]

            authority_message = data["authority_message"]

            queryset_location_table = Location.objects.get(location_name=location)

            queryset_entry_no = Student.objects.get(email=email_)

            # Update the status to "Approved" and also update the authority message
            queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.filter(
                entry_no=queryset_entry_no,
                location_id=queryset_location_table,
                date_time=date_time_,
            ).update(
                is_approved="Approved",
                authority_message=authority_message,
            )

        return Response(status=status.HTTP_200_OK)

    except Exception as e:

        print("Exception in accept_selected_tickets_authorities: " + str(e))

        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def reject_selected_tickets(request):
    try:
        list_data = request.data

        for data in list_data:
            location = data["location"]
            is_approved_ = data["is_approved"]
            ticket_type_ = data["ticket_type"]
            date_time_ = data["date_time"]
            email_ = data["email"]
            queryset_location_table = Location.objects.get(location_name=location)
            queryset_entry_no = Student.objects.get(email=email_)

            queryset_ticket_table = TicketTable.objects.filter(
                entry_no=queryset_entry_no,
                location_id=queryset_location_table,
                date_time=date_time_,
            ).update(is_approved="Rejected")

            # If the ticket is an entry ticket and the guard has pressed rejected, then mark the current status of that person as "out"
            if ticket_type_ == "enter":
                queryset_status_table = StatusTable.objects.filter(
                    entry_no=queryset_entry_no, location_id=queryset_location_table
                ).update(current_status="out")
            # If the ticket is an exit ticket and the guard has pressed rejected, then mark the current status of that person as "in"
            elif ticket_type_ == "exit":
                queryset_status_table = StatusTable.objects.filter(
                    entry_no=queryset_entry_no, location_id=queryset_location_table
                ).update(current_status="in")

        return Response(status=status.HTTP_200_OK)
    except Exception as e:
        print("reject selected tickets raised exception")
        print(e)
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def reject_selected_tickets_visitors(request):
    try:
        list_data = request.data

        for data in list_data:

            visitor_name = data["visitor_name"]
            mobile_no = data["mobile_no"]
            current_status = data["current_status"]
            car_number = data["car_number"]
            authority_name = data["authority_name"]
            authority_email = data["authority_email"]
            authority_designation = data["authority_designation"]
            purpose = data["purpose"]
            authority_status = data["authority_status"]
            authority_message = data["authority_message"]
            date_time_of_ticket_raised = data["date_time_of_ticket_raised"]
            date_time_authority = data["date_time_authority"]
            date_time_guard = data["date_time_guard"]
            date_time_of_exit = data["date_time_of_exit"]
            guard_status = data["guard_status"]
            ticket_type = data["ticket_type"]
            visitor_ticket_id = data["visitor_ticket_id"]

            if authority_status == "Pending":
                continue

            queryset_visitor = Visitor.objects.get(
                visitor_name=visitor_name, mobile_no=mobile_no
            )
            serializer_visitor = VisitorSerializer(queryset_visitor, many=False)
            visitor_id = serializer_visitor.data["visitor_id"]

            # If the ticket is an entry ticket and the guard has pressed rejected, then mark the current status of that person as "out"
            if ticket_type == "enter":
                VisitorTicketTable.objects.filter(
                    visitor_ticket_id=visitor_ticket_id
                ).update(
                    guard_status="Rejected",
                    # ticket_type = "exit",
                    date_time_guard=datetime.now(),
                )

                Visitor.objects.filter(visitor_id=visitor_id).update(
                    current_status="out"
                )

            # If the ticket is an exit ticket and the guard has pressed approved, then mark the current status of that person as "out"
            elif ticket_type == "exit":
                VisitorTicketTable.objects.filter(
                    visitor_ticket_id=visitor_ticket_id
                ).update(
                    guard_status="Rejected",
                    # ticket_type = "enter",
                    date_time_guard=datetime.now(),
                )

                Visitor.objects.filter(visitor_id=visitor_id).update(
                    current_status="in"
                )

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("accepted selected tickets for visitors raised exception: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def reject_selected_tickets_authorities(request):
    try:
        list_data = request.data

        # Fields are [is_approved, ticket_type, date_time, location, email, student_name, authority_message]

        for data in list_data:

            location = data["location"]

            is_approved_ = data["is_approved"]

            ticket_type_ = data["ticket_type"]

            date_time_ = data["date_time"]

            email_ = data["email"]

            authority_message = data["authority_message"]

            queryset_location_table = Location.objects.get(location_name=location)

            queryset_entry_no = Student.objects.get(email=email_)

            # Update the status to "Rejected" and also update the authority message
            queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.filter(
                entry_no=queryset_entry_no,
                location_id=queryset_location_table,
                date_time=date_time_,
            ).update(
                is_approved="Rejected",
                authority_message=authority_message,
            )

        return Response(status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in reject_selected_tickets_authorities: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def approve_all_tickets(request):
    queryset_ticket_table = TicketTable.objects.filter(is_approved="Pending").update(
        is_approved="Approved"
    )
    if int(queryset_ticket_table) == 0:
        return Response(status=status.HTTP_200_OK)
    serializer_ticket_table = TicketTableSerializer(queryset_ticket_table, many=True)
    # return Response(serializer_ticket_table.data)
    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def reject_all_tickets(request):
    queryset_ticket_table = TicketTable.objects.filter(is_approved="Pending").update(
        is_approved="Rejected"
    )
    if int(queryset_ticket_table) == 0:
        return Response(status=status.HTTP_200_OK)
    serializer_ticket_table = TicketTableSerializer(queryset_ticket_table, many=True)
    # return Response(serializer_ticket_table.data)

    return Response(status=status.HTTP_200_OK)


@api_view(["POST"])
def get_guard_tickets_by_location(request):
    data = request.data
    location_name_ = data["location_name"]
    is_approved_ = data["is_approved"]

    queryset_location_table = Location.objects.get(location_name=location_name_)

    queryset_ticket_table = TicketTable.objects.filter(
        location_id=queryset_location_table, is_approved=is_approved_
    )

    serializer_ticket_table = TicketTableSerializer(queryset_ticket_table, many=True)

    return Response(serializer_ticket_table.data)


@api_view(["POST"])
def get_all_locations(request):
    res = []
    query_set = Location.objects.all()
    for each_query_set in query_set:
        serializer = LocationSerializer(each_query_set, many=False)
        location_name = serializer.data["location_name"]
        location_id = serializer.data["location_id"]
        parent_id = serializer.data["parent_id"]
        if parent_id == -1:
            parent_location = "NA"
        else:
            parent_location = Location.objects.get(location_id=parent_id).location_name

        is_present = serializer.data["is_present"]
        if location_name != initial_data and is_present:
            ResultObj = {"location_name": location_name}
            ResultObj["location_id"] = location_id
            ResultObj["parent_id"] = parent_id
            ResultObj["parent_location"] = parent_location
            ResultObj["pre_approval"] = serializer.data["pre_approval_required"]
            ResultObj["automatic_exit"] = serializer.data["automatic_exit_required"]
            res.append(ResultObj)
    output = {"output": res}
    return Response(output, status.HTTP_200_OK)


@api_view(["GET", "POST"])
def view_all_locations(request):
    res = []
    try:
        queryset = Location.objects.filter(is_present=True)

        serializer = LocationSerializer(queryset, many=True)

        for each_location in serializer.data:
            if each_location["location_name"] == initial_data:
                continue

            _parent_id = each_location["parent_id"]
            parent_location = "NA"
            if int(_parent_id) != -1:
                query_set_location = Location.objects.get(location_id=_parent_id)

                parent_location = LocationSerializer(
                    query_set_location, many=False
                ).data["location_name"]

            _pre_approval_required = "No"
            if each_location["pre_approval_required"]:
                _pre_approval_required = "Yes"

            _automatic_exit_required = "No"
            if each_location["automatic_exit_required"]:
                _automatic_exit_required = "Yes"

            item = {
                "location_name": each_location["location_name"],
                "parent_location": parent_location,
                "pre_approval_required": _pre_approval_required,
                "automatic_exit_required": _automatic_exit_required,
                "name": "",
                "entry_no": "",
                "email": "",
                "gender": "",
                "department": "",
                "degree_name": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "profile_img": "",
                "degree_duration": "",
                "designation": "",
            }
            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_parent_location_name(request):
    try:
        location = request.data["location"]
        query_set = Location.objects.get(location_name=location)
        serializer = LocationSerializer(query_set, many=False)
        parent_id = serializer.data["parent_id"]
        parent_location = ""
        if parent_id != -1:
            query_set = Location.objects.get(location_id=parent_id)
            serializer = LocationSerializer(query_set, many=False)
            parent_location = serializer.data["location_name"]

        res = {"parent_location": parent_location}
        return Response(res, status.HTTP_200_OK)
    except Exception as e:
        res = {"parent_location": parent_location}
        return Response(res, status.HTTP_500_INTERNAL_SERVER_ERROR)


# Guard


@api_view(["POST"])
def get_all_guard_emails(request):
    res = []
    query_set = Guard.objects.all()
    for each_query_set in query_set:
        serializer = GuardSerializer(each_query_set, many=False)
        _email = serializer.data["email"]
        is_present = serializer.data["is_present"]
        if is_present:
            ResultObj = {"email": _email}
            res.append(ResultObj)
    output = {"output": res}
    return Response(output, status.HTTP_200_OK)


@api_view(["POST"])
def get_guard_by_email(request):

    data = request.data
    email_ = data["email"]
    print(email_)
    try:
        queryset = Guard.objects.get(email=email_, is_present=True)
        serializer = GuardSerializer(queryset, many=False)

        _location_id = serializer.data["location_id"]
        query_set_location = Location.objects.get(location_id=_location_id)
        location_name = LocationSerializer(query_set_location, many=False).data[
            "location_name"
        ]

        res = {
            "name": serializer.data["guard_name"],
            "email": serializer.data["email"],
            "profile_img": serializer.data["profile_img"],
            "location": location_name,
        }
    except:
        res = {}

    return Response(res)


@api_view(["GET", "POST"])
def get_all_guards(request):
    res = []
    try:
        queryset = Guard.objects.filter(is_present=True)

        serializer = GuardSerializer(queryset, many=True)

        for each_guard in serializer.data:

            _location_id = each_guard["location_id"]

            query_set_location = Location.objects.get(location_id=_location_id)

            location_name = LocationSerializer(query_set_location, many=False).data[
                "location_name"
            ]

            item = {
                "name": each_guard["guard_name"],
                "location_name": location_name,
                "email": each_guard["email"],
                "profile_img": each_guard["profile_img"],
                "entry_no": "",
                "gender": "",
                "department": "",
                "degree_name": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "degree_duration": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }

            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Authoriites


@api_view(["POST"])
def get_authority_by_email(request):
    try:
        data = request.data
        email_ = data["email"]
        queryset = Authorities.objects.get(email=email_, is_present=True)
        serializer = AuthoritiesSerializer(queryset, many=False)

        res = {
            "name": serializer.data["authority_name"],
            "email": serializer.data["email"],
            "profile_img": serializer.data["profile_img"],
            "designation": serializer.data["authority_designation"],
        }
    except:
        res = {}

    return Response(res)


@api_view(["POST"])
def get_authorities_list(request):
    try:
        queryset = Authorities.objects.filter(is_present=True)
        serializer = AuthoritiesSerializer(queryset, many=True)
        res = []
        for each_authority in serializer.data:
            if each_authority["authority_name"] == initial_data:
                continue
            obj = {
                "authority_name": each_authority["authority_name"],
                "authority_designation": each_authority["authority_designation"],
                "email": each_authority["email"],
            }
            res.append(obj)

        obj = {
            "authority_name": "None",
            "authority_designation": "None",
            "email": "None",
        }
        res.append(obj)
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        res = []
        obj = {
            "authority_name": "None",
            "authority_designation": "None",
            "email": "None",
        }
        res.append(obj)
        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_authority_tickets_with_status_accepted(request):
    try:
        data = request.data

        email = data["email"]

        location = data["location"]

        ticket_type = data["ticket_type"]

        queryset_student = Student.objects.get(email=email)

        queryset_location = Location.objects.get(location_name=location)

        queryset_authorities_ticket_table = AuthoritiesTicketTable.objects.filter(
            location_id=queryset_location,
            entry_no=queryset_student,
            is_approved="Approved",
            ticket_type=ticket_type,
        )
        print("here2")

        serializer = AuthoritiesTicketTableSerializer(
            queryset_authorities_ticket_table, many=True
        )

        print("here3")

        res = []

        for each_ticket in serializer.data:

            queryset_auth_id = each_ticket["auth_id"]

            print("queryset_auth_id")
            print(queryset_auth_id)

            queryset_authority = Authorities.objects.get(auth_id=queryset_auth_id)

            print("queryset_authority")
            print(queryset_authority)

            serializer_authority = AuthoritiesSerializer(queryset_authority, many=False)

            obj = {
                "authority_name": serializer_authority.data["authority_name"],
                "authority_designation": serializer_authority.data[
                    "authority_designation"
                ],
                "student_message": each_ticket["student_message"],
                "authority_message": each_ticket["authority_message"],
                "ref_id": str(each_ticket["ref_id"]),
            }
            res.append(obj)

        # obj = {
        #     'authority_name': "None",
        #     'authority_designation': "None",
        #     'student_message': "None",
        #     'authority_message': "None",
        #     'ref_id': "None",
        # }
        # res.append(obj)
        res.reverse()

        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception: " + str(e))
        res = []
        # obj = {
        #     'authority_name': "None",
        #     'authority_designation': "None",
        #     'student_message': "None",
        #     'authority_message': "None",
        #     'ref_id': "None",
        # }
        # res.append(obj)

        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Admin


@api_view(["POST"])
def get_admin_by_email(request):
    data = request.data
    email_ = data["email"]

    try:
        queryset = Admin.objects.get(email=email_, is_present=True)
        serializer = AdminSerializer(queryset, many=False)

        res = {
            "name": serializer.data["admin_name"],
            "email": serializer.data["email"],
            "profile_img": serializer.data["profile_img"],
        }
    except:
        res = {}

    return Response(res)


@api_view(["GET", "POST"])
def get_all_admins(request):
    res = []
    try:
        queryset = Admin.objects.filter(is_present=True)

        serializer = AdminSerializer(queryset, many=True)

        for each_admin in serializer.data:

            item = {
                "name": each_admin["admin_name"],
                "email": each_admin["email"],
                "profile_img": each_admin["profile_img"],
                "entry_no": "",
                "gender": "",
                "department": "",
                "degree_name": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "degree_duration": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }

            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Change Profile Photo


@api_view(["POST"])
def change_profile_picture_of_student(request):
    try:
        upFile = request.FILES.get("image")
        email = request.data["email"]

        is_student_present = (
            len(Student.objects.filter(email=email, is_present=True)) != 0
        )

        if is_student_present:
            student = Student.objects.get(email=email, is_present=True)

            ext = upFile.name.split(".")[-1]

            curr_time = timezone.now()
            custom_name = str(student.entry_no) + "_" + \
                str(curr_time) + "." + ext
            upFile.name = custom_name

            student.profile_img = upFile
            student.save()
            res_str = "Image Updated Sucessfully"
            return Response(res_str, status=status.HTTP_200_OK)

        res_str = "Student Not Found"
        return Response(res_str, status=status.HTTP_200_OK)

    except Exception as e:
        res_str = "Error Occured"
        print("Error = ", e)
        return Response(res_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def change_profile_picture_of_guard(request):
    try:
        upFile = request.FILES.get("image")
        email = request.data["email"]

        is_guard_present = len(Guard.objects.filter(email=email, is_present=True)) != 0

        if is_guard_present:
            guard = Guard.objects.get(email=email, is_present=True)

            ext = upFile.name.split(".")[-1]

            curr_time = timezone.now()
            custom_name = str(guard.email) + "_" + str(curr_time) + "." + ext
            upFile.name = custom_name

            guard.profile_img = upFile
            guard.save()
            res_str = "Image Updated Sucessfully"
            return Response(res_str, status=status.HTTP_200_OK)

        res_str = "Guard Not Found"
        return Response(res_str, status=status.HTTP_200_OK)

    except:
        res_str = "Error Occured"
        return Response(res_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def change_profile_picture_of_authority(request):
    try:
        upFile = request.FILES.get("image")
        email = request.data["email"]

        is_authority_present = (
            len(Authorities.objects.filter(email=email, is_present=True)) != 0
        )

        if is_authority_present:
            authority = Authorities.objects.get(email=email, is_present=True)

            ext = upFile.name.split(".")[-1]

            curr_time = timezone.now()
            custom_name = str(authority.email) + "_" + \
                str(curr_time) + "." + ext
            upFile.name = custom_name

            authority.profile_img = upFile
            authority.save()
            res_str = "Image Updated Sucessfully"
            return Response(res_str, status=status.HTTP_200_OK)

        res_str = "Authority Not Found"
        return Response(res_str, status=status.HTTP_200_OK)

    except:
        res_str = "Error Occured"
        return Response(res_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def change_profile_picture_of_admin(request):
    try:
        upFile = request.FILES.get("image")
        email = request.data["email"]

        is_admin_present = len(Admin.objects.filter(email=email, is_present=True)) != 0

        if is_admin_present:
            admin = Admin.objects.get(email=email, is_present=True)

            ext = upFile.name.split(".")[-1]

            curr_time = timezone.now()
            custom_name = str(admin.email) + "_" + str(curr_time) + "." + ext
            upFile.name = custom_name

            admin.profile_img = upFile
            admin.save()
            res_str = "Image Updated Sucessfully"
            return Response(res_str, status=status.HTTP_200_OK)

        res_str = "Admin Not Found"
        return Response(res_str, status=status.HTTP_200_OK)

    except:
        res_str = "Error Occured"
        return Response(res_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Hostel
@api_view(["GET", "POST"])
def get_all_hostels(request):
    res = []
    try:
        queryset = Hostel.objects.filter(is_present=True)

        serializer = HostelSerializer(queryset, many=True)

        for each_hostel in serializer.data:
            if each_hostel["hostel_name"] == initial_data:
                continue
            item = {
                "hostel": each_hostel["hostel_name"],
                "id": each_hostel["hostel_id"],
                "name": "",
                "entry_no": "",
                "email": "",
                "gender": "",
                "department": "",
                "degree_name": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "profile_img": "",
                "degree_duration": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }
            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Authorities


@api_view(["GET", "POST"])
def get_all_authorites(request):
    res = []
    try:
        queryset = Authorities.objects.filter(is_present=True)

        serializer = AuthoritiesSerializer(queryset, many=True)

        for each_authority in serializer.data:
            if each_authority["authority_name"] == initial_data:
                continue
            item = {
                "name": each_authority["authority_name"],
                "designation": each_authority["authority_designation"],
                "email": each_authority["email"],
                "entry_no": "",
                "gender": "",
                "department": "",
                "degree_name": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "profile_img": "",
                "degree_duration": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
            }

            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Department


@api_view(["GET", "POST"])
def get_all_departments(request):
    res = []
    try:
        queryset = Department.objects.filter(is_present=True)

        serializer = DepartmentSerializer(queryset, many=True)

        for each_department in serializer.data:
            if each_department["dept_name"] == initial_data:
                continue
            item = {
                "department": each_department["dept_name"],
                "id": each_department["dept_id"],
                "name": "",
                "entry_no": "",
                "email": "",
                "gender": "",
                "degree_name": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "profile_img": "",
                "degree_duration": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }
            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Programs


@api_view(["GET", "POST"])
def get_all_programs(request):
    res = []
    try:
        queryset = Program.objects.filter(is_present=True)

        serializer = ProgramSerializer(queryset, many=True)

        for each_program in serializer.data:
            if each_program["degree_name"] == initial_data:
                continue
            item = {
                "degree_name": each_program["degree_name"],
                "degree_duration": str(each_program["degree_duration"]),
                "id": each_program["degree_id"],
                "name": "",
                "entry_no": "",
                "email": "",
                "gender": "",
                "department": "",
                "hostel": "",
                "room_no": "",
                "year_of_entry": "",
                "mobile_no": "",
                "profile_img": "",
                "location_name": "",
                "parent_location": "",
                "pre_approval_required": "",
                "automatic_exit_required": "",
                "designation": "",
            }
            res.append(item)
        return Response({"output": res}, status=status.HTTP_200_OK)
    except:
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET", "POST"])
def insert_in_visitors_ticket_table(request):
    res = {}
    try:
        visitor_name = request.data["visitor_name"]
        mobile_no = request.data["mobile_no"]
        car_number = request.data["car_number"]
        guard_status = request.data["guard_status"]

        purpose = request.data["purpose"]
        ticket_type = request.data["ticket_type"]
        duration_of_stay = request.data["duration_of_stay"]

        type = request.data["type"]

        is_not_present = (
            len(Visitor.objects.filter(visitor_name=visitor_name, mobile_no=mobile_no))
            == 0
        )

        if is_not_present:
            Visitor.objects.create(visitor_name=visitor_name, mobile_no=mobile_no)

        queryset_visitor = Visitor.objects.get(
            visitor_name=visitor_name, mobile_no=mobile_no
        )

        serializer_visitor = VisitorSerializer(queryset_visitor, many=False)

        current_status = serializer_visitor.data["current_status"]

        if ticket_type == "enter" and current_status in ["pending_exit", "in"]:
            print(
                "Cannot raise an entry ticket because person is already inside campus"
            )
            res["status"] = True
            res["message"] = (
                "Cannot raise an entry ticket because person is already inside campus"
            )
            return Response({"output": res}, status=status.HTTP_400_BAD_REQUEST)

        if ticket_type == "exit" and current_status in ["pending_entry", "out"]:
            print(
                "Cannot raise an exit ticket because person is already outside campus"
            )
            res["status"] = True
            res["message"] = (
                "Cannot raise an exit ticket because person is already outside campus"
            )
            return Response({"output": res}, status=status.HTTP_400_BAD_REQUEST)

        if type == "authority":
            authority_name = request.data["authority_name"]
            authority_email = request.data["authority_email"]
            authority_designation = request.data["authority_designation"]
            is_authority_present = (
                len(Authorities.objects.filter(email=authority_email, is_present=True))
                != 0
            )
            if is_authority_present:
                queryset_authority = Authorities.objects.get(
                    email=authority_email, is_present=True
                )

            else:
                print("Requested authority is not present")
                res["status"] = True
                res["message"] = "Requested authority is not present"
                return Response({"output": res}, status=status.HTTP_400_BAD_REQUEST)
            VisitorTicketTable.objects.create(
                visitor_id=queryset_visitor,
                car_number=car_number,
                auth_id=queryset_authority,
                purpose=purpose,
                ticket_type=ticket_type,
                duration_of_stay=duration_of_stay,
                num_additional=num_additional,
            )
        else:
            student_email = request.data["student_email"].strip()
            num_additional = int(request.data["num_additional"])

            is_student_present = (
                len(Student.objects.filter(email=student_email, is_present=True)) != 0
            )
            print(len(Student.objects.filter(email=student_email, is_present=True)))
            if is_student_present:
                student = Student.objects.get(email=student_email, is_present=True)
            else:
                print("Student is not present")
                res["status"] = True
                res["message"] = "Student is not present"
                return Response({"output": res}, status=status.HTTP_400_BAD_REQUEST)

            VisitorTicketTable.objects.create(
                visitor_id=queryset_visitor,
                car_number=car_number,
                purpose=purpose,
                ticket_type=ticket_type,
                duration_of_stay=duration_of_stay,
                num_additional=num_additional,
                student_entry_no=student,
                guard_status=guard_status,
            )

        Visitor.objects.filter(visitor_name=visitor_name, mobile_no=mobile_no).update(
            current_status="pending_entry"
        )

        res["status"] = True
        res["message"] = "Ticket inserted in visitors table successfully"
        return Response({"output": res}, status=status.HTTP_200_OK)

    except Exception as e:
        print(e)
        res["status"] = False
        res["message"] = "Exception in inserting ticket to visitors table"
        return Response({"output": res}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET", "POST"])
def insert_in_visitors_ticket_table_2(request):
    res = {}
    try:
        authority_status = request.data["authority_status"]
        visitor_ticket_id = int(request.data["visitor_ticket_id"])
        authority_message = request.data["authority_message"]

        VisitorTicketTable.objects.filter(visitor_ticket_id=visitor_ticket_id).update(
            authority_status=authority_status,
            authority_message=authority_message,
            date_time_authority=timezone.now(),
        )

        res["status"] = True
        res["message"] = "Authority status of visitor ticket updated"
        return Response({"output": res}, status=status.HTTP_200_OK)

    except:
        res["status"] = False
        res["message"] = "Exception in insert_in_visitors_ticket_table_2"
        return Response({"output": res}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Student



class Get_status_for_all_locations(APIView):
    permission_classes = (IsAuthenticated,IsStudent)
    def post(self,request):
        res = {}
        try:
            _email = request.user.email
            print(f"get_status_for_all_locations $$ email: {_email}")

            queryset_student = Student.objects.get(email=_email)
            queryset_student_serializer = StudentSerializer(queryset_student, many=False)
            _entry_no = queryset_student_serializer.data["entry_no"]
            print(f"get_status_for_all_locations $$ entry_no: {_entry_no}")

            queryset_status_table = StatusTable.objects.filter(entry_no=_entry_no)
            for each_query_set in queryset_status_table:
                queryset_status_table_serializer = StatusTableSerializer(
                    each_query_set, many=False
                )
                _status = queryset_status_table_serializer.data["current_status"]
                _location_id = queryset_status_table_serializer.data["location_id"]

                queryset_location = Location.objects.get(location_id=_location_id)
                queryset_location_serializer = LocationSerializer(
                    queryset_location, many=False
                )
                _location_name = queryset_location_serializer.data["location_name"]
                res[_location_name] = _status

            print("location data")
            print(res)

            return Response(res, status=status.HTTP_200_OK)

        except Exception as e:
            print("Exception Occured in get_status_for_all_locations function")
            print(e)
            res_str = "Error Occured"
            return Response(res_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_location_id(request):
    res = {}
    print(f"before")
    index = int(request.GET.get("index", ""))
    print(f"{index}=after")
    location = ""
    if index == 0:
        location = "Main Gate"
    elif index == 1:
        location = "CS Department"
    elif index == 2:
        location = "Mess"
    elif index == 3:
        location = "Library"
    elif index == 4:
        location = "Hostel"
    elif index == 5:
        location = "CS Lab"
    try:
        print(f"shilu before={location}")
        loc = Location.objects.get(location_name=location)
        print(f"shilu after={location}")
        print(f"shilu data={loc.location_id}")
        res["location_id"] = loc.location_id
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("\n\n\n\nError occured while counting")


@api_view(["GET"])
def get_location_count(request):
    res = {}
    location_id = request.GET.get("location_id")
    try:
        in_count = StatusTable.objects.filter(
            location_id=f"{location_id}", current_status="in"
        ).count()
        print("Inside location count = ")
        print(in_count)
        res["in_count"] = in_count
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("\n\n\n\nError occured while counting")


@api_view(["POST"])
def update_phone_number(request):
    print("update phone")
    phone_number = request.POST.get("phone_number")
    st_email = request.POST.get("email")
    try:
        res = {}
        Student.objects.filter(email=st_email).update(mobile_no=phone_number)
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error occured in updating phone number")


@api_view(["GET"])
def get_guard_at_a_location(request):
    email = request.GET.get("email")
    location = request.GET.get("location")

    print(f"EMAIL={email}")
    print(f"LOCATION={location}")

    try:
        res = {}
        loc_id = Location.objects.get(location_name=location).location_id
        guard_id = Guard.objects.get(location_id=loc_id).email
        print(f"Loc id={loc_id}, guard_id={guard_id}")
        res["loc_id"] = loc_id
        res["guard_id"] = guard_id
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error occured while getting guard")


@api_view(["POST"])
def insert_notification(request):
    res = {}
    print("inside insert notification")
    print(request.POST.get("from_whom"))
    print(request.POST.get("for_whom"))
    print(request.POST.get("ticket_type"))
    print(request.POST.get("location_id"))
    print(request.POST.get("display_message"))
    try:
        notificationObj = NotificationTable()
        notificationObj.from_whom = request.POST.get("from_whom")
        notificationObj.for_whom = request.POST.get("for_whom")
        notificationObj.ticket_type = request.POST.get("ticket_type")
        notificationObj.location_id = request.POST.get("location_id")
        notificationObj.display_message = request.POST.get("display_message")
        notificationObj.save()
        res["data"] = "data"
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")
        return Response(res, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def insert_notification_guard_accept_reject(request):
    res = {}
    print("inside insert notification guard accept reject")
    print(request.POST.get("from_whom"))
    print(request.POST.get("for_whom"))
    print(request.POST.get("ticket_type"))
    print(request.POST.get("location"))
    print(request.POST.get("display_message"))
    try:
        notificationObj = NotificationTable()
        notificationObj.from_whom = request.POST.get("from_whom")
        notificationObj.for_whom = request.POST.get("for_whom")
        notificationObj.ticket_type = request.POST.get("ticket_type")
        notificationObj.location_id = Location.objects.get(
            location_name=request.POST.get("location")
        ).location_id
        notificationObj.display_message = request.POST.get("display_message")
        notificationObj.save()
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def count_notifications(request):
    print(f"Backend email={request.GET.get('email')}")
    res = {}
    try:
        count = NotificationTable.objects.filter(
            for_whom=request.GET.get("email"), is_seen=False
        ).count()
        res["count"] = count
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["POST"])
def mark_notification_as_false(request):
    res = {}
    email = request.POST.get("email")
    print("inside false noti")
    try:
        # Student.objects.filter(email=st_email).update(mobile_no=phone_number)
        NotificationTable.objects.filter(for_whom=email, is_seen=False).update(
            is_seen=True
        )
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


# @api_view(['GET'])
# def fetch_notification_guard(request):
#     email = request.GET.get('email')
#     print("inside false noti")
#     res={}
#     try:
#         notifications = NotificationTable.objects.filter(for_whom=email,is_seen='f')

#         data = [[n.from_whom, n.ticket_type,n.location_id,n.display_message] for n in notifications]

#         res['data']=data
#         return Response(res, status=status.HTTP_200_OK)

#     except Exception as e:
#         print("Error")


@api_view(["GET"])
def fetch_notification_guard(request):
    email = request.GET.get("email")
    print("inside false noti")
    print(email)
    res = {}
    try:
        notifications = NotificationTable.objects.filter(for_whom=email, is_seen=False)

        serializer = NotificationTableSerializer(notifications, many=True)
        print(serializer.data)
        print("print data at backend")
        res["data"] = serializer.data
        # print(res['data'])
        return Response(res, status=status.HTTP_200_OK)

    except NotificationTable.DoesNotExist:
        return Response(
            {"error": "Notifications not found"}, status=status.HTTP_404_NOT_FOUND
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def mark_individual_notification(request):
    ticket_id_notification_table = int(request.POST.get("tick_id"))
    email = request.POST.get("email")
    print(f"tic id={ticket_id_notification_table}")
    print(email)
    res = {}
    try:
        NotificationTable.objects.filter(
            for_whom=email, ticket_id=ticket_id_notification_table, is_seen=False
        ).update(is_seen=True)
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def loc_from_loc_id(request):
    res = {}
    loc_id = request.GET.get("loc_id")
    try:
        loc = Location.objects.get(location_id=loc_id)
        res["loc_name"] = loc.location_name
        print(f"location name bhai={loc.location_name}")
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def hostel_from_hostel_id(request):
    res = {}
    id = request.GET.get("id")
    try:
        hostel = Hostel.objects.get(hostel_id=id)
        res["hostel_name"] = hostel.hostel_name
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def department_from_department_id(request):
    res = {}
    id = request.GET.get("id")
    try:
        department = Department.objects.get(dept_id=id)
        res["dept_name"] = department.dept_name
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def program_from_program_id(request):
    res = {}
    id = request.GET.get("id")
    try:
        program = Program.objects.get(degree_id=id)
        res["degree_name"] = program.degree_name
        res["degree_duration"] = program.degree_duration
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error")


@api_view(["GET"])
def get_all_count(request):
    try:
        student = Student.objects.filter(is_present=True).count()
        guard = Guard.objects.filter(is_present=True).count()
        authority = Authorities.objects.filter(is_present=True).count()
        location = Location.objects.filter(is_present=True).count()
        hostel = Hostel.objects.filter(is_present=True).count()
        program = Program.objects.filter(is_present=True).count()
        department = Department.objects.filter(is_present=True).count()
        res = {
            "student": student,
            "guard": guard,
            "authority": authority,
            "location": location,
            "hostel": hostel,
            "program": program,
            "department": department,
        }
        return Response(res, status=status.HTTP_200_OK)
    except Exception as e:
        print("Error: ", e)
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CustomSerializer(serializers.ModelSerializer):
    entry_no = serializers.PrimaryKeyRelatedField(queryset=Student.objects.all())
    student_name = serializers.CharField(source="entry_no.st_name", read_only=True)
    student_email = serializers.CharField(source="entry_no.email", read_only=True)
    guard_id = serializers.PrimaryKeyRelatedField(queryset=Guard.objects.all())
    guard_name = serializers.CharField(source="guard_id.guard_name", read_only=True)
    guard_email = serializers.CharField(source="guard_id.email", read_only=True)
    location_id = serializers.PrimaryKeyRelatedField(queryset=Location.objects.all())
    location_name = serializers.CharField(
        source="location_id.location_name", read_only=True
    )

    class Meta:
        model = TicketTable
        fields = "__all__"


@api_view(["POST"])
def get_history_student(request):
    data = request.data.get("body", [])
    result = []
    for entry_no in data:
        tickets = TicketTable.objects.select_related(
            "entry_no", "guard_id", "location_id"
        ).filter(entry_no=entry_no)
        for ticket in tickets:
            serializer = CustomSerializer(ticket)
            result.append(serializer.data)
            # print(result)
    try:
        return Response(result, status=status.HTTP_200_OK)
    except Exception as e:
        print("Error: ", e)
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_student_raw(request):
    try:
        data = request.query_params
        # if data :
        entry_no = data.get("id")
        if not entry_no:
            return Response(
                {"error": "Entry No. not provided."}, status=status.HTTP_200_OK
            )

        res = Student.objects.filter(entry_no=entry_no)
        if not res:
            return Response(
                {"error": "No student found with provided Entry No."},
                status=status.HTTP_404_NOT_FOUND,
            )

        res2 = StudentSerializer(res, many=True).data
        return Response(res2, status=status.HTTP_200_OK)
    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
def get_guard_raw(request):
    try:
        data = request.query_params
        # if data :
        email = data.get("email")
        if not email:
            return Response(
                {"error": "email. not provided."}, status=status.HTTP_200_OK
            )

        res = Guard.objects.filter(email=email)
        if not res:
            return Response(
                {"error": "No guard found with provided email."},
                status=status.HTTP_404_NOT_FOUND,
            )

        res2 = GuardSerializer(res, many=True).data
        return Response(res2, status=status.HTTP_200_OK)
    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def update_student_details(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        entry_no = data["entry_no"]
        student = get_object_or_404(Student, entry_no=entry_no)

        # Get the department instance for the given dept_id value
        dept_id = data["dept_id"]
        print("flaskjdf", dept_id)
        department = get_object_or_404(Department, dept_id=dept_id)

        # Get the degree instance for the given degree_id value
        degree_id = data["degree_id"]
        degree = get_object_or_404(Program, degree_id=degree_id)

        # Get the hostel instance for the given hostel_id value
        hostel_id = data["hostel_id"]
        hostel = get_object_or_404(Hostel, hostel_id=hostel_id)

        # Update the fields in the record
        student.st_name = data["st_name"]
        student.email = data["email"]
        student.gender = data["gender"]
        student.room_no = data["room_no"]
        student.year_of_entry = data["year_of_entry"]
        # student.profile_img = data['profile_img']
        student.mobile_no = data["mobile_no"]
        # student.is_present = data['is_present']
        student.dept_id = department
        student.degree_id = degree
        student.hostel_id = hostel

        # Save the updated record to the database
        student.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def update_hostel_details(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        id = data["id"]
        hostel = get_object_or_404(Hostel, hostel_id=id)

        # Update the fields in the record
        hostel.hostel_name = data["hostel_name"]

        # Save the updated record to the database
        hostel.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def update_department_details(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        id = data["id"]
        department = get_object_or_404(Department, dept_id=id)

        # Update the fields in the record
        department.dept_name = data["dept_name"]

        # Save the updated record to the database
        department.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def update_program_details(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        id = data["id"]
        program = get_object_or_404(Program, degree_id=id)

        # Update the fields in the record
        program.degree_name = data["degree_name"]
        program.degree_duration = data["degree_duration"]

        # Save the updated record to the database
        program.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def update_location_details(request):
    try:
        data = request.data
        print("data = ", data)
        id = data["location_id"]
        location = get_object_or_404(Location, location_id=id)
        # print(location)
        # # Update the fields in the record
        location.location_name = data["location_name"]
        location.parent_id = data["parent_id"]
        location.pre_approval_required = data["pre_approval_required"]
        location.automatic_exit_required = data["automatic_exit_required"]

        # # Save the updated record to the database
        location.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def add_student2(request):
    data = request.data

    try:
        dept_id = data["dept_id"]
        degree_id = data["degree_id"]
        hostel_id = data["hostel_id"]
        department = get_object_or_404(Department, dept_id=dept_id)
        degree = get_object_or_404(Program, degree_id=degree_id)
        hostel = get_object_or_404(Hostel, hostel_id=hostel_id)

        student_data = {
            "entry_no": data["entry_no"],
            "st_name": data["st_name"],
            "email": data["email"],
            "gender": data["gender"],
            "room_no": data["gender"],
            "year_of_entry": data["year_of_entry"],
            "mobile_no": data["mobile_no"],
            "dept_id": department,
            "degree_id": degree,
            "hostel_id": hostel,
        }

        student = Student(**student_data)
        student.save()
        user_data = {"email": data["email"], "type": "Student"}
        user = User(**user_data)
        user.save()
        

        queryset_location_table = Location.objects.all()
        queryset_entry_no = Student.objects.get(entry_no=data["entry_no"])

        for each_queryset_location_table in queryset_location_table:
            queryset_location_table_serializer = LocationSerializer(
                each_queryset_location_table, many=False
            )
            queryset_location_table_location_name = (
                queryset_location_table_serializer.data["location_name"]
            )
            if queryset_location_table_location_name != initial_data:
                queryset_status_table = StatusTable.objects.create(
                    entry_no=queryset_entry_no,
                    location_id=each_queryset_location_table,
                )

        response_str = "Student Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add student due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_200_OK)


@api_view(["POST"])
def add_guard_single(request):
    data = request.data

    try:
        location_id = data["location_id"]
        location = get_object_or_404(Location, location_id=location_id)
        guard_data = {
            "guard_name": data["guard_name"],
            "email": data["email"],
            "location_id": location,
        }

        guard = Guard(**guard_data)
        guard.save()
        user_data = {"email": data["email"], "person_type": "Guard"}
        user = User(**user_data)
        user.save()
        


        response_str = "Guard Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add guard due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_200_OK)


@api_view(["POST"])
def add_authority_single(request):
    data = request.data

    try:
        email = data["email"]
        authority_data = {
            "authority_name": data["name"],
            "email": email,
            "authority_designation": data["designation"],
        }

        authority = Authorities(**authority_data)
        authority.save()
        user_data = {"email": data["email"], "person_type": "Authority"}
        user = User(**user_data)
        user.save()

        response_str = "Authority Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add Authority due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_200_OK)


@api_view(["POST"])
def add_location_single(request):
    data = request.data
    try:
        print(data)
        location_name = data["location_name"]
        parent_id = data["parent_id"]
        pre_approval_required = data["pre_approval_required"]
        automatic_exit_required = data["automatic_exit_required"]
        location_data = {
            "location_name": location_name,
            "parent_id": parent_id,
            "pre_approval_required": pre_approval_required,
            "automatic_exit_required": automatic_exit_required,
        }
        location = Location(**location_data)
        location.save()

        response_str = "Location Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add student due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_200_OK)


@api_view(["POST"])
def add_hostel_single(request):
    data = request.data
    try:
        print(data)
        hostel_name = data["hostel_name"]
        hostel_data = {"hostel_name": hostel_name}
        hostel = Hostel(**hostel_data)
        hostel.save()

        response_str = "Location Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add student due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_200_OK)


@api_view(["POST"])
def add_department_single(request):
    data = request.data
    try:
        print(data)
        dept_name = data["dept_name"]
        dept_data = {"dept_name": dept_name}
        dept = Department(**dept_data)
        dept.save()

        response_str = "Department Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add Department due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def add_program_single(request):
    data = request.data
    try:
        print(data)
        degree_name = data["degree_name"]
        degree_duration = data["degree_duration"]
        degree_data = {"degree_name": degree_name, "degree_duration": degree_duration}
        program = Program(**degree_data)
        program.save()

        response_str = "Department Added Successfully"
        return Response(response_str, status=status.HTTP_200_OK)

    except Exception as e:
        response_str = "Failed to add Department due to exception\n" + str(e)
        return Response(response_str, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_guard_profile(request):
    try:
        data = request.data
        print(data)
        # if 'id' in data and 'id' in data['id']:
        if "id" not in data:
            res = {"error": "Invalid request data"}
            return Response(res, status=status.HTTP_400_BAD_REQUEST)
        _email = data["id"]
        # rest of the code here
        # else:
        #     res = {'error': 'Invalid request data'}
        #     return Response(res, status=status.HTTP_400_BAD_REQUEST)
        print("le beta data = ", _email)
        queryset = Guard.objects.get(email=_email)

        serializer = GuardSerializer(queryset, many=False)

        image_path = serializer.data["profile_img"]
        print("0000000000000000000000000000000000000000000000000000000000000000000")
        with open(str(settings.BASE_DIR) + image_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode("utf-8")

        res = {
            "profile_img": encoded_image,
            "image_path": image_path,
        }
        print("------------------------------------------------")
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in get_student_by_email: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def get_authority_profile(request):
    try:
        data = request.data
        print(data)
        # if 'id' in data and 'id' in data['id']:
        if "id" not in data:
            res = {"error": "Invalid request data"}
            return Response(res, status=status.HTTP_400_BAD_REQUEST)
        _email = data["id"]
        # rest of the code here
        # else:
        #     res = {'error': 'Invalid request data'}
        #     return Response(res, status=status.HTTP_400_BAD_REQUEST)
        print("le beta data = ", _email)
        queryset = Authorities.objects.get(email=_email)
        serializer = AuthoritiesSerializer(queryset, many=False)

        image_path = serializer.data["profile_img"]
        print("0000000000000000000000000000000000000000000000000000000000000000000")
        with open(str(settings.BASE_DIR) + image_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode("utf-8")

        res = {
            "profile_img": encoded_image,
            "image_path": image_path,
        }
        print("------------------------------------------------")
        return Response(res, status=status.HTTP_200_OK)

    except Exception as e:
        print("Exception in get_student_by_email: " + str(e))
        return Response(status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def update_guard_details(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        email = data["email"]
        guard = get_object_or_404(Guard, email=email)

        location_id = data["location_id"]
        location = get_object_or_404(Location, location_id=location_id)

        # Update the fields in the record
        guard.guard_name = data["guard_name"]
        guard.email = data["email"]
        guard.location_id = location

        # Save the updated record to the database
        guard.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["POST"])
def get_history_guard(request):
    data = request.data.get("body", [])
    result = []

    for email in data:
        try:
            guard = Guard.objects.get(email=email)
            tickets = TicketTable.objects.select_related(
                "entry_no", "guard_id", "location_id"
            ).filter(guard_id=guard.guard_id)
            for ticket in tickets:
                serializer = CustomSerializer(ticket)
                result.append(serializer.data)
        except Guard.DoesNotExist:
            pass

    return Response(result, status=status.HTTP_200_OK)


class CustomSerializerAuth(serializers.ModelSerializer):
    entry_no = serializers.PrimaryKeyRelatedField(queryset=Student.objects.all())
    student_name = serializers.CharField(source="entry_no.st_name", read_only=True)
    student_email = serializers.CharField(source="entry_no.email", read_only=True)
    auth_id = serializers.PrimaryKeyRelatedField(queryset=Authorities.objects.all())
    authority_name = serializers.CharField(
        source="auth_id.authority_name", read_only=True
    )
    authority_email = serializers.CharField(source="auth_id.email", read_only=True)
    student_message = serializers.CharField(
        source="entry_no.student_message", read_only=True
    )
    location_id = serializers.PrimaryKeyRelatedField(queryset=Location.objects.all())
    location_name = serializers.CharField(
        source="location_id.location_name", read_only=True
    )

    class Meta:
        model = TicketTable
        fields = "__all__"


@api_view(["POST"])
def get_history_authority(request):
    data = request.data.get("body", [])
    result = []

    for email in data:
        try:
            auth = Authorities.objects.get(email=email)
            tickets = AuthoritiesTicketTable.objects.select_related(
                "entry_no", "auth_id", "location_id"
            ).filter(auth_id=auth.auth_id)
            for ticket in tickets:
                serializer = CustomSerializerAuth(ticket)
                result.append(serializer.data)
        except Authorities.DoesNotExist:
            pass

    return Response(result, status=status.HTTP_200_OK)


@api_view(["POST"])
def update_authorities(request):
    try:
        print(request.data)
        print("Here in update function")
        # print(request.data)
        data = request.data
        email = data["email"]
        designation = data["designation"]
        name = data["name"]
        authorities = get_object_or_404(Authorities, email=email)

        # Update the fields in the record
        authorities.authority_name = name
        authorities.authority_designation = designation

        # Save the updated record to the database
        authorities.save()

        return Response({"output": "Ok"}, status=status.HTTP_200_OK)

    except Exception as e:
        print("Error: ", e)
        return Response(
            {"error": "Internal server error."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(["GET"])
def get_location_by_id(request):
    try:
        data = request.query_params
        # if data :
        id = data.get("id")
        if not id:
            return Response({"error": "id. not provided."}, status=status.HTTP_200_OK)

        res = Location.objects.filter(location_id=id)
        if not res:
            return Response(
                {"error": "No location found with provided id."},
                status=status.HTTP_404_NOT_FOUND,
            )

        res2 = LocationSerializer(res, many=True).data
        return Response(res2, status=status.HTTP_200_OK)
    except Exception as e:
        print("Error: ", e)
        return Response({'error': 'Internal server error.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class GenerateRelativesTicketAPIView(APIView):
    # permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data

        # Assuming student_name is obtained from the authenticated user
        # student_name = request.user.username
        # data['student_name'] = 

        serializer = InviteRequestSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GetStudentRelativeTicketsAPIView(APIView):
    # permission_classes = [IsAuthenticated]
    

    def post(self, request):
        # print("**")
        # Extract status and student name from query parameters
        print(request.data)
        # data = json.loads(request.body)
       
        student = request.data.get('student')
       
        print(student)

        # Validate parameters
        # if not status_param or not student_name:
        #     return Response("Status and student_name are required parameters.", status=status.HTTP_400_BAD_REQUEST)

        # Filter tickets based on status and student name
        tickets = InviteRequest.objects.filter(student=student)

        # Serialize the ticket data
        serializer = InviteRequestSerializer(tickets, many=True)
        print(serializer.data)

        return Response(serializer.data, status=status.HTTP_200_OK)

class AdminTicketStatusAPIView(APIView):
    
    def post(self, request):
        # Extract status and student name from query parameters
        print(request.data)
        # data = json.loads(request.body)
        status_param = request.data.get('status')
        print(status_param)

       
        # Filter tickets based on status and student name
        tickets = InviteRequest.objects.filter(status=status_param)

        # Serialize the ticket data
        serializer = InviteRequestSerializer(tickets, many=True)

        for data in serializer.data:
            student_id = data['student']
            print(student_id)
            student = Student.objects.get(entry_no=student_id)
            data['studentName'] = student.st_name

        return Response(serializer.data, status=status.HTTP_200_OK)


class AcceptTicketAPIView(APIView):
    # permission_classes = [IsAdminUser]  # Assuming only admins can access this API

    def post(self, request):
        ticket_id = request.data.get('ticket_id')

        # Check if ticket exists
        try:
            ticket = InviteRequest.objects.get(ticket_id=ticket_id)
        except InviteRequest.DoesNotExist:
            return Response({"error": "Ticket not found"}, status=status.HTTP_404_NOT_FOUND)

        print(ticket)
        # Check if the ticket status is pending or rejected
        if ticket.status in ['Pending', 'Rejected']:
            # Update the ticket status to Accepted
            ticket.status = 'Accepted'
            ticket.save()
            return Response({"message": "Ticket accepted successfully"}, status=status.HTTP_200_OK)
        else:
            print("Ticket status cannot be changed to Accepted")
            return Response({"error": "Ticket status cannot be changed to Accepted"}, status=status.HTTP_400_BAD_REQUEST)

class RejectTicketAPIView(APIView):
    # permission_classes = [IsAuthenticated]

    def post(self, request):
        ticket_id = request.data.get('ticket_id')
        try:
            ticket = InviteRequest.objects.get(ticket_id=ticket_id)
        except InviteRequest.DoesNotExist:
            return Response({"message": "Ticket not found."}, status=status.HTTP_404_NOT_FOUND)
        
        # Check if the ticket status is pending or rejected
        if ticket.status in ['Pending','Accepted']:
            ticket.status = 'Rejected'
            ticket.save()
            return Response({"message": "Ticket rejected successfully."}, status=status.HTTP_200_OK)
        else:
            return Response({"message": "Ticket cannot be rejected as it is already approved."}, status=status.HTTP_400_BAD_REQUEST)
        
class GuardCreateInviteeRecord(APIView):
    # permission_classes = (IsAuthenticated,IsGuard)  # Assuming only admins can access this API
    def post(self,request):
        try:
            try:
                ticket_id=request.data.get('ticket_id')
                vehicle_number=request.data.get("vehicle_number")
                enter_exit=request.data.get("enter_exit")
            except:
                jsonresponse={
                    "ok":False,
                    "error":"invalid input. required ticket_id , ",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            try:
                invite_request=InviteRequest.objects.get(ticket_id=ticket_id)
            except InviteRequest.DoesNotExist:
                jsonresponse={
                    "ok":False,
                    "error":"Ticket not found, or has expired",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            # add a check for the ticket to be expired
            if invite_request.status!="Accepted":
                jsonresponse={
                    "ok":False,
                    "error":f"Ticket Status By Authority : {invite_request.status}. Wait for it to be Accepted",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            if enter_exit=="enter":
                InviteeTicketRecord.objects.create(
                    invite_request=invite_request,
                    vehicle_number=vehicle_number,
                    type=enter_exit,
                    status='Accepted'
                )
                invite_request.cached_vehicle_number=vehicle_number
                invite_request.save()
                # invite_request.vehicle_number=vehicle_number
                # invite_request.enter_time=timezone.now()
                # invite_request.save()
                jsonresponse={
                    "ok":True,
                    "message":"Entry succesfull",
                }
                return Response(jsonresponse,status=status.HTTP_200_OK)                
            elif enter_exit=='exit' :
                InviteeTicketRecord.objects.create(
                    invite_request=invite_request,
                    vehicle_number=vehicle_number,
                    type=enter_exit,
                    status='Accepted'
                )
                invite_request.cached_vehicle_number=vehicle_number
                invite_request.save()

                jsonresponse={
                    "ok":True,
                    "message":"Exit succesfull",
                }
                return Response(jsonresponse,status=status.HTTP_200_OK)
            jsonresponse={
                "ok":False,
                "error":f"you request for <{enter_exit}>Not recognised",
            }
            return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            jsonresponse={
                "ok":False,
                "error":str(e),
            }
            return Response(jsonresponse,status.HTTP_400_BAD_REQUEST)

class GetInviteRequestByTicketID(APIView):
    def post(self,request):
        try:
            try:
                ticket_id=request.data.get('ticket_id')
            except:
                jsonresponse={
                    "ok":False,
                    "error":"invalid input. required ticket_id , ",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            try:
                invite_request=InviteRequest.objects.get(ticket_id=ticket_id)
            except InviteRequest.DoesNotExist:
                jsonresponse={
                    "ok":False,
                    "error":"Ticket not found",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            try:
                
                student=Student.objects.get(entry_no=invite_request.student.entry_no)
            except InviteRequest.DoesNotExist:
                jsonresponse={
                    "ok":False,
                    "error":"Student not found",
                }
                return Response(jsonresponse,status=status.HTTP_400_BAD_REQUEST)
            
            jsonresponse={
                "ok":True,
                "invitee_name":invite_request.invitee_name,
                "student_name":student.st_name,
                "relationship_with_student":invite_request.invitee_relationship,
                "vehicle_number":invite_request.cached_vehicle_number,
            }
            return Response(jsonresponse,status.HTTP_200_OK)       
        except Exception as e:
            jsonresponse={
                "ok":False,
                "error":str(e),
            }
            return Response(jsonresponse,status.HTTP_400_BAD_REQUEST)
class InviteeRecords(APIView):
    ENTRY_CHOICES = {
        'enter': 'Enter',
        'exit': 'Exit'
    }

    STATUS_CHOICES = {
        'Accepted': 'Accepted',
        'Rejected': 'Rejected'
    }

    def get(self, request):
        entry_choice = request.GET.get('entry_choice', None)
        status_type = request.GET.get('status_type', None)

        if entry_choice not in self.ENTRY_CHOICES:
            return Response({'error': 'Invalid entry choice'}, status=status.HTTP_400_BAD_REQUEST)

        if status_type not in self.STATUS_CHOICES:
            return Response({'error': 'Invalid status type'}, status=status.HTTP_400_BAD_REQUEST)

        records = InviteeTicketRecord.objects.filter(type=entry_choice, status=status_type)
        data = []

        for record in records:
            invite_request = record.invite_request
            student = invite_request.student

            record_data = {
                'record_id': record.record_id,
                'student_name': student.st_name,
                'student_entry_no': student.entry_no,
                'invitee_name': invite_request.invitee_name,
                'invitee_relationship': invite_request.invitee_relationship,
                'invitee_contact': invite_request.invitee_contact,
                'invitee_purpose': invite_request.purpose,
                'vehicle_number': record.vehicle_number,
                'time': record.time,
                'type': record.type,
                'status': record.status
            }

            data.append(record_data)
        data.reverse()

        return Response(data, status=status.HTTP_200_OK)

class UpdateInviteeRecordStatus(APIView):
    def post(self, request):
        try:
            record_id = request.data.get('record_id')
            new_status = request.data.get('status')
            # print(record_id)
            if not record_id:
                return Response({'error': 'Record ID is required'}, status=status.HTTP_400_BAD_REQUEST)
            if new_status not in ['Accepted', 'Rejected']:
                return Response({'error': 'Invalid status'}, status=status.HTTP_400_BAD_REQUEST)
            try:
                record = InviteeTicketRecord.objects.get(record_id=record_id)
                record.status = new_status
                record.save()
                print(record_id)
                print(new_status)
                print("sucess")
                return Response({'message': 'Status updated successfully'}, status=status.HTTP_200_OK)
            except InviteeTicketRecord.DoesNotExist:
                return Response({'error': 'Record not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)