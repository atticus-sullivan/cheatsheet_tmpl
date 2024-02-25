local function pr(...)
	-- uncomment the following line to see the emited code while compiling
	-- print(...)
	tex.print(...)
end

local _M = {}

-- emits the code for the content of a table holding the result of [n,m] multiplied by [n,m]
-- needs a table with at least m-n columns
function _M.einmaleins(n,m)
	for j=n,m do
		pr(string.format(
			[[& %d]],
			j
		))
	end
	pr([[\\ \hline]])
	for i=n,m do
		pr(string.format(
			[[%d &]],
			i
		))
		for j=n,m do
			pr(string.format(
				[[%d]],
				i*j
			))
			if j < m then pr("&") end
		end
		pr([[\\]])
	end
end

-- emits the code for the content of a table holding the result of 2^[n,m]
-- needs a table with at least m-n columns, only does one single row
function _M.zweierpot(n,m)
	for j=n,m do
		pr(string.format(
		[[$2^{%d}$]],
		j
		))
		if j < m then pr("&") end
	end
	pr([[\\ \hline]])
	for i=n,m do
		pr(string.format(
		[[%d]],
		2^i
		))
		if i < m then pr("&") end
	end
end

_M.ascii = {
	[000] = [[NUL]],
	[001] = [[SOH]],
	[002] = [[STX]],
	[003] = [[ETX]],
	[004] = [[EOT]],
	[005] = [[ENQ]],
	[006] = [[ACK]],
	[007] = [[BEL]],
	[008] = [[BS]],
	[009] = [[HT]],
	[010] = [[LF]],
	[011] = [[VT]],
	[012] = [[FF]],
	[013] = [[CR]],
	[014] = [[SO]],
	[015] = [[SI]],
	[016] = [[DLE]],
	[017] = [[DC1]],
	[018] = [[DC2]],
	[019] = [[DC3]],
	[020] = [[DC4]],
	[021] = [[NAK]],
	[022] = [[SYN]],
	[023] = [[ETB]],
	[024] = [[CAN]],
	[025] = [[EM]],
	[026] = [[SUB]],
	[027] = [[ESC]],
	[028] = [[FS]],
	[029] = [[GS]],
	[030] = [[RS]],
	[031] = [[US]],
	[032] = [[SPACE]],
	[127] = [[DEL]],
	-- tex escape
	[035] = [[\#]],
	[092] = [[\textbackslash]],
	[095] = [[\_]],
	[094] = [[\^{}]],
	[126] = [[\~{}]],
	[036] = [[\$]],
	[037] = [[\%]],
	[123] = [[\{]],
	[125] = [[\}]],
	[038] = [[\&]],
}

local function toAscii(x)
	return _M.ascii[x] or string.char(x)
	-- if _M.ascii[x] then
	-- 	return _M.ascii[x]
	-- else
	-- 	return string.char(x)
	-- end
end

-- emits the code for the content of a table holding the result of 2^[n,m]
-- needs a table with at least m-n columns, only does one single row
function _M.asciiTab(a, b, cols)
	local rows = math.floor((b-a)/cols)
	for j = 0, rows-1, 1 do
		local first = true
		for i = 0, cols-1, 1 do
			if not first then
				pr([[&]])
			end
			first = false
			local val = rows*i + j
			pr(string.format([[\texttt{%d} & \texttt{0x%02X} & \texttt{%s}]], val, val, toAscii(val)))
		end
		pr([[\\]])
	end
end

-- emits the code for the content of a conversion table between hexadecimal and decimal for the range a_10 to b_10 with cols=#columns
function _M.hexDec(a, b, cols)
	cols = 16
	for i = 0, cols-1, 1 do
		pr(string.format([[& \texttt{%X}]], i))
	end
	pr([[\\ \hline]])

	local rows = math.floor((b-a)/cols)
	for j = 0, rows-1, 1 do
		pr(string.format([[\texttt{%X}]], j))
		for i = 0, cols-1, 1 do
			local val = rows*j + i
			pr(string.format([[& \texttt{%03d}]], val))
		end
		pr([[\\]])
	end
end

-- emits the code for the content of an xor table between two hexadecimal digits with cols=#columns
function _M.xor(a, b, cols)
	cols = 16
	pr([[$\oplus$]])
	for i = 0, cols-1, 1 do
		pr(string.format([[& \texttt{%X}]], i))
	end
	pr([[\\ \hline]])

	local rows = math.floor((b-a)/cols)
	for j = 0, rows-1, 1 do
		pr(string.format([[\texttt{%X}]], j))
		for i = 0, cols-1, 1 do
			pr(string.format([[& \texttt{%X}]], i ~ j))
		end
		pr([[\\]])
	end
end

-- define new submodule for printing packet headers
_M.packet_header = {}
do
	-- shorten the module variable
	local _M = _M.packet_header

	_M.coll = {max=0}
	_M.sk = {set={}, map={}}

	-- reset all currently collected state
	function _M.reset()
		_M.coll = {max=0}
		_M.sk = {set={}, map={}}
	end

	local function draw(s,e, node,c1,c2,c3)
		local st = {row = _M.sk.map[s // 32+2], col = s % 32+1}
		local en = {row = _M.sk.map[e // 32+2], col = e % 32+1}
		if st.row ~= en.row then
			pr(string.format(
				[[\node[inner sep=0pt,fit=(row-%d -| col-%d)(row-%d -| col-%d)] (%s) {};]],
				st.row,1,
				en.row+1,33,
				node
			))
		else
			pr(string.format(
				[[\node[inner sep=0pt,fit=(row-%d -| col-%d)(row-%d -| col-%d)] (%s) {};]],
				st.row,st.col,
				en.row+1,en.col+1,
				node
			))
		end

		if st.row == en.row then
			pr(string.format(
				[[\draw (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]],
				st.row,st.col,
				en.row,en.col+1,
				en.row+1,en.col+1,
				st.row+1,st.col
			))
			if c1 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					st.row,st.col,
					st.row+1,st.col,
					en.row,en.col+1,
					en.row+1,en.col+1,
					c1
				))
			end
		elseif st.row == en.row -1 and st.col > en.col then
			pr(string.format(
				[[\draw (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]],
				st.row+1,33,
				st.row+1,st.col,
				st.row,st.col,
				st.row,33
			))
			pr(string.format(
				[[\draw (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]],
				en.row+1,1,
				en.row+1,en.col+1,
				en.row,en.col+1,
				en.row,1
			))
			if c1 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					st.row,st.col,
					st.row+1,st.col,
					st.row,33,
					st.row+1,33,
					c1
				))
			end
			if c2 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					en.row,en.col,
					en.row+1,en.col,
					en.row,1,
					en.row+1,1,
					c2
				))
			end
		else
				pr(string.format(
					[[\draw (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d)  -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]],
					st.row+1,1,
					st.row+1,st.col,
					st.row,st.col,
					st.row,33,

					en.row,33,
					en.row,en.col+1,
					en.row+1,en.col+1,
					en.row+1,1
				))

			if c1 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					st.row,st.col,
					st.row+1,st.col,
					st.row,33,
					st.row+1,33,
					c1
				))
			end
			if c2 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					en.row,en.col,
					en.row+1,en.col,
					en.row,1,
					en.row+1,1,
					c2
				))
			end
			if c3 and st.row > en.row -1 then
				pr(string.format(
					[[\draw let \p1 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$), \p2 = ($(row-%d -| col-%d)!0.5!(row-%d -| col-%d)$) in ($(\p1)!0.5!(\p2)$) node {%s};]],
					en.row,33,
					st.row+1,33,
					en.row,1,
					st.row+1,1,
					c3
				))
			end
		end
	end

	local cols = 32
	local function tab(rows, skipped_rows, mapping)
		pr([[\setlength{\tabcolsep}{\packetcolsep}]])
		pr(string.format([[\begin{NiceTabular}{*{%d}{c}}[]], cols))
		pr([[code-before = {]])
		pr([[\tikz{]])
		for c=1,cols do
			local e = rows-skipped_rows+2
			if c > _M.coll.max % cols+1 then e = e-1 end
			if c %2 == 1 then
				pr(string.format([[\fill[black!10] (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]], 1,c, e,c, e,c+1, 1,c+1))
			else
				pr(string.format([[\fill[black!20] (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- (row-%d -| col-%d) -- cycle;]], 1,c, e,c, e,c+1, 1,c+1))
			end
		end
		pr("}},")
		-- pr([[code-for-first-col = \ifnum 1<\value{iRow} \pgfmathparse{int((\value{iRow}-2)*4)}\footnotesize\pgfmathresult{} B\fi,]])
		pr([[first-col,]])
		pr("]")

		for c=0,cols-1 do
			pr(string.format([[& \parbox{1em}{\centering \scriptsize %d }]], c))
		end
		pr("\\\\")
		for r=1,rows+1 do
			if mapping[r] then
				pr(string.format(
					[[\footnotesize %dB\\]],
					(r-2)*4
				))
			end
		end

		pr([[\end{NiceTabular}]])
	end


	-- add header field. Arguments:
	-- - from: byte where to start this field
	-- - to: byte where to end this field
	-- - node: name of the node created by tikz (for further referencing)
	-- - c1: node content code to typeset in the field
	-- - c2: node content code for field if it spans multiple rows
	-- - c3: node content code for field if it spans multiple rows
	function _M.collect(from, to, node, c1,c2,c3)
		-- "sort" from and to arguments
		if from > to then
			local tmp = from
			from      = to
			to        = tmp
		end
		table.insert(_M.coll, {from,to, node,c1,c2,c3})
		if to > _M.coll.max then _M.coll.max = to end
	end

	-- skip rows between from and to
	function _M.skip(from, to)
		from = from // cols +1
		to = to // cols -1
		for i=from,to do
			_M.sk.set[i] = true
		end
	end

	-- draw the actual header -- the nicematrix part
	function _M.drawTab()
		local offset = 1
		for c=1,_M.coll.max // cols +1 do
			if _M.sk.set[c] then
				offset = offset - 1
			else
				_M.sk.map[c+1] = c + offset
			end
		end

		local rows = _M.coll.max // cols + 1
		local skipped_rows = 0
		for _,_ in pairs(_M.sk.set) do
			skipped_rows = skipped_rows + 1
		end
		tab(rows, skipped_rows, _M.sk.map)
	end

	-- draw the actual header -- the tikz part for borders
	-- place this inside
	-- \begin{tikzpicture}[remember picture, overlay, name prefix=nm-\NiceMatrixLastEnv-]
	-- and put any other tikz code referencing the nodes from nicematrix here too
	function _M.drawTikz()
		for _,e in ipairs(_M.coll) do
			draw(e[1], e[2], e[3],e[4],e[5],e[6])
		end
		for c=1,_M.coll.max // cols +1 do
			if not _M.sk.set[c-1] and _M.sk.set[c] then
				pr(string.format(
					[[\node[anchor=south] at (row-%d -| col-%d) {$\approx$};]],
					_M.sk.map[c-1]+2,33
				))
			end
		end
	end
end

return _M
