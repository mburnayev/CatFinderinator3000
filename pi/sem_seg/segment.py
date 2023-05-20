# Copyright 2021 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Main script to run image segmentation."""

import sys, time, cv2, numpy as np, utils
from typing import List

from tflite_support.task import core
from tflite_support.task import processor
from tflite_support.task import vision

# Visualization parameters
_FPS_AVERAGE_FRAME_COUNT = 10
_FPS_LEFT_MARGIN = 24  # pixels
_LEGEND_TEXT_COLOR = (0, 0, 255)  # red
_LEGEND_FONT_SIZE = 1
_LEGEND_FONT_THICKNESS = 1
_LEGEND_ROW_SIZE = 20  # pixels
_OVERLAY_ALPHA = 0.5

def run(model: str, display_mode: str, num_threads: int, enable_edgetpu: bool,
        camera_id: int, width: int, height: int) -> None:
  """Continuously run inference on images acquired from the camera.

  Args:
    model: Name of the TFLite image segmentation model.
    display_mode: Name of mode to display image segmentation.
    num_threads: Number of CPU threads to run the model.
    enable_edgetpu: Whether to run the model on EdgeTPU.
    camera_id: The camera id to be passed to OpenCV.
    width: The width of the frame captured from the camera.
    height: The height of the frame captured from the camera.
  """

  # Initialize the image segmentation model.
  base_options = core.BaseOptions(
      file_name=model, use_coral=enable_edgetpu, num_threads=num_threads)
  segmentation_options = processor.SegmentationOptions(
      output_type=processor.OutputType.CATEGORY_MASK)
  options = vision.ImageSegmenterOptions(
      base_options=base_options, segmentation_options=segmentation_options)

  segmenter = vision.ImageSegmenter.create_from_options(options)

  # Variables to calculate FPS
  counter, fps = 0, 0
  start_time = time.time()

  # Start capturing video input from the camera
  cap = cv2.VideoCapture(camera_id)
  cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
  cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)

  # Continuously capture images from the camera and run inference.
  if not cap.isOpened():
        print("Cannot open camera!")
        return
  
  while True:
    success, image = cap.read()
    if not success:
      sys.exit(
          'ERROR: Unable to read from webcam. Please verify your webcam settings.'
      )

    counter += 1
    # image = image[40:440, 120:520] # image[0:480, 80:560], 480x640

    # Convert the image from BGR to RGB as required by the TFLite model.
    rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # Create TensorImage from the RGB image
    tensor_image = vision.TensorImage.create_from_array(rgb_image)
    # Segment with each frame from camera.
    segmentation_result = segmenter.segment(tensor_image)

    # Convert the segmentation result into an image.
    seg_map_img, found_colored_labels = utils.segmentation_map_to_image(segmentation_result)

    # Resize the segmentation mask to be the same shape as input image.
    seg_map_img = cv2.resize(
        seg_map_img,
        dsize=(image.shape[1], image.shape[0]),
        interpolation=cv2.INTER_NEAREST)

    # Visualize segmentation result on image.
    overlay = visualize(image, seg_map_img, display_mode, fps, found_colored_labels)

    # Calculate the FPS
    if counter % _FPS_AVERAGE_FRAME_COUNT == 0:
      end_time = time.time()
      fps = _FPS_AVERAGE_FRAME_COUNT / (end_time - start_time)
      start_time = time.time()

    # Stop the program if the ESC key is pressed.
    if cv2.waitKey(1) == 27:
      break
    cv2.imshow('image_segmentation', overlay)

  cap.release()
  cv2.destroyAllWindows()


def visualize(input_image: np.ndarray, segmentation_map_image: np.ndarray,
              display_mode: str, fps: float,
              colored_labels: List[processor.ColoredLabel]) -> np.ndarray:
  """Visualize segmentation result on image.

  Args:
    input_image: The [height, width, 3] RGB input image.
    segmentation_map_image: The [height, width, 3] RGB segmentation map image.
    display_mode: How the segmentation map should be shown. 'overlay' or
      'side-by-side'.
    fps: Value of fps.
    colored_labels: List of colored labels found in the segmentation result.

  Returns:
    Input image overlaid with segmentation result.
  """
  # Show the input image and the segmentation map image.
  if display_mode == 'overlay':
    overlay = cv2.addWeighted(input_image, _OVERLAY_ALPHA, segmentation_map_image, _OVERLAY_ALPHA, 0)
  elif display_mode == 'side-by-side':
    overlay = cv2.hconcat([input_image, segmentation_map_image])
  else:
    sys.exit(f'ERROR: Unsupported display mode: {display_mode}.')

  # Show the FPS
  fps_text = 'FPS = ' + str(int(fps))
  text_location = (_FPS_LEFT_MARGIN, _LEGEND_ROW_SIZE)
  cv2.putText(overlay, fps_text, text_location, cv2.FONT_HERSHEY_PLAIN,
              _LEGEND_FONT_SIZE, _LEGEND_TEXT_COLOR, _LEGEND_FONT_THICKNESS)

  return overlay

if __name__ == '__main__':
  run("deeplabv3.tflite", "overlay", 4, False, 0, 640, 480)
