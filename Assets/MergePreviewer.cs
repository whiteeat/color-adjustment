using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

[ExecuteInEditMode]
public class MergePreviewer : MonoBehaviour
{
    public enum RenderState
    {
        UseMaterialToMerge,
        UseMaterialToRender
    }

    private RenderState currentState = RenderState.UseMaterialToMerge;

    public Material materialToRenderTemplate;
    private Material materialToMerge;
    private Renderer rend;

    private void Awake()
    {
        rend = GetComponent<Renderer>();
        materialToMerge = rend.sharedMaterial;
    }

    // Start is called before the first frame update
    void Start()
    {
        //Assert.IsNotNull(materialToRenderTemplate);
        //Texture2D mainTex = MergeTextures(materialToMerge);
        //Material materialToRender = new Material(materialToRenderTemplate);
        //materialToRender.mainTexture = mainTex;
        //rend.sharedMaterial = materialToRender;
    }

    public void SwitchMaterial()
    {
        if (currentState == RenderState.UseMaterialToMerge)
        {
            Assert.IsNotNull(materialToRenderTemplate);
            Texture2D mainTex = MergeTextures(materialToMerge);
            Material materialToRender = new Material(materialToRenderTemplate);
            materialToRender.mainTexture = mainTex;
            rend.sharedMaterial = materialToRender;
            currentState = RenderState.UseMaterialToRender;
        }
        else
        {
            Material materialToRender = rend.sharedMaterial;
            rend.sharedMaterial = materialToMerge;
            // DestroyImmediate(materialToRender.mainTexture);
            // DestroyImmediate(materialToRender);
            currentState = RenderState.UseMaterialToMerge;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnDestroy()
    {
        print("I'm destroyed!");
    }

    public Texture2D MergeTextures(Material mat)
    {
        Texture texture = mat.mainTexture;

        int width = texture.width;
        int height = texture.height;

        RenderTexture prevRT = RenderTexture.active;
        RenderTexture rt = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
        rt.autoGenerateMips = true;
        bool prevSRGB = GL.sRGBWrite;
        GL.sRGBWrite = true;

        Graphics.Blit(null, rt, mat);
        GL.sRGBWrite = prevSRGB;
        // Graphics.SetRenderTarget(rt);
        bool hasMip = true;

        Texture2D mainTex = new Texture2D(width, height, TextureFormat.RGB24, hasMip, false);
        mainTex.name = "mainTexture";
        mainTex.ReadPixels(new Rect(0, 0, width, height), 0, 0, false);
        mainTex.Apply(hasMip, false);

        RenderTexture.ReleaseTemporary(rt);
        RenderTexture.active = prevRT;

        return mainTex;
    }
}
