function manifest()
    myManifest = {
        name          = "Vocaloid TTS for Live",
        comment       = "Text to Speech with Vocaloid",
        author        = "spaghetti code",
        pluginID      = "{25C25D4B-1087-4F00-BAF1-A242B6487DEF}",
        pluginVersion = "1.0.0.1",
        apiVersion    = "3.0.0.1"
    }

    return myManifest
end

function main(processParam, envParam)

	require('ptab_j')

	-- パラメータ入力ダイアログのウィンドウタイトルを設定する.
	VSDlgSetDialogTitle("Vocaloid TTS for Live")

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
	dlgStatus, lyrics = VSDlgGetStringValue("lyrics")

	VSSeekToBeginNote()
	result, note = VSGetNextNote()
	while result == 1 do
		VSRemoveNote(note)
		result, note = VSGetNextNote()
	end

	pitch = 0
	word = 0
	pp = 0
	posTick = 100
	k = 4
	cur = string.sub(lyrics, k, k+2)
	while cur ~= '' do
		pre = string.sub(lyrics, k-3, k-1)
		nex = string.sub(lyrics, k+3, k+5)
		if(cur ~= '’' and cur ~= '「' and cur ~= '」' and cur ~= '・' and cur ~= '。' and cur ~= '、' and cur ~= '？' and cur ~= '！' and cur ~= 'ー') then
			--------- word ------------------------------------
			if(pre == '’') then
				word = 1
				pitch = 64
			elseif(pre == '「') then
				word = 1
				pitch = 67
			elseif(pre == '」') then
				word = 1
				pitch = 61
			else
			end
			if(word == 1) then
				if(nex == 'ゃ' or nex == 'ャ' or nex == 'ゅ' or nex == 'ュ' or nex == 'ょ' or nex == 'ョ') then
					cur = cur..nex
					k = k+3
					nex = string.sub(lyrics, k+3, k+5)
				end
				note = {}
				note.posTick = posTick
				note.durTick = 100
				note.noteNum = pitch
				note.velocity = 64
				note.lyric = cur
				note.phonemes = ptab_j.tab[cur]
				if(nex == 'ん' or nex == 'ン') then
					note.phonemes = note.phonemes..' N'
					note.durTick = 180
					k = k+3
					cur = 'ン'
					nex = string.sub(lyrics, k+3, k+5)
				elseif(nex == 'っ' or nex == 'ッ' or nex == 'ぁ' or nex == 'ァ' or nex == 'ぃ' or nex == 'ィ' or nex == 'ぅ' or nex == 'ゥ' or nex == 'ぇ' or nex == 'ェ' or nex == 'ぉ' or nex == 'ォ') then
					k = k+3
					if(nex == 'ぁ' or nex == 'ァ' or nex == 'ぃ' or nex == 'ィ' or nex == 'ぇ' or nex == 'ェ' or nex == 'ぉ' or nex == 'ォ') then
						cur = cur..nex
						note.lyric = cur
						note.phonemes = ptab_j.tab[cur]
					else
						cur = nex
					end
					nex = string.sub(lyrics, k+3, k+5)
				else
				end
				if(nex == 'ー') then
					if(cur ~= 'ン') then
						note.durTick = 180
					end
					k = k+3
					nex = string.sub(lyrics, k+3, k+5)
				end
			end
			if(nex == '’' or nex == '「' or nex == '」' or nex == '・' or nex == '。' or nex == '、' or nex == '？' or nex == '！') then
				if(nex == '・' or nex == '。' or nex == '、' or nex == '？' or nex == '！') then
					note.durTick = 140
				end
				word = 0
			end
			------------ preposition ----------------------------
			if(pre == '・') then
				pp = 1
			end
			if(pp == 1) then
				note = {}
				note.posTick = posTick
				note.durTick = 100
				if(nex == '。' or nex == '、' or nex == '？' or nex == '！') then
					note.durTick = 180
				end
				note.noteNum = 63
				if(cur == 'す' or cur == 'た' or cur == 'よ') then
					note.noteNum = 59
				elseif(cur == 'か') then
					note.noteNum = 66
				else
				end
				note.velocity = 64
				note.lyric = cur
				if(cur == 'は') then
					cur = 'わ'
				end
				note.phonemes = ptab_j.tab[cur]
			end
			if(nex == '’' or nex == '「' or nex == '」' or nex == '・' or nex == '。' or nex == '、' or nex == '？' or nex == '！') then
				if(nex == '・' or nex == '。' or nex == '、' or nex == '？' or nex == '！') then
					note.durTick = 140
				end
				pp = 0
			end
			VSInsertNote(note)
			posTick = note.posTick + note.durTick
		elseif(cur == '。' or cur == '、' or cur == '？' or cur == '！') then 
			posTick = posTick + 140
		else
		end
		k = k+3
		cur = string.sub(lyrics, k, k+2)
	end

	lyrics = string.gsub(lyrics, '’', '')
	lyrics = string.gsub(lyrics, '「', '')
	lyrics = string.gsub(lyrics, '」', '')
	lyrics = string.gsub(lyrics, '・', '')
	-- VSMessageBox(lyrics, 0)
	outFile, errMsg = io.open(envParam.scriptDir..'\\current_input.txt', "w")
	if (outFile) then outFile:write(lyrics) end
end