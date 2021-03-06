local cmd = "tar -xf"
local params = ".PKGINFO -O"
local output = ''
local filename = ''

local fields = {
    {"pkgname",   8,   "\npkgname = ([^\n]+)"}, 
    {"pkgver",    8,    "\npkgver = ([^\n]+)"}, 
    {"pkgdesc",   8,   "\npkgdesc = ([^\n]+)"}, 
    {"url",       8,       "\nurl = ([^\n]+)"}, 
    {"packager",  8,  "\npackager = ([^\n]+)"},  
    {"license",   8,   "\nlicense = ([^\n]+)"}, 
    {"builddate", 8, "\nbuilddate = ([^\n]+)"},  
    {"size",      2,      "\nsize = ([^\n]+)"}, 
    {"conflict",  8,  "\nconflict = ([^\n]+)"}, 
    {"provides",  8,  "\nprovides = ([^\n]+)"},  
    {"replaces",  8,  "\nreplaces = ([^\n]+)"}, 
    {"arch",      7,      "\narch = ([^\n]+)"}, 
    {"raw",       8,                "(.+)\n$"}, 
}

function ContentGetSupportedField(Index)
    if (fields[Index + 1] ~= nil ) then
        if (fields[Index + 1][1] == "arch") then
            return fields[Index + 1][1], "x86_64|i686|arm|armv6h|armv6h|aarch64|aarch64", fields[Index + 1][2];
        else
            return fields[Index + 1][1], "", fields[Index + 1][2];
        end
    end
    return '', '', 0; -- ft_nomorefields
end

function ContentGetDetectString()
    return 'EXT="XZ"';
end

function ContentGetValue(FileName, FieldIndex, UnitIndex, flags)
    if (FileName:find("%.pkg%.tar%.xz$") == nil) then
        return nil;
    end
    if (filename ~= FileName) then
        local attr = SysUtils.FileGetAttr(FileName);
        if (attr < 0) or (math.floor(attr / 0x00000004) % 2 ~= 0) or (math.floor(attr / 0x00000010) % 2 ~= 0) then
            return nil;
        end
        local handle = io.popen(cmd .. ' "' .. FileName .. '" ' .. params, 'r');
        output = handle:read("*a");
        handle:close();
        filename = FileName;
        if (output == '') or (output == nil) then 
            return nil;
        end
    end
    if (output ~= nil) then
        local result = output:match(fields[FieldIndex + 1][3]);
        if (fields[FieldIndex + 1][1] == "builddate") then
            if (result ~= nil) then
                return os.date("%c", tonumber(result));
            end
        else
            return result;
        end
    end
    return nil; -- invalid
end