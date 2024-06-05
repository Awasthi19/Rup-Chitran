import os
import cv2
import datetime
import json

def face_detect_crop_save(image_path): 
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cascade_file_path = os.path.join(script_dir, 'haarcascade_frontalface_default.xml')
    face_cascade = cv2.CascadeClassifier(cascade_file_path)
    img = cv2.imread(image_path)
    faces = face_cascade.detectMultiScale(img, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30), flags=cv2.CASCADE_SCALE_IMAGE)

    output_dir = os.path.join(script_dir, 'cropped_faces')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    if len(faces) == 0:
        return "No faces detected in the image."
    
    # extracting the faces from the image
    for i, (x, y, w, h) in enumerate(faces):
        cropped_face = img[y:y+h, x:x+w]
        resized_face = cv2.resize(cropped_face, (250, 250))
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        face_filename = os.path.join(output_dir, f"{timestamp}_Face_{i+1}.jpg")
        cv2.imwrite(face_filename, resized_face)

        box_dict = {
            'x':int(x),
            'y':int(y),
            'width':int(w),
            'height':int(h)
        }

    bounding_boxes_json = json.dumps(box_dict)
    return bounding_boxes_json
