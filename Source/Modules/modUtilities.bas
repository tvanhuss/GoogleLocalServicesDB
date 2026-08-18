Attribute VB_Name = "modUtilities"
Option Compare Database

Option Explicit


Public Function ValidateMonthDateRange(ByVal StartDate As Variant, ByVal EndDate As Variant) As Boolean
    On Error GoTo Err_Handler
    
    ValidateMonthDateRange = False

    If Not IsDate(StartDate) Or Not IsDate(EndDate) Then
        MsgBox "Both Start Date and End Date are required.", vbExclamation, "Missing Dates"
        Exit Function
    End If

    ' Must be the 1st of the month
    If Day(StartDate) <> 1 Then
        MsgBox "Start Date must be the first day of the month.", vbExclamation, "Invalid Start Date"
        Exit Function
    End If

    ' End Date must be the last day of the same month
    If EndDate <> DateSerial(Year(StartDate), Month(StartDate) + 1, 0) Then
        MsgBox "End Date must be the last day of the same month as the Start Date.", vbExclamation, "Invalid End Date"
        Exit Function
    End If

    ' Must be at least 14 days old
    If EndDate > DateAdd("d", -14, Date) Then
        MsgBox "The selected month must be at least 14 days old." & vbCrLf & vbCrLf & _
            "You cannot process a month until 14 days after it ends.", vbExclamation, "Month Too Recent"
        Exit Function
    End If

    ValidateMonthDateRange = True
    Exit Function

Err_Handler:
    MsgBox "Date validation error: " & Err.Description, vbCritical
End Function


