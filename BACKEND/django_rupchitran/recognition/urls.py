from django.urls import path , include
from .views import *
from rest_framework.routers import DefaultRouter

image_router = DefaultRouter()
image_router.register(r'image', ImageViewSet)

router = DefaultRouter()
router.registry.extend(image_router.registry)

urlpatterns = [
    path("create_course/", TeacherCourseStudentView.as_view(), name="create_course"),
    path('', include(router.urls)),
    path('courses/', CourseView.as_view(), name='courses'),
    path('recognize_face/', FaceRecognitionView.as_view(), name='face'),
    path('recognize_emotion/', EmotionRecognitionView.as_view(), name='emotion')
]