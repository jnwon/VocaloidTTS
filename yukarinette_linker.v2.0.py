from pywinauto import Application
from datetime import datetime
import os
import sys
import time
import json
import psutil
import winsound
import urllib.request

client_id = "ztdadkpxbm"
client_secret = "U8YbVSbyAkZ2ihfkEBTiPlmC88Igl7KNawIRe0U6"

def callPapago(client_id, client_secret, encText, window, ttsTriggerKey):
    data = "source=ko&target=ja&text=" + encText[encText.index(" ")+1:]
    url = "https://naveropenapi.apigw.ntruss.com/nmt/v1/translation"
    request = urllib.request.Request(url)
    request.add_header("X-NCP-APIGW-API-KEY-ID",client_id)
    request.add_header("X-NCP-APIGW-API-KEY",client_secret)
    response = urllib.request.urlopen(request, data=data.encode("utf-8"))
    rescode = response.getcode()
    if(rescode==200):
        response_body = response.read()
        response_obj = json.loads(response_body.decode('utf-8'))
        f = open('tts_script_rendered.txt', 'a', encoding="UTF-8")
        f.write(datetime.now().isoformat() + ' 1 ' + response_obj["message"]["result"]["translatedText"] + '\n')
        f.close()
        runTTS(window, ttsTriggerKey, False)
    else:
        print("Papago Error:" + rescode)

def runTTS(window, key, isFirstPlay):
    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Running Vocaloid TTS..')
    window.send_keystrokes('^'+key)
    #jopPluginWindow = app['Running Job Plugin']
    flag = False
    timer = 0
    while 1:
        time.sleep(0.1)
        timer = timer + 1
        if os.path.isfile('input.txt'):
            f = open('input.txt', "r", encoding='UTF-8')
            inputData = f.readlines()
            f.close()
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
        if timer >= 600:
            print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Vocaloid TTS doesn\'t respond.')
            winsound.PlaySound("wav\\error.wav", winsound.SND_FILENAME)
            break
    if timer < 600:
        window['tool_play'].click()
        time.sleep(playtime)
        window['tool_stop'].click()
        window['tool_gototop'].click()

def restartServer(window):
    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Restarting server..')
    f = open('yukarinette_trigger.log', "a")
    log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Restarting server..\n'
    f.write(log)
    f.close()
    while 1:
        time.sleep(0.5)
        try:
            window['Button5'].click()
            print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Cancel button clicked.')
            break
        except:
            pass
    while 1:
        time.sleep(0.5)
        try:
            window['Button4'].click()
            print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Record button clicked.')
            break
        except:
            pass
    timer = 300
    # timer = 10
    while 1:
        time.sleep(0.5)
        procs = pywinauto.findwindows.find_elements()
        restarted = False
        for proc in procs:
            if proc.name.find('다음 권한을 요청합니다.') > 0 :
                time.sleep(0.5)
                confirm = Application(backend="uia").connect(title='ゆかりねっと - Yukarinette -', process=proc.process_id)
                confirm.window()['허용Button'].click()
                restarted = True
                f = open('yukarinette_trigger.log', "a")
                log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Server restarted.\n'
                f.write(log)
                f.close()
                break
        if restarted:
            print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Server restarted.')
            break

        timer = timer - 0.5
        if timer == 0:
            timer = 300
            # timer = 10
            f = open('yukarinette_trigger.log', "a")
            for prc in psutil.process_iter():
                processName = prc.name()
                processID = prc.pid
                if processName == 'chrome.exe':
                    log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Kill chrome.exe(%d)..\n' %processID
                    print(log)
                    f.write(log)
                    psutil.Process(processID).kill()
                    log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' chrome.exe(%d) killed.\n' %processID
                    print(log)
                    f.write(log)
            log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' All chrome.exe process were terminated.\n'
            print(log)
            f.write(log)
            f.close()
            while 1:
                time.sleep(0.5)
                try:
                    window['Button5'].click()
                    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Cancel button clicked.')
                    break
                except:
                    pass
            while 1:
                time.sleep(0.5)
                try:
                    window['Button4'].click()
                    print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Record button clicked.')
                    break
                except:
                    pass

logDir = os.path.expandvars(r'%LOCALAPPDATA%\Yukarinette\Logs')
isApp1Running = False
isApp2Running = False
ttsTriggerKey = 'f'

for proc in psutil.process_iter():
    try:
        processName = proc.name()
        processID = proc.pid
        if processName == 'Yukarinette.exe' :
            app1 = Application(backend="uia").connect(process=processID)
            isApp1Running = True
        elif processName == 'VOCALOID4.exe' or processName == 'VOCALOID3.exe' :
            app2 = Application(backend="win32").connect(process=processID)
            isApp2Running = True
 
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass

if not isApp1Running:
    print('Yukarinette is not running.')
    sys.exit()

if not isApp2Running:
    print('Vocaloid Editor is not running.')
    sys.exit()


window_y = app1.window()
window_v = app2.window()


try:
    f = open("tts_script.txt", "r")
    lines = f.readlines()
    updateTime = lines[len(lines)-1].split(" ")[0]
    f.close()
except:
    print('tts_script.txt doesn\'t exists.')
    updateTime = '1989-02-17T00:00:00'


if os.path.isfile('setting_tts.txt'):
    f = open('setting_tts.txt', 'r')
    settingData = f.readlines()
    f.close()
    ttsTriggerKey = settingData[0].split("=")[1]
else:
    print('Enter the short-cut key that you set into Vocaloid Editor to run Vocaloid TTS plug-in.')
    ttsTriggerKey = input('Ctrl + ')
    f = open('setting_tts.txt', 'w')
    f.write('shortcutKey='+ttsTriggerKey)
    f.close()


print('Vocaloid TTS was linked with Yukarinette successfully.')

reloading = False
while 1:
    time.sleep(0.1)
    now = datetime.now()
    date = now.strftime('%Y%m%d')
    logFile = logDir + '\\log.' + date + '.log'
    try:
        f = open(logFile, "r")
        lines = f.readlines()
        f.close()
        if lines[len(lines) - 1].find('web server task end.') > 0 :
            restartServer(window_y)
        elif lines[len(lines) - 1].find('Progmram Exit.') > 0 :
            print('Yukarinette was closed.')
            break

        f = open("tts_script.txt", "r")
        lines = f.readlines()
        updateTimeNew = lines[len(lines)-1].split(" ")[0]
        if updateTime != updateTimeNew:
            winsound.PlaySound("wav\\standby.wav", winsound.SND_FILENAME)
            updateTime = updateTimeNew
            val = lines[len(lines)-1][lines[len(lines)-1].index(" ")+1:]
            text = lines[len(lines)-1][lines[len(lines)-1].index(" ")+3:]
            if val[0] == '1':
                callPapago(client_id, client_secret, val, window_v, ttsTriggerKey)
            elif val[0] == '2':
                f = open('tts_script_rendered.txt', 'a', encoding="UTF-8")
                f.write(datetime.now().isoformat() + ' 2 ' + text.replace(' ', ''))
                f.close()
                runTTS(window_v, ttsTriggerKey, False)
        f.close()
        
        try:
            window_v.is_active()
            if reloading:
                print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Vocaloid Editor window object reloaded.')
                reloading = False
        except:
            if not reloading:
                print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Reloading Vocaloid Editor window object..')
                reloading = True
            window_v = app2.window()
    except:
        pass
