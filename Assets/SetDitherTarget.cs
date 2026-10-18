using UnityEngine;

[ExecuteAlways]
public class SetDitherTarget : MonoBehaviour
{
    [SerializeField] private Transform targetObject;
    [SerializeField] private Renderer objectToFadeRenderer;
    [SerializeField] private float fadeRadius = 3.0f;

    private int CullCenterID = Shader.PropertyToID("_CullCenter");
    private int CullRadiusID = Shader.PropertyToID("_CullRadius");

    private MaterialPropertyBlock mpb;

    void Update()
    {
        if (targetObject == null || objectToFadeRenderer == null) return;

        if (mpb == null) mpb = new MaterialPropertyBlock();

        objectToFadeRenderer.GetPropertyBlock(mpb);
        mpb.SetVector(CullCenterID, targetObject.position);
        mpb.SetFloat(CullRadiusID, fadeRadius);
        objectToFadeRenderer.SetPropertyBlock(mpb);
    }
}