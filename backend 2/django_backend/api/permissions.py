from rest_framework.permissions import BasePermission
from rest_framework.exceptions import PermissionDenied

class IsStudent(BasePermission):
    def has_permission(self, request, view):
        # Your custom permission logic here
        if(not request.user.is_authenticated 
            or request.user.type !='Student'):
            raise PermissionDenied(detail="need to be a Student to access")
        
        return True
class IsGuard(BasePermission):
    def has_permission(self, request, view):
        # Your custom permission logic here
        return (
            request.user.is_authenticated 
            and request.user.type =='Guard'
        )
