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
	VSMessageBox(lyricsInput, 0)
end

