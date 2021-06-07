using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleEffect : MonoBehaviour
{
    // Start is called before the first frame update
    private int particlecount = 100000;

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
        public Vector3 position;        //Actual position
        public Vector3 velocity;        //Actual velocity
        public Vector3 acceleration;    //Force applied 

        public float lifespan;         //Duration of particle

    };


    public ComputeShader computeShader;
    ComputeBuffer particleBuffer;

    void Start()
    {
        Particle[] particleArray = new Particle[particlecount];

        WarpCount = Mathf.CeilToInt((float)particlecount / WARP_SIZE);

        for (int i = 0; i < particlecount; i++)
        {
            particleArray[i].position = new Vector3(0, -500, 0);
            particleArray[i].velocity = new Vector3(0, 0, 0);
            particleArray[i].acceleration = new Vector3(0, -4, 0);

            particleArray[i].lifespan = Random.value * 6.0f + 3.0f;

        }

        particleBuffer = new ComputeBuffer(particlecount, PARTICLE_SIZE);
        particleBuffer.SetData(particleArray);

        ComputeShaderID = computeShader.FindKernel("CSParticle");

        computeShader.SetBuffer(ComputeShaderID, "particleBuffer", particleBuffer);
        material.SetBuffer("particleBuffer", particleBuffer);
    }

    void OnRenderObject()
    {
        material.SetPass(0);
        Graphics.DrawProceduralNow(MeshTopology.Points, 1, particlecount);
    }

    void OnDestroy()
    {
        if (particleBuffer != null)
            particleBuffer.Release();
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
