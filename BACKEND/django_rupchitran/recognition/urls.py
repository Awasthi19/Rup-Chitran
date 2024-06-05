from django.urls import path , include
from .views import *
from rest_framework.routers import DefaultRouter
from .views import ImageViewSet

image_router = DefaultRouter()
image_router.register(r'image', ImageViewSet)

router = DefaultRouter()
router.registry.extend(image_router.registry)

urlpatterns = [
    path('facedetect/', FaceDetectView.as_view(), name='face_detect'),
    path("create_course/", TeacherCourseStudentView.as_view(), name="create_course"),
    path('', include(router.urls)),
]