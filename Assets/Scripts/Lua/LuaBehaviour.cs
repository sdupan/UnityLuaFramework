using UnityEngine;
using XLua;
using System;

namespace IdleGame
{
    public class LuaBehaviour : MonoBehaviour
    {
        public string luaScriptPath;
        public LuaInjection[] injections;

        private Action _luaStart;
        private Action _luaUpdate;
        private Action _luaOnDestroy;
        private Action<string> _luaAnimatorEvent;

        private LuaEnv _luaEnv;
        private LuaTable _scriptEnv;
        private bool _luaEnvInited;

        public void AddLuaInjections(string key, GameObject obj)
        {
            if(injections == null)
            {
                injections = new LuaInjection[1];
            }
            else
            {
                var len = Math.Max(1, injections.Length + 1);
                var newArray = new LuaInjection[len];
                injections.CopyTo(newArray, len - 1);
                injections = newArray;
            }
            
            var injectObj = new LuaInjection();
            injectObj.name = key;
            injectObj.value = obj;
            injections.SetValue(injectObj, injections.Length - 1);
            if(_scriptEnv != null)
            {
                _scriptEnv.Set(key, obj);
            }
        }

        void Awake()
        {
            _luaEnvInited = false;
            _luaEnv = LuaManager.Instance.LuaEnv;
            LuaEnv luaEnv = _luaEnv;
            _scriptEnv = luaEnv.NewTable();

            // 为每个脚本设置一个独立的环境，可一定程度上防止脚本间全局变量、函数冲突
            LuaTable meta = luaEnv.NewTable();
            meta.Set("__index", luaEnv.Global);
            _scriptEnv.SetMetaTable(meta);
            meta.Dispose();

            _scriptEnv.Set("self", this);

            CheckLuaEnv();
        }

        // Use this for initialization
        void Start()
        {
            if(!_luaEnvInited)
            {
                CheckLuaEnv();
            }
            
            if (_luaStart != null)
            {
                _luaStart();
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (_luaUpdate != null)
            {
                _luaUpdate();
            }
        }

        void AnimatorEvent(string text)
        {
            if(_luaAnimatorEvent != null)
            {
                _luaAnimatorEvent(text);
            }
        }

        void OnDestroy()
        {
            if (_luaOnDestroy != null)
            {
                _luaOnDestroy();
            }
            _luaOnDestroy = null;
            _luaUpdate = null;
            _luaStart = null;
            _scriptEnv.Dispose();
            injections = null;
        }

        void CheckLuaEnv()
        {
            if(luaScriptPath == null)
            {
                return;
            }

            foreach (var injection in injections)
            {
                _scriptEnv.Set(injection.name, injection.value);
            }

            var filePath = luaScriptPath;
            var luaAsset = LuaManager.Instance.GetLuaAssetByPath(ref filePath);
            if(luaAsset != null)
            {
                _luaEnv.DoString(luaAsset.bytes, filePath, _scriptEnv);

                Action luaAwake = _scriptEnv.Get<Action>("Awake");
                _scriptEnv.Get("Start", out _luaStart);
                _scriptEnv.Get("Update", out _luaUpdate);
                _scriptEnv.Get("OnDestroy", out _luaOnDestroy);
                _scriptEnv.Get("AnimatorEvent", out _luaAnimatorEvent);

                if (luaAwake != null)
                {
                    luaAwake();
                }
            }
            else
            {
                string msg = string.Format("[LuaBehaviour] Exception : lua script file is not exist --> {0}", luaScriptPath);
                Logger.LogError(msg, null);
            }

            _luaEnvInited = true;
        }
    }
}
