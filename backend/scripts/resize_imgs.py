import cv2
import os

path = os.path.join('training_images', 'images')

for dir in os.listdir(path):
    for image in os.listdir(os.path.join(path, dir)):
        image_name = image.split(".")[0]
        image_path = os.path.join('training_images', 'images', dir, image)
        imagee = cv2.imread(image_path)
        imagee = cv2.resize(imagee, (320, 213))
        cv2.imwrite(image_path, imagee)
