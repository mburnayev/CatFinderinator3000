from tflite_model_maker import image_classifier
from tflite_model_maker.image_classifier import DataLoader
import os

# root_path = "/images/"
#image_path = os.path.join(os.path.dirname(root_path), "Calico")
#data = DataLoader.from_folder(image_path)

# When actually using this, images was split into just png images
# and xml files were in their own directory, which I interestingly didn't use...
# There's a lot I didn't do correctly :/

data = DataLoader.from_folder("images")
train, test = data.split(0.9)

model = image_classifier.create(train)
print("-"*20)
print("model made!")

loss, accuracy = model.evaluate(test)
print("-"*20)
print("model evaluated!")

model.export(export_dir=".")
