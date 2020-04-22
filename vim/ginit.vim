GuiTabline 0
GuiPopupmenu 0

if has("win32")
    try
        Guifont Cascadia\ Code:h10
    catch
        Guifont Consolas:h11
    endtry
else
    try
        Guifont Cascadia\ Code:h13
    catch
        Guifont Monaco:h11
    endtry
endif
