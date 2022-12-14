

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
from datetime import datetime
import json




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
            t1 = datetime.fromtimestamp(int(self.start_time/1000000000))
            t2 = datetime.fromtimestamp(int(self.end_time/1000000000))
            
            print( 'start:',t1,'  end:' , t2 ,' ==> diff:',diff,' sec.')
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
                
    def to_json_obj(self):
        result = self.data
        json_obj = {}
        for k in result:
            # print(k,'====================')
            json_obj[k]=[]
            for item in result[k]:
                json_obj[k].append({
                    'start':item.start_time,
                    'end':item.end_time
                })
        return json_obj

    def export(self):
        result = self.data
        first =time.time_ns()
        last = 0
        num = 0
        for k in result:
            print('[',k,']')
            for item in result[k]:
                item.show()
                num=num+1
                if item.start_time < first:
                    first = item.start_time
                if item.end_time!=None and item.end_time > last:
                    last = item.end_time
        if num==0:
            return

        # file name
        t1 = datetime.fromtimestamp(int(first/1000000000))
        t2 = datetime.fromtimestamp(int(last/1000000000))            
        file_name = t1.strftime("export_%Y-%m-%d_%H%M%S_")+t2.strftime("%H%M%S")+'.json'

        print('export json .... start')
        # Serializing json
        json_object = json.dumps(track_data.to_json_obj(), indent=4)
        # Writing to *.json
        # file_name='abc.json'
        with open(file_name, "w") as outfile:
            outfile.write(json_object)
        print('export json .... end')

        # clean data
        for cl in class_labels:
            self.data[cl]=[]


track_data = Track_Data()
# ================
# UI setup
# ================

on_off ='off'
def btn_on():
    print( 'btn on....')
    global on_off
    on_off='on'
    global track_data
    track_data = Track_Data()

def btn_off():
    print( 'btn off....')
    global on_off
    on_off='off'
    

def btn_export():
    print( 'btn export....')
    track_data.export()
    


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

cap=cv2.VideoCapture(1)

# Define function to show frame
frame_count = 0
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
            track_data.add_seg(emotion_label)

    if on_off=='off':
        btnOn['state']='active'
        btnOff['state']='disabled'
    else:
        btnOn['state']='disabled'
        btnOff['state']='active'
        cv2.putText(frame,'[REC]',(20,40),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,255),2)

   

    # Get the latest frame and convert into Image
    frame= cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)
    img = Image.fromarray(frame)
    # Convert image to PhotoImage
    imgtk = ImageTk.PhotoImage(image = img)
    label.imgtk = imgtk
    label.configure(image=imgtk)
    # Repeat after an interval to capture continiously
    label.after(20, show_frames)

    global frame_count
    frame_count = frame_count+1
    if frame_count > 10*50:# 10 sec.
        # track_data.export()
        frame_count = 0

show_frames()
window.mainloop()
