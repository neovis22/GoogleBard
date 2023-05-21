#NoEnv
#SingleInstance Force

SetBatchLines -1

#Include GoogleBard.ahk

session_id := "" ; __Secure-1PSID cookie

bard := new GoogleBard(session_id)

Gui New
Gui Font,, Segoe UI
Gui Add, Edit, w500 r20 ReadOnly hwndhChat
Gui Add, Edit, w420 vmessage
Gui Add, Button, x+ yp-1 w80 hp2 Default gask, Send
Gui Show,, Google Bard
GuiControl Focus, message
return

ask(hCtrl) {
    global bard, hChat
    GuiControlGet message
    GuiControl,, message
    GuiControl Disable, % hCtrl
    editAppendText(hChat, "User> " message "`r`n")
    try
        answer := bard.ask(message).content
    catch err
        answer := "Error: " err.message
    editAppendText(hChat, "Bard> " answer "`r`n")
    GuiControl Enable, % hCtrl
}

editAppendText(hwnd, text) {
    DllCall("SendMessage", "ptr",hwnd, "uint",0xB1, "uptr",-1, "ptr",-1)
    DllCall("SendMessage", "ptr",hwnd, "uint",0xC2, "uptr",false, "str",text)
}