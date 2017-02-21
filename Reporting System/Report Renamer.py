#-*- coding=utf8 -*-
'''
This program is for the full automation of the reporting sysyem,
which can detect 5 kinds of reports and rename them with deisred
fornat and will be executed every 6 hours once it's started.
'''
import os, time, datetime, sys
from datetime import timedelta
def rename_daily_app_report():
    path=r"指定目錄"
    flag=0 #The variable for deciding whether to print out the message on Line 30
    for file_entity in os.listdir(path):
            currenttime=time.time()-1*86400
            weeknumber=datetime.datetime.fromtimestamp(currenttime).strftime('%w')
            if file_entity=="每日報表.xml":
                #If it Monday; 0 represents Sunday; see Line 6
                if weeknumber=='0':
                    flag=1
                    previoustime=time.time()-3*86400
                    file_entity=os.path.join(path, file_entity)
                    newname="每日報表_"+datetime.datetime.fromtimestamp(previoustime).strftime('%Y%m%d')+"-"+datetime.datetime.fromtimestamp(currenttime).strftime('%m%d')+".xml"
                    newname=os.path.join(path, newname)
                    os.rename(file_entity, newname)
                    print(file_entity+" has been changed as "+ newname)
                else:
                    flag=1
                    file_entity=os.path.join(path, file_entity)
                    newname="每日報表_"+datetime.datetime.fromtimestamp(currenttime).strftime('%Y%m%d')+".xml"
                    newname=os.path.join(path, newname)
                    os.rename(file_entity, newname)
                    print(file_entity+" has been changed as "+ newname)
    if flag==0:
        print("每日報表.xml doesn't exist in ("+path+").")
    else:
        daily_finished_time=time.time()
        print("※Daily Report Renamer has finished the mission at " + \
              datetime.datetime.fromtimestamp(daily_finished_time).strftime('%Y-%m-%d %H:%M:%S')+ "!")

def rename_weekly_app_report():
    path=r"指定目錄"
    weeklyflag=0
    for file_entity in os.listdir(path):
        currenttime=time.time()-1*86400
        weeknumber=datetime.datetime.fromtimestamp(currenttime).strftime('%w')
        if file_entity=="週報表.xml":
            if weeknumber=='3':
                weeklyflag=1
                previoustime=time.time()-7*86400
                file_entity=os.path.join(path, file_entity)
                newname="週報表_"+datetime.datetime.fromtimestamp(previoustime).strftime('%Y%m%d')+"-" \
                         +datetime.datetime.fromtimestamp(currenttime).strftime('%m%d')+".xml"
                newname=os.path.join(path, newname)
                os.rename(file_entity, newname)
                print(file_entity+"has been changed as "+ newname)
    if weeklyflag==0:
        print("週報表.xml doesn't exist in ("+path+").")
    else:
        weekly_finished_time=time.time()
        print("※Weekly Report Renamer has finished the mission at " + \
              datetime.datetime.fromtimestamp(weekly_finished_time).strftime('%Y-%m-%d %H:%M:%S') + "!")

def rename_accumulated_app_report():
    path=r"指定目錄"
    accumulatedflag=0
    today_date=datetime.date.today()
    first_date=datetime.date(today_date.year, today_date.month,1)
    if today_date-first_date >= timedelta(7):
        desirable_base_date=datetime.date(today_date.year, today_date.month, 1)
    else:
        desirable_base_date=datetime.date(today_date.year, today_date.month-1, 1)
    for file_entity in os.listdir(path):
        if file_entity=="累積報表.xml":
            accumulatedflag=1
            file_entity=os.path.join(path, file_entity)
            genuine_date=today_date-datetime.timedelta(1)
            newname="累積報表_"+desirable_base_date.strftime('%Y%m%d')+"-" \
                     +genuine_date.strftime('%m%d')+".xml"
            newname=os.path.join(path, newname)
            os.rename(file_entity, newname)
            print(file_entity+"has been changed as "+ newname)
    if accumulatedflag==0:
        print("累積報表.xml doesn't exist in ("+ path+").")
    else:
        accumulated_finished_time=time.time()
        print("※Accumulated Report Renamer has finished the mission at " + \
              datetime.datetime.fromtimestamp(accumulated_finished_time).strftime('%Y-%m-%d %H:%M:%S')+"!")

def rename_monthly_app_report():
    import calendar
    path=r"指定目錄"
    monthlyflag=0
    today_date=datetime.date.today()
    first_date=datetime.date(today_date.year, today_date.month-1,1)
    _, number_days=calendar.monthrange(today_date.year, today_date.month-1)
    last_date=datetime.date(today_date.year, today_date.month-1,number_days)
    for file_entity in os.listdir(path):
        if file_entity=="APP月報表.xml":
            monthlyflag=1
            file_entity=os.path.join(path, file_entity)
            newname="APP月報表_"+first_date.strftime('%Y%m%d')+"-"+last_date.strftime('%m%d')+".xml"
            newname=os.path.join(path, newname)
            os.rename(file_entity, newname)
            print(file_entity+"has been changed as "+newname)
    if monthlyflag==0:
        print("APP月報表.xml doesn't exist in (" + path+").")
    else:
        monthly_finished_time=time.time()
        print("※Monthly Report Renamer has finished the mission at " + \
              datetime.datetime.fromtimestamp(monthly_finished_time).strftime('%Y-%m-%d %H:%M:%S')+"!")

def rename_quarterly_app_report():
    import calendar
    path=r"指定目錄"
    quarterflag=0
    today_date=datetime.date.today()
    if 1 <= today_date.month and today_date.month <=3:
        _, number_days=calendar.monthrange(today_date.year-1, 12)
        last_date=datetime.date(today_date.year-1, 12, number_days)
        first_date=datetime.date(last_date.year, last_date.month-2, 1)
    else:
        _, number_days=calendar.monthrange(today_date.year, today_date.month-1)
        last_date=datetime.date(today_date.year, today_date.month-1, number_days)
        first_date=datetime.date(last_date.year, last_date.month-2, 1)
    for file_entity in os.listdir(path):
        if file_entity=="APP季報表.xml":
            quarterflag=1
            file_entity=os.path.join(path, file_entity)
            newname="APP季報表_"+first_date.strftime('%Y%m%d')+"-"+last_date.strftime('%m%d')+".xml"
            newname=os.path.join(path, newname)
            os.rename(file_entity, newname)
            print(file_entity+"has been changed as "+newname)
    if quarterflag==0:
        print("APP季報表.xml doesn't exist in (" + path+").")
    else:
        quarterly_finished_time=time.time()
        print("※Quarterly Report Renamer has finished the mission at " + \
              datetime.datetime.fromtimestamp(quarterly_finished_time).strftime('%Y-%m-%d %H:%M:%S')+"!")
    
while(True):
    rename_daily_app_report()
    rename_weekly_app_report()
    rename_accumulated_app_report()
    rename_monthly_app_report()
    rename_quarterly_app_report()
    time.sleep(21600)
