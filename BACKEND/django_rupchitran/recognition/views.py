from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from .face_detection import *
from .models import *
from .facecrop import face_detect_crop_save
from rest_framework.viewsets import ModelViewSet
from .serializers import ImageSerializer
from BACKEND.FaceNet.detect import recognize_faces
from BACKEND.Emotion.emotion import recognize_emotion

class ImageViewSet(ModelViewSet):
    queryset = Image.objects.all()
    serializer_class = ImageSerializer

class FaceRecognitionView(APIView):
        
        def get(self, request):
            latest_image = Image.objects.latest('uploaded_at')
            data = recognize_faces(latest_image.image.path)
            return Response(data)
        
class EmotionRecognitionView(APIView):
     
     def get(self,request):
        latest_image = Image.objects.latest('uploaded_at')
        data = recognize_emotion(latest_image.image.path)
        return Response(data)
          
        
class CourseView(APIView):
    
    def get(self, request):
        teacher_name = request.data.get('teacher')
        teacher = Teacher.objects.get(teacherName=teacher_name)
        teacher_id = teacher.id
        courses = Course.objects.filter(teacher=teacher_id)
        data = []
        for course in courses:
            data.append({
                'course_name': course.courseName,
            })
        return Response(data)

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

    

        

    

    
    

        

        




        