local K_REJECT, K_ACCEPT, K_NOOP = 0, 1, 2

local kana = [[
ぁあぃいぅうぇえぉお
かがきぎくぐけげこご
さざしじすずせぜそぞ
ただちぢっつづてでとど
なにぬねの
はばぱひびぴふぶぷへべぺほぼぽ
まみむめも
ゃやゅゆょよ
らりるれろゎ
わゐゑをんゔ
ゕゖ゛゜ゝゞゟ
゙
゚
ァアィイゥウェエォオ
カガキギクグケゲコゴ
サザシジスズセゼソゾ
タダチヂッツヅテデトド
ナニヌネノ
ハバパヒビピフブプヘベペホボポ
マミムメモ
ャヤュユョヨ
ラリルレロ
ヮワヰヱヲンヴ
ヵヶヷヸヹヺ・ーヽヾヿ
･ｦｧｨｩｪｫｬｭｮｯ
ｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿ
ﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏ
ﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ
ㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿ
]]
kana = kana:gsub("\n", "")

local code4kana = {}
for _, code in utf8.codes(kana) do
	code4kana[code] = true
end

local function is_kanas(s)
	for _, code in utf8.codes(s) do
		if not code4kana[code] then
			return false
		end
	end

	return true
end

local P = {}

function P.init(env)
end

function P.fini(env)
end

function P.func(key, env)
	local context = env.engine.context
	local key_repr = key:repr()
	local commit_text = context:get_commit_text()

	local katakana = context:get_option('katakana')
	local kanji = context:get_option('kanji_mode')

	if not context:has_menu() or commit_text == "" then
		return K_NOOP
	end

	if key_repr == 'Alt_L' then
		if kanji then
			context:set_option('kanji_mode', false)
			context:set_option('katakana', false)
		else
			context:set_option('kanji_mode', true)
		end

		env.engine:commit_text(commit_text)
		context:clear()
		return K_ACCEPT
	end

	if key_repr == 'Alt_R' then
		if kanji then
			context:set_option('kanji_mode', false)
			context:set_option('katakana', true)
		elseif katakana then
			context:set_option('katakana', false)
		else
			context:set_option('katakana', true)
		end

		env.engine:commit_text(commit_text)
		context:clear()
		return K_ACCEPT
	end

	return K_NOOP
end

local F = {}

function F.init(env)
end

function F.func(input, env)
	if env.engine.context:get_option('kanji_mode') then
		for cand in input:iter() do
			if not is_kanas(cand.text) then yield(cand) end
		end
	else
		for cand in input:iter() do
			if is_kanas(cand.text) then yield(cand) end
		end
	end
end

return { proc=P, filter=F }
