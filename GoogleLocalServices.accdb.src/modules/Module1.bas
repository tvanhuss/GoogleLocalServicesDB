Attribute VB_Name = "Module1"
Option Compare Database
Option Explicit

Sub OpenDashboard()


    'Purpose    : Creates Excel object and opens excel dashboard
    'Author     :Terry Van Huss
    'Description:
    'Date       : 06/19/2024
   On Error GoTo HandleError

   Application.TempVars.Add "DatabasePath", CurrentProject.Path
   Dim strFilePath As String
   strFilePath = TempVars!DatabasePath + "\" + "Dashboard.xlsx"
    Dim MyXL As Object

    Set MyXL = CreateObject("Excel.application")
    With MyXL
      .Application.Visible = True
      .Workbooks.Open strFilePath
   End With
   TempVars.RemoveAll
HandleExit:
    Exit Sub
HandleError:
    MsgBox Err.Description
    Resume HandleExit

End Sub
