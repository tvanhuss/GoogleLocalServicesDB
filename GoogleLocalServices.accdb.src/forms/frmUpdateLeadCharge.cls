Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cmdRunQuery_Click()
' ------------------------------------------------------
' Name: Form_frmUpdateLeadCharge
' Kind: VBA Document
' Purpose:
' Author: Terry Van Huss
' Date: 1/14/2025
' ------------------------------------------------------

    On Error GoTo cmdRunQuery_Click_Error
        DoCmd.OpenQuery "qryUpdateLeadCharge", acViewNormal

    On Error GoTo 0
    Exit Sub

cmdRunQuery_Click_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure cmdRunQuery_Click, line " & Erl & "."

End Sub

Private Sub cmdRunSelectQuery_Click()
' ------------------------------------------------------
' Name: Form_frmUpdateLeadCharge
' Kind: VBA Document
' Purpose:
' Author: Terry Van Huss
' Date: 1/14/2025
' ------------------------------------------------------


    On Error GoTo cmdRunSelectQuery_Click_Error

    DoCmd.OpenQuery "qrySelectUpDateCharge", acViewNormal


    On Error GoTo 0
    Exit Sub

cmdRunSelectQuery_Click_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure cmdRunSelectQuery_Click, line " & Erl & "."

End Sub
