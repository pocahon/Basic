Sub PseudonymizeData()
    
    Dim inputRange As Range
    Set inputRange = Application.InputBox("Select a range to pseudonymize", Type:=8)
    
    Dim cell As Range
    Dim dictionary As Object
    Set dictionary = CreateObject("Scripting.Dictionary")
    
    For Each cell In inputRange
        If cell.Value <> "" And Not dictionary.Exists(cell.Value) Then
            dictionary.Add cell.Value, "P" & (dictionary.Count + 1)
        End If
    Next cell
    
    For Each cell In inputRange
        If cell.Value <> "" Then
            cell.Value = dictionary(cell.Value)
        End If
    Next cell
    
End Sub
