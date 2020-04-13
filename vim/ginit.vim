if has("win32")
    GuiTabline 0
    GuiPopupmenu 0

    try
        Guifont Cascadia\ Code:h10
    catch
        Guifont Consolas:h11
    endtry
endif
