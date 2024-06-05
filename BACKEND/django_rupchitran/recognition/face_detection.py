from mtcnn import MTCNN
import cv2
import json

# function to get latest added image from images folder


def detect_faces(image_path):
    image = cv2.imread(image_path)
    detector = MTCNN()
    faces = detector.detect_faces(image)
    #bounding_boxes = []
    if faces:
        for face in faces:
            box_dict = {
                'x':face['box'][0],
                'y':face['box'][1],
                'width':face['box'][2],
                'height':face['box'][3]
            }
            #x, y, width, height = face['box']
            #bounding_boxes.append({'x': x, 'y': y, 'width': width, 'height': height})
            #bounding_boxes.append(box_dict)

    #bounding_boxes_json = json.dumps(bounding_boxes)
    bounding_boxes_json = json.dumps(box_dict)

    return bounding_boxes_json




