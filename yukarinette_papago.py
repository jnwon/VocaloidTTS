from datetime import datetime
import os
import sys
import json
import time
import urllib.request

client_id = "ztdadkpxbm"
client_secret = "U8YbVSbyAkZ2ihfkEBTiPlmC88Igl7KNawIRe0U6"

def callPapago(client_id, client_secret, encText):
    data = "source=ko&target=en&text=" + encText
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


now = datetime.now()
date = now.strftime('%Y%m%d')
logDir = os.path.expandvars(r'%LOCALAPPDATA%\Yukarinette\Logs')
logFile = logDir + '\\log.'+date+'.log'

try:
    f = open(logFile, "r")
    lines = f.readlines()
    updateTime = lines[len(lines)-1].split(" ")[1]
    f.close()
except:
    print('Yukarinette log file('+logFile+') doesn\'t exists.')
    sys.exit()

while 1:
    time.sleep(0.1)
    f = open(logFile, "r")
    lines = f.readlines()
    updateTimeNew = lines[len(lines)-1].split(" ")[1]
    if updateTime != updateTimeNew:
        updateTime = updateTimeNew
        i = len(lines)-1
        while 1:
            if lines[i].find("message=") > 0 :
                recognizedText = lines[i].split("message=")[1]
                callPapago(client_id, client_secret, recognizedText)
                break
            i = i-1
    f.close()
