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

	for i=1,5 do
		note = {}
		note.posTick = ebifry.posTick[i]
		note.durTick = ebifry.durTick
		note.noteNum = ebifry.noteNum[i]
		note.velocity = ebifry.velocity
		note.lyric = string.sub(ebifry.lyric, 3*i-2, 3*i)
		note.phonemes = ebifry.phonemes[i]
		VSInsertNote(note)
	end
end

