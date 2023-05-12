import cv2
from pixellib.custom_train import instance_custom_training
from pixellib.instance import custom_segmentation

# visualization to make sure bounding boxes correctly bound class before training
maskrcnn = instance_custom_training()
maskrcnn.load_dataset("Calico")
maskrcnn.visualize_sample()

# train custom model using custom dataset
maskrcnn.modelConfig(network_backbone = "resnet50", num_classes= 2, batch_size = 4)
maskrcnn.train_model(num_epochs = 300, augmentation = True,  path_trained_models = "mask_rcnn_models")

# evaluate built custom model
maskrcnn.evaluate_model("mask_rccn_models/Nature_model_resnet101.h5")

# (for) live inferencing with custom model
segment_img = custom_segmentation()
segment_img.inferConfig(num_classes = 1, class_names = ["BG", "Calico"])
#segment_img.load_model("model goes here")
segmask, output = segment_img.segmentImage("image/frame", show_bboxex = True)
# cv2.imwrite("img.jpg", output) / camera operation here