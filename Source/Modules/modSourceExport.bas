Attribute VB_Name = "modSourceExport"
Option Compare Database
Option Explicit

Public Sub ExportAllSource()
    On Error GoTo ErrorHandler

    Dim rootPath As String

    rootPath = CurrentProject.Path & "\..\Developer\Source"

    EnsureFolder rootPath
    EnsureFolder rootPath & "\Forms"
    EnsureFolder rootPath & "\Reports"
    EnsureFolder rootPath & "\Modules"
    EnsureFolder rootPath & "\Classes"
    EnsureFolder rootPath & "\Queries"
    EnsureFolder rootPath & "\Macros"

    ExportForms rootPath & "\Forms"
    ExportReports rootPath & "\Reports"
    ExportModules rootPath & "\Modules", rootPath & "\Classes"
    ExportQueries rootPath & "\Queries"
    ExportMacros rootPath & "\Macros"

    MsgBox "Source export completed successfully." & vbCrLf & _
           rootPath, vbInformation, "Export Complete"

ExitProcedure:
    Exit Sub

ErrorHandler:
    MsgBox "Source export failed." & vbCrLf & vbCrLf & _
           "Error " & Err.Number & ": " & Err.Description, _
           vbCritical, "Export Error"
    Resume ExitProcedure
End Sub

Private Sub ExportForms(ByVal destinationFolder As String)
    Dim obj As AccessObject

    For Each obj In CurrentProject.AllForms
        Application.SaveAsText _
            acForm, _
            obj.Name, _
            destinationFolder & "\" & SafeFileName(obj.Name) & ".txt"
    Next obj
End Sub

Private Sub ExportReports(ByVal destinationFolder As String)
    Dim obj As AccessObject

    For Each obj In CurrentProject.AllReports
        Application.SaveAsText _
            acReport, _
            obj.Name, _
            destinationFolder & "\" & SafeFileName(obj.Name) & ".txt"
    Next obj
End Sub

Private Sub ExportModules( _
    ByVal moduleFolder As String, _
    ByVal classFolder As String)

    Dim obj As AccessObject
    Dim componentType As Long
    Dim destinationPath As String

    For Each obj In CurrentProject.AllModules
        componentType = Application.VBE.ActiveVBProject _
            .VBComponents(obj.Name).Type

        Select Case componentType
            Case 1 ' vbext_ct_StdModule
                destinationPath = moduleFolder & "\" & _
                                  SafeFileName(obj.Name) & ".bas"

            Case 2 ' vbext_ct_ClassModule
                destinationPath = classFolder & "\" & _
                                  SafeFileName(obj.Name) & ".cls"

            Case Else
                destinationPath = moduleFolder & "\" & _
                                  SafeFileName(obj.Name) & ".txt"
        End Select

        Application.VBE.ActiveVBProject _
            .VBComponents(obj.Name).Export destinationPath
    Next obj
End Sub

Private Sub ExportQueries(ByVal destinationFolder As String)
    Dim qdf As DAO.QueryDef

    For Each qdf In CurrentDb.QueryDefs
        If Left$(qdf.Name, 1) <> "~" Then
            Application.SaveAsText _
                acQuery, _
                qdf.Name, _
                destinationFolder & "\" & _
                SafeFileName(qdf.Name) & ".txt"
        End If
    Next qdf
End Sub

Private Sub ExportMacros(ByVal destinationFolder As String)
    Dim obj As AccessObject

    For Each obj In CurrentProject.AllMacros
        Application.SaveAsText _
            acMacro, _
            obj.Name, _
            destinationFolder & "\" & _
            SafeFileName(obj.Name) & ".txt"
    Next obj
End Sub

Private Sub EnsureFolder(ByVal folderPath As String)
    If Len(Dir$(folderPath, vbDirectory)) = 0 Then
        MkDir folderPath
    End If
End Sub

Private Function SafeFileName(ByVal value As String) As String
    Dim invalidCharacters As Variant
    Dim item As Variant

    invalidCharacters = Array("\", "/", ":", "*", "?", """", "<", ">", "|")

    SafeFileName = value

    For Each item In invalidCharacters
        SafeFileName = Replace$(SafeFileName, CStr(item), "_")
    Next item
End Function

