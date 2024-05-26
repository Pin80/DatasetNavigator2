#!/usr/bin/env python3

import sys
import cv2
import numpy as np
import math
from threading import Thread, Lock
import PIL
from PIL import Image, ImageDraw
import scipy
from scipy import ndimage
import matplotlib
from matplotlib import pyplot as plt
import glob
import zmq
import copy
import json
import webbrowser 
import logging # thread safe
from logging.handlers import TimedRotatingFileHandler
from logging import Formatter
import re
import os
import time 

DEFAULT_MASKNAME = "mask_original.png"
DEFAULT_LOGNAME = "annot_tool.log"
CLASS_CODE = 255


def check_versions():
    print(sys.version)
    print(cv2.__version__)
    print(np.__version__)
    print(PIL.__version__)
    print(scipy.__version__)
    print(matplotlib.__version__)
    print(zmq.__version__)
    return
def load_settings(ctx):
    try:
        f = open('settings.json')
    except Exception as inst:
        logging.critical("error: setting's file is not found %s line: %s",                          
                         inst.args, 
                         inst.__traceback__.tb_lineno)
        return
    except:
        logging.critical("error: setting's file is not found")
        return
    settings = json.load(f)
    try:
        ctx.log_filename = settings["log_filename"]
        ctx.zmqurlpc = settings["zmqurlpc"]
        ctx.zmqurlcp = settings["zmqurlcp"]
        ctx.suffix = settings["suffix"]
        ctx.mprefix = settings["mask_prefix"]
        ctx.mfolder = settings["mask_subfolder"]
        ctx.default_width = settings["default_width"]
        ctx.default_height = settings["default_height"]
        ctx.manual = settings["manual"]
        ctx.screenmaskcolor = tuple(settings["scolor"])
        ctx.frozenmaskcolor = tuple(settings["fcolor"])
        ctx.cursormaskcolor = tuple(settings["ccolor"])
        ctx.linecolor = tuple(settings["lcolor"])
        return
    except:
        logging.critical("setting's key is not found")
        return

def init_logger(ctx):
    try:
        ctx.main_logger = logging.getLogger('main:')
        ctx.main_logger.setLevel(logging.DEBUG)
        ctx.high_logger = logging.getLogger('highgui:')
        ctx.high_logger.setLevel(logging.DEBUG)
        ctx.draw_logger = logging.getLogger('draw:')
        ctx.draw_logger.setLevel(logging.DEBUG)
        handler = TimedRotatingFileHandler(filename=ctx.log_filename,
                                            when='D', 
                                            interval=1, 
                                            backupCount=7, 
                                            encoding='utf-8', 
                                            delay=False)
        formatter = Formatter(fmt="%(asctime)s %(name)s %(levelname)s:  %(message)s")
        handler.setFormatter(formatter)
        ctx.main_logger.addHandler(handler)
        ctx.high_logger.addHandler(handler)
        ctx.draw_logger.addHandler(handler)
    except:
        logging.critical("error in logging initialization")
        return

def rgb_to_hex(r, g, b):
    return '#{:02x}{:02x}{:02x}'.format(r, g, b)

def get_spotmask(r = 3, value = CLASS_CODE):
    dst = np.full([r*2 + 1, r*2 + 1], 0, dtype=np.uint8)
    if (r > 0):
        img = Image.fromarray(dst, mode='L')
        draw = ImageDraw.Draw(img)
        draw.ellipse((0, 0, 2*r+1, 2*r+1), fill = (value))
        dst = np.array(img.getdata(), np.uint8).reshape(img.size[1], img.size[0])
    else:
        dst[0, 0] = value
    return dst

def get_circlemask(r = 3):
    dst = np.full([r*2 + 1, r*2 + 1], 0, dtype=np.uint8)
    if (r > 0):
        img = Image.fromarray(dst, mode='L')
        draw = ImageDraw.Draw(img)
        draw.ellipse((0, 0, 2*r+1, 2*r+1), outline = (255))
        dst = np.array(img.getdata(), np.uint8).reshape(img.size[1], img.size[0])
    else:
        dst[0, 0] = 255
    return dst

def fill_mask_gray(src, mask, idx_y, idx_x, value = CLASS_CODE):
    rows, cols = src.shape
    mrows, mcols = mask.shape
    valid_coord = True
    valid_coord &= (idx_x - mcols//2) > 0
    valid_coord &= (idx_y - mrows//2) > 0
    valid_coord &= (idx_x + mcols//2) < cols
    valid_coord &= (idx_y + mrows//2) < rows
    if (valid_coord):
        center_x = mcols//2
        center_y = mrows//2
        for row in range(mrows):
            for col in range(mcols):
                crd_x = idx_x - center_x + col
                crd_y = idx_y - center_y + row 
                if (mask[row, col] != 0):
                    src[crd_y, crd_x] = value
    return src

def restore_region_image(src, mask, spotmask, idx_y, idx_x, original):
    if (src.ndim == 3):
        rows, cols, _ = src.shape
    elif (src.ndim == 2):
        rows, cols = src.shape
    else:
        raise Exception("Unexpected error") 
    mrows, mcols = spotmask.shape
    valid_coord = True
    valid_coord &= (idx_x - mcols//2) > 0
    valid_coord &= (idx_y - mrows//2) > 0
    valid_coord &= (idx_x + mcols//2) < cols
    valid_coord &= (idx_y + mrows//2) < rows
    if (valid_coord):
        center_x = mcols//2
        center_y = mrows//2
        for row in range(mrows):
            for col in range(mcols):
                crd_x = idx_x - center_x + col
                crd_y = idx_y - center_y + row 
                if (spotmask[row, col] != 0):
                    mask[crd_y, crd_x] = 0
                    if (src.ndim == 2):
                        src[crd_y, crd_x] = original[crd_y, crd_x]
                    elif (src.ndim == 3):
                        src[crd_y, crd_x, 0] = original[crd_y, crd_x, 0]
                        src[crd_y, crd_x, 1] = original[crd_y, crd_x, 1]
                        src[crd_y, crd_x, 2] = original[crd_y, crd_x, 2]
                    else:
                        raise Exception("Unexpected error") 
    return src

def test_window_maskcross(src, mask, idx_x, idx_y):
    rows, cols, _ = src.shape
    mrows, mcols = mask.shape
    valid_coord = True
    wnd = np.zeros([mrows, mcols, 3], dtype=np.uint8)
    valid_coord &= (idx_x - mcols//2) > 0
    valid_coord &= (idx_y - mrows//2) > 0
    valid_coord &= (idx_x + mcols//2) < cols
    valid_coord &= (idx_y + mrows//2) < rows
    is_crossed = False
    bound_color = (255, 255, 255)
    if (valid_coord):
        center_x = mcols//2
        center_y = mrows//2
        for row in range(mrows):
            for col in range(mcols):
                if (mask[row, col] != 0):
                    crd_x = idx_x - center_x + col
                    crd_y = idx_y - center_y + row 
                    if ((src[crd_y, crd_x, 0] ==  bound_color[0]) and
                        (src[crd_y, crd_x, 1] ==  bound_color[1]) and
                        (src[crd_y, crd_x, 2] ==  bound_color[2])):
                        is_crossed = True
    return is_crossed


def put_rgbmask(src, mask, idx_y, idx_x, color = (0, 255, 0)):
    rows, cols,_ = src.shape
    if ((idx_y is None) or (idx_x is None)):
        for row in range(rows):
            for col in range(cols):
                if (mask[row, col].any() != 0):
                    src[row, col, 0] = mask[row, col, 0]
                    src[row, col, 1] = mask[row, col, 1]
                    src[row, col, 2] = mask[row, col, 2]
    else:
        mrows, mcols = mask.shape
        valid_coord = True
        valid_coord &= (idx_x - mcols//2) > 0
        valid_coord &= (idx_y - mrows//2) > 0
        valid_coord &= (idx_x + mcols//2) < cols
        valid_coord &= (idx_y + mrows//2) < rows
        if (valid_coord):
            center_x = mcols//2
            center_y = mrows//2
            for row in range(mrows):
                for col in range(mcols):
                    crd_x = idx_x - center_x + col
                    crd_y = idx_y - center_y + row 
                    if (mask[row, col] != 0):
                        src[crd_y, crd_x, 0] = color[0]
                        src[crd_y, crd_x, 1] = color[1]
                        src[crd_y, crd_x, 2] = color[2]
    return src

# Experimental
def flood_window(src, mask, spotmask, idx_x, idx_y, color = (0, 255, 0), value = CLASS_CODE ):
    rows, cols, _ = src.shape
    mrows, mcols = spotmask.shape
    center_x = mcols//2
    center_y = mrows//2
    started = False
    doflood = False
    def flood_step(src, mask,  row, col, 
                   idx_x_ = idx_x, idx_y_ = idx_y, 
                   center_x_ = center_x, 
                   center_y_ = center_y, color_ = color):
        #global started#, center_x, center_y
        #global idx_y, idx_x, color
        nonlocal started, doflood
        crd_x = idx_x_ - center_x_ + col
        crd_y = idx_y_ - center_y_ + row 
        if (not started):
            if ((src[crd_y, crd_x, 0] == 255) or
                (src[crd_y, crd_x, 1] == 255) or
                (src[crd_y, crd_x, 2] == 255)):
                #print("std",started)
                started = True
                doflood = True
        else:
            if ((src[crd_y, crd_x, 0] == 255) or
                (src[crd_y, crd_x, 1] == 255) or
                (src[crd_y, crd_x, 2] == 255)):
                doflood = False
        if (doflood):
            src[crd_y, crd_x, 0] = color[0]
            src[crd_y, crd_x, 1] = color[1]
            src[crd_y, crd_x, 2] = color[2]
            mask[crd_y, crd_x] = value
        return src, mask, started
    valid_coord = (idx_x - mcols//2) > 0
    valid_coord &= (idx_y - mrows//2) > 0
    valid_coord &= (idx_x + mcols//2) < cols
    valid_coord &= (idx_y + mrows//2) < rows
    if (valid_coord):
        for row in range(mrows):
            started = False
            doflood = False
            for col in range(mcols):
                src, mask, started = flood_step(src, mask, row, col)
        for row in range(mrows):
            started = False
            doflood = False
            for col in range(mcols, -1, -1):
                src, mask, started = flood_step(src, mask, row, col)
        for col in range(mcols):
            started = False
            doflood = False
            for row in range(mrows):
                src, mask, started = flood_step(src, mask, row, col)
        for col in range(mcols):
            started = False
            doflood = False
            for row in range(mrows, -1, -1):
                src, mask, started = flood_step(src, mask, row, col)

    return src, mask

def highlight_spot(src, mask, spotmask, x = -1, y = -1, color = (0, 255, 0), value = CLASS_CODE):
    if (src.ndim == 2):
        rows, cols = src.shape
        dst = np.full([rows, cols, 3], 0, dtype=np.uint8)
        for row in range(rows):
            for col in range(cols):
                dst[row, col, 0] = src[row, col]
                dst[row, col, 1] = src[row, col]
                dst[row, col, 2] = src[row, col]
    else:
        rows, cols, _ = src.shape
        dst = src
        #dst_cmask = np.full([rows, cols, 3], 0, dtype=np.uint8)
        rows, cols, _ = src.shape
    dst_mask = fill_mask_gray(mask, spotmask, y, x, value)
    dst = put_rgbmask(dst, spotmask, y, x, color=color)
    
    return dst, dst_mask

#apply mask to rgb image
def apply_mask(src, mask, color = (0, 255, 0)):
    if (src.ndim == 2):
        rows, cols = src.shape
        dst = np.full([rows, cols, 3], 0, dtype=np.uint8)
        dst_cmask = np.full([rows, cols, 3], 0, dtype=np.uint8)
        for row in range(rows):
            for col in range(cols):
                dst[row, col, 0] = src[row, col]
                dst[row, col, 1] = src[row, col]
                dst[row, col, 2] = src[row, col]
    else:
        rows, cols, _ = src.shape
        dst = src
        dst_cmask = np.full([rows, cols, 3], 0, dtype=np.uint8)
        rows, cols, _ = src.shape
    for row in range(rows):
        for col in range(cols):
            if (mask[row, col] != 0):
                dst_cmask[row, col, 0] = color[0]
                dst_cmask[row, col, 1] = color[1]
                dst_cmask[row, col, 2] = color[2]
            else:
                dst_cmask[row, col, 0] = dst[row, col, 0]
                dst_cmask[row, col, 1] = dst[row, col, 1]
                dst_cmask[row, col, 2] = dst[row, col, 2]
    result = dst_cmask
    return result


def highlight_circle(src, x = -1, y = -1, r = 3):
    if (src.ndim == 2):
        rows, cols = src.shape
        dst = np.full([rows, cols, 3], 0, dtype=np.uint8)
        for row in range(rows):
            for col in range(cols):
                dst[row, col, 0] = src[row, col]
                dst[row, col, 1] = src[row, col]
                dst[row, col, 2] = src[row, col]
    else:
        rows, cols, _ = src.shape
        dst = src
        rows, cols, _ = src.shape
    img = Image.fromarray(dst, mode='RGB')
    draw = ImageDraw.Draw(img)
    if ((x -r > 0) & (y - r > 0) & (x + r < cols) & (y + r < rows)):
        draw.ellipse((x - r, y - r, x + r, y + r),  outline = (255, 0, 0))
    dst = np.array(img.getdata(), np.uint8).reshape(img.size[1], img.size[0], 3)
    return dst


def highlight_line(src, line, color = (255 ,255, 255)):
    lwidth = line[4]
    if (src.ndim == 2):
        rows, cols = src.shape
        dst = np.full([rows, cols, 3], 0, dtype=np.uint8)
        for row in range(rows):
            for col in range(cols):
                dst[row, col, 0] = src[row, col]
                dst[row, col, 1] = src[row, col]
                dst[row, col, 2] = src[row, col]
    else:
        dst = src
        rows, cols, _ = src.shape
    img = Image.fromarray(dst, mode='RGB')
    draw = ImageDraw.Draw(img)
    x1 = line[0]; 
    y1 = line[1]; 
    x2 = line[2]; 
    y2 = line[3]
    draw.line((x1, y1, x2, y2), fill=color, width=lwidth)
    dst = np.array(img.getdata(), np.uint8).reshape(img.size[1], img.size[0], 3)
    return dst

def save_matrix(M, filename='dump.txt'):
    np.savetxt(fname=filename, X=M, fmt="%d", delimiter=" ", newline='\n')
    return


def load_image(img_name):
    img_dst = cv2.imread(img_name)
    return img_dst

def get_arctan(dY, dX):
    anglepi = math.atan2(dY, dX) # -pi; +pi
    angle = np.round((180.0/np.pi)*anglepi)
    if (angle < 0):
        angle = 180 + angle
    return np.uint16(angle)

def test_line_lng(x1, y1, x2, y2, w):
    is_valid = False
    if ((abs(x2 - x1) > w) & (abs(y2 - y1) > w)):
        is_valid = True
    return is_valid

### TO DO (in progress)
def save_line_list(llist, fname):
    str1 = fname.split('photo')[1]
    filename = "../processed/histogramB_test" + str1[0] + ".txt"
    with open(filename, "w") as dst:
        dst.write('ind, freq angle\n')
        for line in llist:
            str1 = "{} {} {}".format(*line) + '\n'
            dst.write(str1)
            
def save_mask(fname, mask):
    img = Image.fromarray(mask, 'L')
    #str1 = fname.split('photo')[1]
    if (not fname is None):
        newname = fname
        print(newname)
        img.save(newname)
        return True
    else:
        return False

class Context:
    DEFAULT_WIDTH = 15
    def __init__(self):
        self.original_name = ""
        self.mask_name = DEFAULT_MASKNAME
        self.log_filename = DEFAULT_LOGNAME
        self.main_logger = None
        self.high_logger = None
        self.draw_logger = None
        self.zmqurlpc = ""
        self.zmqurlcp = ""
        self.suffix = "+"
        self.mprefix = "+"
        self.mfolder = "./"
        self.default_height = 320
        self.default_width = 640
        self.manual = ""
        self.screenmaskcolor = (0, 0, 255)
        self.frozenmaskcolor = (0, 255, 0)
        self.cursormaskcolor = (255, 0, 0)
        self.linecolor = (255, 255, 255)
        self.original_image = np.zeros([self.default_height, self.default_width, 3], dtype=np.uint8)
        self.original_image_gray = np.zeros([self.default_height, self.default_width], dtype=np.uint8)
        self.img_initimage = np.copy(self.original_image)
        self.img_initimage2 = np.copy(self.original_image)
        self.img_finalimage = np.copy(self.original_image)
        self.polygon_layer = np.zeros_like(self.original_image)
        self.frozen_mask = np.zeros_like(self.original_image_gray)
        self.screen_mask = np.zeros_like(self.original_image_gray)
        self.spot_mask = get_spotmask(Context.DEFAULT_WIDTH)
        self.view_number = 0
        self.polygon =  [] # example: [(50, 50), (100, 50), (100, 100), (50, 100)]
        self.mutex = Lock()
    def get_image_type(self, img):
        if img.ndim == 2:
            return 0
        elif img.ndim == 3:
            if img.shape[2] == 3:
                return 1
            else:
                return -1
        else:
            return -1
    def create_masks_by_image(self, img):
        itype = self.get_image_type(img)
        if itype == -1:
            return -1
        elif itype == 1:
            w_, h_, _ = img.shape
            new_shape = (w_, h_)
            print ("w_", w_, "h_", h_)
            self.original_image_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 
            self.frozen_mask = np.zeros_like(self.original_image_gray)
            self.screen_mask = np.zeros_like(self.original_image_gray)
            return 1
        elif itype == 0:
            w_, h_ = img.shape
            new_shape = (w_, h_)
            print ("w_", w_, "h_", h_)
            self.original_image_gray = img #cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 
            self.frozen_mask = np.zeros_like(self.original_image_gray)
            self.screen_mask = np.zeros_like(self.original_image_gray)
            return 0
        else:
            return -1
class Main_Window:
    mouse_down = False
    x_coord = -1
    y_coord = -1
    x_lcoord = -1
    y_lcoord = -1
    k1xy = 5
    k2xy = [[1,1],[1,-1],[-1,-1],[-1,1]]
    shift_x = -5
    shift_y = -5
    WindowName = "Annotation_Tool"
    cursor_state = 2
    def __init__(self, ctx, default_class = CLASS_CODE):
        self.ctx = ctx
        cv2.namedWindow(self.WindowName, cv2.WINDOW_GUI_NORMAL)
        self.width = Context.DEFAULT_WIDTH
        self.class_idx = default_class
        cv2.createTrackbar("class#", self.WindowName,0, 255,Main_Window.nothing)
        cv2.setTrackbarPos("class#", self.WindowName, self.class_idx)
        cv2.createTrackbar("width#", self.WindowName,0, 15,Main_Window.nothing)
        cv2.createTrackbar("min#", self.WindowName,0, 255,Main_Window.nothing)
        cv2.createTrackbar("max#", self.WindowName,0, 255,Main_Window.nothing)
        cv2.createTrackbar("tool#", self.WindowName,0, 25,Main_Window.nothing)
        self.width = cv2.getTrackbarPos("width#", self.WindowName)
        self.lowcanny = cv2.getTrackbarPos("min#", self.WindowName)
        self.highcanny = cv2.getTrackbarPos("max#", self.WindowName)
        self.toolnumber = cv2.getTrackbarPos("tool#", self.WindowName)
        self.oldtoolnumber = self.toolnumber
        cv2.setMouseCallback(self.WindowName,Main_Window.onMouseCallBack)
        self.oldlow = self.lowcanny
        self.oldhigh = self.highcanny
        self.oldwidth = self.width
        self.oldfidx = self.class_idx
    def process_widgets(self):
        self.class_idx = cv2.getTrackbarPos("class#", self.WindowName)
        self.width = cv2.getTrackbarPos("width#", self.WindowName)
        self.lowcanny = cv2.getTrackbarPos("min#", self.WindowName)
        self.highcanny = cv2.getTrackbarPos("max#", self.WindowName)
        self.toolnumber = cv2.getTrackbarPos("tool#", self.WindowName)
    def set_title_saved(self, title):
        cv2.setWindowTitle(self.WindowName, os.path.basename(title) + " (saved)")
    def set_title_busy(self, title):
        cv2.setWindowTitle(self.WindowName, os.path.basename(title) + " (busy)")
    def set_title(self, title):
        cv2.setWindowTitle(self.WindowName, os.path.basename(title))
    def show_image(self, image):
        cv2.imshow(self.WindowName,image)
    def onMouseCallBack(event, x, y, flags, param):
        Main_Window.x_coord = x + Main_Window.shift_x
        Main_Window.y_coord = y + Main_Window.shift_y
        if event == cv2.EVENT_RBUTTONDOWN:
            Main_Window.mouse_down = True
            Main_Window.x_lcoord = x
            Main_Window.y_lcoord = y
        if event == cv2.EVENT_RBUTTONUP and Main_Window.mouse_down:
            Main_Window.mouse_down = False
        return None
    def nothing(arg):
        pass
    def isReadyClose(self):
        return (cv2.getWindowProperty(self.WindowName, cv2.WND_PROP_VISIBLE) <1)
    def __del__(self):
        cv2.destroyAllWindows()
        print("window is closed")
ctx = Context()

def draw_mask_polygon(src, mask, polygon, value = CLASS_CODE, color = (0, 0, 255)):
    if (len(polygon) > 2):
        img = Image.fromarray(src, mode='RGB')
        img_gray = Image.fromarray(mask, mode='L')
        draw = ImageDraw.Draw(img)
        draw_gray = ImageDraw.Draw(img_gray)
        draw.polygon(polygon, fill =rgb_to_hex(*color), outline =rgb_to_hex(*color))  
        draw_gray.polygon(polygon, fill =value, outline =value)  
        result = np.array(img.getdata(), np.uint8).reshape(img.size[1], img.size[0], 3)
        result_gray = np.array(img_gray.getdata(), np.uint8).reshape(img_gray.size[1], img_gray.size[0])
        return result, result_gray
    else:
        return src, mask
    
class Controller:
    quit = False
    trigger_highgui = False
    trigger_after_highgui = True
    trigger3 = False
    trigger_refresh = False
    trigger_polygon = False
    trigger_send = False


# Prepare our context and sockets

class Zmq_receiver:
    poller = zmq.Poller()
    context = zmq.Context()
    subscriber = context.socket(zmq.SUB)
    publisher = context.socket(zmq.PUB)
    trigger = False
    def __init__(self, ctx):
        self.isError = True
        self.ctx = ctx
        self.zmq_orig_name = "None"
        self.mask_name = None
        self.mask_found = False
        # Connect to weather server
        self.isconnected = self.subscriber.connect(ctx.zmqurlpc)
        if (self.isconnected):
            sndhwm = 2048;
            #zmq.setsockopt(m_publisher, ZMQ_SNDHWM, sndhwm);
            self.subscriber.set_hwm(sndhwm)
            #subscriber.setsockopt(zmq.SUBSCRIBE, b"10001")
            self.subscriber.setsockopt(zmq.SUBSCRIBE, b"")
            self.subscriber.setsockopt(zmq.LINGER, 0)  # All topics
            self.subscriber.RCVTIMEO = 500  # timeout: 1 sec
            # Initialize poll set
            #poller.register(receiver, zmq.POLLIN)
            self.poller.register(self.subscriber, zmq.POLLIN)
            self.isError = False
        else:
            raise Exception("zmq is not connected")
        # Connect to weather server
        self.publisher.bind(ctx.zmqurlcp)

    def process_messages(self,ctx, logger):
        try:
            socks = dict(self.poller.poll(200))
        except KeyboardInterrupt:
            print("Ex1")
            self.isError = True
            return
            #break
        if self.subscriber in socks:
            message = self.subscriber.recv_string()
            self.zmq_orig_name = ""
            logger.info("message0: %s",message)
            if (message):
                #print("Hello")
                name_tuple = message[:].split('*')
                self.zmq_orig_name = name_tuple[0]
                self.mask_found = False
                if (len(name_tuple) > 1):
                    if (name_tuple[1]):
                        self.mask_found = True
                if (self.mask_found):
                    logger.info("mask is found")
                    mname = name_tuple[1]
                    maskpath = os.path.dirname(name_tuple[1])
                    logger.info("maskpath: %s", maskpath)
                    self.mask_name = mname #tmppath + "/" + ctx.mfolder + "/"  + mname
                    logger.info("mask name: %s",self.mask_name)
                    self.trigger = True
                else:
                    logger.info("mask is not found")
                    if (name_tuple[0]):
                        tmppath = os.path.dirname(name_tuple[0])
                        logger.info("image path: %s", tmppath)
                        bname = os.path.basename(self.zmq_orig_name)
                        pattern = "^.*" + ctx.suffix + "\d+\.(?:jpg|png|jpeg)$"
                        res = re.fullmatch(pattern, bname)
                        if (res):
                            suffix = ctx.suffix + bname.split(ctx.suffix)[1]
                            self.mask_name = tmppath + "/" + ctx.mfolder + "/" + ctx.mprefix + suffix
                        else:
                            self.mask_name = tmppath + "/" + ctx.mfolder + "/" + ctx.mprefix + bname
                        self.ctx.frozen_mask = np.zeros_like(ctx.original_image)
                        self.trigger = True
                    else:
                        logger.info("message: %s",message)
                        raise Exception(b"Error: illegal message format")
    def send_message(self, msg):
        bmsg = bytes(msg, 'utf-8')
        self.publisher.send(bmsg)
                

def process_highgui(*args):
    global imglist
    global toolnumber, MASK_NAME, DEFAULT_MASKNAME
    if (len(args) < 3):
        return
    ctl = args[0]
    ctx = args[1]
    mwnd = args[2]
    try:
        zrec = Zmq_receiver(ctx)
    except Exception as inst:
        ctx.high_logger.error("error in zmq initialization: %s line: %s",                          
                              inst.args, 
                              inst.__traceback__.tb_lineno)
    except:
        ctx.high_logger.error("error in zmq initialization")
    try:
        ctx.high_logger.info("highgui loop is running")
        while(not ctl.quit):
            time.sleep(0.05)
            if (ctl.trigger_send):
                ctl.trigger_send = False
                zrec.send_message(os.path.basename(ctx.original_name))
            if (zrec.isconnected):
                zrec.process_messages(ctx, ctx.high_logger)
            if (zrec.trigger):
                ctx.high_logger.info("zmq message has been got image name: %s mask name %s ",
                                     zrec.zmq_orig_name, zrec.mask_name)
                ctx.polygon.clear()
                ctl.trigger_highgui = True  
                ctx.polygon_layer = None
            if ((mwnd.oldhigh != mwnd.highcanny) or (mwnd.oldlow != mwnd.lowcanny)):
                ctl.trigger_highgui = True
            if (ctl.trigger_highgui):
                ctx.mask_name = zrec.mask_name
                #os.path.isfile(fname) 
                if (not zrec.zmq_orig_name is None and os.path.isfile(zrec.zmq_orig_name)):
                    bname = os.path.basename(zrec.zmq_orig_name)
                    ctx.high_logger.info("start downloading image: %s", zrec.zmq_orig_name)
                    img_tmp = load_image(zrec.zmq_orig_name)
                    if (img_tmp is None):
                        raise Exception("Error of loading of image file")
                    ctx.original_image = img_tmp
                    ctx.original_name = zrec.zmq_orig_name
                    if (zrec.trigger):
                        zrec.trigger = False
                        if (not zrec.mask_found):
                            code = ctx.create_masks_by_image(ctx.original_image)
                            if (code == -1):
                                ctl.quit = True
                                raise Exception("Error: creation of mask")
                                #break
                        else:
                            if (os.path.isfile(zrec.mask_name)):
                                ctx.high_logger.info("start downloading mask image: %s", zrec.mask_name)
                                tmpmask = load_image(zrec.mask_name)
                                ctx.frozen_mask = cv2.cvtColor(tmpmask, cv2.COLOR_BGR2GRAY) 
                                ctx.screen_mask = np.zeros_like(ctx.frozen_mask)
                            else:
                                ctx.frozen_mask = np.zeros_like(ctx.original_image)
                                ctx.screen_mask = np.zeros_like(ctx.frozen_mask)
                                ctx.high_logger.info("screen shape is: %s frozen shape is: %s", 
                                                    ctx.screen_mask.shape, 
                                                    ctx.frozen_mask.shape)
                else:
                    if (zrec.trigger):
                            zrec.trigger = False
                            ctl.quit = True 
                            raise Exception("Error: image file is not found")
                            #break
                    ctx.original_name = zrec.zmq_orig_name
            mwnd.process_widgets()
            if (ctl.trigger_highgui or ctl.trigger_refresh):
                mwnd.oldhigh = mwnd.highcanny
                mwnd.oldlow = mwnd.lowcanny
                mwnd.set_title(ctx.original_name)
                #img_gray = np.copy(imglist[file_idx])
                vnumber = ctx.view_number
                if (vnumber == 0):
                    img_canny = cv2.Canny(ctx.screen_mask,
                         threshold1 = mwnd.lowcanny, 
                         threshold2 = mwnd.highcanny, 
                         apertureSize=3)
                    ctx.img_initimage  = apply_mask(img_canny, ctx.frozen_mask, color = ctx.frozenmaskcolor)
                    ctx.img_initimage2  = apply_mask(ctx.img_initimage, ctx.screen_mask, color = ctx.screenmaskcolor)
                elif (vnumber == 1):
                    ctx.img_initimage  = apply_mask(ctx.original_image, ctx.frozen_mask, color = ctx.frozenmaskcolor)
                    ctx.img_initimage2  = apply_mask(ctx.img_initimage, ctx.screen_mask, color = ctx.screenmaskcolor)
                #trigger = False
                if (ctx.polygon_layer is None):
                    ctx.polygon_layer = np.zeros_like(ctx.original_image)
                ctl.trigger_after_highgui = True
                ctl.trigger_highgui = False
                ctl.trigger_refresh = False
            if (ctl.quit): break
    except Exception as inst:
        ctx.high_logger.error("error: %s line: %s",                          
                              inst.args, 
                              inst.__traceback__.tb_lineno)
        ctl.quit = True
        logging.shutdown()
        os._exit(0)
        
def draw_spot(*args):           
    global toolnumber
    ctl = args[0]
    ctx = args[1]
    mwnd = args[2]
    def _tool1():
        x_froz = int(mwnd.x_coord)
        y_froz = int(mwnd.y_coord)
        mwnd.set_title_busy(ctx.original_name)
        is_allowed = not test_window_maskcross(ctx.img_finalimage, ctx.spot_mask, 
                                                x_froz, y_froz)
        if (is_allowed):
            ctx.mutex.acquire()
            ctx.img_finalimage, ctx.screen_mask = highlight_spot(ctx.img_finalimage, 
                                            ctx.screen_mask, ctx.spot_mask, 
                                            x_froz, y_froz, 
                                            color = ctx.screenmaskcolor, value = mwnd.class_idx)
            ctx.mutex.release()
        mwnd.set_title(ctx.original_name)
        ctl.trigger3 = True
        return
    def _tool2():
        mwnd.set_title_busy(ctx.original_name)
        ctx.mutex.acquire()
        ctx.img_finalimage, ctx.screen_mask = highlight_spot(ctx.img_finalimage, ctx.screen_mask, 
                                                ctx.spot_mask, mwnd.x_coord, mwnd.y_coord, 
                                                color = ctx.screenmaskcolor, value = mwnd.class_idx)
        ctx.mutex.release()
        mwnd.set_title(ctx.original_name)
        ctl.trigger3 = True
        return
    def _tool3():
        mwnd.set_title_busy(ctx.original_name)
        ctx.mutex.acquire()
        #experimental
        ctx.img_finalimage, ctx.screen_mask = flood_window(ctx.img_finalimage, 
                                                ctx.screen_mask, ctx.spot_mask,
                                                mwnd.x_coord, mwnd.y_coord, 
                                                color = ctx.screenmaskcolor, value = mwnd.class_idx )
        ctx.mutex.release()
        mwnd.set_title(ctx.original_name)
        ctl.trigger3 = True
        return
    def _tool4():
        mwnd.set_title_busy(ctx.original_name)
        if (ctx.view_number == 0):
            x_froz = int(mwnd.x_coord)
            y_froz = int(mwnd.y_coord)
            is_allowed = not test_window_maskcross(ctx.img_finalimage, ctx.spot_mask, 
                                                x_froz, y_froz)
            if (is_allowed):
                ctx.mutex.acquire()
                ctx.img_finalimage, _ = highlight_spot(ctx.img_finalimage, ctx.screen_mask, 
                                                    ctx.spot_mask, x_froz, y_froz, 
                                                    color = (0, 0, 0), value = mwnd.class_idx)
                ctx.mutex.release()
        else:
            ctx.mutex.acquire()
            ctx.img_finalimage = restore_region_image(ctx.img_finalimage, ctx.screen_mask, 
                                                    ctx.spot_mask, mwnd.y_coord, mwnd.x_coord, 
                                                    ctx.img_initimage.copy())
            ctx.mutex.release()
            #ctx.img_finalimage = ctx.img_initimage.copy()
            #print("yes")
        mwnd.set_title(ctx.original_name)
        ctl.trigger3 = True
        return
    def _tool5():
        mwnd.set_title_busy(ctx.original_name)
        pt = (int(mwnd.x_coord), int(mwnd.y_coord))
        ctx.polygon.append(pt)
        plng = len(ctx.polygon)
        if (plng > 1):
            ctx.mutex.acquire()
            pt_prev = ctx.polygon[plng - 2]
            pt_curr = ctx.polygon[plng - 1]
            line = [int(pt_prev[0]), int(pt_prev[1]), int(pt_curr[0]), int(pt_curr[1]), 1]
            #print("line is:",pt_prev[0], pt_prev[1], pt_curr[0], pt_curr[1])
            ctx.polygon_layer = highlight_line(ctx.polygon_layer, line, ctx.linecolor)
            ctx.mutex.release()
            ctl.trigger_polygon = True
        new_title = ctx.original_name + " " + str(plng)
        mwnd.set_title(new_title)
        Main_Window.mouse_down = False
        return
    def _default():
        pass
    if (len(args) < 3):
        return
    try:
        ctx.draw_logger.info('draw loop is running')
        switch = {
            1: _tool1,
            2: _tool2,
            3: _tool3,
            4: _tool4,
            5: _tool5
        }
        while(not ctl.quit):
            time.sleep(0.02)
            if (Main_Window.mouse_down):
                if (not ctl.trigger_highgui): 
                    switch.get(mwnd.toolnumber, _default)()
    except Exception as inst:
        ctx.draw_logger.error("error: %s line: %s", 
                              inst.args, 
                              inst.__traceback__.tb_lineno)
        ctl.quit = True
        logging.shutdown()
        os._exit(0)

def process_terminal(*args):
    ctl = args[0]
    while(not ctl.quit):
        Key = sys.stdin.read()
        #time.sleep(0.01)
        #Key = readchar.readchar()
        if (Key == 'q'):
            ctl.quit = True
    return
    
def main_loop():
    global ctx
    def _change_view():
        nonlocal ctl
        ctx.main_logger.info('change view is selected')
        #ctx.screen_mask = np.zeros_like(ctx.original_image_gray)
        ctx.view_number = (ctx.view_number + 1)%2
        ctl.trigger_refresh = True
        return
    def _clean_mask():
        nonlocal ctl
        ctx.main_logger.info('clean mask is selected')
        ctx.screen_mask = np.zeros_like(ctx.screen_mask)
        ctl.trigger_highgui = True
        return
    def _froze_mask():
        nonlocal ctl
        ctx.main_logger.info('froze mask is selected')
        tmp_img_or = cv2.bitwise_or(ctx.frozen_mask, ctx.screen_mask)
        ctx.frozen_mask = tmp_img_or
        ctx.screen_mask= np.zeros_like(ctx.screen_mask)
        ctl.trigger_highgui = True
        return
    def _save_mask():
        nonlocal mwnd
        ctx.main_logger.info('mask file is going to be saved by name: %s', ctx.mask_name)
        result = save_mask(ctx.mask_name, ctx.frozen_mask)
        mwnd.set_title_saved(ctx.original_name)
        if (result):
            ctx.main_logger.info("file is saved")
        else:
            ctx.main_logger.info("file is not saved")
        k = cv2.waitKey(10) & 0xFF
        ctl.trigger_send = True
        return
    def _reset_masks():
        nonlocal ctl
        ctx.main_logger.info('reset all masks is selected')
        ctx.frozen_mask = np.zeros_like(ctx.frozen_mask)
        ctx.screen_mask = np.zeros_like(ctx.screen_mask)
        ctl.trigger_highgui = True
        return
    def _draw_mask_polygon():
        ctx.main_logger.info('draw polygon is selected')
        mwnd.set_title_busy(ctx.original_name)
        ctx.img_finalimage, ctx.screen_mask = draw_mask_polygon(ctx.img_finalimage, 
                                                                ctx.screen_mask, 
                                                                ctx.polygon,
                                                                mwnd.class_idx,
                                                                ctx.screenmaskcolor)
        ctx.polygon.clear()
        ctx.polygon_layer = np.zeros_like(ctx.original_image)
        new_title = ctx.original_name + " " + str(len(ctx.polygon))
        mwnd.set_title(new_title)
        return
    def _reset_polygon():
        ctx.main_logger.info('reset polygon is selected')
        ctx.polygon.clear()
        new_title = ctx.original_name + " " + str(len(ctx.polygon))
        mwnd.set_title(new_title)
        ctx.polygon_layer = np.zeros_like(ctx.original_image)
        return
    def _cursor_shift():
        ctx.main_logger.info('cursor shift is selected')
        old_k2x = Main_Window.k2xy[Main_Window.cursor_state][0] 
        old_k2y = Main_Window.k2xy[Main_Window.cursor_state][1] 
        Main_Window.cursor_state = (Main_Window.cursor_state + 1)%4
        new_k2x = Main_Window.k2xy[Main_Window.cursor_state][0] 
        new_k2y = Main_Window.k2xy[Main_Window.cursor_state][1] 
        Main_Window.shift_x = Main_Window.k1xy*new_k2x
        Main_Window.shift_y = Main_Window.k1xy*new_k2y
        change_x = (old_k2x*new_k2x - 1)*Main_Window.k1xy
        change_y = (old_k2y*new_k2y - 1)*Main_Window.k1xy
        Main_Window.x_coord = mwnd.x_coord - new_k2x*change_x
        Main_Window.y_coord = mwnd.y_coord - new_k2y*change_y
        return
    def _exit_app():
        nonlocal mwnd, ctl, t1, t2
        ctl.quit = True
        return
    def _help():
        try:
            webbrowser.open(ctx.manual, new=0, autoraise=True)
        except:
            ctx.main_logger.error("manual is not found")
        return
    def _default():
        return
    ctl = Controller()
    load_settings(ctx)
    init_logger(ctx)
    try:
        mwnd = Main_Window(ctx)
        #img_mask = np.zeros_like(original_image)
        COLCENTER1 = ctx.original_image.shape[1]//2
        ROWCENTER1 = ctx.original_image.shape[0]//2
        t1 = Thread(target=process_highgui, args=(ctl,ctx,mwnd))
        t2 = Thread(target=draw_spot, args=(ctl,ctx,mwnd,))
        t3 = Thread(target=process_terminal, args=(ctl,))
        t1.start()
        t2.start()
        t3.start()
        #t2.start()
        mwnd.old_fidx = mwnd.class_idx
        circle_mask = get_circlemask(mwnd.width)

        switch = {
            ord('v'): _change_view,
            ord('c'): _clean_mask,
            ord('s'): _froze_mask,
            ord('f'): _save_mask,
            ord('p'): _draw_mask_polygon,
            ord('r'): _reset_masks,
            ord('o'): _reset_polygon,
            ord('m'): _cursor_shift,
            ord('h'): _help,
            #ord('q'):  _exit_app,
            27: _exit_app
            # и так далее
        }
        old_x = 0
        old_y = 0
        img_finalimage_nocursor = np.zeros_like(ctx.img_finalimage)
        img_polygon_mask = np.zeros_like(ctx.img_finalimage)
        img_polygon_mask_ = np.zeros_like(ctx.img_finalimage)
    except Exception as inst:
        logging.critical("error durring application initialization: %s line: %s", 
                         inst.args, 
                         inst.__traceback__.tb_lineno)
    except:
        logging.critical("error durring logging initialization")
        return
    ctx.main_logger.info('main loop is running')
    while(not ctl.quit):
        if (mwnd.oldwidth != mwnd.width):
            mwnd.oldwidth = mwnd.width
            ctx.spot_mask = get_spotmask(mwnd.width, mwnd.class_idx)
            circle_mask = get_circlemask(mwnd.width)
        if (mwnd.class_idx != mwnd.old_fidx):
            ctx.main_logger.info('change class is selected. new is: %s', mwnd.class_idx)
            mwnd.old_fidx = mwnd.class_idx
            #trigger = True
        if (mwnd.toolnumber != mwnd.oldtoolnumber):
            ctx.main_logger.info('change tool is selected. new is: %s', mwnd.toolnumber)
            mwnd.oldtoolnumber = mwnd.toolnumber
            #trigger = True      
            
        if (ctl.trigger_after_highgui):
            ctx.mutex.acquire()
            ctx.img_finalimage, ctx.screen_mask = highlight_spot(ctx.img_initimage2, ctx.screen_mask, 
                                                     ctx.spot_mask,
                                                     color = (0, 0, 0), value = mwnd.class_idx)

            ctl.trigger_after_highgui = False
            ctl.trigger_polygon = True
            ctx.mutex.release()
            
            
        if (mwnd.y_coord != old_y or mwnd.x_coord != old_x or ctl.trigger_polygon or ctl.trigger3):
            ctx.mutex.acquire()
            img_finalimage_nocursor = copy.deepcopy(ctx.img_finalimage)
            ctx.mutex.release()
            if (len(ctx.polygon) > 1):
                if (ctl.trigger_polygon):
                    ctl.trigger_polygon = False
                    ctx.mutex.acquire()
                    img_polygon_mask = put_rgbmask(img_finalimage_nocursor, ctx.polygon_layer, 
                                                 None, None,(255,255,255))
                    img_polygon_mask_ = copy.deepcopy(img_polygon_mask)
                    ctx.mutex.release()
                else:
                    img_polygon_mask = copy.deepcopy(img_polygon_mask_)
            else:
                img_polygon_mask = img_finalimage_nocursor
                ctl.trigger_polygon = False
            old_x = mwnd.x_coord
            old_y = mwnd.y_coord
            img_finalimage_cursor = put_rgbmask(img_polygon_mask, circle_mask, 
                                         mwnd.y_coord, mwnd.x_coord,
                                         color=ctx.cursormaskcolor)
            mwnd.show_image(img_finalimage_cursor)
            #mwnd.show_image(ctx.polygon_layer)
            ctl.trigger3 = False

        k = cv2.waitKey(10) & 0xFF
        switch.get(k, _default)()
        time.sleep(0.01)

        if (not ctl.quit and mwnd.isReadyClose()):
            _exit_app()
    t1.join(3)
    t2.join(2)
    del mwnd
    ctx.main_logger.info("Annotation tool is terminating")
    logging.shutdown()
    os._exit(0)
try:
    check_versions()
    logging.basicConfig(format='%(asctime)s %(name)s %(levelname)s:  %(message)s', level=logging.DEBUG)
    main_loop()
except Exception as inst:
    logging.critical("error %s line:", inst.args, inst.__traceback__.tb_lineno)     # arguments stored in .args
    logging.shutdown()
    os._exit(0)

