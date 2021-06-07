using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleEffect : MonoBehaviour
{
    private int pcount = 100000;

    public Material material;
    public Vector3 InitPos;
    public Vector3 InitLaunch;
    public Vector3 randomRangePos;
    public Vector3 randomRangeLaunch;

    private const int PARTICLE_SIZE = 40;
    private const int WARP_SIZE = 256;

    private int ComputeShaderID;
    private int WarpCount;
    struct Particle
    {
        public Vector3 position;        //Curr pos
        public Vector3 velocity;        //Curr vel
        public Vector3 acceleration;    //Gravity

        public float lifespan;

    };


    public ComputeShader computeShader;
    ComputeBuffer particles;

    void Start()
    {
        Particle[] particleArray = new Particle[pcount];

        WarpCount = Mathf.CeilToInt((float)pcount / WARP_SIZE);

        for (int i = 0; i < pcount; i++)
        {
            particleArray[i].position = new Vector3(0, -500, 0);
            particleArray[i].velocity = new Vector3(0, 0, 0);
            particleArray[i].acceleration = new Vector3(0, -4, 0);

            particleArray[i].lifespan = Random.value * 6.0f + 3.0f;

        }

        particles = new ComputeBuffer(pcount, PARTICLE_SIZE);
        particles.SetData(particleArray);

        ComputeShaderID = computeShader.FindKernel("CSParticle");

        computeShader.SetBuffer(ComputeShaderID, "particleBuffer", particles);
        material.SetBuffer("particleBuffer", particles);
    }

    void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, 1, pcount);
    }

    void OnDestroy()
    {
        if (particles != null)
            particles.Release();
    }

    void Update()
    {
        float[] Pos = { Random.Range(InitPos.x - randomRangePos.x, InitPos.x + randomRangePos.x),
                        Random.Range(InitPos.y - randomRangePos.y, InitPos.y + randomRangePos.y),
                        Random.Range(InitPos.z - randomRangePos.z, InitPos.z + randomRangePos.z)};

        float[] Launch = { Random.Range(InitLaunch.x - randomRangeLaunch.x, InitLaunch.x + randomRangeLaunch.x),
                           Random.Range(InitLaunch.y                      , InitLaunch.y + randomRangeLaunch.y),
                           Random.Range(InitLaunch.z - randomRangeLaunch.z, InitLaunch.z + randomRangeLaunch.z)};

        computeShader.SetFloat("deltaTime", Time.deltaTime);
        computeShader.SetFloats("InitialPush", Launch);
        computeShader.SetFloats("InitialPos", Pos);
        computeShader.Dispatch(ComputeShaderID, WarpCount, 1, 1);
    }
}
