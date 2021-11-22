local drawing = require("hs.drawing")
local screen = require("hs.screen")
local styledtext = require("hs.styledtext")

local statusmessage = {}

statusmessage.new = function(messageText)
    local buildParts = function(messageText)
        local frame = screen.primaryScreen():frame()

        local styledTextAttributes = { font = { name = "Monaco", size = 14 } }
        local styledText = styledtext.new("⊞ " .. messageText, styledTextAttributes)

        local styledTextSize = drawing.getTextDrawingSize(styledText)
        local textRect = {
            x = frame.w - styledTextSize.w - 40,
            y = frame.h - styledTextSize.h,
            w = styledTextSize.w + 40,
            h = styledTextSize.h + 40,
        }
        local text = drawing.text(textRect, styledText)

        local background = drawing.rectangle({
            x = frame.w - styledTextSize.w - 45,
            y = frame.h - styledTextSize.h - 3,
            w = styledTextSize.w + 15,
            h = styledTextSize.h + 6,
        })
        background:setRoundedRectRadii(6, 6)
        background:setFillColor({red = 1, green = 0.972549, blue = 0.905882, alpha = 0.9})

        return background, text
    end

    return {
        _buildParts = buildParts,
        show = function(self)
            self:hide()

            self.background, self.text = self._buildParts(messageText)
            self.background:show()
            self.text:show()
        end,
        hide = function(self)
            if self.background then
                self.background:delete()
                self.background = nil
            end
            if self.text then
                self.text:delete()
                self.text = nil
            end
        end,
        notify = function(self, seconds)
            seconds = seconds or 1
            self:show()
            hs.timer.delayed.new(seconds, function()
                self:hide()
            end):start()
        end,
    }
end

return statusmessage
