import os
import matplotlib.pyplot as plt

from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam


# =========================
# PATHS
# =========================
TRAIN_DIR = r"D:\fraud-detection-system\data\IMAGES\TRAIN"
VAL_DIR   = r"D:\fraud-detection-system\data\IMAGES\VAL"

MODEL_PATH = "model/image_model.keras"


# =========================
# DATA GENERATORS
# =========================
train_gen = ImageDataGenerator(
    rescale=1./255,
    horizontal_flip=True,
    zoom_range=0.3,
    rotation_range=15,
    brightness_range=[0.8, 1.2],
    width_shift_range=0.1,
    height_shift_range=0.1
)

val_gen = ImageDataGenerator(rescale=1./255)


# 🔥 FORCE LABEL ORDER
train_data = train_gen.flow_from_directory(
    TRAIN_DIR,
    target_size=(224, 224),
    batch_size=16,
    class_mode='binary',
    classes=['real', 'fake']
)

val_data = val_gen.flow_from_directory(
    VAL_DIR,
    target_size=(224, 224),
    batch_size=16,
    class_mode='binary',
    classes=['real', 'fake']
)

print("\nClass indices:", train_data.class_indices)


# =========================
# MODEL (FINE-TUNED)
# =========================
base_model = MobileNetV2(
    weights='imagenet',
    include_top=False,
    input_shape=(224, 224, 3)
)

# 🔥 Train last 50 layers
for layer in base_model.layers[:-50]:
    layer.trainable = False

for layer in base_model.layers[-50:]:
    layer.trainable = True


x = base_model.output
x = GlobalAveragePooling2D()(x)

x = Dense(128, activation='relu')(x)
x = Dropout(0.6)(x)   # 🔥 stronger dropout

output = Dense(1, activation='sigmoid')(x)

model = Model(inputs=base_model.input, outputs=output)

model.compile(
    optimizer=Adam(learning_rate=0.00001),
    loss='binary_crossentropy',
    metrics=['accuracy']
)

model.summary()


# =========================
# TRAIN
# =========================
print("\nStarting training...\n")

# 🔥 handle class imbalance
class_weight = {0: 1.0, 1: 1.3}

history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=6,
    class_weight=class_weight,
    verbose=1
)


# =========================
# SAVE MODEL
# =========================
os.makedirs("model", exist_ok=True)
model.save(MODEL_PATH)

print("\nModel saved to:", MODEL_PATH)


# =========================
# PLOT RESULTS
# =========================
plt.figure(figsize=(10,4))

# Loss
plt.subplot(1,2,1)
plt.plot(history.history['loss'], label='train')
plt.plot(history.history['val_loss'], label='val')
plt.legend()
plt.title("Loss")

# Accuracy
plt.subplot(1,2,2)
plt.plot(history.history['accuracy'], label='train')
plt.plot(history.history['val_accuracy'], label='val')
plt.legend()
plt.title("Accuracy")

plt.show()