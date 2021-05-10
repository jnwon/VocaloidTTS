function manifest()
    myManifest = {
        name          = "Vocaloid TTS",
        comment       = "Text to Speech with Vocaloid",
        author        = "spaghetti code",
        pluginID      = "{4F2E5CF3-CAB2-46AE-862F-7C672CC50609}",
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

	-- パラメータ入力ダイアログのウィンドウタイトルを設定する.
	VSDlgSetDialogTitle("Vocaloid TTS")

	-- ダイアログにフィールドを追加する.
	local field = {}
	field.name       = "lyrics"
	field.caption    = "Lyrics"
	field.initialVal = ""
	field.type       = 3
	dlgStatus = VSDlgAddField(field)

	-- ダイアログから入力値を取得する.
	dlgStatus = VSDlgDoModal()
	if (dlgStatus == 2) then
		-- When it was cancelled.
		return 0
	end
	if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
		-- When it returned an error.
		return 1
	end

	-- ダイアログから入力値を取得する.
	dlgStatus, lyricsInput = VSDlgGetStringValue("lyrics")
	lyrics = string.gsub(lyricsInput, 'ー', '')
	lyrics = lyrics..'。。'

	-- VSSeekToBeginNote()
	-- result, note = VSGetNextNote()
	-- while result == 1 do
	-- 	VSMessageBox(note.velocity, 0)
	-- 	result, note = VSGetNextNote()
	-- end

	i = 0
	k = 1
	for line in io.lines("../aubio-0.4.6-win64/bin/voicetest.wav.txt") do
		if (i > 1) then
			tmpTable = SplitString(line, '%s')
			if (tonumber(tmpTable[1]) > 100 and tonumber(tmpTable[2]) > 1000) then
				lyric = string.sub(lyrics, 3*k-2, 3*k)
				if(lyric ~= '。' and lyric ~= '、' and lyric ~= '？' and lyric ~= '！') then
					nextLyric = string.sub(lyrics, 3*k+1, 3*k+3)
					if(nextLyric == 'ゃ' or nextLyric == 'ャ' or nextLyric == 'ゅ' or nextLyric == 'ュ' or nextLyric == 'ょ' or nextLyric == 'ョ') then
						lyric = lyric..nextLyric
						k = k+1
					end
					if (tonumber(tmpTable[3]) > 70) then
						tmpTable[3] = 67
					end
					note = {}
					note.posTick = math.floor(tonumber(tmpTable[4])*1000)
					note.durTick = math.floor(tonumber(tmpTable[6])*1000)
					if (note.durTick > 150 or nextLyric == '。' or nextLyric == '、' or nextLyric == '？' or nextLyric == '！') then
						note.durTick = 150
					end
					note.noteNum = tmpTable[3]
					note.velocity = 64
					note.lyric = lyric
					note.phonemes = ptab_j.tab[lyric]
					nextLyric = string.sub(lyrics, 3*k+1, 3*k+3)
					if(nextLyric == 'ん' or nextLyric == 'ン') then
						note.phonemes = note.phonemes..' n'
						k = k+1
					elseif(nextLyric == 'っ' or nextLyric == 'ッ' or nextLyric == 'ぁ' or nextLyric == 'ァ' or nextLyric == 'ぃ' or nextLyric == 'ィ' or nextLyric == 'ぅ' or nextLyric == 'ゥ' or nextLyric == 'ぇ' or nextLyric == 'ェ' or nextLyric == 'ぉ' or nextLyric == 'ォ') then
						k = k+1
					else
					end
					VSInsertNote(note)
				end
				k = k+1
			end
		end
		i = i+1
	end
end