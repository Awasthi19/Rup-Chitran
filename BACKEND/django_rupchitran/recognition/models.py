from django.db import models

class Image(models.Model):
    image = models.ImageField(upload_to='images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.image.name

class Student(models.Model):
    studentName = models.CharField(max_length=100)
    rollNo = models.IntegerField()
    def __str__(self):
        return self.studentName

class Teacher(models.Model):
    teacherName = models.CharField(max_length=100)
    email = models.EmailField() 
    password = models.CharField(max_length=100)
    def __str__(self):
        return self.teacherName
    
class Course(models.Model):
    courseName = models.CharField(max_length=100)
    teacher = models.ForeignKey('Teacher', on_delete=models.CASCADE, related_name='courses')
    students = models.ManyToManyField('Student', related_name='courses')
    def __str__(self):
        return self.courseName

class Attendance(models.Model):
    course = models.ForeignKey('Course', on_delete=models.CASCADE, related_name='attendances')
    date = models.DateField()
    students = models.ManyToManyField('Student', related_name='attendances')
    Status = models.BooleanField(default=False)
    def __str__(self):
        return self.course.courseName + ' ' + str(self.date)

    