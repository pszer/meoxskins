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
	["\nWelcome!\n\nMeoxSkins editor © 2025 \nMIT license (see LICENSE.md)"]={
		pl="\nWitam!\n\nMeoxSkins editor © 2025 \nMIT licencja\n(zobacz LICENSE.md)",
		jp="\n いらっしゃいませ！\n\nMeoxSkinsエディター(C) 2025\nMIT特許\n(LICENSE.mdをごらんなさい)",
	},
	["~bClose."]={
		pl="~bZamknij",
		jp="~b閉じる",
	},
	["Save"]={
		pl="Zapisz",
		jp="セーブ"
	},
	["Open"]={
		pl="Otworz",
		jp="オーペン"
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

	["Skin type?"]={
		pl="Typ skinu?",
		jp="スキン型？"
	},
	["Slim"]={
		pl="Szczupły",
		jp="スリム"
	},
	["Wide"]={
		pl="Szeroki",
		jp="ワイド"
	},

	["default_group_name"]={
		eng="Group",
		pl ="Grupa",
		jp ="組",
	},

	["~(green)New layer"]={
		eng="~(green)New layer",
		pl ="~(green)Nowa warstwa",
		jp ="~(green)新しいレイヤー",
	},
	["~bDelete layer"]={
		eng="~bDelete layer",
		pl ="~bUsuń warstwę",
		jp ="~bレイヤーを削除r",
	},
	["Move layer up"]={
		eng="Move layer up",
		pl ="Przesuń warstwę w górę",
		jp ="レイヤーを上に移動",
	},
	["Move layer down"]={
		eng="Move layer down",
		pl ="Przesuń warstwę w dół",
		jp ="レイヤーを下に移動",
	},
	["Slim/Wide mode"]={
		eng="Slim/Wide mode",
		pl ="Tryb wąski/szeroki",
		jp ="スリム・ワイドモード",
	},
	["Colour Picker"]={
		eng="Colour Picker",
		pl ="Próbnik Kolorów",
		jp ="カラーピッカー",
	},
	["Visible Parts"]={
		eng="Visible Parts",
		pl ="Widoczne Części",
		jp ="見える部分",
	},
	["Filters"]={
		eng="Filters",
		pl ="Filtry",
		jp ="フィルタ",
	},
	["Recent filters"]={
		eng="Recent filters",
		pl ="Ostatnie filtry",
		jp ="最近のフィルター",
	},
	["Skin"]={
		eng="Skin",
		pl ="Skin",
		jp ="スキン",
	},
	["Save as project"]={
		eng="Save as project",
		pl ="Zapisz jako projekt",
		jp ="プロジェクトとしてセーブ",
	},
	["Key settings"]={
		eng="Key settings",
		pl ="Ustawienia klawiszy",
		jp ="キー設定",
	},
	["Merge layer down"]={
		eng="Merge layer down",
		pl ="Scalić warstwę w dół",
		jp ="レイヤーを下にマージ",
	},
	["Rename layer"]={
		eng="Rename layer",
		pl ="Zmień nazwę warstwy",
		jp ="レイヤの名前を変更",
	},
	["Change background colour"]={
		eng="Change background colour",
		pl ="Zmień kolor tła",
		jp ="背景色を変更",
	},
	["Toggle grid"]={
		eng="Toggle grid",
		pl ="Przełącz siatkę",
		jp ="グリッドの切り替え",
	},
	["Adjust HSL"]={
		eng="Adjust HSL",
		pl ="Dostosuj HSL",
		jp ="HSLを調整",
	},
	["Contrast/Brightness"]={
		eng="Contrast/Brightness",
		pl ="Kontrast/Jasność",
		jp ="コントラスト/明るさ",
	},
	["Curves"]={
		eng="Curves",
		pl ="Paski",
		jp ="曲線",
	},
	["Invert (HSL)"]={
		eng="Invert (HSL)",
		pl ="Odwrotność (HSL)",
		jp ="色反転 (HSL)",
	},
	["Pose"]={
		eng="Pose",
		pl ="Poza",
		jp ="ポーズ",
	},
	["~b~(green)Confirm"]={
		eng="~b~(green)Confirm",
		pl ="~b~(green)Konfirmuj",
		jp ="~b~(green)はい",
	},
	["Rename ~b\""]={
		eng="Rename ~b\"",
		pl ="Zmień nazwę ~b\"",
		jp ="名前を変更~b\"",
	},
	["Gamma"]={
		eng="Gamma",
		pl ="Gamma",
		jp ="ガンマ",
	},
	["Preview"]={
		eng="Preview",
		pl ="Podgląd",
		jp ="プレビュー",
	},
	["Hue"]={
		eng="Hue",
		pl ="Hue",
		jp ="色彩",
	},
	["Sat"]={
		eng="Sat",
		pl ="Sat",
		jp ="彩度",
	},
	["Lum"]={
		eng="Lum",
		pl ="Lum",
		jp ="輝度",
	},
	["Con"]={
		eng="Con",
		pl ="Kon",
		jp ="コン",
	},
	[""]={
		eng="",
		pl ="",
		jp ="",
	},
	["Yaw"]={
		eng="Yaw",
		pl ="Yaw",
		jp ="ヨー",
	},
	["Pitch"]={
		eng="Pitch",
		pl ="Pitch",
		jp ="ピッチ",
	},
	["Roll"]={
		eng="Roll",
		pl ="Roll",
		jp ="ロール",
	},
	["Head"]={
		eng="Head",
		pl ="Głowa",
		jp ="頭",
	},
	["Right arm"]={
		eng="Right arm",
		pl ="Prawe ramię",
		jp ="右腕",
	},
	["Left arm"]={
		eng="Left arm",
		pl ="Lewe ramię",
		jp ="左腕",
	},
	["Left leg"]={
		eng="Left arm",
		pl ="Lewe noga",
		jp ="左脚",
	},
	["Right leg"]={
		eng="Right leg",
		pl ="Prawe noga",
		jp ="右脚",
	},
	["R arm"]={
		eng="R arm",
		pl ="P ramię",
		jp ="右腕",
	},
	["L arm"]={
		eng="L arm",
		pl ="L ramię",
		jp ="左腕",
	},
	["L leg"]={
		eng="L arm",
		pl ="L noga",
		jp ="左脚",
	},
	["R leg"]={
		eng="R leg",
		pl ="P noga",
		jp ="右脚",
	},
	["Torso"]={
		eng="Torso",
		pl ="Tułów",
		jp ="胴体",
	},
	["Reset"]={
		eng="Reset",
		pl ="Reset",
		jp ="リセット",
	},
	["Name is too long"]={
		eng="Name is too long",
		pl ="Nazwa jest za długa",
		jp ="名前が長すぎる",
	},
	["Name already exists"]={
		eng="Name already exists",
		pl ="Nazwa już istnieje",
		jp ="名前はすでに存在します",
	},
	["Changes background to the currently picked colour."]={
		eng="Changes background to the currently picked colour.",
		pl ="Zmien tło na aktualnie wybrany kolor",
		jp ="背景色を現在選択されている色に変更します",
	},
	["Enable or disable the grid overlay."]={
		eng="Enable or disable the grid overlay.",
		pl ="Włącz lub wyłącz siatke.",
		jp ="グリッドを有効または無効にします。",
	},
	["Change skin to have wide or slim arms."]={
		eng="Change skin to have wide or slim arms.",
		pl ="Zmień skórę, aby mieć szerokie lub szczupłe ramiona.",
		jp ="スキンを変更して腕を太くしたり細くしたりします。",
	},
	["Change pose of limbs."]={
		eng="Change pose of limbs.",
		pl ="Zmień pozycję kończyn.",
		jp ="手足のポーズを変える。",
	},

	["Hide/Show"]={
		eng="Hide/Show",
		pl ="Ukryj/Pokaż",
		jp ="非表示/表示",
	},

	["Erase Pixel"]={
		eng="Erase Pixel",
		pl ="Usuń Piksel",
		jp ="ピクセルを消去",
	},
	["Fill Face"]={
		eng="Fill Face",
		pl ="Wypełnij Twarz",
		jp ="面を塗りつぶす",
	},
	["Pick Pixel Colour"]={
		eng="Pick Pixel Colour",
		pl ="Wybierz Kolor Piksela",
		jp ="ピクセルの色を選択",
	},
	["Toggle Mirror"]={
		eng="Toggle Mirror",
		pl ="Przełącz Lustrzane Odbicie",
		jp ="鏡像切り替え",
	},
	["Toggle Grid"]={
		eng="Toggle Grid",
		pl ="Przełącz Siatkę",
		jp ="グリッドの切り替え",
	},
	["Ignore Alpha Lock"]={
		eng="Ignore Alpha Lock",
		pl ="Zignoruj Blokadę Alfa",
		jp ="アルファロックを無視",
	},
	["Hide/Show Overlay"]={
		eng="Hide/Show Overlay",
		pl ="Ukryj/Pokaż Nakładkę",
		jp ="オーバーレイを非表示/表示",
	},
	["Language"]={
		eng="Language",
		pl ="Język",
		jp ="言語",
	},

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
