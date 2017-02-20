# -*- coding: utf-8 -*-
'''
Created on 2016年4月12日

@author: Administrator
'''

import requests
from openpyxl import load_workbook
import datetime
import time
import shutil
import os.path
import pycurl
import sys
import subprocess


newpath = "指定路徑1"
oldpath = "指定路徑2"
logpath = "指定路徑3"


def checkdirstatus():
    try:
        os.makedirs(newpath)
    except:
        pass
    
    try:
        os.makedirs(oldpath)
    except:
        pass
    
    try:
        os.makedirs(logpath)
    except:
        pass

newfile = newpath + "指定檔名.xlsx"
newSecondfile = newpath + "指定檔名_2.xlsx"
print(newfile)

def checkfilesize():
    statinfo = None
    if os.path.exists(newfile):
        statinfo = os.stat(newfile)
        if statinfo.st_size >= 10485760:
            return True
        else:
            return False
        
def uploadfile(c, url, field, path):
    print("Processing..........!!!!")
    c.setopt(c.POST, 1)
    c.setopt(c.URL, url)
    c.setopt(c.HTTPPOST, [(field, (c.FORM_FILE,  newfile))])
    #c.setopt(c.VERBOSE, 1)
    c.perform()

def auto_personal_update_file():
    a = datetime.datetime.now()
    field = "uploadFile"
    url = '指定鏈結'
    if os.path.exists(newfile):
        try:
            c = pycurl.Curl()
            uploadfile(c, url, field, newfile) ;
            if os.path.exists(newSecondfile):
                uploadfile(c, url, field, newSecondfile) ;
        except:
            t = time.time()
            logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('error_log_%Y-%m-%d.log')
            #print(logfile)
            with open(logfile, "a") as myfile:
                myfile.write("Upload File Error" + "----------" + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
            time.sleep(10)
            c.close()
            print("Error..........!!!!")
            return
        print("Success Prccessing..........!!!!")
        c.close()      
        b = datetime.datetime.now() 
        print(b-a) 
        t = time.time()
        logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('error_log_%Y-%m-%d.log')
        with open(logfile, "a") as myfile:
            tmp = "success update file.  --------"
            myfile.write(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
            print(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
        oldfile = oldpath + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d_%H-%M-%S') + ".xlsx"
        shutil.move(newfile, oldfile)
    else:
        t = time.time()
        logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('log_%Y-%m-%d.log')
        print(logfile)
        with open(logfile, "a") as myfile:
            tmp = "File not ready.  ----------"
            myfile.write(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
            print(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
        time.sleep(120)
    time.sleep(120)

def auto_personal_update():
    rerun = False
    i = 0 ;
    while True:
        if os.path.exists(newfile):
            wb = load_workbook(filename=newfile, read_only=True)
            ws = wb['MULTI_RECORD_SAMPLE'] # ws is now an IterableWorksheet
            
            a = datetime.datetime.now()
            print(a)
            for row in ws.rows:
                i = i + 1
                #print(row[0].value + "----------" + row[1].value) ;
                if i > 1:
                    tmp = "指定鏈結2" + row[0].value + "%22&val=%22"+ row[1].value +"%22"
                    try:
                        r = requests.get(tmp)
                        if r.status_code != 200:
                            t = time.time()
                            logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('error_log_%Y-%m-%d.log')
                            print(row[0].value)
                            with open(logfile, "a") as myfile:
                                myfile.write(row[0].value + "----------" + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
                            rerun = True
                    except:
                        t = time.time()
                        logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('error_log_%Y-%m-%d.log')
                        with open(logfile, "a") as myfile:
                            myfile.write(row[0].value + "__Connection Error" + "----------" + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
                        rerun = True    
                    
            wb._archive.close()    
            if rerun == False:
                b = datetime.datetime.now()       
                print(b-a) 
                t = time.time()
                oldfile = oldpath + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d_%H-%M-%S') + ".xlsx"
                shutil.move(newfile, oldfile)
                logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('log_%Y-%m-%d.log')
                with open(logfile, "a") as myfile:
                    tmp = "success update file.  --------"
                    myfile.write(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
                    print(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
            else:
                t = time.time()
                logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('error_log_%Y-%m-%d.log')
                with open(logfile, "a") as myfile:
                    myfile.write("run again. " + "----------" + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
                print("run again..............." + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S'))
                time.sleep(60)
            rerun = False    
        else:
            t = time.time()
            logfile = logpath + datetime.datetime.fromtimestamp(t).strftime('log_%Y-%m-%d.log')
            print(logfile)
            with open(logfile, "a") as myfile:
                tmp = "File not ready.  ----------"
                myfile.write(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
                print(tmp + datetime.datetime.fromtimestamp(t).strftime('_%Y-%m-%d %H:%M:%S\n'))
            time.sleep(120)
            break
            
if __name__ == "__main__":
    while True:
        checkdirstatus()
        if checkfilesize():
            auto_personal_update_file()
        else:
            auto_personal_update()
