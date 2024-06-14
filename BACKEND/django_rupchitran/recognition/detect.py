# Import the modules
import numpy as np
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
#import tensorflow as tf
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics.pairwise import cosine_similarity
import pickle
import cv2 as cv
from keras_facenet import FaceNet

def recognize_faces(image_path):
    global recognized_face
    recognized_face = []

    facenet = FaceNet()

    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cascade_file_path = os.path.join(script_dir, 'haarcascade_frontalface_default.xml')
    facenet_file_path = os.path.join(script_dir, 'faces_embeddings_done_4classes.npz')
    svm_file_path = os.path.join(script_dir, 'svm_model_160x160.pkl')

    # Load embeddings and labels
    if not os.path.exists(facenet_file_path):
        print(f"Error: File '{facenet_file_path}' not found.")
        exit()

    faces_embeddings = np.load(facenet_file_path)
    X = faces_embeddings['arr_0']
    Y = faces_embeddings['arr_1']
    encoder = LabelEncoder()
    encoder.fit(Y)

    # Load Haar cascade for face detection
    if not os.path.exists(cascade_file_path):
        print(f"Error: File '{cascade_file_path}' not found.")
        exit()

    haarcascade = cv.CascadeClassifier(cascade_file_path)

    # Load pre-trained SVM model
    if not os.path.exists(svm_file_path):
        print(f"Error: File '{svm_file_path}' not found.")
        exit()

    model = pickle.load(open(svm_file_path, 'rb'))

    threshold = 0.6

    img = cv.imread(image_path)

    rgb_img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
    gray_img = cv.cvtColor(img, cv.COLOR_BGR2GRAY)

    faces = haarcascade.detectMultiScale(gray_img, 1.3, 5)
    print(faces)
    for (x, y, w, h) in faces:
        img = rgb_img[y:y+h, x:x+w]
        img = cv.resize(img, (160, 160))
        img_expanded = np.expand_dims(img, axis=0)
        ypred = facenet.embeddings(img_expanded)
        similarities = cosine_similarity(ypred, X)
        max_similarity = np.max(similarities)
        if max_similarity < threshold:
            final_name = "unknown"
        else:
            face_name = model.predict(ypred)
            final_name = encoder.inverse_transform(face_name)[0]

        recognized_face.append({"Name": final_name, "coordinates": {"x": x, "y": y, "w": w, "h": h}})
        print(f"Detected Name: {final_name} at coordinates: x={x}, y={y}, w={w}, h={h}")
        print(recognized_face)
        
    return recognized_face
    
name = recognize_faces("D:\\ChitranRup\\BACKEND\\django_rupchitran\\recognition\\72a7434a-a991-4517-8c83-87ed5c20c83b.png")
name = recognize_faces("D:\\ChitranRup\\BACKEND\\django_rupchitran\\recognition\\72a7434a-a991-4517-8c83-87ed5c20c83b.png")

