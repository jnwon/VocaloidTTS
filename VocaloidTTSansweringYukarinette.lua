function manifest()
    myManifest = {
        name          = "Vocaloid TTS answering Yukarinette",
        comment       = "Text to Speech with Vocaloid - Answering to Yukarinette Input",
        author        = "spaghetti code",
        pluginID      = "{DA115C85-5E21-4ABA-9B9E-83D96CE7AEC3}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }

    return myManifest
end

function SplitString(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)

   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
     last_end = e+1
     s, e, cap = str:find(fpat, last_end)
   end

   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end

   return t
end

function main(processParam, envParam)

	require('ptab_j')
	require('k2jmap')

	VSSeekToBeginNote()
	result, note = VSGetNextNote()
	while result == 1 do
		VSRemoveNote(note)
		result, note = VSGetNextNote()
	end
	--VSUpdateControlAt("BRI", 100, 64);
	--VSUpdateControlAt("DYN", 100, 64);
	--VSMessageBox(date, 0)
	
	cmd = '$readfile = Get-Content tts_script_rendered.txt -Tail 1 -Encoding UTF8; $tokens = $readfile -split \' \'; Set-Content script_mode.txt $tokens[1] -Encoding UTF8; Set-Content input.txt $tokens[2] -Encoding UTF8'
	os.execute('powershell '..cmd)
	
	for line in io.lines("script_mode.txt") do
		if string.find(line,'2') ~= nil then
			stupit = ''
			for input in io.lines("input.txt") do
				input = string.gsub(input, '%.', '。')
				input = string.gsub(input, ',', '、')
				input = string.gsub(input, '?', '？')
				input = string.gsub(input, '!', '！')
				input = string.gsub(input, '0', "よん")
				input = string.gsub(input, '1', "いる")
				input = string.gsub(input, '2', "い")
				input = string.gsub(input, '3', "さむ")
				input = string.gsub(input, '4', "さ")
				input = string.gsub(input, '5', "お")
				input = string.gsub(input, '6', "ゆく")
				input = string.gsub(input, '7', "ちる")
				input = string.gsub(input, '8', "ぱる")
				input = string.gsub(input, '9', "ぐ")

				replaced = ''
				for i = 1, string.len(input), 3 do
					char = string.sub(input, i, i+2)
					if ((string.byte(char) >= string.byte('가')) and (string.byte(char) <= string.byte('힝'))) then
						replaced = replaced..k2jmap.map[char]
					elseif char == '。' or char == '、' or char == '？' or char == '！' or char == 'よ' or char == 'ん' or char == 'い' or char == 'る' or char == 'さ' or char == 'む' or char == 'お' or char == 'ゆ' or char == 'く' or char == 'ち' or char == 'ぱ' or char == 'ぐ' then
						replaced = replaced..char
					end
				end
				if (string.len(replaced) > 0) then
					stupit = replaced
				end
			end
			os.execute("powershell \"Write-Output "..stupit.." | Set-Content input.txt -Encoding UTF8\"")
		end
	end
	os.execute("open_jtalk.exe -m mei/mei_normal.htsvoice -x dic -ow output.wav -ot analyzed.txt input.txt")
	
	token = {}
	i = 1
	for line in io.lines("analyzed.txt") do
		if (line == '') then
			break
		end
		if string.find(line,'[Text analysis result]') ~= nil then

		elseif string.find(line,'　') ~= nil then

		else
			tokeninfo = {}	
			analysis = SplitString(line, ',')
			tokeninfo.word = analysis[1]
			tokeninfo.class = analysis[2]
			tokeninfo.kana = string.gsub(analysis[10], '’', '')
			accentpart = SplitString(analysis[11], '/')
			tokeninfo.accent = tonumber(accentpart[1])
			tokeninfo.length = tonumber(accentpart[2])
			if (tokeninfo.accent > tokeninfo.length) or (tokeninfo.accent > 5) then
				tokeninfo.accent = 2
			end
			if (tokeninfo.length >= 3) and (tokeninfo.accent == 0) then
				tokeninfo.accent = 2
			end
			if (tokeninfo.class == '助詞') and (tokeninfo.kana == 'カラ') then
				tokeninfo.accent = 1
			end
			token[i] = tokeninfo
			i = i+1
		end
	end

	posTick = 100
	lastpitch = 0
	for i, item in pairs(token) do
		nextword = ''
		prevclass = ''
		if i < #token then
			nextword = token[i+1].word
		end
		if i > 1 then
			prevclass = token[i-1].class
		end
		pitch = {}
		pitch[1] = 64
		pitch[2] = 64
		pitch[3] = 64
		pitch[4] = 64
		pitch[5] = 64
		pitch[6] = 64
		offset = -2
		prop = 0
		k = 1
		if (item.class == '助詞') or (item.class == '助動詞') then
			prop = 1
		end

		if item.accent == 0 then
			pitch[1] = 67
			pitch[2] = 67
			pitch[3] = 67
			pitch[4] = 67
			pitch[5] = 67
			pitch[6] = 67
		elseif item.accent == 1 then
			pitch[1] = 69
			pitch[2] = 64
			pitch[3] = 64
			pitch[4] = 64
			pitch[5] = 64
			pitch[6] = 64
		elseif item.accent == 2 then
			pitch[1] = 62
			pitch[2] = 67
			pitch[3] = 67
			pitch[4] = 67
			pitch[5] = 67
			pitch[6] = 67
		elseif item.accent == 3 then
			pitch[1] = 60
			pitch[2] = 64
			pitch[3] = 69
			pitch[4] = 64
			pitch[5] = 64
			pitch[6] = 64
		elseif item.accent == 4 then
			pitch[1] = 60
			pitch[2] = 64
			pitch[3] = 66
			pitch[4] = 69
			pitch[5] = 65
			pitch[6] = 64
		elseif item.accent == 5 then
			pitch[1] = 62
			pitch[2] = 64
			pitch[3] = 64
			pitch[4] = 67
			pitch[5] = 65
			pitch[6] = 64
		end

		j = 1
		cur = string.sub(item.kana, k, k+2)
		pre = ''
		while cur ~= '' do
			nex = string.sub(item.kana, k+3, k+5)
			if (cur ~= 'ッ') then
				if(nex == 'ャ' or nex == 'ュ' or nex == 'ョ' or nex == 'ァ' or nex == 'ィ' or nex == 'ェ' or nex == 'ォ') then
					cur = cur..nex
					k = k+3
					nex = string.sub(item.kana, k+3, k+5)
				end
				note = {}
				note.posTick = posTick
				note.durTick = 100
				if nex == '' then
					note.durTick = 140
				end
				if (prop == 1 and cur == 'ス') or (prop == 1 and nex == 'ス' and (nextword == '。' or nextword == '！' or nextword == '？' or nextword == '、')) or (prevclass == '動詞' and cur == 'ン') or (prevclass == '助動詞' and cur == 'ン') or (item.class == '動詞' and cur == 'シ') then
					note.durTick = 50
				end
				if (i > 1) and ((prop == 1) or (prevclass == '助動詞' and cur == 'ン')) then
					if j < 7 then
						note.noteNum = lastpitch + (pitch[j]-pitch[1]) + offset
					else
						note.noteNum = lastpitch + (pitch[6]-pitch[1]) + offset
					end
				else
					if j < 7 then
						note.noteNum = pitch[j]+offset
					else
						note.noteNum = pitch[6]+offset
					end
				end
				if note.noteNum - offset < 60 then
					note.noteNum = note.noteNum + 2
				end
				lastpitch = note.noteNum - (offset+1)
				note.velocity = 64
				if (pre == 'ッ') then
					note.velocity = 16
					pre = ''
				end
				note.lyric = cur
				note.phonemes = ptab_j.tab[cur]
				VSInsertNote(note)
				posTick = note.posTick + note.durTick
				if (prop == 1 and nex == 'ス') then
					note.posTick = posTick
					note.durTick = 50
					note.noteNum = note.noteNum -2
					note.velocity = 64
					note.lyric = '-'
					note.phonemes = '-'
					VSInsertNote(note)
					posTick = note.posTick + note.durTick
				elseif (prop == 1 and cur == 'ス') then
					--VSUpdateControlAt("BRI", note.posTick, 16);
					--VSUpdateControlAt("DYN", note.posTick, 32);
				end
			else
				pre = cur
			end
			j = j+1
			k = k+3
			cur = string.sub(item.kana, k, k+2)
		end

		if (nextword == '。' or nextword == '！' or (nextword == '' and prop ~= 1) or (nextword == '' and prop == 1 and string.find(item.kana,'カ') == nil)) then
			for k=1, 2 do
				note = {}
				note.posTick = posTick
				note.durTick = 70
				note.noteNum = lastpitch -k*2 +offset
				note.velocity = 64
				note.lyric = '-'
				note.phonemes = '-'
				VSInsertNote(note)
				posTick = note.posTick + note.durTick
			end
			posTick = posTick + 70
		elseif (nextword == '？' or (nextword == '' and prop == 1 and string.find(item.kana,'カ') ~= nil)) then
			for k=1, 2 do
				note = {}
				note.posTick = posTick
				note.durTick = 100
				note.noteNum = lastpitch + 2*((-1)^k) +offset
				note.velocity = 64
				note.lyric = '-'
				note.phonemes = '-'
				VSInsertNote(note)
				posTick = note.posTick + note.durTick
			end
			posTick = posTick + 70
		elseif (nextword == '、') then
			note = {}
			note.posTick = posTick
			note.durTick = 70
			note.noteNum = lastpitch -2 +offset
			note.velocity = 64
			note.lyric = '-'
			note.phonemes = '-'
			VSInsertNote(note)
			posTick = note.posTick + note.durTick + 70
		end
	end

	outFile, errMsg = io.open(envParam.scriptDir..'\\input.txt', "a")
	if (outFile) then outFile:write(os.date(posTick)) end
	
end
