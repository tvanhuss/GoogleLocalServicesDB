Attribute VB_Name = "modSplashScreen"
Option Compare Database

Option Explicit

' 1. Get Current Windows Username
Public Function GetAccessUsername() As String
    GetAccessUsername = CreateObject("WScript.Network").UserName
End Function

' 2. Get Current Database Directory Path
Public Function GetProjectFolder() As String
    GetProjectFolder = CurrentProject.Path
End Function

' 3. Get Detailed Attached Tables Information
Public Function GetAttachedTablesInfo() As String
    Dim db As DAO.Database
    Dim tdf As DAO.TableDef
    Dim result As String
    
    Set db = CurrentDb
    result = "--- Attached Tables ---" & vbCrLf
    
    For Each tdf In db.TableDefs
        ' Check if the table is a linked/attached table
        If (tdf.Attributes And dbAttachedTable) Or (tdf.Attributes And dbAttachSavePWD) Then
            result = result & "Table: " & tdf.Name & vbCrLf & _
                      "Source: " & tdf.Connect & vbCrLf & vbCrLf
        End If
    Next tdf
    
    If result = "--- Attached Tables ---" & vbCrLf Then
        result = result & "No attached tables found."
    End If
    
    GetAttachedTablesInfo = result
End Function

