# Code adapted from Madhawa Vidanapathirana
# https://medium.com/@madhawavidanapathirana/real-time-human-detection-in-computer-vision-part-2-c7eda27115c6
# who adapted it from Tensorflow Object Detection Framework
# https://github.com/tensorflow/models/blob/master/research/object_detection/object_detection_tutorial.ipynb

import os
import re
import shutil
import time
from datetime import datetime, timedelta

import cv2
import numpy as np
import tensorflow as tf


def main():
    # Model
    model_path = 'faster_rcnn_inception_v2_coco_2018_01_28/frozen_inference_graph.pb'
    imgs_format = '.png'
    threshold = 0.6  # only for the visualisation (when vid_display=1), no threshold considered for txt results

    # Directories
    dataset_dir = '..\\dataset'
    in_main_dir = os.path.join(dataset_dir, 'png')
    res_dir = os.path.join(dataset_dir, 'res')
    output_logs_dir = '..\\logs\\pedestrian_detection'

    # Settings
    vid_display = 0
    info_display = 1
    clean_prev_res = 1
    flattened_res_tree = 1
    if flattened_res_tree:
        clean_prev_res = 1
        copy_res_dir = os.path.join(dataset_dir, 'res_nonflat')

    # Initialisations
    cpt_img_tot = 0
    start_time = time.time()
    processing_total_time = 0
    average_fps = 0.01

    # Clean results' folder
    if clean_prev_res:
        if os.path.exists(res_dir):
            shutil.rmtree(res_dir)

    # Some display
    output_logs_fname = datetime.now().strftime('run_%Y_%m_%d__%H_%M_%S') + '.txt'
    output_logs_f = open(os.path.join(output_logs_dir, output_logs_fname), 'w')
    if info_display:
        num_im_tot, num_dirs_tot = get_num_format_file(in_main_dir, imgs_format)
        display_str = '  num_im_tot : ' + str(num_im_tot) + '\nnum_dirs_tot : ' + str(num_dirs_tot) + '\n'
        print(display_str)
        output_logs_f.write(display_str)

    odapi = DetectorAPI(path_to_ckpt=model_path)

    cpt_dir = 0
    for root, dirs, files in os.walk(in_main_dir):

        files = [file for file in files if imgs_format in file]
        if not files:
            continue
        cpt_dir += 1

        # Some display
        if info_display:
            display_str = '\n current_dir : {} (#{}/{})\n       numIm : {:d}\nelapsed_time : {}\n   remaining : {}\n average_fps : {:.2f}'. \
                format(root, cpt_dir, num_dirs_tot, len(files), str(timedelta(seconds=processing_total_time)),
                       str(timedelta(seconds=((num_im_tot - cpt_img_tot) / average_fps))), average_fps)
            print(display_str)
            output_logs_f.write('\n' + display_str)

        vid_res_file_path = os.path.join(res_dir, root[len(in_main_dir) + 1: len(root)]) + '.txt'
        if not os.path.isdir(os.path.split(vid_res_file_path)[0]):
            os.makedirs(os.path.split(vid_res_file_path)[0])
        vid_res_file = open(vid_res_file_path, 'w')

        # Pedestrian detection frame by frame
        cpt_img = 0
        # for image_name in os.listdir(root):  # TODO why didn't I use 'for image_name in files' ?
        for image_name in files:

            img = cv2.imread(os.path.join(root, image_name))

            boxes, scores, classes, num, elasped_time = odapi.processFrame(img)

            cpt_img += 1
            processing_total_time += elasped_time

            for i in range(len(boxes)):
                # Class 1 represents human
                if classes[i] == 1 and scores[i] > 0:
                    box = boxes[i]
                    str_box = '{:d} {:d} {:d} {:d} {:.2f}\n'.format(box[1], box[0], box[3] - box[1], box[2] - box[0],
                                                                    scores[i])
                    vid_res_file.write('{:d} '.format(cpt_img - 1) + str_box)
                    if vid_display and scores[i] > threshold:
                        cv2.rectangle(img, (box[1], box[0]), (box[3], box[2]), (255, 0, 0), 2)

            if vid_display:
                cv2.imshow("preview", img)
                key = cv2.waitKey(1)
                if key & 0xFF == ord('q'):
                    break

        cpt_img_tot += cpt_img
        average_fps = cpt_img_tot / processing_total_time
        vid_res_file.close()
        if vid_display:
            cv2.destroyWindow("preview")

    total_elapsed_time = time.time() - start_time

    if not os.path.exists(output_logs_dir):
        os.makedirs(output_logs_dir)

    # Some dipslay
    display_str1 = '\n\n             numFrame : {:d}\n'.format(cpt_img_tot)
    display_str2 = 'processingElapsedTime : {} ({:.2f} sec/frame | {:.2f} fps)\n' \
        .format(str(timedelta(seconds=processing_total_time)), processing_total_time / cpt_img_tot,
                cpt_img_tot / processing_total_time)
    display_str3 = '     totalElapsedTime : {} ({:.2f} % spend in functions)\n' \
        .format(str(timedelta(seconds=time.time() - start_time)),
                ((total_elapsed_time - processing_total_time) / total_elapsed_time) * 100)
    if info_display:
        print(display_str1 + display_str2 + display_str3)
    output_logs_f.write('\n' + display_str1)
    output_logs_f.write(display_str2)
    output_logs_f.write(display_str3)
    output_logs_f.close()

    if flattened_res_tree:
        flatten_res(res_dir, copy_res_dir)


class DetectorAPI:
    def __init__(self, path_to_ckpt):
        self.path_to_ckpt = path_to_ckpt

        self.detection_graph = tf.Graph()
        with self.detection_graph.as_default():
            od_graph_def = tf.GraphDef()
            with tf.gfile.GFile(self.path_to_ckpt, 'rb') as fid:
                serialized_graph = fid.read()
                od_graph_def.ParseFromString(serialized_graph)
                tf.import_graph_def(od_graph_def, name='')

        self.default_graph = self.detection_graph.as_default()
        self.sess = tf.Session(graph=self.detection_graph)

        # Definite input and output Tensors for detection_graph
        self.image_tensor = self.detection_graph.get_tensor_by_name('image_tensor:0')
        # Each box represents a part of the image where a particular object was
        # detected.
        self.detection_boxes = self.detection_graph.get_tensor_by_name('detection_boxes:0')
        # Each score represent how level of confidence for each of the objects.
        # Score is shown on the result image, together with the class label.
        self.detection_scores = self.detection_graph.get_tensor_by_name('detection_scores:0')
        self.detection_classes = self.detection_graph.get_tensor_by_name('detection_classes:0')
        self.num_detections = self.detection_graph.get_tensor_by_name('num_detections:0')

    def processFrame(self, image):
        im_height_org, im_width_org, _ = image.shape
        image = cv2.resize(image, (1280, 720))
        # Expand dimensions since the trained_model expects images to have
        # shape: [1, None, None, 3]
        image_np_expanded = np.expand_dims(image, axis=0)
        # Actual detection.
        start_time = time.time()
        (boxes, scores, classes, num) = self.sess.run(
            [self.detection_boxes, self.detection_scores, self.detection_classes, self.num_detections],
            feed_dict={self.image_tensor: image_np_expanded})
        end_time = time.time()

        boxes_list = [None for _ in range(boxes.shape[1])]

        for i in range(boxes.shape[1]):
            boxes_list[i] = (int(boxes[0, i, 0] * im_height_org),
                             int(boxes[0, i, 1] * im_width_org),
                             int(boxes[0, i, 2] * im_height_org),
                             int(boxes[0, i, 3] * im_width_org))

        return boxes_list, scores[0].tolist(), [int(x) for x in classes[0].tolist()], int(num[0]), end_time - start_time

    def close(self):
        self.sess.close()
        self.default_graph.close()


def flatten_res(main_res_dir, copy_res_dir):
    res_format_file = '.txt'
    vid_pattern = r'V[0-9]{3}\Z'
    set_pattern = r'set[0-9]{2}\Z'

    if os.path.isdir(copy_res_dir):
        shutil.rmtree(copy_res_dir)
    shutil.copytree(main_res_dir, copy_res_dir)
    shutil.rmtree(main_res_dir)

    for root, dirs, files in os.walk(copy_res_dir):
        m_set = re.search(set_pattern, root)

        if m_set:
            between_res_and_set = root[len(copy_res_dir) + 1: m_set.span(0)[0] - 1]
            between_res_and_set = re.sub(r'\\', r'_', between_res_and_set)

            if 'original' in between_res_and_set: # TODO here it outputs 'original_' ('original' wanted), because before it was 'original_thr=0.7' but there is no more thr
                files = [file for file in files if res_format_file in file]

                for file in files:
                    fileparts = re.split('_', file[0:len(file) - 4])

                    prev_path = os.path.join(root, file)
                    next_path_root = os.path.join(main_res_dir,
                                                  between_res_and_set + '_' + '_'.join(fileparts[1:len(fileparts)]),
                                                  m_set.group(0))
                    next_path = os.path.join(next_path_root, fileparts[0] + '.txt')

                    if not os.path.isdir(next_path_root):
                        os.makedirs(next_path_root)

                    shutil.copy2(prev_path, next_path)

            else:
                for root2, dirs2, files2 in os.walk(root):
                    m_vid = re.search(vid_pattern, root2)

                    if not m_vid:
                        continue
                    else:

                        files2 = [file for file in files2 if res_format_file in file]

                        for file2 in files2:
                            res_dir_flattened = between_res_and_set + '_' + file2[0:len(file2) - 4]
                            prev_path = os.path.join(root2, file2)
                            next_path_root = os.path.join(main_res_dir, res_dir_flattened, m_set.group(0))
                            next_path = os.path.join(next_path_root, m_vid.group(0) + '.txt')

                            if not os.path.isdir(next_path_root):
                                os.makedirs(next_path_root)

                            shutil.copy2(prev_path, next_path)


def get_num_format_file(main_dir, format_file):
    num_files = 0
    num_dirs = 0

    for root, dirs, files in os.walk(main_dir):
        files = [file for file in files if format_file in file]

        if not files:
            continue

        num_dirs += 1
        num_files += len(files)

    return num_files, num_dirs


if __name__ == "__main__":
    main()
