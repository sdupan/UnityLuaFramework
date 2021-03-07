using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using XLua;
using FairyGUI;

namespace IdleGame
{
    public class UIManager
    {
        [CSharpCallLua]
        public delegate void DoAddPackageDelegate(string name, int result);

        public static void Init()
        {
            UIPackage.unloadBundleByFGUI = false;
            NTexture.CustomDestroyMethod += (Texture tex) =>
            {
                Addressables.Release(tex);
                Logger.Log(".... release addressable: " + tex.name);
            };

            NAudioClip.CustomDestroyMethod += (AudioClip audio) =>
            {
                Addressables.Release(audio);
                Logger.Log(".... release addressable: " + audio.name);
            };
        }

        public static void AddPackage(string address, string prefix, DoAddPackageDelegate action)
        {
            AsyncOperationHandle<TextAsset> handle = Addressables.LoadAssetAsync<TextAsset>(address);
            handle.Completed += op =>
            {
                if(op.Status == AsyncOperationStatus.Succeeded)
                {
                    UIPackage.AddPackage(op.Result.bytes, prefix, async (string name, string extension, System.Type type, PackageItem item) =>
                    {
                        if (type == typeof(Texture))
                        {
                            Texture tex = await Addressables.LoadAssetAsync<Texture>(name).Task;
                            item.owner.SetItemAsset(item, tex, DestroyMethod.Custom);
                        }
                        else if(type == typeof(AudioClip))
                        {
                            AudioClip audio = await Addressables.LoadAssetAsync<AudioClip>(name + extension).Task;
                            item.owner.SetItemAsset(item, audio, DestroyMethod.Custom);
                        }
                    });
                    if(action != null)
                    {
                        action(address, 0);
                    }
                }
                else
                {
                    Logger.LogError("UIManager.AddPackage failed --> " + address);
                    if(action != null)
                    {
                        action(address, -1);
                    }
                }

                Addressables.Release(handle);
            };
        }

        public static void RemovePackage(string pkgName)
        {
            UIPackage pkg = UIPackage.GetByName(pkgName);
            if(pkg != null)
            {
                pkg.UnloadAssets();
                UIPackage.RemovePackage(pkgName);
            }
        }
    }
}