from pywinauto import Application
from datetime import datetime
import pywinauto
import os
import sys
import time
import psutil

def restartServer(window):
    print('Restarting server..')
    while 1:
        time.sleep(0.5)
        try:
            window['Button5'].click()
            break
        except:
            pass
    while 1:
        time.sleep(0.5)
        try:
            window['Button4'].click()
            break
        except:
            pass
    timer = 300
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
            for prc in psutil.process_iter():
                try:
                    processName = prc.name()
                    processID = prc.pid
                    if processName == 'chrome.exe':
                        psutil.Process(processID).kill()
                        break

                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    pass
            while 1:
                time.sleep(0.5)
                try:
                    window['Button5'].click()
                    break
                except:
                    pass
            while 1:
                time.sleep(0.5)
                try:
                    window['Button4'].click()
                    break
                except:
                    pass

logDir = os.path.expandvars(r'%LOCALAPPDATA%\Yukarinette\Logs')
isAppRunning = False

for proc in psutil.process_iter():
    try:
        processName = proc.name()
        processID = proc.pid
        if processName == 'Yukarinette.exe' :
            app = Application(backend="uia").connect(process=processID)
            isAppRunning = True
            break
 
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass

if not isAppRunning:
    print('Yukarinette is not running.')
    sys.exit()


window = app.window()

while 1:
    time.sleep(1)
    now = datetime.now()
    date = now.strftime('%Y%m%d')
    logFile = logDir + '\\log.' + date + '.log'
    try:
        f = open(logFile, "r")
        lines = f.readlines()
        f.close()
        if lines[len(lines) - 1].find('web server task end.') > 0 :
            restartServer(window)
        elif lines[len(lines) - 1].find('Progmram Exit.') > 0 :
            print('Yukarinette was closed.')
            break
    except:
        pass
