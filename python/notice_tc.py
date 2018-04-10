# -*- coding:utf-8 -*-
"""
notice transaction compensation
事务补偿，自动发短信功能
"""
import json
import requests
import time


BASE_PATH = '/cloud/log/saas-some-project/logback/saas-some-project_ERROR_'
BASE_CONTENT = ''


def send_msg(msg):
    print msg


def call_http_func(url='',payload = '00000'):
    headers = {'content-type': 'application/json'}
    r = requests.post(url, data=payload, headers=headers)
    returnVal = r.text
    send_msg(returnVal)
    return returnVal


def send_sms(msg):
    data = {
    "mobilePhoneNumber":u"13300001111",
    "message":msg,
    "account":u"ACCOUNT",
    "password":u"PASSWORD",
    "validateCode":""
    }
    key = call_http_func('http://127.0.0.1/sms/getKey',json.dumps(data))
    data['validateCode'] = key
    call_http_func('http://127.0.0.1/sms/send',json.dumps(data))


#send_sms('tc error,pls check')

def check_monitor():
    global BASE_PATH, BASE_CONTENT
    date_str = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    print date_str
    date_str = BASE_PATH + date_str + ".log"
    try:
        f = open(date_str)
        contents = f.read()
        if None == contents or contents.strip() == '':
            return False
        elif BASE_CONTENT == '':
            BASE_CONTENT = contents
            return False
        elif BASE_CONTENT == contents:
            return False
        else:
            time_str = time.strftime('%Y-%m-%d %H:%m:%S',time.localtime(time.time()))
            send_sms('tc error : %s' % time_str)
            return True
    except IOError:
        return False
    return False
    



def job():
    hour = time.strftime('%H',time.localtime(time.time()))
    hour_int = int(hour)
    flag = False
    #工作时间才执行任务
    if hour_int > 8 and hour_int < 18:
        print 'handle monitor task'
        flag = check_monitor()
        print 'moitor task is over'
    return flag



while(True):
    result = job()
    if result:
        break
    time.sleep(15)