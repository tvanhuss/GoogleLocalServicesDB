VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmCallSourceReview"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Function JsonEscape(ByVal text As String) As String
    Dim result As String
    result = text
    result = Replace(result, "\", "\\")
    result = Replace(result, """", "\""")
    result = Replace(result, vbCrLf, "\n")
    result = Replace(result, vbCr, "\n")
    result = Replace(result, vbLf, "\n")
    result = Replace(result, vbTab, "\t")
    JsonEscape = result
End Function

Private Function ExtractJsonValue(json As String, key As String) As String
    On Error Resume Next
    Dim startPos As Long, endPos As Long, searchFor As String
    
    searchFor = """" & key & """:"
    startPos = InStr(1, json, searchFor, vbTextCompare)
    
    If startPos = 0 Then
        ExtractJsonValue = ""
        Exit Function
    End If
    
    startPos = startPos + Len(searchFor)
    
    ' Skip spaces and quotes
    Do While Mid(json, startPos, 1) = " " Or Mid(json, startPos, 1) = """"
        startPos = startPos + 1
    Loop
    
    If LCase(Mid(json, startPos, 4)) = "true" Then
        ExtractJsonValue = "true"
        Exit Function
    ElseIf LCase(Mid(json, startPos, 5)) = "false" Then
        ExtractJsonValue = "false"
        Exit Function
    End If
    
    endPos = InStr(startPos, json, """")
    If endPos = 0 Then endPos = InStr(startPos, json, ",")
    If endPos = 0 Then endPos = InStr(startPos, json, "}")
    
    ExtractJsonValue = Trim(Mid(json, startPos, endPos - startPos))
    ExtractJsonValue = Replace(ExtractJsonValue, """", "")
End Function

Private Sub cmdAccept_Click()
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim leadID As Long
    
    If Len(Me!txtSelectedID & "") = 0 Then
        MsgBox "No record selected.", vbExclamation
        Exit Sub
    End If
    
    leadID = CLng(Me!txtSelectedID)
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tblTransProcess WHERE leadId = " & leadID, dbOpenDynaset)
    
    If rs.EOF Then
        MsgBox "Record not found.", vbExclamation
        GoTo CleanUp
    End If
    
    rs.Edit
    rs!leadName = Me!txtName
    rs!leadAddress = Me!txtAddress
    rs!leadCity = Me!txtCity
    rs!leadSt = Me!txtState
    rs!leadZip = Me!txtZip
    rs!leadEmailAddress = Me!txtEmail
    rs!leadNotes = Me!txtWorkNeeded
    rs!leadCallStatus = Me!cboCallStatus
    rs!callDisputeRecommended = Me!chkDispute
    rs!callDisputeReason = Me!txtDisputeReason
    rs!callAIConfidence = Val(Me!txtConfidence & "")
    rs!callTranscript = Me!txtTranscript
    rs!callAIResponseRaw = Me.Tag
    rs!callReviewed = True
    rs!callReviewedDate = Now
    
    If Len(Me!txtPhone & "") >= 10 Then
        rs!leadPhoneNumber = Replace(Replace(Replace(Replace(Me!txtPhone, "(", ""), ")", ""), "-", ""), " ", "")
    End If
    
    rs.Update
    rs.Close
    
    MsgBox "Record updated successfully.", vbInformation
    
    Me!frmSubCallSourceReview.Requery
    
    ' Clear form
    Me!txtTranscript = ""
    Me!txtName = ""
    Me!txtAddress = ""
    Me!txtCity = ""
    Me!txtState = ""
    Me!txtZip = ""
    Me!txtPhone = ""
    Me!txtEmail = ""
    Me!txtWorkNeeded = ""
    Me!cboCallStatus = Null
    Me!chkDispute = False
    Me!txtDisputeReason = ""
    Me!txtConfidence = ""
    Me!txtSelectedID = ""
    Me!txtSelectedPhone = ""
    Me!txtSelectedDate = ""
    Me!txtSelectedDept = ""
    Me.Tag = ""
    
CleanUp:
    Set rs = Nothing
    Set db = Nothing
    Exit Sub
    
ErrHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    Resume CleanUp
End Sub

Private Sub cmdAnalyzeAI_Click()
    On Error GoTo ErrHandler
    
    Dim http As Object
    Dim url As String
    Dim apiKey As String
    Dim body As String
    Dim response As String
    Dim transcript As String
    Dim systemPrompt As String
    Dim userContent As String
    Dim jsonText As String
    Dim testValue As Variant
    Dim contentStart As Long, contentEnd As Long
    Dim rawContent As String
    
    transcript = Trim(Me!txtTranscript & "")
    
    If Len(transcript) < 20 Then
        MsgBox "Please paste a transcript first.", vbExclamation
        Exit Sub
    End If
    
    If Len(Me!txtSelectedID & "") = 0 Then
        MsgBox "Please select a record from the list first.", vbExclamation
        Exit Sub
    End If
    
    ' Get API Key
    testValue = DLookup("SettingValue", "tblSettings", "SettingName = 'xai_api_key'")
    If IsNull(testValue) Then
        MsgBox "API key not found in tblSettings.", vbCritical
        Exit Sub
    End If
    apiKey = CStr(testValue)
    
    url = "https://api.x.ai/v1/chat/completions"
    
    systemPrompt = "You are an expert at analyzing call transcripts for a home services company (HVAC, Plumbing, Electrical) that uses Google Local Services. " & _
                   "Extract the following information and return ONLY valid JSON in this exact structure: " & _
                   "{""CustomerName"":"""",""Address"":"""",""City"":"""",""State"":"""",""Zip"":"""",""Phone"":"""",""Email"":"""",""WorkNeeded"":"""",""CallStatus"":""Booked"",""DisputeRecommended"":false,""DisputeReason"":"""",""Confidence"":85}. " & _
                   "Rules for CallStatus (use exactly one): Booked, Lost, Quoted, Voicemail, Other. " & _
                   "Dispute Rules - recommend true only for: Spam/robocall/solicitation, Wrong number, Existing customer follow-up (not a new lead), Extremely short call with no conversation, Caller clearly outside service area. " & _
                   "Do NOT recommend dispute just because the customer did not book. Return only the JSON. No extra text."
    
    userContent = JsonEscape(transcript)
    systemPrompt = JsonEscape(systemPrompt)
    
    body = "{" & _
           """model"": ""grok-4.5""," & _
           """messages"": [" & _
           "{""role"": ""system"", ""content"": """ & systemPrompt & """}," & _
           "{""role"": ""user"", ""content"": """ & userContent & """}" & _
           "]," & _
           """temperature"": 0.2" & _
           "}"
    
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    http.Open "POST", url, False
    http.setRequestHeader "Content-Type", "application/json"
    http.setRequestHeader "Authorization", "Bearer " & apiKey
    http.send body
    
    If http.Status <> 200 Then
        MsgBox "API Error " & http.Status & vbCrLf & Left(http.responseText, 1000), vbCritical
        GoTo CleanUp
    End If
    
    response = http.responseText
    
    ' Extract the content
    contentStart = InStr(response, """content"":""")
    If contentStart = 0 Then
        MsgBox "Could not find content in the response." & vbCrLf & Left(response, 800), vbExclamation
        GoTo CleanUp
    End If
    
    contentStart = contentStart + Len("""content"":""")
    contentEnd = InStr(contentStart, response, """,""reasoning_content""")
    If contentEnd = 0 Then contentEnd = InStr(contentStart, response, """,""refusal""")
    If contentEnd = 0 Then contentEnd = InStr(contentStart, response, """},")
    
    rawContent = Mid(response, contentStart, contentEnd - contentStart)
    rawContent = Replace(rawContent, "\n", "")
    rawContent = Replace(rawContent, "\""", """")
    rawContent = Replace(rawContent, "\\", "\")
    
    jsonText = rawContent
    
    ' Fill the fields
    Me!txtName = ExtractJsonValue(jsonText, "CustomerName")
    Me!txtAddress = ExtractJsonValue(jsonText, "Address")
    Me!txtCity = ExtractJsonValue(jsonText, "City")
    Me!txtState = ExtractJsonValue(jsonText, "State")
    Me!txtZip = ExtractJsonValue(jsonText, "Zip")
    Me!txtPhone = ExtractJsonValue(jsonText, "Phone")
    Me!txtEmail = ExtractJsonValue(jsonText, "Email")
    Me!txtWorkNeeded = ExtractJsonValue(jsonText, "WorkNeeded")
    Me!cboCallStatus = ExtractJsonValue(jsonText, "CallStatus")
    Me!chkDispute = (LCase(ExtractJsonValue(jsonText, "DisputeRecommended")) = "true")
    Me!txtDisputeReason = ExtractJsonValue(jsonText, "DisputeReason")
    Me!txtConfidence = ExtractJsonValue(jsonText, "Confidence")
    
    Me.Tag = jsonText
    
    MsgBox "AI analysis complete. Please review and edit if needed, then click Accept.", vbInformation
    
CleanUp:
    Set http = Nothing
    Exit Sub
    
ErrHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical
    Resume CleanUp
End Sub

Private Sub Command48_Click()
Dim txtValue As String
    
    ' 1. Get the text value from your text box
    txtValue = Me.txtSelectedDate.text
    
    ' 2. Copy the text string to the Windows Clipboard
    With CreateObject("New:{1C3B4210-F441-11CE-B9EA-00AA006B1A69}")
        .SetText txtValue
        .PutInClipboard
    End With
    
    MsgBox "Text successfully copied to clipboard!", vbInformation
End Sub
