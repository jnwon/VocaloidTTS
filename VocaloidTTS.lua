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
	-- dlgStatus = VSDlgDoModal()
	-- if (dlgStatus == 2) then
	-- 	-- When it was cancelled.
	-- 	return 0
	-- end
	-- if ((dlgStatus ~= 1) and (dlgStatus ~= 2)) then
	-- 	-- When it returned an error.
	-- 	return 1
	-- end

	-- ダイアログから入力値を取得する.
	-- dlgStatus, lyricsInput = VSDlgGetStringValue("lyrics")
	-- VSMessageBox(lyricsInput, 0)

	-- VSSeekToBeginNote()
	-- result, note = VSGetNextNote()
	-- while result == 1 do
	-- 	VSMessageBox(note.velocity, 0)
	-- 	result, note = VSGetNextNote()
	-- end

	ebifry = {}
	ebifry.posTick = {0, 120, 240, 360, 480}
	ebifry.durTick = 120
	ebifry.noteNum = {65, 67, 68, 65, 62}
	ebifry.velocity = 64
	ebifry.lyric = "エビフライ"
	ebifry.phonemes = {"e", "b' i", "p\\ M", "4 a", "i"}

	-- for i=1,5 do
	-- 	note = {}
	-- 	note.posTick = ebifry.posTick[i]
	-- 	note.durTick = ebifry.durTick
	-- 	note.noteNum = ebifry.noteNum[i]
	-- 	note.velocity = ebifry.velocity
	-- 	note.lyric = string.sub(ebifry.lyric, 3*i-2, 3*i)
	-- 	note.phonemes = ebifry.phonemes[i]
	-- 	VSInsertNote(note)
	-- end

	i = 0
	for line in io.lines("notes(papago).txt") do
		if (i > 0) then
			tmpTable = SplitString(line, '%s')
			if (math.floor(tonumber(tmpTable[1])) > 70) then
				tmpTable[1] = 67
			else
				tmpTable[1] = math.floor(tonumber(tmpTable[1]))
			end
			note = {}
			note.posTick = math.floor(tonumber(tmpTable[2]*1000))
			note.durTick = math.floor(tonumber(tmpTable[3]*1000) - tonumber(tmpTable[2]*1000))
			note.noteNum = tmpTable[1]
			note.velocity = 64
			note.lyric = tmpTable[4]
			note.phonemes = "a"
			VSInsertNote(note)
			-- VSMessageBox(note.posTick..' '..note.durTick..' '..note.noteNum..' '..note.lyrics, 0)	
			-- for k, v in pairs(tmpTable) do
			-- 	VSMessageBox(v, 0)
			-- end
		end
		i = i+1
	end
end

