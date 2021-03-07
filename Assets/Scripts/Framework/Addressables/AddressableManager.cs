using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.ResourceManagement.ResourceLocations;
using XLua;
using System.Collections.Generic;
using System.Collections;

namespace IdleGame
{
    public class AddressableManager
    {
        [CSharpCallLua]
        public delegate void DoLoadGameObjectDelegate(GameObject obj);
        [CSharpCallLua]
        public delegate void DoLoadTextAssetDelegate(TextAsset obj);
        [CSharpCallLua]
        public delegate void DoLoadSpriteDelegate(Sprite obj);
        [CSharpCallLua]
        public delegate void DoLoadTextureDelegate(Texture obj);
        [CSharpCallLua]
        public delegate void DoLoadLuaScriptsDelegate(int count, int maxCount);
        [CSharpCallLua]
        public delegate void DoLoadProtoDelegate(string resourceName, string asset, int count, int maxCount);

        public static void LoadGameObjectAssetAsync(string address, DoLoadGameObjectDelegate action)
        {
            Addressables.LoadAssetAsync<GameObject>(address).Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    if(action != null){
                        action(op.Result);
                    }
                }
                else{
                    Logger.LogError("AddressableManager.LoadGameObjectAssetAsync failed --> " + address);
                }
            };
        }

        public static void InstantiateGameObjectAssetAsync(string address, DoLoadGameObjectDelegate action)
        {
            Addressables.InstantiateAsync(address).Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    if(action != null){
                        action(op.Result);
                    }
                }
                else{
                    Logger.LogError("AddressableManager.InstantiateGameObjectAssetAsync failed --> " + address);
                }
            };
        }

        public static void LoadTextAssetAsync(string address, DoLoadTextAssetDelegate action)
        {
            Addressables.LoadAssetAsync<TextAsset>(address).Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    if(action != null){
                        action(op.Result);
                    }
                }
                else{
                    Logger.LogError("AddressableManager.LoadTextAssetAsync failed --> " + address);
                }
            };
        }

        public static void LoadSpriteAssetAsync(string address, DoLoadSpriteDelegate action)
        {
            Addressables.LoadAssetAsync<Sprite>(address).Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    if(action != null){
                        action(op.Result);
                    }
                }
                else{
                    Logger.LogError("AddressableManager.LoadSpriteAssetAsync failed --> " + address);
                }
            };
        }

        public static void LoadTextureAssetAsync(string address, DoLoadTextureDelegate action)
        {
            Addressables.LoadAssetAsync<Texture>(address).Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    if(action != null){
                        action(op.Result);
                    }
                }
                else{
                    Logger.LogError("AddressableManager.LoadTextureAssetAsync failed --> " + address);
                }
            };
        }

        public static IEnumerator LoadLaunchScripts()
        {
            // 加载启动必须要的Lua脚本
            AsyncOperationHandle<IList<IResourceLocation>> handle = Addressables.LoadResourceLocationsAsync("LuaLaunch");
            yield return handle;

            var ops = new List<AsyncOperationHandle<TextAsset>>();
            foreach (IResourceLocation location in handle.Result)
            {
                AsyncOperationHandle<TextAsset> op = Addressables.LoadAssetAsync<TextAsset>(location);
                ops.Add(op);
                op.Completed += obj => LuaManager.Instance.AddLuaAsset(location.InternalId, obj.Result);
            }

            foreach(var op in ops)
            {
                yield return op;
                Addressables.Release(op);
            }

            Addressables.Release(handle);
        }

        public static void LoadLuaScripts(DoLoadLuaScriptsDelegate action)
        {
            int loadCount = 0;
            int maxCount = 0;
            AsyncOperationHandle<IList<IResourceLocation>> handle = Addressables.LoadResourceLocationsAsync("Lua");
            handle.Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    maxCount = op.Result.Count;
                    foreach (IResourceLocation location in op.Result)
                    {
                        Addressables.LoadAssetAsync<TextAsset>(location).Completed += obj =>
                        {
                            LuaManager.Instance.AddLuaAsset(location.PrimaryKey, obj.Result);
                            loadCount++;
                            if(action != null)
                            {
                                action(loadCount, maxCount);
                            }
                            if(loadCount >= maxCount){
                                Addressables.Release(handle);
                            }
                        };
                    }
                }
            };
        }

        public static void LoadProtos(DoLoadProtoDelegate action)
        {
            int loadCount = 0;
            int maxCount = 0;
            AsyncOperationHandle<IList<IResourceLocation>> handle = Addressables.LoadResourceLocationsAsync("Proto");
            handle.Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    maxCount = op.Result.Count;
                    foreach (IResourceLocation location in op.Result)
                    {
                        AsyncOperationHandle<TextAsset> textOp = Addressables.LoadAssetAsync<TextAsset>(location);
                        textOp.Completed += obj =>
                        {
                            loadCount++;
                            if(action != null)
                            {
                                action(location.PrimaryKey, obj.Result.text, loadCount, maxCount);
                                Addressables.Release(textOp);
                            }
                            if(loadCount >= maxCount){
                                Addressables.Release(handle);
                            }
                        };
                    }
                }
            };
        }
    }
}