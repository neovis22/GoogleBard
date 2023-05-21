#NoEnv
#SingleInstance Force

SetBatchLines -1

#Include GoogleBard.ahk

session_id := "" ; __Secure-1PSID cookie

bard := new GoogleBard(session_id)

res := bard.ask("오토핫키로 계산기만드는 코드를 작성해줘")
MsgBox % res.content
