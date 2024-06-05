from drf_extra_fields.fields import Base64ImageField
from rest_framework import serializers
from .models import Image

class ImageSerializer(serializers.ModelSerializer):
    image = Base64ImageField()
    class Meta:
        model = Image
        fields = ['image', 'uploaded_at']
