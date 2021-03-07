using UnityEngine;
using UnityEditor;
using System.IO;
using Debug = UnityEngine.Debug;
using System.Diagnostics;

namespace  IdleGame
{
    [InitializeOnLoad]
    public static class XLuaMenu
    {
        public const string luaScriptsFolder = "LuaScripts";

        [MenuItem("LuaGame/Publish Lua Scripts", false, 51)]
        public static void CopyLuaFilesToAssetsPackage()
        {
            bool encodeLua = false;  //对lua 编译

            //准备目标路径
            string destination = Path.Combine(Application.dataPath, LuaManager.LUA_SCRIPTE_FOLDER);
    
            //准备源目录
            string source = Path.Combine(Application.dataPath, luaScriptsFolder);
            if(source.Length == 0)
            {
                Debug.LogError("Source error:"+ source);
                return;
            }
            //先删除后copy 否则会失败
            AssetDatabase.Refresh();
            GameUtility.SafeDeleteDir(destination);
            FileUtil.CopyFileOrDirectoryFollowSymlinks(source, destination);
            //清理非Lua文件
            var notLuaFiles = GameUtility.GetSpecifyFilesInFolder(destination, new string[] { ".lua" ,".pb"}, true);
            if (notLuaFiles != null && notLuaFiles.Length > 0)
            {
                for (int i = 0; i < notLuaFiles.Length; i++)
                {
                    GameUtility.SafeDeleteFile(notLuaFiles[i]);
                }
            }
            //获取所有的lua文件准备编译
            var luaFiles = GameUtility.GetSpecifyFilesInFolder(destination, new string[] { ".lua",".pb" }, false);
            if (luaFiles != null && luaFiles.Length > 0)
            {
                for (int i = 0; i < luaFiles.Length; i++)
                {
                    if (encodeLua)
                    {
                        if (Application.platform == RuntimePlatform.WindowsEditor)
                        {
                            if (luaFiles[i].Contains(".lua")){
                                // window 平台直接编译
                                EncodeLuaFile(luaFiles[i], luaFiles[i] + ".bytes");
                                GameUtility.SafeDeleteFile(luaFiles[i]);
                            }
                            else
                            {
                                //对pb文件直接重命名
                                GameUtility.SafeRenameFile(luaFiles[i], luaFiles[i] + ".bytes");
                            }
                            
                        }
                        else if (Application.platform == RuntimePlatform.OSXEditor)
                        {
                            // mac 平台，lua_encode.py编译好的文件复制过来,直接重命名
                            GameUtility.SafeRenameFile(luaFiles[i], luaFiles[i] + ".bytes");
                        }
                        
                    }
                    else
                    {
                        GameUtility.SafeRenameFile(luaFiles[i], luaFiles[i] + ".bytes");
                    }
                }

            }

            AssetDatabase.Refresh();
            Debug.Log("Copy lua files over");
        }

        private static void EncodeLuaFile(string srcFile , string outFile)
        {

        }
    }
}
