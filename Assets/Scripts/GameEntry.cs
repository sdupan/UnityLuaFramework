using UnityEngine;
using System.Collections;

namespace IdleGame
{
    public class GameEntry : MonoBehaviour
    {
        // Start is called before the first frame update
        IEnumerator Start()
        {
            yield return AddressableManager.LoadLaunchScripts();

            UIManager.Init();
            LuaManager.Instance.StartGame();
        }

        // Update is called once per frame
        void Update()
        {
            
        }
    }
}