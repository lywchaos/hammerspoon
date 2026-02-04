--- Xunfei Voice Input Toggle
--- Toggles Xunfei voice input while preserving/restoring the original input method

local M = {}

-- State
local isActive = false
local storedInputMethod = nil
local storedInputLayout = nil

-- Xunfei input method name
local XUNFEI_INPUT_METHOD = "讯飞输入法"

--- Trigger Xunfei voice input by simulating Ctrl+Fn
local function triggerXunfeiVoice()
    local keyDown = hs.eventtap.event.newKeyEvent({}, "fn", true)
    keyDown:setFlags({ctrl = true, fn = true})

    local keyUp = hs.eventtap.event.newKeyEvent({}, "fn", false)
    keyUp:setFlags({ctrl = false, fn = false})

    print("Triggering Xunfei voice input")
    keyDown:post()
    keyUp:post()
    print("Xunfei voice input triggered")
end

--- Toggle Xunfei voice input on/off
function M.toggle()
    if isActive then
        -- Cancel any pending voice-trigger from the activation path.
        if M._pendingVoiceTimer then
            M._pendingVoiceTimer:stop()
            M._pendingVoiceTimer = nil
        end
    end

    if not isActive then
        -- Activate: store input method/layout, switch to Xunfei, trigger voice, set flag
        storedInputMethod = hs.keycodes.currentMethod()
        storedInputLayout = storedInputMethod == nil and hs.keycodes.currentLayout() or nil
        hs.keycodes.setMethod(XUNFEI_INPUT_METHOD)
        print("Input method set to: " .. XUNFEI_INPUT_METHOD)
        isActive = true
        hs.alert.show("Xunfei ON")
        -- Wait for input method to switch before triggering voice.
        -- Keep a handle so we can cancel if the user toggles off quickly.
        M._pendingVoiceTimer = hs.timer.doAfter(0.5, function()
            M._pendingVoiceTimer = nil
            triggerXunfeiVoice()
        end)
    else
        -- Deactivate: restore input method/layout, clear flag
        if storedInputMethod then
            hs.keycodes.setMethod(storedInputMethod)
        elseif storedInputLayout then
            hs.keycodes.setLayout(storedInputLayout)
        end
        isActive = false
        storedInputMethod = nil
        storedInputLayout = nil
        hs.alert.show("Xunfei OFF")
    end
end

--- Bind the toggle to a hotkey
--- @param mods table Modifier keys (e.g., {"cmd", "shift", "option", "ctrl"})
--- @param key string The key to bind
function M.bind_hotkey(mods, key)
    hs.hotkey.bind(mods, key, M.toggle)
end

return M
