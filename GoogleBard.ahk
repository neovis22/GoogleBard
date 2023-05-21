/*
    by neovis
    
    Requires:
    https://github.com/neovis22/json
    
    Ported from:
    https://github.com/acheong08/Bard
*/

class GoogleBard {
    
    __New(session_id) {
        this.session_id := session_id
        Random _reqid, 1000, 9999
        this._reqid := _reqid
    }
    
    ask(message) {
        if (this.SNlM0e == "")
            this.SNlM0e := this.getSNlM0e()
        
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", "https://bard.google.com/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate"
            . "?bl=boq_assistant-bard-web-server_20230514.20_p0"
            . "&rt=c&_reqid=" this._reqid, true)
        this._reqid += 10000
        http.SetRequestHeader("Cookie", "__Secure-1PSID=" this.session_id)
        http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36")
        http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8")
        http.Send("at=" this.SNlM0e "&f.req=" this.encodeURIComponent(json_stringify([json_null(), json_stringify([[message], json_null(), [this.conversationId, this.responseId, this.choiceId]])])))
        http.WaitForResponse()
        
        body := http.responseBody
        DllCall("oleaut32\SafeArrayAccessData", "ptr",ComObjValue(body), "ptrp",pdata)
        text := StrGet(pdata, body.MaxIndex()+1, "utf-8")
        DllCall("oleaut32\SafeArrayUnaccessData", "ptr",ComObjValue(body))
        if (!data := json_parse(StrSplit(text, "`n")[4])[1][3])
            throw Exception("Google Bard Error: " text)
        data := json_parse(data)
        
        res := {
        (Join, LTrim
            "content": data[1][1]
            "conversationId": data[2][1]
            "responseId": data[2][2]
            "factualityQueries": data[4]
            "textQuery": data[3][1]
            "choices": choices := []
        )}
        for i, v in data[5]
            choices.Push({"id": v[1], "content": v[2]})
        
        this.conversationId := res["conversationId"]
        this.responseId := res["responseId"]
        this.choiceId := res["choices"][1]["id"]
        return res
    }
    
    getSNlM0e() {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", "https://bard.google.com", true)
        http.SetRequestHeader("Cookie", "__Secure-1PSID=" this.session_id)
        http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36")
        http.Send()
        http.WaitForResponse()
        
        body := http.responseBody
        DllCall("oleaut32\SafeArrayAccessData", "ptr",ComObjValue(body), "ptrp",pdata)
        text := StrGet(pdata, body.MaxIndex()+1, "utf-8")
        DllCall("oleaut32\SafeArrayUnaccessData", "ptr",ComObjValue(body))
        if (RegExMatch(text, """SNlM0e"":""(.*?)""", m))
            return m1
        
        throw Exception("Google Bard Error: SNlM0e")
    }
    
    encodeURIComponent(uri, encoding="utf-8") {
        VarSetCapacity(buf, length := StrPut(uri, encoding)*(encoding = "utf-16" || encoding = "cp1200" ? 2 : 1)-1)
        StrPut(uri, &buf, length, encoding)
        loop % length
            res .= Chr(ch := NumGet(buf, A_Index-1, "uchar")) ~= "[A-Za-z0-9\-_.!~*'()]" ? Chr(ch) : Format("%{:02X}", ch)
        return res
    }
}
