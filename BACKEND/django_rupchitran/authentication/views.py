from rest_framework.views import APIView
from .models import Users
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import status
from django.contrib.auth.hashers import make_password, check_password
import datetime
import jwt
from django.conf import settings


class SignupView(APIView):
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        try:
            username = request.data.get('username')
            email = request.data.get('email')
            password = request.data.get('password')

            if not username or not email or not password:
                return Response({'message': 'Please fill all the fields'}, status=status.HTTP_400_BAD_REQUEST)

            if Users.objects.filter(email=email).exists():
                return Response({'message': 'Email already exists'}, status=status.HTTP_400_BAD_REQUEST)

            hashed_password = make_password(password)
            user = Users(username=username, email=email, password=hashed_password)
            user.save()

            return Response({'message': 'User created'}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'message': f'An error occurred: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LoginView(APIView):
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response({'message': 'Email and password are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = Users.objects.get(email=email)
        except Users.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        if not check_password(password, user.password):
            return Response({'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        now = datetime.datetime.now(datetime.timezone.utc)
        expiration = now + datetime.timedelta(minutes=60)

        payload = {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'exp': expiration,
            'iat': now
        }

        try:
            token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')
        except Exception as e:
            return Response({'message': f'Error encoding token: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        response = Response({'jwt': token}, status=status.HTTP_200_OK)
        response.set_cookie(key='jwt', value=token, httponly=True)
        
        return response
        
class ProfileView(APIView):
    permission_classes = []
    authentication_classes = []

    def get(self, request):
        token = request.GET.get('jwt', None)
        print(token)

        if not token:
            print("Not authenticated")
            return Response({'error': 'Not authenticated'}, status=401)
        
        try:
            print("Decoding token")
            payload = jwt.decode(token, 'secret', algorithms=['HS256'])
            print("Payload")
            print(payload)
        except jwt.ExpiredSignatureError:
            return Response({'error': 'Token expired'}, status=401)
        except jwt.InvalidTokenError as e:
            print("Invalid Token Error:", e) 
            return Response({'error': 'Invalid token'}, status=401)
        
        try:
            user = Users.objects.get(id=payload['id'])
            courses = Course.objects.filter(user=user)  # Assuming a ForeignKey relationship
            course_data = [{'id': course.id, 'title': course.title, 'description': course.description} for course in courses]

            response_data = {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'courses': course_data
            }
            return Response(response_data)
        except Users.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)

class LogoutView(APIView):
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        response = Response()
        response.delete_cookie('jwt')
        response.data = {
            'message': 'logged out'
        }