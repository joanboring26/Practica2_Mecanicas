using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleEffect : MonoBehaviour
{
    // Start is called before the first frame update
    public int particlecount = 400;

    private const int PARTICLE_SIZE = 20;

    private int ComputeShaderID;
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
        StartComputeShader();
    }

    // Update is called once per frame
    
    void StartComputeShader()
    {
        Particle[] particleArray = new Particle[particlecount];


        for(int i = 0; i < particlecount; i++) 
        {
            particleArray[i].position = new Vector3(0,0,0);
            particleArray[i].velocity = new Vector3(0, 10, 0);
            particleArray[i].acceleration = new Vector3(0, -4, 0);

            particleArray[i].lifespan = Random.value * 6.0f + 3.0f;

        }

        particleBuffer = new ComputeBuffer(particlecount, PARTICLE_SIZE);
        particleBuffer.SetData(particleArray);

        ComputeShaderID = computeShader.FindKernel("CSParticle");

        computeShader.SetBuffer(ComputeShaderID, "particleBuffer", particleBuffer);
    }
}
