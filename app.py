import streamlit as st
from PIL import Image
import numpy as np
import tensorflow as tf
from keras import backend as K

def load_model():
    """Load pre-trained MobileNetV2 model"""
    return tf.keras.models.load_model("model.h5")

def process_image(image):
    """Process image for model prediction"""
    # Resize image to 224x224 pixels
    image = tf.image.resize(image, (336, 224))
    # Convert to array and expand dimensions
    image = np.array(image)
    image = np.expand_dims(image, axis=0)
    # Preprocess the image
    return image

def classify_image(model, image):
    """Make prediction using the model"""
    labels = ["Citra", "Madu Deli Hijau"]
    processed_image = process_image(image)
    predictions = model.predict(processed_image)
    prediction = np.argmax(predictions, axis=1)[0]
    print(predictions)
    return labels[prediction], predictions[0][prediction]

def main():
    st.title("Image Classification App")
    
    # Initialize session state variables if they don't exist
    if 'camera_on' not in st.session_state:
        st.session_state.camera_on = False
    if 'current_image' not in st.session_state:
        st.session_state.current_image = None
    if 'image_source' not in st.session_state:
        st.session_state.image_source = None

    # Create two columns for camera and file upload
    col1, col2 = st.columns(2)

    # Camera controls
    with col1:
        st.subheader("Camera Input")
        if st.button("Toggle Camera"):
            st.session_state.camera_on = not st.session_state.camera_on
            st.session_state.image_source = None
            st.session_state.current_image = None

        if st.session_state.camera_on:
            camera_image = st.camera_input("Take a photo")
            if camera_image is not None:
                st.session_state.current_image = Image.open(camera_image)
                st.session_state.image_source = "camera"

    # File upload
    with col2:
        st.subheader("File Upload")
        uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "jpeg", "png"])
        if uploaded_file is not None:
            st.session_state.current_image = Image.open(uploaded_file)
            st.session_state.image_source = "upload"

    # Display current image and classification results
    if st.session_state.current_image is not None:
        st.image(st.session_state.current_image, caption="Selected Image", use_column_width=True)
        
        if st.button("Classify Image"):
            try:
                # Load model
                model = load_model()
                
                # Convert PIL Image to numpy array
                image_array = np.array(st.session_state.current_image)
                
                # Make prediction
                label, confidence = classify_image(model, image_array)
                
                # Display results
                st.subheader("Classification Results:")
                
                st.write(f"{label} ({confidence*100:.2f}% confidence)")

                K.clear_session()
                del model
                    
            except Exception as e:
                st.error(f"Error during classification: {str(e)}")
    else:
        st.warning("Please either take a photo with the camera or upload an image before classification.")

if __name__ == "__main__":
    main()