# https://youtu.be/NJpS-sFGLng
"""
Live prediction of emotion, age, and gender using pre-trained models. 
Uses haar Cascades classifier to detect face..
then, uses pre-trained models for emotion, gender, and age to predict them from 
live video feed. 
Prediction is done using tflite models. 
Note that tflite with optimization takes too long on Windows, so not even try.
Try it on edge devices, including RPi. 
"""

from keras.models import load_model
from time import sleep
from keras.preprocessing.image import img_to_array
from keras.preprocessing import image
import cv2
import numpy as np
import tensorflow as tf
import tkinter as tk
from PIL import Image, ImageTk
import time




# ================
# classifier setup
# ================


face_classifier=cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

# Load the TFLite model and allocate tensors.
emotion_interpreter = tf.lite.Interpreter(model_path="emotion_detection_model_100epochs_no_opt.tflite")
emotion_interpreter.allocate_tensors()

# Get input and output tensors.
emotion_input_details = emotion_interpreter.get_input_details()
emotion_output_details = emotion_interpreter.get_output_details()

# Test the model on input data.
emotion_input_shape = emotion_input_details[0]['shape']

class_labels=['Angry','Disgust', 'Fear', 'Happy','Neutral','Sad','Surprise']
gender_labels = ['Male', 'Female']

# ================
# Data Class
# ================
class Time_Seg:
    def __init__(self , em , time) -> None:
        self.emotion = em 
        self.start_time = time 
        self.end_time = None
    def show( self ):
        if self.end_time!=None:
            diff = (self.end_time - self.start_time)/1000000000
            print( 'diff:',diff,' sec.')
        pass

class Track_Data:
    def __init__(self ):
        self.data ={}
        for cl in class_labels:
            self.data[cl]=[]
    def add_seg( self , emotion ):
        t=time.time_ns()
        # print("t:",t)
        if len(self.data[emotion])==0:
            self.data[emotion].append(Time_Seg( emotion,t))
        else:
            last_one = self.data[emotion][-1]
            if last_one.end_time != None:
                # less than 0.3 sec ==> extend segments
                # else ==> new segments
                if t-last_one.end_time<3*100000000:
                    last_one.end_time = t 
                else:
                    self.data[emotion].append(Time_Seg( emotion,t))
            else:
                # less than 0.3 sec ==> extend segments
                # else ==> set new segments
                if t-last_one.start_time<3*100000000:
                    last_one.end_time = t 
                else:
                    last_one.start_time = t 
                



track_data = Track_Data()
# ================
# UI setup
# ================

on_off ='off'
def btn_on():
    print( 'btn on....')
    global on_off
    on_off='on'

def btn_off():
    print( 'btn off....')
    global on_off
    on_off='off'

def btn_export():
    print( 'btn export....')

window = tk.Tk()
window.title('GUI')


window.columnconfigure(0, weight=1)
window.columnconfigure(1, weight=1)
window.columnconfigure(2, weight=1)
window.columnconfigure(3, weight=15)

btnOn = tk.Button(window, text='On',command=btn_on , width=7,height=2,pady=10)
btnOn.grid(row=1,column=0)

btnOff = tk.Button(window, text='Off',command=btn_off, width=7,height=2,pady=10)
btnOff.grid(row=1,column=1)

btnExport = tk.Button(window, text='Export',command=btn_export, width=7,height=2,pady=10)
btnExport.grid(row=1,column=2)

vFrame = tk.Frame( window , bg='black')
label = tk.Label(vFrame)
label.pack()
vFrame.grid(row=2,column=0 , columnspan = 4, padx = 5, pady = 5)

cap=cv2.VideoCapture(0)

# Define function to show frame
def show_frames():

    ret,frame=cap.read()  
    if on_off=='on':            
        gray=cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)
        faces=face_classifier.detectMultiScale(gray,1.3,5)

        for (x,y,w,h) in faces:
            cv2.rectangle(frame,(x,y),(x+w,y+h),(255,0,0),2)
            roi_gray=gray[y:y+h,x:x+w]
            roi_gray=cv2.resize(roi_gray,(48,48),interpolation=cv2.INTER_AREA)

            #get image ready for prediction
            roi=roi_gray.astype('float')/255.0  #Scale
            roi=img_to_array(roi)
            roi=np.expand_dims(roi,axis=0)  #expand dims to get it ready for prediction (1, 48, 48, 1)
            
            emotion_interpreter.set_tensor(emotion_input_details[0]['index'], roi)
            emotion_interpreter.invoke()
            emotion_preds = emotion_interpreter.get_tensor(emotion_output_details[0]['index'])

            #preds=emotion_model.predict(roi)[0]  #Yields one hot encoded result for 7 classes
            emotion_label=class_labels[emotion_preds.argmax()]  #find the label
            emotion_label_position=(x,y)
            cv2.putText(frame,emotion_label,emotion_label_position,cv2.FONT_HERSHEY_SIMPLEX,1,(0,255,0),2)

    if on_off=='off':
        btnOn['state']='active'
        btnOff['state']='disabled'
    else:
        btnOn['state']='disabled'
        btnOff['state']='active'
        cv2.putText(frame,'[REC]',(20,40),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,255),2)

    track_data.add_seg('test')

    # Get the latest frame and convert into Image
    frame= cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)
    img = Image.fromarray(frame)
    # Convert image to PhotoImage
    imgtk = ImageTk.PhotoImage(image = img)
    label.imgtk = imgtk
    label.configure(image=imgtk)
    # Repeat after an interval to capture continiously
    label.after(20, show_frames)

show_frames()
window.mainloop()
