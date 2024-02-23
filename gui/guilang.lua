local __lang_fonts = {
	eng = {
		regular = {fname = "AnonymousPro-Regular.ttf"   ,size=12,hinting="normal"},
		bold    = {fname = "AnonymousPro-Bold.ttf"      ,size=12,hinting="normal"},
		italic  = {fname = "AnonymousPro-Italic.ttf"    ,size=12,hinting="normal"},
		ibold   = {fname = "AnonymousPro-BoldItalic.ttf",size=12,hinting="normal"},
	},

	pl = {
		regular = {fname = "AnonymousPro-Regular.ttf"   ,size=12,hinting="normal"},
		bold    = {fname = "AnonymousPro-Bold.ttf"      ,size=12,hinting="normal"},
		italic  = {fname = "AnonymousPro-Italic.ttf"    ,size=12,hinting="normal"},
		ibold   = {fname = "AnonymousPro-BoldItalic.ttf",size=12,hinting="normal"},
	},

	jp = {
		regular = {fname = "KH-Dot-Kodenmachou-12.ttf"   ,size=12,hinting="normal"},
		bold    = {fname = "KH-Dot-Kodenmachou-12-Ki.ttf",size=12,hinting="normal"},
		italic  = {fname = "KH-Dot-Kodenmachou-12-Ki.ttf",size=12,hinting="normal"},
		ibold   = {fname = "KH-Dot-Kodenmachou-12-Ki.ttf",size=12,hinting="normal"},
	}
}

local MapEditGUILanguage = {
	__supported = {"eng","pl","jp"},
	__curr_lang = "eng",
}

local MapEditGUILanguageStrings = {
	["~bCopy"] = {
		pl="~bKopiuj",
		jp="写す",
	},
	["Paste"] = {
		pl="~bPrzyklei",
		jp="張る",
	},
	["Undo"] = {
		pl="Cofnij",
		jp="アンドゥ",
	},
	["Redo"] = {
		pl="Przerób",
		jp="リドゥ",
	},
	["~b~(orange)Delete"]={
		pl="~b~(orange)Skasuj",
		jp="~b~(orange)削除する",
	},
	["~(lpurple)Group"]={
		pl="~(lpurple)Grupa",
		jp="~(lpurple)モデル組",
	},
	["~(green)~bCreate"]={
		pl="~(green)~bUtwórz Grupę",
		jp="~(green)~b作る",
	},
	["Merge Groups"]={
		pl="Połącz Grupy",
		jp="モデル組を合わせる"
	},
	["Add To Group"]={
		pl="Dodaj do Grupy",
		jp="モデル組を加える"
	},
	["~(lpurple)Ungroup"]={
		pl="~(lpurple)Rozgrupuj",
		jp="モデル組を解く"
	},
	["No group"]={
		pl="Nie ma grupy",
		jp="選択組ではありません",
	},

	["~(lgray)--Transform--"]={
		pl="~(lgray)--Transformuj--",
		jp="~(lgray)トランスフォーマー"
	},
	["~(lgray)--Actions--"]={
		pl="~(lgray)--Operacje--",
		jp="~(lgray)作用",
	},
	["Flip"]={
		pl="Odbij",
		jp="反転",
	},

	["... by ~i~(lred)X~r Axis"]={
		pl="... względem Osi ~i~(lred)X~r",
		jp="。。~i~(lred)Ｘ~rの軸に対して",
	},
	["... by ~i~(lgreen)Y~r Axis"]={
		pl="... względem Osi ~i~(lgreen)Y~r",
		jp="。。~i~(lgreen)Ｙ~rの軸に対して",
	},
	["... by ~i~(lblue)Z~r Axis"]={
		pl="... względem Osi ~i~(lblue)Z~r",
		jp="。。~i~(lblue)Ｚ~rの軸に対して",
	},

	["Rotate"]={
		pl="Obróć",
		jp="回転",
	},
	["Rotate selection."]={
		pl="Obróć selekcje.",
		jp="選択を回転する。",
	},
	["... by angle°"]={
		pl="... według kąta°",
		jp="。。角度によって"
	},
	["... around ~i~(lred)X~r Axis"]={
		pl="... dookoła Osi ~i~(lred)X~r",
		jp="。。~i~(lred)Ｘ~rの軸を中心に",
	},
	["... around ~i~(lgreen)Y~r Axis"]={
		pl="... dookoła Osi ~i~(lgreen)Y~r",
		jp="。。~i~(lgreen)Ｙ~rの軸を中心に",
	},
	["... around ~i~(lblue)Z~r Axis"]={
		pl="... dookoła Osi ~i~(lblue)Z~r",
		jp="。。~i~(lblue)Ｚ~rの軸を中心に",
	},
	["Scale"]={
		pl="Zmien rozmiaj",
		jp="拡大縮小す",
	},
	["Scale selection."]={
		pl="Zmien rozmiar.",
		jp="選択を拡大縮小する。"
	},
	["~bReset"]={
		pl="Zresetuj",
		jp="リセット",
	},
	["Keybinds"]={
		pl="Ustawienia Klawiatury",
		jp="入力設定",
	},
	["Set Language"]={
		pl="Zmień język",
		jp="言語を設定する",
	},
	["~iAbout"]={
		pl="Informacja",
		jp="プログラムについて",
	},
	["~b~(red)Do not click the kappa."]={
		pl="~b~(red)Nie klikaj kappy.",
		jp="~b~(red)カッパを押すな",
	},
	["\nWelcome!\n\nMeoxSkins editor © 2024 \nMIT license (see LICENSE.md)"]={
		pl="\nWitam!\n\nMeoxSkins editor © 2023 \nMIT licencja\n(zobacz LICENSE.md)",
		jp="\n いらっしゃいませ！\n\nMeoxSkinsエディター(C) 2023\nMIT特許\n(LICENSE.mdをごらんあさい)",
	},
	["~bClose."]={
		pl="~bZamknij",
		jp="~b閉じる",
	},
	["Save"]={
		pl="Zapisz",
		jp="セーブ"
	},
	["~iQuit"]={
		pl="~iWyjdź",
		jp="~i出る"
	},
	["File"]={
		pl="Plik",
		jp="ファイル",
	},
	["Edit"]={
		pl="Edytuj",
		jp="変える",
	},
	["Help"]={
		pl="Pomoca",
		jp="介助",
	},
	["Import"]={
		pl="Importuj",
		jp="輸入する",
	},
	["Delete"]={
		pl="Skasuj",
		jp="削除する",
	},

	[" is part of an animated texture, can't be deleted."]={
		pl=" jest część animowanej tekstury, nie można usunąć.",
		jp="はアニメーションテクスチャの一部であり、削除できません。"
	},
	[" is applied to the map mesh, can't be deleted."]={
		pl=" jest część siatka mapy, nie można usunąć.",
		jp="はマップのメッシュに付いてあります、削除できません。"
	},

	["[Drop texture here]"]={
		pl="[Upuść teksture tutaj]",
		jp="[ここにテクスチャをドロップ]",
	},
	["[Drop model here]"]={
		pl="[Upuść model tutaj]",
		jp="[ここにモデルをドロップ]",
	},
	[" is not in src/img/ folder."]={
		pl=" nie jest w środku folderu src/img/.",
		jp=" は「src/img/」ディレクトリ内にはありません。"
	},
	[" is not in src/models/ folder."]={
		pl=" nie jest w środku folderu src/models/.",
		jp=" は「src/models/」ディレクトリ内にはありません。"
	},
	[" doesn't exist."]={
		pl=" nie istnieje.",
		jp=" は存在しません。"
	},
	[" failed to open."]={
		pl=" nie udało się otworzyć.",
		jp=" を開くことできませんでした。"
	},
	["Place model"]={
		pl="Postaw model",
		jp="モデルを入れる",
	},
	["... at ~(lpink)selection~r."]={
		pl="... na ~(lpink)selekcji~r.",
		jp="。。~(lpink)選択~rの上に",
	},
	["... at world origin."]={
		pl="... na początek świata.",
		jp="。。世界の原点に",
	},

	["Type in new name."]={
		pl="Wpisz nowy imie.",
		jp="名前を新しく入力してください。"
	},
	["Cancel"]={
		pl="Anuluj",
		jp="キャンセル"
	},
	["~bCommit"]={
		pl="~bZrub",
		jp="~bコミット"
	},

	["Move"]={
		pl="Przesun",
		jp="動かす"
	},
	["Locally"]={
		pl="Lokalnie",
		jp="地域的",
	},
	["Globally"]={
		pl="Globalnie",
		jp="大域的"
	},
	["Move selection."]={
		pl="Przesun selekcje.",
		jp="選択を動かす。"
	},

	["Edit wall texture attributes."]={
		pl="Zmien atrybuty tekstury.",
		jp="テクスチャのプロパティを改める",
	},
	["Edit tile texture attributes."]={
		pl="Zmien atrybuty tekstury.",
		jp="テクスチャのプロパティを改める",
	},
	["Keep offset"]={
		pl="Zostaw offset",
		jp="位置を温存",
	},
	["Keep scale"]={
		pl="Zostaw rozmiar",
		jp="規模を温存",
	},
	["Flip ~(lred)~bX"]={
		pl="Odbij ~(lred)~bX",
		jp="~(lred)~bX~rで反転",
	},
	["Flip ~(lgreen)~bY"]={
		pl="Odbij ~(lgreen)~bY",
		jp="~(lgreen)~bY~rで反転",
	},
	["Enable global scaling."]={
		pl="Włącz globalny skalowanie",
		jp="大域的の拡大縮小",
	},

	["~(red)%s~(red) is malformed."]={
		pl="~(red)%s~(red) jest błędny.",
		jp="~(red)%s~(red)の入力は無効です。"
	},
	["~b~(red)Angle"]={
		pl="~b~(red)Kąt",
		jp="~b~(red)角度"
	},

	["default_group_name"]={
		eng="Group",
		pl ="Grupa",
		jp ="組",
	}
}

function MapEditGUILanguage:setLanguage(lang)
	assert(lang and type(lang)=="string")
	local supported = false
	for i,v in ipairs(self.__supported) do
		if v == lang then supported = true break end
	end
	if not supported then
		print(string.format("Unsupported language %s",lang))
		self.__curr_lang = "eng"
		return
	end

	self.__curr_lang = lang
end

function MapEditGUILanguage:getFontInfo(lang)
	local curr_lang = lang or MapEditGUILanguage.__curr_lang
	return __lang_fonts[curr_lang]
end

MapEditGUILanguage.__index = function(table, key)
	local curr_lang = MapEditGUILanguage.__curr_lang

	local t = MapEditGUILanguageStrings[key]
	if t and not t["eng"] and curr_lang=="eng" then
		local key = key
		if key == "" then return " " end
		return key
	end

	if t then
		local S = t[curr_lang]
		if S then
			if S == "" then return " " end
			return S
		end
	end

	return key
end
setmetatable(MapEditGUILanguage, MapEditGUILanguage)
return MapEditGUILanguage
