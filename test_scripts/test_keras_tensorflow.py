#################################
##### Lade Modelle ##############
#################################
try:
    yolo_model_path = '/home/appuser/gputest/test_scripts/yolov8n-face-lindevs.pt'
    xception_model_path = '/home/appuser/gputest/test_scripts/_mini_XCEPTION.102-0.66.hdf5'

    # Lade YOLO-Modell
    yolo_model = YOLO(yolo_model_path)
    logging.info("YOLO-Modell erfolgreich geladen.")

    # Lade Xception-Modell
    keras_model = load_model(xception_model_path, compile=False)
    logging.info("Xception-Modell erfolgreich geladen.")
except Exception as e:
    logging.error(f"Fehler beim Laden der Modelle: {str(e)}")
    exit(1)

#################################
##### Videoverarbeitung #########
#################################
try:
    # Ersetze 'path_to_video.mp4' durch den Pfad zu deinem Video
    video_path = '/home/appuser/gputest/test_scripts/testclip.mp4'
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        logging.error("Video konnte nicht geöffnet werden.")
        exit(1)

    frame_count = 0
    emotions_per_frame = []

    while cap.isOpened():
        success, img = cap.read()
        if not success:
            break

        # Führe YOLO-Vorhersage durch
        results = yolo_model.predict(img, conf=0.5)
        emotion_data = []

        for result in results:
            for box in result.boxes:
                # Extrahiere das Gesicht aus dem Bild
                x1, y1, x2, y2 = int(box.xyxy[0][0]), int(box.xyxy[0][1]), int(box.xyxy[0][2]), int(box.xyxy[0][3])
                face = img[y1:y2, x1:x2]
                face = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
                face = cv2.resize(face, (64, 64))
                face = image.img_to_array(face)
                face = np.expand_dims(face, axis=0)
                face /= 255

                # Führe Emotionserkennung durch
                preds = keras_model.predict(face)
                emotion_score = np.max(preds)
                emotion_label = ["angry", "disgust", "scared", "happy", "sad", "surprised", "neutral"][preds.argmax()]

                # Speichere Emotionsdaten
                emotion_data.append((emotion_label, emotion_score))

        emotions_per_frame.append(emotion_data)
        frame_count += 1

        logging.info(f"Frame {frame_count}: Emotionserkennung erfolgreich.")

    cap.release()
    logging.info("Videoverarbeitung abgeschlossen.")
    logging.info(f"Emotionsdaten: {emotions_per_frame}")

except Exception as e:
    logging.error(f"Fehler bei der Videoverarbeitung: {str(e)}")
    exit(1)