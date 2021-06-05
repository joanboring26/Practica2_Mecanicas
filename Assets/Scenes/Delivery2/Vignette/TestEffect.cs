using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(TestEffectRenderer), PostProcessEvent.AfterStack, "Custom/TestEffect")]
public sealed class TestEffect : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Effect intensity.")]
    public FloatParameter intensty = new FloatParameter { value = 0f };
    public FloatParameter lens_feathering = new FloatParameter { value = 0f };
    public FloatParameter lens_radius = new FloatParameter { value = 0f };
}

public sealed class TestEffectRenderer : PostProcessEffectRenderer<TestEffect>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/TestEffect"));
        sheet.properties.SetFloat("_intensity", settings.intensty);
        sheet.properties.SetFloat("_lens_radius", settings.lens_radius);
        sheet.properties.SetFloat("_lens_feathering", settings.lens_feathering);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
