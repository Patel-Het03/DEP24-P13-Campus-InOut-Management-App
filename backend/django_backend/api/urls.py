from django.urls import path
from api.views import *
from rest_framework_simplejwt import views as jwt_views

# http://localhost:8000/students/add_authorities_from_file
# http://localhost:8000/students/delete_authorities_from_file

urlpatterns = [
    # React Test
    path("reactCheck", testReact, name="react"),
    # Login
    #     path('login_user', login_user),
    path("forgot_password", forgot_password),
    path("reset_password", reset_password),
    path("get_welcome_message", get_welcome_message),
    # Init and clear DB
    path("init_db", init_db),
    path("clear_db", clear_db),
    # add data from files routes
    path("files/add_departments_from_file", add_departments_from_file),
    path("files/add_programs_from_file", add_programs_from_file),
    path("files/add_hostels_from_file", add_hostels_from_file),
    path("files/add_locations_from_file", add_locations_from_file),
    path("files/add_authorities_from_file", add_authorities_from_file),
    path("files/add_guards_from_file", add_guards_from_file),
    path("files/add_students_from_file", add_students_from_file),
    # delete data from files routes
    path("files/delete_departments_from_file", delete_departments_from_file),
    path("files/delete_programs_from_file", delete_programs_from_file),
    path("files/delete_hostels_from_file", delete_hostels_from_file),
    path("files/delete_locations_from_file", delete_locations_from_file),
    path("files/delete_authorities_from_file", delete_authorities_from_file),
    path("files/delete_guards_from_file", delete_guards_from_file),
    path("files/delete_students_from_file", delete_students_from_file),
    # add data using forms
    path("forms/add_guard_form", add_guard_form),
    path("forms/add_admin_form", add_admin_form),
    # modify data using forms
    path("forms/modify_guard_form", modify_guard_form),
    # delete data using forms
    path("forms/delete_guard_form", delete_guard_form),
    # Students
    path("students/get_students", get_students),
    path("students/get_all_students", get_all_students),
    path("students/add_student", add_student),
    path("students/get_tickets_for_student", get_tickets_for_student),
    path("students/get_student_status", get_student_status),
    path("students/get_student_by_email", get_student_by_email),
    path("students/get_student_by_id", get_student_by_id),
    path(
        "students/get_authority_tickets_for_students",
        get_authority_tickets_for_students,
    ),
    path(
        "students/change_profile_picture_of_student", change_profile_picture_of_student
    ),
    path("students/get_status_for_all_locations", Get_status_for_all_locations.as_view()),
    path("students/get_location_count/", get_location_count),
    path("students/update_phone_number/", update_phone_number),
    # Locations
    path("locations/add_new_location", add_new_location),
    path("locations/modify_locations", modify_locations),
    path("locations/delete_location", delete_location),
    # only fetches location and pre_approval field
    path("locations/get_all_locations", get_all_locations),
    # fetches all the locations
    path("locations/view_all_locations", view_all_locations),
    path("locations/get_parent_location_name", get_parent_location_name),
    path("locations/get_location_id/", get_location_id),
    path("locations/get_guard_at_a_location/", get_guard_at_a_location),
    # Guards
    path("guards/get_all_guard_emails", get_all_guard_emails),
    path("guards/insert_in_guard_ticket_table", insert_in_guard_ticket_table),
    path("guards/accept_selected_tickets", accept_selected_tickets),
    path("guards/reject_selected_tickets", reject_selected_tickets),
    # To find "Pending" tickets for given location
    path("guards/get_pending_tickets_for_guard", get_pending_tickets_for_guard),
    # To find "Accepted"|"Rejected" tickets for given location for Students
    path("guards/get_tickets_for_guard", get_tickets_for_guard),
    # To find "Accepted"|"Rejected" tickets for given location for visiter
    path("guards/get_visitor_tickets", get_visitor_tickets),
    path("guards/get_guard_by_email", get_guard_by_email),
    path("guards/get_list_of_entry_numbers", get_list_of_entry_numbers),
    path("guards/change_profile_picture_of_guard", change_profile_picture_of_guard),
    path("guards/get_all_guards", get_all_guards),
    # Visitors
    path("visitors/insert_in_visitors_ticket_table", insert_in_visitors_ticket_table),
    path(
        "visitors/insert_in_visitors_ticket_table_2", insert_in_visitors_ticket_table_2
    ),
    path("visitors/get_list_of_visitors", get_list_of_visitors),
    path("visitors/get_pending_tickets_for_visitors", get_pending_tickets_for_visitors),
    path(
        "visitors/get_pending_visitor_tickets_for_authorities",
        get_pending_visitor_tickets_for_authorities,
    ),
    path(
        "visitors/get_past_visitor_tickets_for_authorities",
        get_past_visitor_tickets_for_authorities,
    ),
    path("visitors/accept_selected_tickets_visitors", accept_selected_tickets_visitors),
    path("visitors/reject_selected_tickets_visitors", reject_selected_tickets_visitors),
    # path('/guards/accept_selected_tickets_QR_accepted_rejected',
    #     accept_selected_tickets_QR_accepted_rejected ),
    # Authorities
    path(
        "authorities/accept_selected_tickets_authorities",
        accept_selected_tickets_authorities,
    ),
    path(
        "authorities/reject_selected_tickets_authorities",
        reject_selected_tickets_authorities,
    ),
    # To find "Pending" tickets for given authority email
    path(
        "authorities/get_pending_tickets_for_authorities",
        get_pending_tickets_for_authorities,
    ),
    # To find "Accepted"|"Rejected" tickets for given authority email
    path("authorities/get_tickets_for_authorities", get_tickets_for_authorities),
    path("authorities/get_authority_by_email", get_authority_by_email),
    path("authorities/get_authorities_list", get_authorities_list),
    path(
        "authorities/insert_in_authorities_ticket_table",
        insert_in_authorities_ticket_table,
    ),
    path(
        "authorities/get_authority_tickets_with_status_accepted",
        get_authority_tickets_with_status_accepted,
    ),
    path(
        "authorities/change_profile_picture_of_authority",
        change_profile_picture_of_authority,
    ),
    path("authorities/get_all_authorites", get_all_authorites),
    path("authorities/get_list_of_entry_numbers", get_list_of_entry_numbers),
    # Admin
    # To find "Accepted"|"Rejected" tickets for given authority email
    path("admins/get_admin_by_email", get_admin_by_email),
    # To find "Accepted"|"Rejected" tickets for given authority email
    path("admins/change_profile_picture_of_admin", change_profile_picture_of_admin),
    # Get the list of all admins
    path("admins/get_all_admins", get_all_admins),
    # Statistics
    path("statistics/get_statistics_data_by_location", get_statistics_data_by_location),
    path(
        "statistics/get_piechart_statistics_by_location",
        get_piechart_statistics_by_location,
    ),
    # Hostel
    path("hostels/get_all_hostels", get_all_hostels),
    # Department
    path("departments/get_all_departments", get_all_departments),
    # Program
    path("programs/get_all_programs", get_all_programs),
    # Notification
    path("notification/insert_notification/", insert_notification),
    path("notification/count_notification/", count_notifications),
    path("notification/mark_notification_as_false/", mark_notification_as_false),
    path("notification/fetch_notification_guard/", fetch_notification_guard),
    path("notification/mark_individual_notification/", mark_individual_notification),
    path(
        "notification/insert_notification_guard_accept_reject/",
        insert_notification_guard_accept_reject,
    ),
    # Hostel
    path("location/loc_from_loc_id/", loc_from_loc_id),
    path("hostel/hostel_from_id/", hostel_from_hostel_id),
    path("department/department_from_id/", department_from_department_id),
    path("program/program_from_id/", program_from_program_id),
    # This should be at the last
    # path('',thread_functions),
    # Delete Student
    path("student/delete_student_by_id/", delete_student_by_id),
    #     # login test
    #     path('login_admin_test/', login_admin_test),
    #     path('anothertest/', protected_endpoint),
    # manage student
    path("manage/student/delete", delete_student),
    # manage guard
    path("manage/guard/delete", delete_guard),
    # manage authority
    path("manage/authority/delete", delete_authority),
    path("manage/location/delete", delete_location_web),
    path("manage/hostel/delete", delete_hostel_web),
    path("manage/department/delete", delete_department_web),
    path("manage/program/delete", delete_program_web),
    # count
    path("getdata/count", get_all_count),
    # get history of student
    path('get_history/student', get_history_student),
    path('get_raw/student', get_student_raw),
    path('get_raw/guard', get_guard_raw),
    path('update/student', update_student_details),
    path('update/hostel', update_hostel_details),
    path('update/department', update_department_details),
    path('update/program', update_program_details),
    path('update/location', update_location_details),
    path('manage/add/student', add_student2),
    path('manage/add/location', add_location_single),
    path('manage/add/department', add_department_single),
    path('manage/add/hostel', add_hostel_single),
    path('manage/add/guard', add_guard_single),
    path('manage/add/program', add_program_single),
    path('manage/add/authority', add_authority_single),
    path('getprofile/guard', get_guard_profile),
    path('getprofile/authority', get_authority_profile),
    path('update/guard', update_guard_details),
    path('get_history/guard', get_history_guard),
    path('get_history/authority', get_history_authority),
    path('update/authorities', update_authorities),
    path('get/location', get_location_by_id),


     # byHet
    path('generate_relatives_ticket',GenerateRelativesTicketAPIView.as_view()),
    path('getStudentRelativeTickets', GetStudentRelativeTicketsAPIView.as_view(), name='student_ticket_status'),
    path('adminTickets/status/', AdminTicketStatusAPIView.as_view(), name='student_ticket_status'),
    path('accept_ticket/', AcceptTicketAPIView.as_view(), name='accept_ticket'),
    path('reject_ticket/', RejectTicketAPIView.as_view(), name='reject_ticket'),

    path('getInviteRequestByTicketID',GetInviteRequestByTicketID.as_view(),name='get_invited_request_ticket_id'),
    path('guardApproveInviteeEntryRequest',GuardApproveInviteeEntryRequest.as_view()),

    path('register', register_user, name='register'),
    #     path('login', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    #     path('login', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path(
        "api/token/", jwt_views.TokenObtainPairView.as_view(), name="token_obtain_pair"
    ),
    path(
        "api/token/refresh/", jwt_views.TokenRefreshView.as_view(), name="token_refresh"
    ),
    #     path('api/protect/', protected_endpoint, name='protect_endpoint'),
    #     path('api/protect/', protected_view, name='protect_endpoint'),
]
