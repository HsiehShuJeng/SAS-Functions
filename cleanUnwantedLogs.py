#-*- coding=utf8 -*-
'''
This program is created for full automation, which can delete files
that have existed for more than 10 days in a specific directory and
is executed everyday once it's started.
'''
import os, time, datetime, sys
def clean_unwanted_log():
    path=r"指定目錄"
    now=time.time()
    for file_entity in os.listdir(path):
        file_entity = os.path.join(path, file_entity)
        if os.stat(file_entity).st_mtime < now - 10*86400:
            if os.path.isfile(file_entity):
                try:
                    os.remove(file_entity)
                except OSError as e:
                    print ("Failed with:", e.strerror)

while (True):
    clean_unwanted_log()
    t = time.time()
    print("Log cleaner has done the mission at " + datetime.datetime.fromtimestamp(t).strftime('%Y-%m-%d %H:%M:%S') + "!")
    time.sleep(86400)
