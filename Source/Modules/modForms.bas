Attribute VB_Name = "modForms"
Option Compare Database
Option Explicit


'=== Put this in a standard module (e.g. modUtilities) ===
Public Function OpenFormIfHasRecords(FormName As String, QueryName As String) As Boolean
    If DCount("*", QueryName) = 0 Then
        MsgBox "There are no records to display at this time." & vbCrLf & vbCrLf & _
               "Source: " & QueryName, vbInformation, "No Records"
        OpenFormIfHasRecords = False
    Else
        DoCmd.OpenForm FormName
        OpenFormIfHasRecords = True
    End If
End Function

Public Function CleanPhoneNumber(ByVal strPhone As String) As String
    Dim i As Long
    Dim strDigits As String
    Dim char As String
    
    strPhone = Trim(strPhone & "")
    strDigits = ""
    
    ' Keep only digits
    For i = 1 To Len(strPhone)
        char = Mid(strPhone, i, 1)
        If char >= "0" And char <= "9" Then
            strDigits = strDigits & char
        End If
    Next i
    
    ' If it's 11 digits and starts with 1, strip the leading 1
    If Len(strDigits) = 11 And Left(strDigits, 1) = "1" Then
        strDigits = Mid(strDigits, 2)
    End If
    
    CleanPhoneNumber = strDigits
End Function
