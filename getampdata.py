import pyaudio
import time
import numpy
import wave
import sys

CHUNK = 1024

if len(sys.argv) < 3:
    print("Usage: %s filename.wav filename.txt" % sys.argv[0])
    sys.exit(-1)

wf = wave.open(sys.argv[1], 'rb')
RATE = wf.getframerate()

p = pyaudio.PyAudio()

stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
                channels=wf.getnchannels(),
                rate=RATE,
                output=True)

tf = open(sys.argv[2], 'r')
line = tf.readline()
data = wf.readframes(int(float(line)*RATE))

out = open(sys.argv[1]+'.txt', 'w')
prvAmp = 0
out.write('{0:<5}'.format('amp')
              + '{0:<7}'.format('ampDif')
              + '{0:<6}'.format('note')
              + '{0:<11}'.format('start')
              + '{0:<11}'.format('end')
              + '{0:<8}'.format('duration')
              + '\n\n')
while True:
    line = tf.readline()
    if not line: break
    if len(line) < 10: continue
    token = line.split()
    durSec = float(token[2]) - float(token[1])
    data = wf.readframes(int(durSec * RATE))
    amp = numpy.frombuffer(data, numpy.int16)
    # aveAmp = int(numpy.average(numpy.abs(amp)))
    # aveAmp = int(numpy.average(amp))
    maxAmp = int(max(numpy.abs(amp)))
    ampDif = abs(maxAmp - prvAmp)
    prvAmp = maxAmp
    out.write('{0:<6}'.format(str(maxAmp))
              + '{0:<6}'.format(str(ampDif))
              + '{0:<6}'.format(str(int(float(token[0]))))
              + token[1] + '   ' + token[2] + '   ' + '{0:0<8}'.format(str(round(durSec, 7))) + '\n')
    # out.write(str(maxAmp) + ' '
    #           + str(ampDif) + ' '
    #           + str(int(float(token[0]))) + ' '
    #           + token[1] + ' ' + token[2] + ' ' + str(round(durSec, 7)) + '\n')
    stream.write(data)
    time.sleep(1)

wf.close()
tf.close()
out.close()

stream.stop_stream()
stream.close()

p.terminate()