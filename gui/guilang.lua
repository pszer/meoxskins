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
	},

	id = {
		regular = {fname = "AnonymousPro-Regular.ttf"   ,size=12,hinting="normal"},
		bold    = {fname = "AnonymousPro-Bold.ttf"      ,size=12,hinting="normal"},
		italic  = {fname = "AnonymousPro-Italic.ttf"    ,size=12,hinting="normal"},
		ibold   = {fname = "AnonymousPro-BoldItalic.ttf",size=12,hinting="normal"},
	},
}

local MapEditGUILanguage = {
	__supported = {"eng","pl","jp","id"},
	__curr_lang = "eng",
}

local MapEditGUILanguageStrings = {
	["~bCopy"] = {
		pl="~bKopiuj",
		jp="写す",
		id="~bSalin",
	},
	["Paste"] = {
		pl="~bPrzyklei",
		jp="張る",
		id="~bTempel",
	},
	["Undo"] = {
		pl="Cofnij",
		jp="アンドゥ",
		id="Urungkan",
	},
	["Redo"] = {
		pl="Przerób",
		jp="リドゥ",
		id="Ulangi",
	},
	["~b~(orange)Delete"]={
		pl="~b~(orange)Skasuj",
		jp="~b~(orange)削除する",
		id="~b~(orange)Hapus",
	},
	["~(lpurple)Group"]={
		pl="~(lpurple)Grupa",
		jp="~(lpurple)モデル組",
		id="",
	},
	["~(green)~bCreate"]={
		pl="~(green)~bUtwórz Grupę",
		jp="~(green)~b作る",
		id="~(green)Buat",
	},
	["Merge Groups"]={
		pl="Połącz Grupy",
		jp="モデル組を合わせる",
		id=""
	},
	["Add To Group"]={
		pl="Dodaj do Grupy",
		jp="モデル組を加える",
		id=""
	},
	["~(lpurple)Ungroup"]={
		pl="~(lpurple)Rozgrupuj",
		jp="モデル組を解く",
		id=""
	},
	["No group"]={
		pl="Nie ma grupy",
		jp="選択組ではありません",
		id="",
	},

	["~(lgray)--Transform--"]={
		pl="~(lgray)--Transformuj--",
		jp="~(lgray)トランスフォーマー",
		id=""
	},
	["~(lgray)--Actions--"]={
		pl="~(lgray)--Operacje--",
		jp="~(lgray)作用",
		id="",
	},
	["Flip"]={
		pl="Odbij",
		jp="反転",
		id="",
	},

	["... by ~i~(lred)X~r Axis"]={
		pl="... względem Osi ~i~(lred)X~r",
		jp="。。~i~(lred)Ｘ~rの軸に対して",
		id="",
	},
	["... by ~i~(lgreen)Y~r Axis"]={
		pl="... względem Osi ~i~(lgreen)Y~r",
		jp="。。~i~(lgreen)Ｙ~rの軸に対して",
		id="",
	},
	["... by ~i~(lblue)Z~r Axis"]={
		pl="... względem Osi ~i~(lblue)Z~r",
		jp="。。~i~(lblue)Ｚ~rの軸に対して",
		id="",
	},

	["Rotate"]={
		pl="Obróć",
		jp="回転",
		id="",
	},
	["Rotate selection."]={
		pl="Obróć selekcje.",
		jp="選択を回転する。",
		id="",
	},
	["... by angle°"]={
		pl="... według kąta°",
		jp="。。角度によって",
		id=""
	},
	["... around ~i~(lred)X~r Axis"]={
		pl="... dookoła Osi ~i~(lred)X~r",
		jp="。。~i~(lred)Ｘ~rの軸を中心に",
		id="",
	},
	["... around ~i~(lgreen)Y~r Axis"]={
		pl="... dookoła Osi ~i~(lgreen)Y~r",
		jp="。。~i~(lgreen)Ｙ~rの軸を中心に",
		id="",
	},
	["... around ~i~(lblue)Z~r Axis"]={
		pl="... dookoła Osi ~i~(lblue)Z~r",
		jp="。。~i~(lblue)Ｚ~rの軸を中心に",
		id="",
	},
	["Scale"]={
		pl="Zmien rozmiaj",
		jp="拡大縮小す",
		id="",
	},
	["Scale selection."]={
		pl="Zmien rozmiar.",
		jp="選択を拡大縮小する。",
		id=""
	},
	["~bReset"]={
		pl="~bZresetuj",
		jp="リセット",
		id="~bReset",
	},
	["Keybinds"]={
		pl="Ustawienia Klawiatury",
		jp="入力設定",
		id="Pintasan Keyboard",
	},
	["Set Language"]={
		pl="Zmień język",
		jp="言語を設定する",
		id="Atur Bahasa",
	},
	["~iAbout"]={
		pl="~iInformacja",
		jp="プログラムについて",
		id="~iTentang",
	},
	["~b~(red)Do not click the kappa."]={
		pl="~b~(red)Nie klikaj kappy.",
		jp="~b~(red)カッパを押すな",
		id="~b~(red)Jangan mengklik sang kappa",
	},
	["\nWelcome!\n\nMeoxSkins editor © 2025 \nMIT license (see LICENSE.md)"]={
		pl="\nWitam!\n\nMeoxSkins editor © 2025 \nMIT licencja\n(zobacz LICENSE.md)",
		jp="\n いらっしゃいませ！\n\nMeoxSkinsエディター(C) 2025\nMIT特許\n(LICENSE.mdをごらんなさい)",
		id="\nSelamat datang!\n\nMeoxSkins editor © 2025 \nMIT license (lihat LICENSE.md)",
	},
	["~bClose."]={
		pl="~bZamknij",
		jp="~b閉じる",
		id="~bTutup",
	},
	["Save"]={
		pl="Zapisz",
		jp="セーブ",
		id="Simpan"
	},
	["Open"]={
		pl="Otworz",
		jp="オーペン",
		id="Buka"
	},
	["~iQuit"]={
		pl="~iWyjdź",
		jp="~i出る",
		id="~iBerangkat"
	},
	["File"]={
		pl="Plik",
		jp="ファイル",
		id="File",
	},
	["Edit"]={
		pl="Edytuj",
		jp="変える",
		id="Edit",
	},
	["Help"]={
		pl="Pomoca",
		jp="介助",
		id="Bantuan",
	},
	["Import"]={
		pl="Importuj",
		jp="輸入する",
		id="",
	},
	["Delete"]={
		pl="Skasuj",
		jp="削除する",
		id="Hapus",
	},

	[" is part of an animated texture, can't be deleted."]={
		pl=" jest część animowanej tekstury, nie można usunąć.",
		jp="はアニメーションテクスチャの一部であり、削除できません。",
		id=""
	},
	[" is applied to the map mesh, can't be deleted."]={
		pl=" jest część siatka mapy, nie można usunąć.",
		jp="はマップのメッシュに付いてあります、削除できません。",
		id=""
	},

	["[Drop texture here]"]={
		pl="[Upuść teksture tutaj]",
		jp="[ここにテクスチャをドロップ]",
		id="",
	},
	["[Drop model here]"]={
		pl="[Upuść model tutaj]",
		jp="[ここにモデルをドロップ]",
		id="",
	},
	[" is not in src/img/ folder."]={
		pl=" nie jest w środku folderu src/img/.",
		jp=" は「src/img/」ディレクトリ内にはありません。",
		id=""
	},
	[" is not in src/models/ folder."]={
		pl=" nie jest w środku folderu src/models/.",
		jp=" は「src/models/」ディレクトリ内にはありません。",
		id=""
	},
	[" doesn't exist."]={
		pl=" nie istnieje.",
		jp=" は存在しません。",
		id=" tidak berada."
	},
	[" failed to open."]={
		pl=" nie udało się otworzyć.",
		jp=" を開くことできませんでした。",
		id=" gagal untuk dibuka."
	},
	["Place model"]={
		pl="Postaw model",
		jp="モデルを入れる",
		id="",
	},
	["... at ~(lpink)selection~r."]={
		pl="... na ~(lpink)selekcji~r.",
		jp="。。~(lpink)選択~rの上に",
		id="",
	},
	["... at world origin."]={
		pl="... na początek świata.",
		jp="。。世界の原点に",
		id="",
	},

	["Type in new name."]={
		pl="Wpisz nowy imie.",
		jp="名前を新しく入力してください。",
		id="Ketik nama baru."
	},
	["Cancel"]={
		pl="Anuluj",
		jp="キャンセル",
		id="Batal"
	},
	["~bCommit"]={
		pl="~bZrub",
		jp="~bコミット",
		id="~bLakukan"
	},

	["Move"]={
		pl="Przesun",
		jp="動かす",
		id="Pindah"
	},
	["Locally"]={
		pl="Lokalnie",
		jp="地域的",
		id="",
	},
	["Globally"]={
		pl="Globalnie",
		jp="大域的",
		id=""
	},
	["Move selection."]={
		pl="Przesun selekcje.",
		jp="選択を動かす。",
		id=""
	},

	["Edit wall texture attributes."]={
		pl="Zmien atrybuty tekstury.",
		jp="テクスチャのプロパティを改める",
		id="",
	},
	["Edit tile texture attributes."]={
		pl="Zmien atrybuty tekstury.",
		jp="テクスチャのプロパティを改める",
		id="",
	},
	["Keep offset"]={
		pl="Zostaw offset",
		jp="位置を温存",
		id="",
	},
	["Keep scale"]={
		pl="Zostaw rozmiar",
		jp="規模を温存",
		id="",
	},
	["Flip ~(lred)~bX"]={
		pl="Odbij ~(lred)~bX",
		jp="~(lred)~bX~rで反転",
		id="",
	},
	["Flip ~(lgreen)~bY"]={
		pl="Odbij ~(lgreen)~bY",
		jp="~(lgreen)~bY~rで反転",
		id="",
	},
	["Enable global scaling."]={
		pl="Włącz globalny skalowanie",
		jp="大域的の拡大縮小",
		id="",
	},

	["~(red)%s~(red) is malformed."]={
		pl="~(red)%s~(red) jest błędny.",
		jp="~(red)%s~(red)の入力は無効です。",
		id=""
	},
	["~b~(red)Angle"]={
		pl="~b~(red)Kąt",
		jp="~b~(red)角度",
		id=""
	},

	["Skin type?"]={
		pl="Typ skinu?",
		jp="スキン型？",
		id="Jenis skin?"
	},
	["Slim"]={
		pl="Szczupły",
		jp="スリム",
		id="Langsing"
	},
	["Wide"]={
		pl="Szeroki",
		jp="ワイド",
		id="Lebar"
	},

	["default_group_name"]={
		eng="Group",
		pl ="Grupa",
		jp ="組",
		id ="",
	},

	["~(green)New layer"]={
		eng="~(green)New layer",
		pl ="~(green)Nowa warstwa",
		jp ="~(green)新しいレイヤー",
		id ="~(green)Lapisan baru",
	},
	["~bDelete layer"]={
		eng="~bDelete layer",
		pl ="~bUsuń warstwę",
		jp ="~bレイヤーを削除r",
		id ="~bHapus lapisan",
	},
	["Move layer up"]={
		eng="Move layer up",
		pl ="Przesuń warstwę w górę",
		jp ="レイヤーを上に移動",
		id ="Pindah lapisan ke atas",
	},
	["Move layer down"]={
		eng="Move layer down",
		pl ="Przesuń warstwę w dół",
		jp ="レイヤーを下に移動",
		id ="Pindah lapisan ke bawah",
	},
	["Slim/Wide mode"]={
		eng="Slim/Wide mode",
		pl ="Tryb wąski/szeroki",
		jp ="スリム・ワイドモード",
		id ="Mode langsing/lebar",
	},
	["Colour Picker"]={
		eng="Colour Picker",
		pl ="Próbnik Kolorów",
		jp ="カラーピッカー",
		id ="Pemilih Warna",
	},
	["Visible Parts"]={
		eng="Visible Parts",
		pl ="Widoczne Części",
		jp ="見える部分",
		id ="Bagian Terlihat",
	},
	["Filters"]={
		eng="Filters",
		pl ="Filtry",
		jp ="フィルタ",
		id ="Filter",
	},
	["Recent filters"]={
		eng="Recent filters",
		pl ="Ostatnie filtry",
		jp ="最近のフィルター",
		id ="Filter terbaru",
	},
	["Skin"]={
		eng="Skin",
		pl ="Skin",
		jp ="スキン",
		id ="Skin",
	},
	["Save as project"]={
		eng="Save as project",
		pl ="Zapisz jako projekt",
		jp ="プロジェクトとしてセーブ",
		id ="Simpan sebagai proyek",
	},
	["Key settings"]={
		eng="Key settings",
		pl ="Ustawienia klawiszy",
		jp ="キー設定",
		id ="Pintasan keyboard",
	},
	["Merge layer down"]={
		eng="Merge layer down",
		pl ="Scalić warstwę w dół",
		jp ="レイヤーを下にマージ",
		id ="Gabung lapisan ke bawah",
	},
	["Rename layer"]={
		eng="Rename layer",
		pl ="Zmień nazwę warstwy",
		jp ="レイヤの名前を変更",
		id ="Ganti nama lapisan",
	},
	["Change background colour"]={
		eng="Change background colour",
		pl ="Zmień kolor tła",
		jp ="背景色を変更",
		id ="Ubah warna latar",
	},
	["Toggle grid"]={
		eng="Toggle grid",
		pl ="Przełącz siatkę",
		jp ="グリッドの切り替え",
		id ="Alihkan kisi",
	},
	["Adjust HSL"]={
		eng="Adjust HSL",
		pl ="Dostosuj HSL",
		jp ="HSLを調整",
		id ="Sesuaikan HSL",
	},
	["Contrast/Brightness"]={
		eng="Contrast/Brightness",
		pl ="Kontrast/Jasność",
		jp ="コントラスト/明るさ",
		id ="Kontras/Kecerahan",
	},
	["Curves"]={
		eng="Curves",
		pl ="Paski",
		jp ="曲線",
		id ="Kurva",
	},
	["Invert (HSL)"]={
		eng="Invert (HSL)",
		pl ="Odwrotność (HSL)",
		jp ="色反転 (HSL)",
		id ="Balikkan (HSL)",
	},
	["Pose"]={
		eng="Pose",
		pl ="Poza",
		jp ="ポーズ",
		id ="Sikap",
	},
	["~b~(green)Confirm"]={
		eng="~b~(green)Confirm",
		pl ="~b~(green)Konfirmuj",
		jp ="~b~(green)はい",
		id ="~b~(green)Konfirmasi",
	},
	["Rename ~b\""]={
		eng="Rename ~b\"",
		pl ="Zmień nazwę ~b\"",
		jp ="名前を変更~b\"",
		id ="Ganti nama ~b\"",
	},
	["Gamma"]={
		eng="Gamma",
		pl ="Gamma",
		jp ="ガンマ",
		id ="Gamma",
	},
	["Preview"]={
		eng="Preview",
		pl ="Podgląd",
		jp ="プレビュー",
		id ="Pratinjau",
	},
	["Hue"]={
		eng="Hue",
		pl ="Hue",
		jp ="色彩",
		id ="Hue",
	},
	["Sat"]={
		eng="Sat",
		pl ="Sat",
		jp ="彩度",
		id ="Sat",
	},
	["Lum"]={
		eng="Lum",
		pl ="Lum",
		jp ="輝度",
		id ="Lum",
	},
	["Con"]={
		eng="Con",
		pl ="Kon",
		jp ="コン",
		id ="Kon",
	},
	[""]={
		eng="",
		pl ="",
		jp ="",
		id ="",
	},
	["Yaw"]={
		eng="Yaw",
		pl ="Yaw",
		jp ="ヨー",
		id ="Yaw",
	},
	["Pitch"]={
		eng="Pitch",
		pl ="Pitch",
		jp ="ピッチ",
		id ="Pitch",
	},
	["Roll"]={
		eng="Roll",
		pl ="Roll",
		jp ="ロール",
		id ="Roll",
	},
	["Head"]={
		eng="Head",
		pl ="Głowa",
		jp ="頭",
		id ="Kepala",
	},
	["Right arm"]={
		eng="Right arm",
		pl ="Prawe ramię",
		jp ="右腕",
		id ="Lengan kanan",
	},
	["Left arm"]={
		eng="Left arm",
		pl ="Lewe ramię",
		jp ="左腕",
		id ="Lengan kiri",
	},
	["Left leg"]={
		eng="Left arm",
		pl ="Lewe noga",
		jp ="左脚",
		id ="Kaki kiri",
	},
	["Right leg"]={
		eng="Right leg",
		pl ="Prawe noga",
		jp ="右脚",
		id ="Kaki kanan",
	},
	["R arm"]={
		eng="R arm",
		pl ="P ramię",
		jp ="右腕",
		id ="Lengan R",
	},
	["L arm"]={
		eng="L arm",
		pl ="L ramię",
		jp ="左腕",
		id ="Lengan L",
	},
	["L leg"]={
		eng="L arm",
		pl ="L noga",
		jp ="左脚",
		id ="Kaki L",
	},
	["R leg"]={
		eng="R leg",
		pl ="P noga",
		jp ="右脚",
		id ="Kaki R",
	},
	["Torso"]={
		eng="Torso",
		pl ="Tułów",
		jp ="胴体",
		id ="Batang Tubuh",
	},
	["Reset"]={
		eng="Reset",
		pl ="Reset",
		jp ="リセット",
		id ="Reset",
	},
	["Name is too long"]={
		eng="Name is too long",
		pl ="Nazwa jest za długa",
		jp ="名前が長すぎる",
		id ="Nama terlalu panjang",
	},
	["Name already exists"]={
		eng="Name already exists",
		pl ="Nazwa już istnieje",
		jp ="名前はすでに存在します",
		id ="Nama sudah ada",
	},
	["Changes background to the currently picked colour."]={
		eng="Changes background to the currently picked colour.",
		pl ="Zmien tło na aktualnie wybrany kolor",
		jp ="背景色を現在選択されている色に変更します",
		id ="Mengubah latar belakang ke warna yang saat ini dipilih.",
	},
	["Enable or disable the grid overlay."]={
		eng="Enable or disable the grid overlay.",
		pl ="Włącz lub wyłącz siatke.",
		jp ="グリッドを有効または無効にします。",
		id ="Aktifkan atau nonaktifkan kisi hamparan itu.",
	},
	["Change skin to have wide or slim arms."]={
		eng="Change skin to have wide or slim arms.",
		pl ="Zmień skórę, aby mieć szerokie lub szczupłe ramiona.",
		jp ="スキンを変更して腕を太くしたり細くしたりします。",
		id ="Mengubah skin agar memiliki lengan lebar atau langsing.",
	},
	["Change pose of limbs."]={
		eng="Change pose of limbs.",
		pl ="Zmień pozycję kończyn.",
		jp ="手足のポーズを変える。",
		id ="Mengubah posisi anggota badan.",
	},

	["Hide/Show"]={
		eng="Hide/Show",
		pl ="Ukryj/Pokaż",
		jp ="非表示/表示",
		id ="Sembunyi/Tampil",
	},

	["Erase Pixel"]={
		eng="Erase Pixel",
		pl ="Usuń Piksel",
		jp ="ピクセルを消去",
		id ="Hapus Piksel",
	},
	["Fill Face"]={
		eng="Fill Face",
		pl ="Wypełnij Twarz",
		jp ="面を塗りつぶす",
		id ="Isi Sisi",
	},
	["Pick Pixel Colour"]={
		eng="Pick Pixel Colour",
		pl ="Wybierz Kolor Piksela",
		jp ="ピクセルの色を選択",
		id ="Pilih Warna Piksel",
	},
	["Toggle Mirror"]={
		eng="Toggle Mirror",
		pl ="Przełącz Lustrzane Odbicie",
		jp ="鏡像切り替え",
		id ="Alihkan Cermin",
	},
	["Toggle Grid"]={
		eng="Toggle Grid",
		pl ="Przełącz Siatkę",
		jp ="グリッドの切り替え",
		id ="Alihkan kisi",
	},
	["Ignore Alpha Lock"]={
		eng="Ignore Alpha Lock",
		pl ="Zignoruj Blokadę Alfa",
		jp ="アルファロックを無視",
		id ="Abaikan Kunci Alfa",
	},
	["Hide/Show Overlay"]={
		eng="Hide/Show Overlay",
		pl ="Ukryj/Pokaż Nakładkę",
		jp ="オーバーレイを非表示/表示",
		id ="Sembunyi/Tampil Lapisan Atas",
	},
	["Language"]={
		eng="Language",
		pl ="Język",
		jp ="言語",
		id ="Bahasa",
	},


	["Recover autosaved project?"]={
		eng="Recover autosaved project?",
		pl ="Odzyskać automatycznie zapisany projekt?",
		jp ="自動保存されたプロジェクトを復元しますか？",
		id ="Memulihkan proyek yang disimpan otomatis?",
	},
	["~(green)~bYes"]={
		eng="~(green)~bYes",
		pl ="~(green)~bTak",
		jp ="はい",
		id ="~(green)~bIya",
	},
	["No"]={
		eng="No",
		pl ="Nie",
		jp ="いいえ",
		id ="Tidak",
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
