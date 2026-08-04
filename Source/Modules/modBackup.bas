Attribute VB_Name = "modBackup"
Option Compare Database

Public Sub BackupCurrentDatabase(Optional ByVal KeepDays As Integer = 14)
    On Error GoTo ErrHandler
    
    Dim fso As Object
    Dim sourcePath As String
    Dim backupFolder As String
    Dim tempBackup As String
    Dim finalBackup As String
    Dim fileName As String
    Dim dt As String
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Path of the currently open database
    sourcePath = CurrentDb.Name
    
    ' Backup folder next to the database
    backupFolder = fso.GetParentFolderName(sourcePath) & "\Backup\"
    
    If Not fso.FolderExists(backupFolder) Then
        fso.CreateFolder backupFolder
    End If
    
    ' Build filenames
    fileName = fso.GetBaseName(sourcePath)
    dt = Format(Now, "yyyymmdd_hhnn")
    
    tempBackup = backupFolder & fileName & "_" & dt & "_temp." & fso.GetExtensionName(sourcePath)
    finalBackup = backupFolder & fileName & "_" & dt & "." & fso.GetExtensionName(sourcePath)
    
    ' 1. Copy the open database
    fso.CopyFile sourcePath, tempBackup, True
    
    ' 2. Compact the copy into the final backup file
    DBEngine.CompactDatabase tempBackup, finalBackup
    
    ' 3. Delete the temporary (uncompacted) copy
    fso.DeleteFile tempBackup
    
    MsgBox "Compacted backup created successfully:" & vbCrLf & vbCrLf & finalBackup, _
           vbInformation, "Backup Complete"
    
    ' Optional: clean up old backups
    Call DeleteOldBackups(backupFolder, KeepDays)
    
CleanUp:
    Set fso = Nothing
    Exit Sub
    
ErrHandler:
    MsgBox "Backup failed." & vbCrLf & vbCrLf & _
           "Error " & Err.Number & ": " & Err.Description, vbCritical, "Backup Error"
    
    ' Clean up temp file if it exists
    On Error Resume Next
    If fso.FileExists(tempBackup) Then fso.DeleteFile tempBackup
    Resume CleanUp
End Sub

Private Sub DeleteOldBackups(ByVal folderPath As String, ByVal KeepDays As Integer)
    On Error Resume Next
    Dim fso As Object, folder As Object, file As Object
    Dim cutoff As Date
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set folder = fso.GetFolder(folderPath)
    cutoff = Date - KeepDays
    
    For Each file In folder.Files
        If file.DateLastModified < cutoff Then
            file.Delete
        End If
    Next file
End Sub

