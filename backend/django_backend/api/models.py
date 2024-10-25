from django.db import models
from django.contrib.auth.hashers import *
import datetime
from django.contrib.auth.models import AbstractUser

# If we delete anything, change the value of is_present to False
default_password = "IIT_Ropar"
default_encrypted_password = make_password(default_password)

TYPES = (
    ("student", "Student"),
    ("guard", "Guard"),
    ("authority", "Authority"),
    ("admin", "Admin"),
)
ENTRY_CHOICES = (
        ('enter', 'Enter'),
        ('exit', 'Exit'),
    )
from django.contrib.auth.models import BaseUserManager

import uuid 
from django.utils import timezone

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=default_password, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create(self, email, password=default_password, **extra_fields):
        return self.create_user(email, password, **extra_fields)

    def update_user(self, user, password=None, **extra_fields):
        if password:
            user.set_password(password)
        for field, value in extra_fields.items():
            setattr(user, field, value)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    email=models.CharField(max_length=255,unique=True)
    password=models.CharField(max_length=255)
    type=models.CharField(max_length=255,default='student',null=False,choices=TYPES)
    username=None

    USERNAME_FIELD='email' 

    REQUIRED_FIELDS=[]

    objects = CustomUserManager()




class Location(models.Model):
    location_id = models.AutoField(primary_key=True)
    location_name = models.CharField(max_length=100, unique=True, blank=False)
    parent_id = models.IntegerField(default=-1)  # -1 denotes no parent of this location
    pre_approval_required = models.BooleanField(
        default=False
    )  # Example for Mess no type of approval is required from authorities which is not the case with Main Gate
    automatic_exit_required = models.BooleanField(
        default=False
    )  # Example for mess we require automatic exit
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.location_name


class Department(models.Model):
    dept_id = models.AutoField(primary_key=True)
    dept_name = models.CharField(max_length=100, unique=True)
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.dept_name


class Program(models.Model):
    degree_id = models.AutoField(primary_key=True)
    degree_name = models.CharField(max_length=100, unique=True)
    degree_duration = models.IntegerField(
        blank=True, null=True
    )  # This field is optional
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.degree_name


class Hostel(models.Model):
    hostel_id = models.AutoField(primary_key=True)
    hostel_name = models.CharField(max_length=100, unique=True)
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.hostel_name


class Person(models.Model):
    email = models.CharField(max_length=100, primary_key=True)
    person_type = models.CharField(
        max_length=100
    )  # Takes values "Student"|"Guard"|"Authority"|"Admin"
    is_present = models.BooleanField(default=True)


class Password(models.Model):
    email = models.CharField(max_length=100, primary_key=True)
    password = models.CharField(max_length=1000, default=default_encrypted_password)
    is_present = models.BooleanField(default=True)


class OTP(models.Model):
    email = models.CharField(max_length=100, primary_key=True)
    otp = models.IntegerField()


class Student(models.Model):
    st_name = models.CharField(max_length=100, default="")
    entry_no = models.CharField(max_length=100, primary_key=True)
    email = models.CharField(max_length=100, unique=True)
    created = models.DateTimeField(auto_now_add=True)
    gender = models.CharField(
        max_length=100, default=None
    )  # Takes values "Male" | "Female" | "Others"
    dept_id = models.ForeignKey("Department", on_delete=models.DO_NOTHING, null=True)
    degree_id = models.ForeignKey("Program", on_delete=models.DO_NOTHING, null=True)
    hostel_id = models.ForeignKey("Hostel", on_delete=models.DO_NOTHING, null=True)
    room_no = models.CharField(max_length=100, null=True)
    year_of_entry = models.IntegerField(default=2019)
    # Only these 2 parameters can be modified
    profile_img = models.ImageField(
        upload_to="images/profile_pictures",
        blank=True,
        null=True,
        default="images/profile_pictures/dummy_person.jpg",
    )
    mobile_no = models.CharField(
        max_length=15, blank=True, null=True, default="9999999999"
    )
    is_present = models.BooleanField(default=True)
    # vehicleRegNum = models.

    def __str__(self):
        return self.st_name

    class Meta:
        ordering = ["-created"]


class Guard(models.Model):
    guard_id = models.AutoField(primary_key=True)
    profile_img = models.ImageField(
        upload_to="images/profile_pictures",
        blank=True,
        null=True,
        default="images/dummy_images/dummy_person.jpg",
    )
    guard_name = models.CharField(max_length=100)  # Example "Happy Singh"
    location_id = models.ForeignKey("Location", on_delete=models.DO_NOTHING, null=True)
    email = models.CharField(max_length=100, unique=True)
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.guard_name


class Admin(models.Model):
    admin_id = models.AutoField(primary_key=True)
    admin_name = models.CharField(max_length=100, default="")
    profile_img = models.ImageField(
        upload_to="images/profile_pictures",
        blank=True,
        null=True,
        default="images/dummy_images/dummy_person.jpg",
    )
    email = models.CharField(max_length=100, unique=True, default="")
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.admin_name


class Authorities(models.Model):
    auth_id = models.AutoField(primary_key=True)  # PK
    authority_name = models.CharField(
        max_length=100, default=""
    )  # Example "Dr. Ravi Kant"
    profile_img = models.ImageField(
        upload_to="images/profile_pictures",
        blank=True,
        null=True,
        default="images/dummy_images/dummy_person.jpg",
    )
    authority_designation = models.CharField(
        max_length=100, default=""
    )  # Example "Chief Warden"
    email = models.CharField(
        max_length=100, unique=True, default=""
    )  # Actual primary key
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.authority_name


class Visitor(models.Model):
    visitor_id = models.AutoField(primary_key=True)
    visitor_name = models.CharField(max_length=100, default="")
    mobile_no = models.CharField(
        max_length=15, unique=True, blank=True, null=True, default="9999999999"
    )
    current_status = models.CharField(
        max_length=100, default="out"
    )  # Takes values "in" | "out" | "pending_entry" | "pending_exit"
    is_present = models.BooleanField(default=True)

    def __str__(self):
        return self.visitor_name


class AuthoritiesTicketTable(models.Model):
    ref_id = models.AutoField(primary_key=True)
    auth_id = models.ForeignKey("Authorities", on_delete=models.DO_NOTHING, null=True)
    entry_no = models.ForeignKey("Student", on_delete=models.DO_NOTHING, null=True)
    date_time = models.DateTimeField(null=True)
    location_id = models.ForeignKey("Location", on_delete=models.DO_NOTHING, null=True)
    ticket_type = models.CharField(
        max_length=100, default=None
    )  # Takes values "enter"|"exit"
    authority_message = models.CharField(max_length=1000, default="")
    student_message = models.CharField(max_length=1000, default="")
    is_approved = models.CharField(
        max_length=100, default="Pending"
    )  # Takes values "Approved" | "Rejected" | "Pending"

    class Meta:
        unique_together = (("location_id", "entry_no", "date_time"),)


class TicketTable(models.Model):
    ticket_id = models.AutoField(primary_key=True)
    guard_id = models.ForeignKey("Guard", on_delete=models.DO_NOTHING, null=True)
    ref_id = models.ForeignKey(
        "AuthoritiesTicketTable", on_delete=models.DO_NOTHING, null=True
    )
    is_approved = models.CharField(
        max_length=100, default="Pending"
    )  # Takes values "Approved" | "Rejected" | "Pending"
    ticket_type = models.CharField(
        max_length=100, default=None
    )  # Takes values "enter" | "exit"
    location_id = models.ForeignKey("Location", on_delete=models.DO_NOTHING, null=True)
    entry_no = models.ForeignKey("Student", on_delete=models.DO_NOTHING, null=True)
    date_time = models.DateTimeField()
    destination_address = models.CharField(max_length=200, default="")
    vehicle_reg_num = models.CharField(max_length=200, default="")
    # date_time = models.CharField(max_length=100, default = None)

    class Meta:
        unique_together = (("location_id", "entry_no", "date_time"),)


class StatusTable(models.Model):
    status_id = models.AutoField(primary_key=True)
    entry_no = models.ForeignKey("Student", on_delete=models.DO_NOTHING, null=True)
    location_id = models.ForeignKey("Location", on_delete=models.DO_NOTHING, null=True)
    current_status = models.CharField(
        max_length=100, default="out"
    )  # Takes values "in" | "out" | "pending_entry" | "pending_exit"
    is_present = models.BooleanField(default=True)

    class Meta:
        unique_together = (("location_id", "entry_no"),)


# Stores the list of tickets for visitors
class VisitorTicketTable(models.Model):
    visitor_ticket_id = models.AutoField(primary_key=True)  # PK of this table
    visitor_id = models.ForeignKey(
        "Visitor", on_delete=models.DO_NOTHING, null=True
    )  # Linked to the visitor table
    # (visitor_id, visitor_name, mobile_no, current_status)
    car_number = models.CharField(max_length=100, default=None)  # Optional field
    auth_id = models.ForeignKey(
        "Authorities", on_delete=models.DO_NOTHING, null=True
    )  # Link the authority for which this ticket is being raised
    purpose = models.CharField(max_length=1000, default=None)
    authority_status = models.CharField(
        max_length=100, default="Pending"
    )  # Takes values "Approved" | "Rejected" | "Pending"
    authority_message = models.CharField(max_length=1000, default="")
    date_time_of_ticket_raised = models.DateTimeField(auto_now_add=True)
    date_time_authority = models.DateTimeField(null=True)
    date_time_guard = models.DateTimeField(null=True)
    date_time_of_exit = models.DateTimeField(null=True)
    guard_status = models.CharField(
        max_length=100, default="Pending"
    )  # Takes values "Approved" | "Rejected" | "Pending"
    ticket_type = models.CharField(
        max_length=100, default=None
    )  # Takes values "enter"|"exit"
    duration_of_stay = models.CharField(max_length=100, default=None)
    student_entry_no = models.ForeignKey(
        "Student", on_delete=models.DO_NOTHING, null=True
    )
    num_additional = models.IntegerField(default=0)
    type = models.CharField(
        max_length=32,
        default="authoriy",
        choices=(("student", "Student"), ("authority", "Authority")),
    )


class NotificationTable(models.Model):
    ticket_id = models.AutoField(primary_key=True)  # PK of this table
    is_seen = models.BooleanField(default=False)  #
    from_whom = models.CharField(max_length=100, default=None)
    for_whom = models.CharField(max_length=100, default=None)
    ticket_type = models.CharField(max_length=100, default=None)
    location_id = models.IntegerField()
    display_message = models.CharField(max_length=200,default=None)
    date_time = models.DateTimeField(default=timezone.now)


class InviteRequest(models.Model):
    ticket_id = models.UUIDField(
        default=uuid.uuid4, editable=False, unique=True, primary_key=True
    )
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    invitee_name = models.CharField(max_length=100)
    invitee_relationship = models.CharField(max_length=100)
    invitee_contact = models.CharField(max_length=100)
    purpose = models.TextField()
    status = models.CharField(max_length=20, default='Pending')
    created_at = models.DateTimeField(auto_now_add=True)
    visit_date = models.CharField(null=True, blank=True)
    duration=models.IntegerField(null=True, blank=True)
    cached_vehicle_number = models.CharField(max_length=100,null=True,blank=True, default=None) # Optional field

class InviteeTicketRecord(models.Model):

    record_id = models.AutoField(primary_key=True)
    invite_request = models.ForeignKey(InviteRequest, on_delete=models.CASCADE)
    vehicle_number = models.CharField(max_length=20,blank=True,default="")
    time = models.DateTimeField(auto_now_add=True)
    type = models.CharField(max_length=10, choices=ENTRY_CHOICES)
    status = models.CharField(max_length=20, choices=(('Accepted', 'Accepted'), ('Rejected', 'Rejected')),default='Accepted')