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

