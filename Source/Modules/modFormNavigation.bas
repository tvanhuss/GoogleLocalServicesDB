Attribute VB_Name = "modFormNavigation"
Option Compare Database
Option Explicit

Private Const NAV_TEMPVAR_PREFIX As String = "TVH_Parent_"

'===============================================================================
' OpenChildForm
'
' Opens a child form and hides the calling parent form ONLY if the child
' successfully opens.
'
' Works for both:
'   - normal/menu forms that always open
'   - data forms that may cancel themselves in Form_Open
'===============================================================================
Public Sub OpenChildForm( _
    ByVal ChildFormName As String, _
    ByVal ParentForm As Form, _
    Optional ByVal WhereCondition As String = vbNullString)

    On Error GoTo ErrorHandler

    Dim TempVarName As String

    TempVarName = NAV_TEMPVAR_PREFIX & ChildFormName

    'Remove an existing navigation value if one exists.
    RemoveTempVarIfExists TempVarName

    'Remember which form opened this child.
    TempVars.Add TempVarName, ParentForm.Name

    'Attempt to open the child.
    If Len(WhereCondition) > 0 Then
        DoCmd.OpenForm _
            FormName:=ChildFormName, _
            View:=acNormal, _
            WhereCondition:=WhereCondition
    Else
        DoCmd.OpenForm _
            FormName:=ChildFormName, _
            View:=acNormal
    End If

    'Important:
    'Hide the parent ONLY if the child actually opened.
    '
    'If the child's Form_Open event set Cancel = True,
    'IsLoaded will be False and the parent remains visible.
    If CurrentProject.AllForms(ChildFormName).IsLoaded Then
        ParentForm.Visible = False
    Else
        RemoveTempVarIfExists TempVarName
    End If

ExitProcedure:
    Exit Sub

ErrorHandler:

    'If the form canceled its own Open event, this is an expected
    'condition (for example, because there are no records).
    '
    'The form itself has already notified the user, so do not
    'display a second error message.
    If Not CurrentProject.AllForms(ChildFormName).IsLoaded Then
        RemoveTempVarIfExists TempVarName
        Resume ExitProcedure
    End If

    RemoveTempVarIfExists TempVarName

    MsgBox _
        "The form '" & ChildFormName & "' could not be opened." & _
        vbCrLf & vbCrLf & _
        "Error " & Err.Number & ": " & Err.Description, _
        vbExclamation, _
        "Unable to Open Form"

    Resume ExitProcedure

End Sub


'===============================================================================
' RestoreParentForm
'
' Called when a child form closes.
' Makes the form that opened it visible again.
'===============================================================================
Public Sub RestoreParentForm(ByVal ChildFormName As String)

    On Error GoTo ErrorHandler

    Dim TempVarName As String
    Dim parentFormName As String

    TempVarName = NAV_TEMPVAR_PREFIX & ChildFormName

    If Not TempVarExists(TempVarName) Then
        Exit Sub
    End If

    parentFormName = Nz(TempVars(TempVarName).value, vbNullString)

    If Len(parentFormName) > 0 Then

        If CurrentProject.AllForms(parentFormName).IsLoaded Then
            Forms(parentFormName).Visible = True

            'Bring the parent back to the front.
            DoCmd.SelectObject acForm, parentFormName, False
        End If

    End If

    RemoveTempVarIfExists TempVarName

ExitProcedure:
    Exit Sub

ErrorHandler:
    RemoveTempVarIfExists TempVarName
    Resume ExitProcedure

End Sub


'===============================================================================
' TempVarExists
'===============================================================================
Private Function TempVarExists(ByVal TempVarName As String) As Boolean

    On Error Resume Next

    Dim value As Variant

    value = TempVars(TempVarName).value
    TempVarExists = (Err.Number = 0)

    Err.Clear

End Function


'===============================================================================
' RemoveTempVarIfExists
'===============================================================================
Private Sub RemoveTempVarIfExists(ByVal TempVarName As String)

    On Error Resume Next

    TempVars.Remove TempVarName

    Err.Clear

End Sub
