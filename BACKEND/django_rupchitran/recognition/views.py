from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .face_detection import *
from .models import *
from .facecrop import face_detect_crop_save
from rest_framework.viewsets import ModelViewSet
from .serializers import ImageSerializer
from .detect import recognize_faces
from .emotion import recognize_emotion
import jwt
from django.contrib.auth.hashers import make_password, check_password
import datetime
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

            if Teacher.objects.filter(email=email).exists():
                return Response({'message': 'Email already exists'}, status=status.HTTP_400_BAD_REQUEST)

            hashed_password = make_password(password)
            user = Teacher(teacherName=username, email=email, password=hashed_password)
            user.save()

            return Response({'message': 'User created'}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'message': f'An error occurred: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LoginView(APIView):
    permission_classes = []
    authentication_classes = []

    def post(self, request):
        print("Login view")
        email = request.data.get('email')
        password = request.data.get('password')
        print(email)

        if not email or not password:
            return Response({'message': 'Email and password are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = Teacher.objects.get(email=email)
        except Teacher.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        if not check_password(password, user.password):
            return Response({'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        now = datetime.datetime.now(datetime.timezone.utc)
        expiration = now + datetime.timedelta(minutes=60)

        payload = {
            'teacherName': user.teacherName,
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
            user = Teacher.objects.get(id=payload['id'])
            courses = Course.objects.filter(user=user)  # Assuming a ForeignKey relationship
            course_data = [{'id': course.id, 'title': course.title, 'description': course.description} for course in courses]

            response_data = {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'courses': course_data
            }
            return Response(response_data)
        except Teacher.DoesNotExist:
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



class ImageViewSet(ModelViewSet):
    queryset = Image.objects.all()
    serializer_class = ImageSerializer

class FaceRecognitionView(APIView):
        
    def get(self, request):
        print("faceRecognition")
        latest_image = Image.objects.latest('uploaded_at')
        faces = recognize_faces(latest_image.image.path)
        names = [face['Name'] for face in faces if face['Name'] != "unknown"]
        course_name = request.data.get("course")
        print(course_name)
        course = Course.objects.get(courseName=course_name)
        today = datetime.date.today()
        current_time = datetime.datetime.now()
        
        students = Student.objects.filter(studentName__in=names)
        studentInCourse = course.students.filter(studentName__in=names)

        for student in studentInCourse:
            detection, created = Detection.objects.get_or_create(
                student=student, 
                course=course,
                defaults={'first_detected': current_time, 'last_detected': current_time}
            )
            
            if not created:
                detection.last_detected = current_time
                detection.save()
                
            # Check if the duration between first and last detection is more than an hour
            if detection.last_detected - detection.first_detected >= datetime.timedelta(hours=1):
                attendance, created = Attendance.objects.get_or_create(course=course, date=today)
                attendance.students.add(student)
                attendance.Status = True
                attendance.save()
                faces.append({'Status': 'Present'})
        
        return Response(faces)
        
class EmotionRecognitionView(APIView):
     
     def get(self,request):
        latest_image = Image.objects.latest('uploaded_at')
        faces = recognize_emotion(latest_image.image.path)

        return Response(faces)
     
class StudentView(APIView):
        
    def post(self, request):
        student_name = request.data.get('studentName')
        roll_no = request.data.get('rollNo')
        course_name = request.data.get('courseName')
        if not student_name or not roll_no or not course_name:
            return Response({'error': 'Student name, roll number and course name are required'}, status=400)
        
        course = Course.objects.get(courseName=course_name)
        student,created = Student.objects.get_or_create(studentName=student_name, rollNo=roll_no)
        course.students.add(student)
        return Response({'message': 'Student added successfully'}, status=201)
    
    def get(self, request):
        course_name = request.GET.get('courseName')
        course = Course.objects.get(courseName=course_name)
        students = course.students.all()
        data = []
        for student in students:
            data.append({
                'student_name': student.studentName,
                'roll_no': student.rollNo
            })
        return Response({'students': data}, status=200)
          
        
class CourseView(APIView):

    def post(self, request):
        #token = request.COOKIES.get('jwt')
        token = request.headers.get('Authorization')

        if not token:
            return Response({'error': 'Not authenticated'}, status=401)
        
        try:

            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
            print(payload)
        except jwt.ExpiredSignatureError:
            return Response({'error': 'Token expired'}, status=401)
        except jwt.InvalidTokenError:
            return Response({'error': 'Invalid token'}, status=401)
        
        teacher_name = payload['teacherName']
        teacher = Teacher.objects.get(teacherName=teacher_name)
        course_name = request.data.get('courseName')
        print(course_name)
        if not course_name :
            return Response({'error': 'Course name is required'}, status=400)

        try:
            # Create the course
            course = Course.objects.create(courseName=course_name, teacher=teacher)
            course.save()

            return Response({'message': 'Course created successfully'}, status=201)
        
        except Exception as e:
            return Response({'error': str(e)}, status=500)

  
    def get(self, request):
        token = request.COOKIES.get('jwt')
        #token = request.headers.get('Authorization')
        print(token)
        if not token:
            return Response({'error': 'Not authenticated'}, status=401)
        
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            return Response({'error': 'Token expired'}, status=401)
        except jwt.InvalidTokenError:
            return Response({'error': 'Invalid token'}, status=401)
        print(token)
        teacher_name = payload['teacherName']
        teacher = Teacher.objects.get(teacherName=teacher_name)
        courses = Course.objects.filter(teacher=teacher)
        data = []
        for course in courses:
            data.append({
                'course_name': course.courseName,
            })
        print(data)
        return Response({'courses': data}, status=200)
    
    def delete(self, request):
        #token = request.COOKIES.get('jwt')
        token = request.headers.get('Authorization')
        if not token:
            return Response({'error': 'Not authenticated'}, status=401)
        
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            return Response({'error': 'Token expired'}, status=401)
        except jwt.InvalidTokenError:
            return Response({'error': 'Invalid token'}, status=401)
        
        teacher_name = payload['teacherName']
        teacher = Teacher.objects.get(teacherName=teacher_name)
        course_name = request.data.get('courseName')
        if not course_name:
            return Response({'error': 'Course name is required'}, status=400)
        
        try:
            course = Course.objects.get(courseName=course_name, teacher=teacher)
            course.delete()
            return Response({'message': 'Course deleted successfully'}, status=200)
        except Course.DoesNotExist:
            return Response({'error': 'Course not found'}, status=404)


class TeacherCourseStudentView(APIView):
    
    def post(self, request):
        teacher = Teacher.objects.get(id=request.data.get('teacher_id'))
        course = Course.objects.create(
            courseName=request.data.get('course_name'),
            teacher=teacher
        )
        students = request.data.get('students')
        for student in students:
            student_obj = Student.objects.create(
                studentName=student.get('student_name'),
                rollNo=student.get('roll_no')
            )
            course.students.add(student_obj)
        return Response('Course and Students added successfully')

    

 