import cv2
from matplotlib import pyplot as plt

# ------------------

import numpy as np
import tensorflow as tf

# ------------------
detect_fn = tf.saved_model.load("model/saved_model")

labels = [
    {"name": "tylenol", "id": 1},
    {"name": "peroxide", "id": 2},
    {"name": "move free", "id": 3},
    {"name": "motrin", "id": 4},
]
Threshold = 0.5


def ExtractBBoxes(bboxes, bclasses, bscores, width, height):
    # print(len(bboxes))
    # print(len(bclasses))
    # print(bclasses[0])
    bbox = []
    class_labels = []
    for idx in range(len(bboxes)):
        # print(idx)
        if bscores[idx] >= Threshold:
            y_min = int(bboxes[idx][0] * height)
            x_min = int(bboxes[idx][1] * width)
            y_max = int(bboxes[idx][2] * height)
            x_max = int(bboxes[idx][3] * width)
            class_label = labels[int(bclasses[idx]) - 1]["name"]
            class_labels.append(class_label)
            bbox.append([x_min, y_min, x_max, y_max, class_label, float(bscores[idx])])
        #  print(bscores[idx])
    return (bbox, class_labels)


def get_classification(image_path):
    #  img = cv2.imread(image_path)

    # print(img)

    image = tf.image.decode_image(open(image_path, "rb").read(), channels=3)
    # print(image)

    # plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    # plt.show()
    # # Change this resolution if needed
    image = tf.image.resize(image, (320, 213))
    image = tf.cast(image, tf.uint8)

    input_tensor = tf.expand_dims(image, 0)
    detections = detect_fn(input_tensor)

    bboxes = detections["detection_boxes"][0].numpy()
    bclasses = detections["detection_classes"][0].numpy().astype(np.int32)
    bscores = detections["detection_scores"][0].numpy()
    _, class_labels = ExtractBBoxes(
        bboxes, bclasses, bscores, image.shape[1], image.shape[0]
    )

    return class_labels


def displayImage(path):
    img = cv2.imread(path)
    image_np = np.array(img)
    plt.imshow(cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB))
    plt.show()
