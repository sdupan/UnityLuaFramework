using UnityEngine;
using XLua;
using System;

namespace IdleGame
{
    public class LuaSMBehaviour : StateMachineBehaviour
    {
        public string luaScriptPath;
        public LuaInjection[] injections;

        private Action<Animator, AnimatorStateInfo, int> _luaOnStateEnter;
        private Action<Animator, AnimatorStateInfo, int> _luaOnStateExit;
        private Action<Animator, AnimatorStateInfo, int> _luaOnStateUpdate;
        private Action<Animator, AnimatorStateInfo, int> _luaOnStateMove;
        private Action<Animator, AnimatorStateInfo, int> _luaOnStateIK;
        private Action _luaOnDestroy;

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

        void OnEnable()
        {
            if(!_luaEnvInited)
            {
                CheckLuaEnv();
            }
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
                _scriptEnv.Get("OnStateEnter", out _luaOnStateEnter);
                _scriptEnv.Get("OnStateExit", out _luaOnStateExit);
                _scriptEnv.Get("OnStateUpdate", out _luaOnStateUpdate);
                _scriptEnv.Get("OnStateMove", out _luaOnStateMove);
                _scriptEnv.Get("OnStateIK", out _luaOnStateIK);
                _scriptEnv.Get("OnDestroy", out _luaOnDestroy);

                if (luaAwake != null)
                {
                    luaAwake();
                }
            }
            else
            {
                string msg = string.Format("[LuaSMBehaviour] Exception : lua script file is not exist --> {0}", luaScriptPath);
                Logger.LogError(msg, null);
            }

            _luaEnvInited = true;
        }

        public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            base.OnStateEnter(animator, stateInfo, layerIndex);

            if (_luaOnStateEnter != null)
            {
                _luaOnStateEnter(animator, stateInfo, layerIndex);
            }
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            base.OnStateExit(animator, stateInfo, layerIndex);

            if (_luaOnStateExit != null)
            {
                _luaOnStateExit(animator, stateInfo, layerIndex);
            }
        }

        public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            base.OnStateUpdate(animator, stateInfo, layerIndex);

            if (_luaOnStateUpdate != null)
            {
                _luaOnStateUpdate(animator, stateInfo, layerIndex);
            }
        }

        public override void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            base.OnStateMove(animator, stateInfo, layerIndex);

            if (_luaOnStateMove != null)
            {
                _luaOnStateMove(animator, stateInfo, layerIndex);
            }
        }

        public override void OnStateIK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            base.OnStateIK(animator, stateInfo, layerIndex);

            if (_luaOnStateIK != null)
            {
                _luaOnStateIK(animator, stateInfo, layerIndex);
            }
        }

        void OnDestroy()
        {
            if (_luaOnDestroy != null)
            {
                _luaOnDestroy();
            }
            _luaOnDestroy = null;
            _luaOnStateEnter = null;
            _luaOnStateExit = null;
            _luaOnStateUpdate = null;
            _luaOnStateMove = null;
            _luaOnStateExit = null;
            _scriptEnv.Dispose();
            injections = null;
        }
    }
}
