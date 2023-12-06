from pywinauto import Application
from datetime import datetime
import os
import sys
import json
import time
import psutil
import urllib.request

client_id = "ztdadkpxbm"
client_secret = "U8YbVSbyAkZ2ihfkEBTiPlmC88Igl7KNawIRe0U6"

def callPapago(client_id, client_secret, encText):
    data = "source=ja&target=ko&text=" + encText
    url = "https://naveropenapi.apigw.ntruss.com/nmt/v1/translation"
    request = urllib.request.Request(url)
    request.add_header("X-NCP-APIGW-API-KEY-ID",client_id)
    request.add_header("X-NCP-APIGW-API-KEY",client_secret)
    response = urllib.request.urlopen(request, data=data.encode("utf-8"))
    rescode = response.getcode()
    if(rescode==200):
        response_body = response.read()
        response_obj = json.loads(response_body.decode('utf-8'))
        f = open('output.papago.txt', 'w', encoding="UTF-8")
        f.write(response_obj["message"]["result"]["translatedText"])
        f.close()
    else:
        print("Papago Error:" + rescode)

def runTTS(window, key, isFirstPlay):
    print('Generating Vocaloid Notes..')
    window.send_keystrokes('^'+key)
    #jopPluginWindow = app['Running Job Plugin']
    flag = False
    while 1:
        time.sleep(0.1)
        if os.path.isfile('input.txt'):
            f = open('input.txt', "r", encoding='UTF-8')
            inputData = f.readlines()
            f.close()
            encText = urllib.parse.quote(inputData[0])
            callPapago(client_id, client_secret, encText)
        else:
            inputData = [1,2]
        if len(inputData) == 1:
            if not flag:
                flag = True
        if flag and len(inputData) == 2:
            playtime = int(inputData[1])*0.0015
            if isFirstPlay:
                playtime = playtime +2
            break
    window['tool_play'].click()
    time.sleep(playtime)
    window['tool_stop'].click()
    window['tool_gototop'].click()


now = datetime.now()
date = now.strftime('%Y%m%d')
logDir = os.path.expandvars(r'%LOCALAPPDATA%\Yukarinette\Logs')
logFile = logDir + '\\log.'+date+'.log'
errorMsg_1 = 'Error: Vocaloid Editor is not running.'
errorMsg_2 = 'Error: Yukarinette log file('+logFile+') doesn\'t exists.'
isAppRunning = False
ttsTriggerKey = 'f'

for proc in psutil.process_iter():
    try:
        processName = proc.name()
        processID = proc.pid
        if processName == 'VOCALOID4.exe' or processName == 'VOCALOID3.exe' :
            app = Application(backend="win32").connect(process=processID)
            isAppRunning = True
            break
 
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass

if not isAppRunning:
    print(errorMsg_1)
    f = open('errorlog.txt', "a")
    log = '[' + now.strftime('%Y-%m-%d %H:%M:%S') + '] ' + errorMsg_1 + '\n'
    f.write(log)
    f.close()
    time.sleep(1)
    quit()


window = app.window()

try:
    f = open(logFile, "r")
    lines = f.readlines()
    updateTime = lines[len(lines)-1].split(" ")[1]
    f.close()
except:
    print(errorMsg_2)
    f = open('errorlog.txt', "a")
    log = '[' + now.strftime('%Y-%m-%d %H:%M:%S') + '] ' + errorMsg_2 + '\n'
    f.write(log)
    f.close()
    time.sleep(1)
    quit()


if os.path.isfile('setting.txt'):
    f = open('setting.txt', 'r')
    settingData = f.readlines()
    f.close()
    ttsTriggerKey = settingData[0].split("=")[1]
else:
    print('Enter the short-cut key that you set into Vocaloid Editor to run Vocaloid TTS plug-in.')
    ttsTriggerKey = input('Ctrl + ')
    f = open('setting.txt', 'w')
    f.write('shortcutKey='+ttsTriggerKey)
    f.close()


print('Vocaloid TTS was linked with Yukarinette successfully.')

firstPlay = True
while 1:
    time.sleep(0.1)
    f = open(logFile, "r")
    lines = f.readlines()
    updateTimeNew = lines[len(lines)-1].split(" ")[1]
    if updateTime != updateTimeNew:
        updateTime = updateTimeNew
        if firstPlay:
            firstPlay = False
            runTTS(window, ttsTriggerKey, True)
        else:
            runTTS(window, ttsTriggerKey, False)
    f.close()
    
    try:
        window.is_active()
    except:
        print('Vocaloid Editor was closed.')
        break
