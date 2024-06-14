import numpy as np
import os
import tensorflow as tf
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics.pairwise import cosine_similarity
import pickle
import cv2 as cv
from keras_facenet import FaceNet

# Define global variables for the models and data
facenet = None
haarcascade = None
model = None
encoder = None
X = None
threshold = 0.6

def load_models():
    global facenet, haarcascade, model, encoder, X
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cascade_file_path = os.path.join(script_dir, 'haarcascade_frontalface_default.xml')
    facenet_file_path = os.path.join(script_dir, 'faces_embeddings_done_4classes.npz')
    svm_file_path = os.path.join(script_dir, 'svm_model_160x160.pkl')
    
    # Initialize FaceNet model
    facenet = FaceNet()
    
    # Load embeddings and labels
    if not os.path.exists(facenet_file_path):
        print(f"Error: File '{facenet_file_path}' not found.")
        return

    faces_embeddings = np.load(facenet_file_path)
    X = faces_embeddings['arr_0']
    Y = faces_embeddings['arr_1']
    encoder = LabelEncoder()
    encoder.fit(Y)

    # Load Haar cascade for face detection
    if not os.path.exists(cascade_file_path):
        print(f"Error: File '{cascade_file_path}' not found.")
        return

    haarcascade = cv.CascadeClassifier(cascade_file_path)

    # Load pre-trained SVM model
    if not os.path.exists(svm_file_path):
        print(f"Error: File '{svm_file_path}' not found.")
        return

    model = pickle.load(open(svm_file_path, 'rb'))

def recognize_faces(image_path):
    global recognized_face
    global facenet, haarcascade, model, encoder, X
    
    recognized_face = []

    # Check if models and data are loaded, if not, call load_models
    if facenet is None or haarcascade is None or model is None or encoder is None or X is None:
        load_models()
    
    if facenet is None or haarcascade is None or model is None or encoder is None or X is None:
        print("Error: Models and data not loaded properly.")
        return

    if not os.path.exists(image_path):
        print(f"Error: Image file '{image_path}' not found.")
        return

    img = cv.imread(image_path)
    if img is None:
        print(f"Error: Unable to read image file '{image_path}'.")
        return

    rgb_img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
    gray_img = cv.cvtColor(img, cv.COLOR_BGR2GRAY)

    faces = haarcascade.detectMultiScale(gray_img, 1.3, 5)
    print(f"Faces detected: {faces}")
    for (x, y, w, h) in faces:
        face_img = rgb_img[y:y+h, x:x+w]
        face_img = cv.resize(face_img, (160, 160))
        img_expanded = np.expand_dims(face_img, axis=0)
        ypred = facenet.embeddings(img_expanded)
        similarities = cosine_similarity(ypred, X)
        max_similarity = np.max(similarities)
        if max_similarity < threshold:
            final_name = "unknown"
        else:
            face_name = model.predict(ypred)
            final_name = encoder.inverse_transform(face_name)[0]

        recognized_face.append({"Name": final_name, "coordinates": {"x": x, "y": y, "w": w, "h": h}})
        print(recognized_face)
        
    return recognized_face


# Example usage
name = recognize_faces("D:\\ChitranRup\\BACKEND\\django_rupchitran\\recognition\\0b7d551e-4634-4eab-b54a-7adfcf23c184.jpg")



"""

# Initialize video capture (0 for built-in webcam, 1 for external)
camera_index = 0  # Try with built-in camera first
cap = cv.VideoCapture(camera_index)
if not cap.isOpened():
    print("Error: Could not open video stream.")
    exit()

# Set the distance threshold
threshold = 0.6

# Main loop
try:
    while cap.isOpened():
        # Read a frame from the video capture
        ret, frame = cap.read()
        if not ret:
            print("Error: Could not read frame.")
            break

        # Convert frame to RGB and grayscale
        rgb_img = cv.cvtColor(frame, cv.COLOR_BGR2RGB)
        gray_img = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)

        # Detect faces
        faces = haarcascade.detectMultiScale(gray_img, 1.3, 5)

        for (x, y, w, h) in faces:
            # Extract the face region
            img = rgb_img[y:y+h, x:x+w]
            img = cv.resize(img, (160, 160))  # Resize to 160x160

            # Expand dimensions to match model input
            img = np.expand_dims(img, axis=0)

            # Get embeddings
            ypred = facenet.embeddings(img)

            # Calculate cosine similarity with known faces
            similarities = cosine_similarity(ypred, X)
            max_similarity = np.max(similarities)

            # Determine if the face is "unknown"
            if max_similarity < threshold:
                final_name = "unknown"
            else:
                face_name = model.predict(ypred)
                final_name = encoder.inverse_transform(face_name)[0]

            # Print the face name in the terminal
            print(f"Detected face: {final_name}")

            # Draw rectangle and put text on the frame
            cv.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 255), 2)
            cv.putText(frame, str(final_name), (x, y-10), cv.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2, cv.LINE_AA)

        # Display the frame
        cv.imshow("Face Recognition", frame)

        # Exit on 'q' key press
        if cv.waitKey(1) & 0xFF == ord('q'):
            break
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    # Release resources
    cap.release()
    cv.destroyAllWindows()
"""