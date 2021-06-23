using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AverageLight : MonoBehaviour
{
    public Material hdrMat;
    public Material finalMat;
    public RenderTexture text;
    public float baseGamma;
    public float changeSpeed;
    private Texture2D text2;

    public float averageLum;
    private float accVal;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, hdrMat);
    }

    private void LateUpdate()
    {
        text2 = new Texture2D(16,16);
        RenderTexture.active = text;
        Rect sqr = new Rect(0,0, 16, 16);
        text2.ReadPixels(sqr,0,0);
        text2.Apply();
        RenderTexture.active = null;

        accVal = 0;
        float r;
        float g;
        float b;
        Color tempCol;
        tempCol = text2.GetPixel(0, 0);
        
        for (int x = 0; x < 16; x++)
        {
            for (int y = 0; y < 16; y++)
            {
                tempCol = text2.GetPixel(x, y);
                
                accVal += Vector3.Dot( new Vector3(tempCol.r,tempCol.g,tempCol.b), new Vector3(0.0396819152f, 0.458021790f, 0.00609653955f));
            }
        }

        averageLum = accVal / 256;
        float finalRes = Mathf.Lerp(finalMat.GetFloat("_Gamma"), Mathf.Clamp(baseGamma - averageLum, 0.18f, 0.6f), changeSpeed);
        finalMat.SetFloat("_Gamma", finalRes);
    }
}