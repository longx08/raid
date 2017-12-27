--随机一条数据
function PickRandomData( t )
    if t == nil or type(t) ~= "table" then
        return nil
    end
    local result = t[RandomInt( 1, #t )] 
    return result
end

--复制
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-- 洗牌
function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

-- 计数
function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

-- 寻找key
function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end


--显示错误信息
function ShowError( PlayerID,msg )
	Notifications:ClearBottom(PlayerID)
	Notifications:Bottom(PlayerID,{text=msg,duration=3.0,style={color="red", ["font-size"]="40px", border="0px"}})
	-- body
end

--显示提示信息
function ShowTips( PlayerID,msg1,msg2,msg3 )
	Notifications:Bottom(PlayerID,{text=msg1, duration=2, style={color="#E0FFFF", ["font-size"]="40px", border="0px"}})
	if msg2 then
		Notifications:Bottom(PlayerID,{text=msg2, duration=2, style={color="#E0FFFF", ["font-size"]="40px", border="10px"},continue=true})
	end
	if msg3 then
		Notifications:Bottom(PlayerID,{text=msg3, duration=2, style={color="#E0FFFF", ["font-size"]="40px", border="0px"},continue=true})
	end
	-- body
end

--显示全局信息
function ShowAll( msg )
	Notifications:TopToAll({text=msg,duration=5.0,style={color="red", ["font-size"]="50px", border="0px"}})
	-- body
end