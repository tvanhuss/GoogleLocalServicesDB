Attribute VB_Name = "modImportOldCallsTable"
Public Sub AssignTempLeadIDs()

    On Error GoTo AssignTempLeadIDs_Error
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim nextID As Long
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT * FROM tbl_tmp_importedCalls ORDER BY leadDate, leadTime", dbOpenDynaset)
    
    nextID = 1001
    
    Do While Not rs.EOF
        rs.Edit
        rs!leadId = nextID
        rs.Update
        nextID = nextID + 1
        rs.MoveNext
    Loop
    
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    
    MsgBox "Lead IDs assigned successfully." & vbCrLf & _
        "IDs used: 1001 through " & (nextID - 1), vbInformation
    
    On Error GoTo 0
    Exit Sub

AssignTempLeadIDs_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure AssignTempLeadIDs, line " & Erl & "."

End Sub


