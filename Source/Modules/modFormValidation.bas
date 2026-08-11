Attribute VB_Name = "modFormValidation"
Option Compare Database
Option Explicit

'===============================================================================
' FormHasRecords
'
' Returns True when the form's underlying record source contains at least
' one record.
'
' Intended to be called from the form's Form_Open event.
'===============================================================================
Public Function FormHasRecords(ByVal frm As Form) As Boolean

    On Error GoTo ErrorHandler

    Dim rs As DAO.Recordset

    'A form with no RecordSource is not considered an error.
    'That allows unbound forms to open normally if this helper is
    'accidentally called.
    If Len(Trim$(Nz(frm.RecordSource, vbNullString))) = 0 Then
        FormHasRecords = True
        Exit Function
    End If

    Set rs = frm.RecordsetClone

    FormHasRecords = Not (rs.BOF And rs.EOF)

ExitProcedure:
    On Error Resume Next

    If Not rs Is Nothing Then
        rs.Close
        Set rs = Nothing
    End If

    Exit Function

ErrorHandler:
    MsgBox _
        "Unable to determine whether records are available for form '" & _
        frm.Name & "'." & _
        vbCrLf & vbCrLf & _
        "Record Source: " & GetFriendlyRecordSource(frm.RecordSource) & _
        vbCrLf & _
        "Error " & Err.Number & ": " & Err.Description, _
        vbExclamation, _
        "Record Check"

    'Safer behavior:
    'If we cannot verify the dataset, do not open the form.
    FormHasRecords = False

    Resume ExitProcedure

End Function


'===============================================================================
' NotifyNoRecords
'
' Displays the standard message when a data form contains no records.
'===============================================================================
Public Sub NotifyNoRecords(ByVal frm As Form)

    MsgBox _
        "There are currently no records available for this form." & _
        vbCrLf & vbCrLf & _
        "Record Source: " & GetFriendlyRecordSource(frm.RecordSource), _
        vbInformation, _
        "No Records Available"

End Sub


'===============================================================================
' GetFriendlyRecordSource
'
' Returns a friendly table/query name when possible.
' Avoids displaying a huge SQL statement to the user.
'===============================================================================
Private Function GetFriendlyRecordSource( _
    ByVal RecordSource As String) As String

    Dim sourceText As String

    sourceText = Trim$(Nz(RecordSource, vbNullString))

    If Len(sourceText) = 0 Then
        GetFriendlyRecordSource = "(none)"
        Exit Function
    End If

    If UCase$(Left$(sourceText, 6)) = "SELECT" Then
        GetFriendlyRecordSource = "(SQL statement)"
    Else
        GetFriendlyRecordSource = sourceText
    End If

End Function

