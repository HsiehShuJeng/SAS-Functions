# -*- coding: utf-8 -*-
import os, csv, shutil
from poster.encode import multipart_encode
from poster.streaminghttp import register_openers
import urllib2
import pycurl
import time
import datetime


def check_format_CSV(path, tag=None, val=None):
    fet = None
    line = None
    f = open(path, "rb") #b means binary
    reader = csv.reader(f, delimiter='\t') #\t stands for tab.
    count = 0
    fet = open('指定路徑', 'w+')
    for line in reader:
        if count != 0:
            val = line[1]
            print(line[1])
            if '[\"' not in line[1]:
                print(line[1])
                line[1] = line[1].replace("[", "")
                line[1] = '["' + line[1]
            if '\"]' not in line[1]:
                line[1] = line[1].replace("]", "")
                line[1] = line[1] + '"]'
            print(line[0:])

            fet.write(line[0] + "\t" + line[1] + "\n")
        else:
            fet.write(line[0] + "\t" + line[1] + "\n")
        count = count + 1
    f.close()

def delete_file(path):
    os.remove(path)
    shutil.move("指定路徑", path)

def move_file(path, name):
    tmppath = "指定路徑2"
    t = time.time()
    destpath = tmppath + name + "_" + datetime.datetime.fromtimestamp(t).strftime('%Y-%m-%d_%H_%M_%S')
    shutil.move(path, destpath)

def upload_file():
    count = 0
    tag = ""
    val = ""
    while (True):
        count = count + 1
        tag = ""
        tag = str(count) + "-A"
        """
        """
        fname = "指定檔名" + tag + "_OK.tab"
        distname = "指定檔名" + tag + ".tab"
        src_path = "指定路徑3" + fname 
        print(src_path)
        if os.path.exists(src_path):
            if os.path.exists(src_path):
                check_format_CSV(src_path)
                print("add double core")
                delete_file(src_path)
                print("delete file")
                url = '指定鏈結'
                print("post file")
                pc = pycurl.Curl()
                pc.setopt(pycurl.POST, 1) 
                pc.setopt(pycurl.URL, url) 
                try:
                    pc.setopt(pycurl.HTTPPOST, [(distname, (pc.FORM_FILE, src_path))]) 
                    pc.perform()
                    move_file(src_path, distname)
                except:
            	    print('Connection Failed........')
            	    t = time.time()
            	    print("Failed time: " + datetime.datetime.fromtimestamp(t).strftime('%Y-%m-%d %H:%M:%S'))
                finally:
                    print('Close connection........')
                    pc.close()
    	        time.sleep(20)
        if count >= 24:
            print('sucess........')
            break

def updatetobackupserver():
    count = 0
    while True:
    	count = count + 1
        tag = str(count) + "-A"
        fname = "指定檔名" + tag + ".tab"
        distname = "指定檔名" + tag + "_OK.tab"
        srcPath = "指定路徑3"
        udr_path = srcPath + fname
        print(udr_path)
        if os.path.isfile(udr_path):
            f = open(udr_path, "rb") 
            reader = csv.reader(f, delimiter='\t')
            index = 0
            for line in reader:
                if index != 0:
                    val = line[1]
                    print(line[1])
                if '[\"' not in line[1]:
                    line[1] = line[1].replace("[", "")
                else:
                    line[1] = line[1].replace("[\"", "")
                if '\"]' not in line[1]:
                    line[1] = line[1].replace("]", "")
                else:
                    line[1] = line[1].replace("\"]", "")
                print(line[0])
                index = index + 1
            f.close()
            try:
                url = '指定鏈結2' + tag + '\"&val=\"' + line[1] + '\"'
                print(url)
                while True:
                    content = "+OK"
                    content_stream = urllib2.urlopen(url)
                    content = content_stream.read()
                    print(content)
                    if "OK" in content:
                        print("success....!")
                    else:
                        print("failed....!")
                    time.sleep(5)
                    dist = srcPath + distname
                    print(udr_path + "\n")
                    print(dist + "\n")
                    os.rename(udr_path, dist)
                    break
            except:
                print("connect failed!!!")
        else:
            print("file not exists")
            time.sleep(5)
        if count == 24:
            break

if __name__ == '__main__':
    print('start....')
    while (True):
        updatetobackupserver()
        upload_file()
        t = time.time()
        print("run time: " + datetime.datetime.fromtimestamp(t).strftime('%Y-%m-%d %H:%M:%S'))
        time.sleep(60)
