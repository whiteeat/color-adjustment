using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MergePreviewer))]
public class MergePreviewerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        MergePreviewer myScript = (MergePreviewer)target;
        if(GUILayout.Button("Switch Material"))
        {
            myScript.SwitchMaterial();
        }
    }
}
