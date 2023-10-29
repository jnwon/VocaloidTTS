from pywinauto import Application
from datetime import datetime
import pywinauto
import os
import sys
import time
import psutil

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
                    log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + 'Kill chrome.exe(%d)..' %processID
                    print(log)
                    f.write(log)
                    psutil.Process(processID).kill()
                    log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + 'chrome.exe(%d) killed.' %processID
                    print(log)
                    f.write(log)
            log = datetime.now().strftime('%Y-%m-%d %H:%M:%S') + 'All chrome.exe process were terminated.'
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
        # if lines[len(lines) - 1].find('speech received task end.') > 0 or lines[len(lines) - 1].find('web server task end.') > 0:
            restartServer(window)
        elif lines[len(lines) - 1].find('Progmram Exit.') > 0 :
            print('Yukarinette was closed.')
            break
    except:
        pass
