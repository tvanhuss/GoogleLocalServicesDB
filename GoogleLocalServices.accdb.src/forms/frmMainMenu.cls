Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit



Private Sub btnOpenDashBoard_Click()
    'Purpose    :
    'Author     :
    'Description:
    'Date       : 18Jun24
    On Error GoTo HandleError
    OpenDashboard

HandleExit:
    Exit Sub
HandleError:
    MsgBox Err.Description
    Resume HandleExit

End Sub

Private Sub cmdFrmUpdateLeadCharge_Click()
' ------------------------------------------------------
' Name: Form_frmMainMenu
' Kind: VBA Document
' Purpose:
' Author: Terry Van Huss
' Date: 1/14/2025
' ------------------------------------------------------


    On Error GoTo cmdFrmUpdateLeadCharge_Click_Error
    DoCmd.OpenForm "frmUpdateLeadCharge", acNormal, , , , acWindowNormal

    On Error GoTo 0
    Exit Sub

cmdFrmUpdateLeadCharge_Click_Error:

    MsgBox "Error " & Err.Number & " (" & Err.Description & ") in procedure cmdFrmUpdateLeadCharge_Click, line " & Erl & "."

End Sub

Private Sub Form_Load()

    'Purpose    :
    'Author     :Terry Van Huss
    'Description:
    'Date       : 06/19/2024
    On Error GoTo HandleError
      Application.TempVars.Add "UserName", Environ("Username")
      Application.TempVars.Add "ComputerName", Environ("Computername")
      Application.TempVars.Add "DatabasePath", CurrentProject.Path
      Dim strCaption As String
      strCaption = "User Name: " + TempVars!UserName + vbCrLf + "Computer: " + TempVars!ComputerName
      Me.lblEnvironment.Caption = strCaption

HandleExit:
    Exit Sub
HandleError:
    MsgBox Err.Description
    Resume HandleExit


End Sub
