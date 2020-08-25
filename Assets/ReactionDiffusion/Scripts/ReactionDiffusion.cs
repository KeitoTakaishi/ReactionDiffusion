using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReactionDiffusion : MonoBehaviour
{
    /*
    {f, k}
    stripe    : {0.022, 0.051}
    spot      : {0.035, 0.065}
    amorphous : {0.04, 0.06}
    bubble    : {0.012, 0.05}
    wave      :{0.025, 0.05 }
    */
    [SerializeField] float dx = 0.01f;
    [SerializeField] float dt = 1f;
    float feed = 0.022f;
    float kill = 0.051f;

    float Du = 2e-5f;
    float Dv = 1e-5f;

    [SerializeField] RenderTexture u;
    [SerializeField] RenderTexture v;
    [SerializeField] ComputeShader cs;
    int kernel;
    const int TexSize = 1024;
    int thread_size_x, thread_size_y;


    [SerializeField] bool isPulseReset = false;
    [SerializeField] float fadeTime = 60.0f;
    [SerializeField] float tempfadeTime = 0.0f;
    [SerializeField] bool fadeDone = false;

    
    void Start()
    {
        InitRenderTexture();
        thread_size_x = 32;
        thread_size_y = 32;
        Init();
        /*
        cs.SetFloat("Dv", Dv);
        cs.SetFloat("Du", Du);
        cs.SetFloat("feed", feed);
        cs.SetFloat("kill", kill);
        cs.SetFloat("dt", dt);
        */

    }

    private void OnEnable()
    {
        InitRenderTexture();
        thread_size_x = 32;
        thread_size_y = 32;
        Init();
    }

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.W))
        {
            if(isPulseReset)
            {
                Init();//pulse reset
            } else
            {
                fadeDone = false;
            }
            //RandomSet();
        }


        if(!isPulseReset)
        {
            if(!fadeDone)
            {
                Fade();
            }
        }

        if(!isPulseReset)
        {
            if(fadeDone)
            {
                Simulate();
            }
        } else
        {
            Simulate();
        }
        
    }


    //-----------------------------------------------------------
    void InitRenderTexture()
    {
        u.Release();
        u.enableRandomWrite = true;
        u.format = RenderTextureFormat.ARGBFloat;
        u.Create();
        v.Release();
        v.enableRandomWrite = true;
        v.format = RenderTextureFormat.ARGBFloat;
        v.Create();
    }
    //-----------------------------------------------------------
    void Init()
    {
        kernel = cs.FindKernel("init");


        //Du = 2e-5f;
        //Dv = 1e-5f;
        //dt = 1.0f;
        //dx = 0.01f;
        SendParames(Du, Dv, dt, dx);


        cs.SetTexture(kernel, "u", u);
        cs.SetTexture(kernel, "v", v);
        cs.SetFloat("TexSize", u.width);
        cs.Dispatch(kernel, TexSize / thread_size_x, TexSize / thread_size_y, 1);
        kernel = cs.FindKernel("simulate");

    }
    //-----------------------------------------------------------
    void Simulate()
    {
        cs.SetTexture(kernel, "u", u);
        cs.SetTexture(kernel, "v", v);
        cs.Dispatch(kernel, TexSize / thread_size_x, TexSize / thread_size_y, 1);
    }

    //-----------------------------------------------------------
    void RandomSet()
    {
        kernel = cs.FindKernel("randomSet");
        cs.SetFloat("time", Time.realtimeSinceStartup);
        cs.SetTexture(kernel, "u", u);
        cs.SetTexture(kernel, "v", v);
        SendParames(Du, Dv, dt, dx);
        cs.Dispatch(kernel, TexSize / thread_size_x, TexSize / thread_size_y, 1);
        kernel = cs.FindKernel("simulate");
    }

    //-----------------------------------------------------------
    void SendParames(float _Du, float _Dv, float _dt, float _dx)
    {
        float _feed = 0.0f;
        float _kill = 0.0f;

       
        
        float index = Random.Range(0.0f, 1.0f);
        if(index < 0.2f)
        {
            feed = 0.04f;
            kill = 0.06f;
        } else if(0.2f <= index && index < 0.4f)
        {
            feed = 0.035f;
            kill = 0.065f;
        } else if(0.4f <= index && index < 0.6f)
        {
            feed = 0.012f;
            kill = 0.05f;
        } else if(0.6f <= index && index < 0.8f)
        {
            feed = 0.025f;
            kill = 0.05f;
        } else if(0.8f <= index)
        {
            feed = 0.022f;
            kill = 0.051f;
        }

        _feed = feed;
        _kill = kill;

        cs.SetFloat("Du", _Du);
        cs.SetFloat("Dv", _Du);
        cs.SetFloat("feed", _feed);
        cs.SetFloat("kill", _kill);
        cs.SetFloat("dt", _dt);
        cs.SetFloat("dx", _dx);
    }
    //-----------------------------------------------------------
    void Fade()
    {
        if(tempfadeTime <= fadeTime)
        {
            tempfadeTime = tempfadeTime + 1;
            kernel = cs.FindKernel("fade");
            cs.SetTexture(kernel, "u", u);
            cs.SetTexture(kernel, "v", v);
            cs.SetFloat("level", 1.0f - (tempfadeTime / fadeTime));
            cs.Dispatch(kernel, TexSize / thread_size_x, TexSize / thread_size_y, 1);
        } else
        {
            fadeDone = true;
            tempfadeTime = 0;
            Init();
        }
    }
}