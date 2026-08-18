Attribute VB_Name = "modSplashScreen"
Option Compare Database

Option Explicit

' 1. Get Current Windows Username
Public Function GetAccessUsername() As String

    On Error GoTo GetAccessUsername_Error
    GetAccessUsername = CreateObject("WScript.Network").UserName
    
    On Error GoTo 0
    Exit Function

GetAccessUsername_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure GetAccessUsername, line " & Erl & "."

End Function

' 2. Get Current Database Directory Path
Public Function GetProjectFolder() As String

    On Error GoTo GetProjectFolder_Error
    GetProjectFolder = CurrentProject.Path
    
    On Error GoTo 0
    Exit Function

GetProjectFolder_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure GetProjectFolder, line " & Erl & "."

End Function

' 3. Get Detailed Attached Tables Information
Public Function GetAttachedTablesInfo() As String

    On Error GoTo GetAttachedTablesInfo_Error
    Dim db As DAO.Database
    Dim tdf As DAO.TableDef
    Dim result As String
    
    Set db = CurrentDb
    result = "--- Attached Tables ---" & vbCrLf
    
    For Each tdf In db.TableDefs
        ' Check if the table is a linked/attached table
        If (tdf.Attributes And dbAttachedTable) Or (tdf.Attributes And dbAttachSavePWD) Then
            result = result & "Table: " & tdf.Name & vbCrLf & _
                "Source: " & tdf.Connect & vbCrLf
        End If
    Next tdf
    
    If result = "--- Attached Tables ---" & vbCrLf Then
        result = result & "No attached tables found."
    End If
    
    GetAttachedTablesInfo = result
    
    On Error GoTo 0
    Exit Function

GetAttachedTablesInfo_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure GetAttachedTablesInfo, line " & Erl & "."

End Function


