VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmImportSearchKings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cmdImportCSV_Click()
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim fso As Object
    Dim folder As Object
    Dim ts As Object
    Dim logTs As Object
    
    Dim inboxPath As String, processedPath As String, logsPath As String
    Dim logFileName As String
    Dim line As String, fields() As String
    Dim idValue As Long
    Dim recordsAdded As Long, duplicates As Long, filesProcessed As Long
    Dim sourceFileName As String, fullSourcePath As String
    Dim newFileName As String, newFullPath As String
    Dim leadDateValue As Date
    Dim sql As String
    Dim fileList As Collection
    Dim i As Long
    Dim rawID As String
    Dim phone As String
    Dim dept As String
    Dim file As Object
    '=== Paths ===
    inboxPath = CurrentProject.Path & "\Inbox\"
    processedPath = CurrentProject.Path & "\Processed\"
    logsPath = CurrentProject.Path & "\Logs\"
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FolderExists(inboxPath) Then fso.CreateFolder inboxPath
    If Not fso.FolderExists(processedPath) Then fso.CreateFolder processedPath
    If Not fso.FolderExists(logsPath) Then fso.CreateFolder logsPath
    
    '=== Start Log ===
    logFileName = logsPath & "ImportLog_" & Format(Now, "yyyymmdd_hhnnss") & ".txt"
    Set logTs = fso.CreateTextFile(logFileName, True)
    logTs.WriteLine "Search Kings Import Log - " & Now
    logTs.WriteLine String(70, "-")
    
    Set db = CurrentDb
    Set fileList = New Collection
    
    ' Collect CSV files first (avoids locking)
    Set folder = fso.GetFolder(inboxPath)
    For Each file In folder.Files
        If LCase(fso.GetExtensionName(file.Name)) = "csv" Then
            fileList.Add file.Path
        End If
    Next file
    
    recordsAdded = 0
    duplicates = 0
    filesProcessed = 0
    
    For i = 1 To fileList.Count
        fullSourcePath = fileList(i)
        sourceFileName = fso.GetFileName(fullSourcePath)
        
        logTs.WriteLine vbCrLf & "Processing file: " & sourceFileName
        filesProcessed = filesProcessed + 1
        
        Set ts = fso.OpenTextFile(fullSourcePath, 1)
        
        ' Skip header
        If Not ts.AtEndOfStream Then ts.ReadLine
        
        Do While Not ts.AtEndOfStream
            line = ts.ReadLine
            If Len(Trim(line)) = 0 Then GoTo NextLine
            
            fields = Split(line, ",")
            If UBound(fields) < 0 Then GoTo NextLine
            
            '----- ID -----
            rawID = SafeText(fields, 0)
            If Not IsNumeric(rawID) Or Len(rawID) = 0 Then
                logTs.WriteLine "  Skipped - invalid ID: " & fields(0)
                GoTo NextLine
            End If
            idValue = CLng(rawID)
            
            '----- Duplicate check -----
            sql = "SELECT leadId FROM tblTransProcess WHERE leadId = " & idValue
            Set rs = db.OpenRecordset(sql, dbOpenSnapshot)
            
            If Not rs.EOF Then
                duplicates = duplicates + 1
                logTs.WriteLine "  Duplicate skipped - ID: " & idValue
            Else
                Set rs = db.OpenRecordset("tblTransProcess", dbOpenDynaset)
                rs.AddNew
                
                rs!leadID = idValue
                
                ' Department mapping
                dept = LCase(SafeText(fields, 2))
                Select Case dept
                    Case "hvac"
                        rs!leadDept = "HVAC"
                    Case "plumber"
                        rs!leadDept = "PLUM"
                    Case "electrician"
                        rs!leadDept = "ELEC"
                    Case Else
                        rs!leadDept = UCase(dept)
                End Select
                
                rs!leadIsCharged = SafeBoolean(fields, 4)
                rs!leadCreditStatus = SafeText(fields, 5)   ' creditState
                
                ' Phone - clean to 10 digits
                phone = SafeText(fields, 8)

                ' Remove common junk characters
                phone = Replace(phone, "+", "")
                phone = Replace(phone, "-", "")
                phone = Replace(phone, "(", "")
                phone = Replace(phone, ")", "")
                phone = Replace(phone, " ", "")
                phone = Replace(phone, ".", "")

                ' Remove leading 1 if present (now that + is gone)
                If Left(phone, 1) = "1" And Len(phone) = 11 Then
                    phone = Mid(phone, 2)
                End If

                rs!leadPhoneNumber = phone
                
                rs!LeadCallDuration = SafeLong(fields, 14)
                
                ' Date/Time - convert UTC to Central
                leadDateValue = ConvertUTCtoCentral(SafeText(fields, 16))
                If leadDateValue > 0 Then
                    rs!leadDate = leadDateValue
                    rs!leadTime = leadDateValue   ' same value - display as time only
                End If
                
                rs!leadFeedbackSubmitted = SafeBoolean(fields, 17)
                
                ' System fields
                rs!leadSourceFile = sourceFileName
                rs!leadImportDateTime = Now
                rs!callReviewed = False
                rs!leadProcessed = False
                
                rs.Update
                recordsAdded = recordsAdded + 1
            End If
            rs.Close
NextLine:
        Loop
        
        ts.Close
        Set ts = Nothing
        
        ' Move file
        newFileName = Format(Now, "yyyymmdd") & "_" & sourceFileName
        newFullPath = processedPath & newFileName
        
        On Error Resume Next
        fso.MoveFile fullSourcePath, newFullPath
        If Err.Number <> 0 Then
            logTs.WriteLine "  WARNING: Could not move file - " & Err.Description
            Err.Clear
        Else
            logTs.WriteLine "  Moved to: " & newFileName
        End If
        On Error GoTo ErrHandler
    Next i
    
    ' Summary
    logTs.WriteLine vbCrLf & String(70, "-")
    logTs.WriteLine "SUMMARY"
    logTs.WriteLine "Files processed : " & filesProcessed
    logTs.WriteLine "Records added   : " & recordsAdded
    logTs.WriteLine "Duplicates      : " & duplicates
    logTs.WriteLine "Log saved to    : " & logFileName
    logTs.Close
    
    MsgBox "Import completed." & vbCrLf & vbCrLf & _
        "Files processed: " & filesProcessed & vbCrLf & _
        "Records added: " & recordsAdded & vbCrLf & _
        "Duplicates skipped: " & duplicates & vbCrLf & vbCrLf & _
        "Log: " & logFileName, vbInformation, "Search Kings Import"
    
CleanUp:
    On Error Resume Next
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set db = Nothing
    Set ts = Nothing
    Set logTs = Nothing
    Set fso = Nothing
    Set fileList = Nothing
    Exit Sub
    
ErrHandler:
    MsgBox "Error " & Err.Number & ": " & Err.Description, vbCritical, "Import Error"
    If Not logTs Is Nothing Then
        logTs.WriteLine "ERROR: " & Err.Description
        logTs.Close
    End If
    Resume CleanUp
End Sub

' ========== Helper Functions ==========

Private Function SafeText(fields() As String, index As Integer) As String
    On Error Resume Next
    If index <= UBound(fields) Then
        SafeText = Trim(Replace(fields(index), """", ""))
    Else
        SafeText = ""
    End If
End Function

Private Function SafeLong(fields() As String, index As Integer) As Long
    On Error Resume Next
    Dim v As String
    v = SafeText(fields, index)
    If IsNumeric(v) And Len(v) > 0 Then SafeLong = CLng(v) Else SafeLong = 0
End Function

Private Function SafeBoolean(fields() As String, index As Integer) As Boolean
    On Error Resume Next
    Dim v As String
    v = UCase(SafeText(fields, index))
    SafeBoolean = (v = "TRUE" Or v = "YES" Or v = "1")
End Function

Private Function ConvertUTCtoCentral(iso As String) As Date
    On Error Resume Next
    Dim utcDate As Date
    Dim centralDate As Date
    
    ' Example incoming: 2026-05-29T21:09:18.000Z
    If Len(iso) >= 19 Then
        utcDate = CDate(Left(iso, 10) & " " & Mid(iso, 12, 8))
        
        ' Simple UTC to Central conversion
        ' Central is UTC-6 (CST) or UTC-5 (CDT)
        ' For reliability we use a fixed -6 hours for now.
        ' (Can be improved later with proper DST handling if needed)
        centralDate = DateAdd("h", -6, utcDate)
        
        ConvertUTCtoCentral = centralDate
    Else
        ConvertUTCtoCentral = 0
    End If
End Function

