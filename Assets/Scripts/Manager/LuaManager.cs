using System.Collections.Generic;
using System.Collections;
using System.IO;
using System;
using UnityEngine;
using XLua;

namespace IdleGame
{
    public class LuaManager: MonoSingleton<LuaManager>
    {
        public const string LUA_SCRIPTE_FOLDER = "LuaPackage";
        public const string GAME_MAIN_SCRIPT_NAME = "GameMain";

        //lua虚拟机
        private LuaEnv _luaEnv;
        private LuaUpdater luaUpdater = null;

        public LuaEnv LuaEnv => _luaEnv;

        Dictionary<string, TextAsset> luaAssetsDict = new Dictionary<string, TextAsset>();

        //是否已经开始游戏
        public bool HasGameStart
        {
            get;
            protected set;
        }

        protected override void Init()
        {
            HasGameStart = false;
            if(_luaEnv == null){
                _luaEnv = new LuaEnv();
                _luaEnv.AddLoader(CustomLoader);
                _luaEnv.AddBuildin("lpeg", XLua.LuaDLL.Lua.LoadLpeg);
                _luaEnv.AddBuildin("rapidjson", XLua.LuaDLL.Lua.LoadRapidJson);
                _luaEnv.AddBuildin("pb", XLua.LuaDLL.Lua.LoadProtobufC);
                _luaEnv.Global.Set("RootScene", gameObject);
            }

#if UNITY_EDITOR
            UnityEditor.EditorApplication.playModeStateChanged -= OnEditorPalyModeChanged;
            UnityEditor.EditorApplication.playModeStateChanged += OnEditorPalyModeChanged;
#endif
        }

#if UNITY_EDITOR
        private void OnEditorPalyModeChanged(UnityEditor.PlayModeStateChange state)
        {
            //点击编辑器停止的时候调用
            if(state == UnityEditor.PlayModeStateChange.ExitingPlayMode)
            {
                UnityEditor.EditorApplication.playModeStateChanged -= OnEditorPalyModeChanged;
                Exit();
            }
        }
#endif

        public override void Dispose()
        {
            if(_luaEnv != null)
            {
                try
                {
                    if(luaUpdater != null)
                    {
                        luaUpdater.Dispose();
                        Destroy(luaUpdater);
                        luaUpdater = null;
                    }
                    _luaEnv.Dispose();
                    _luaEnv = null;
                }
                catch (System.Exception ex)
                {
                    string msg = string.Format("LuaManager.Dispose Exception : {0}\n {1}", ex.Message, ex.StackTrace);
                    Logger.LogError(msg, null);
                }
            }
        }

        // 这里必须要等待资源管理模块加载Lua AB包以后才能初始化
        public void onInit()
        {
            if (_luaEnv != null)
            {
                luaUpdater = gameObject.GetComponent<LuaUpdater>();
                if (luaUpdater == null)
                {
                    luaUpdater = gameObject.AddComponent<LuaUpdater>();
                }
                luaUpdater.OnInit(_luaEnv);
            }
        }

        public void AddLuaAsset(string key, TextAsset luaAsset)
        {
            luaAssetsDict.Remove(key);
            luaAssetsDict.Add(key, new TextAsset(luaAsset.text));
        }

        public TextAsset GetLuaAssetByPath(ref string filePath)
        {
            filePath = filePath.Replace(".", "/") + ".lua.bytes";
            filePath = Path.Combine("Assets/" + LUA_SCRIPTE_FOLDER + "/", filePath);

            TextAsset luaAsset = null;
            luaAssetsDict.TryGetValue(filePath, out luaAsset);
            return luaAsset;
        }

        public void StartGame()
        {
            if (_luaEnv != null)
            {
                LoadScript(GAME_MAIN_SCRIPT_NAME);
                HasGameStart = true;
            }
        }

        // 重启虚拟机：热更资源以后被加载的lua脚本可能已经过时，需要重新加载
        // 最简单和安全的方式是另外创建一个虚拟器，所有东西一概重启
        public void Restart()
        {
            StartCoroutine(_DoRestart());
        }

        private IEnumerator _DoRestart()
        {
            yield return new WaitForSeconds(0.5f);
            Dispose();
            Init();
            StartGame();
        }

        public void SafeDoString(string scriptContent)
        {
            if (_luaEnv != null)
            {
                try
                {
                    _luaEnv.DoString(scriptContent);
                }
                catch (System.Exception ex)
                {
                    string msg = string.Format("LuaManager.SafeDoString Exception : {0}\n {1}", ex.Message, ex.StackTrace);
                    Logger.LogError(msg, null);
                }
            }
        }

        public void ReloadScript(string scriptName)
        {
            SafeDoString(string.Format("package.loaded['{0}'] = nil", scriptName));
            LoadScript(scriptName);
        }

        public void LoadScript(string scriptName)
        {
            SafeDoString(string.Format("require('{0}')", scriptName));
        }

        public static byte[] CustomLoader(ref string filepath) 
        {
            TextAsset luaAsset = LuaManager.Instance.GetLuaAssetByPath(ref filepath);
            if(luaAsset != null){
                return luaAsset.bytes;
            }
            return null;
        }

        private void Update()
        {
            _luaEnv.Tick();
        }

        private void OnApplicationQuit()
        {
            Exit();
        }

        private void Exit()
        {
            if (_luaEnv != null && HasGameStart)
            {
                SafeDoString("GameMain.OnApplicationQuit()");
                HasGameStart = false;
            }
        }
    }

#if UNITY_EDITOR
    public static class CSharpCallLuaExport
    {
        [CSharpCallLua]
        public static List<Type> CSharpCallLua = new List<Type>() {
            typeof(Action),
            typeof(Func<double, double, double>),
            typeof(Action<string>),
            typeof(Action<double>),
            typeof(Action<float, float>),
            typeof(Action<float>),
            typeof(Action<UnityEngine.Animator, UnityEngine.AnimatorStateInfo, int>),
            typeof(UnityEngine.Events.UnityAction),
            typeof(System.Collections.IEnumerator)
        };
    }
#endif
}