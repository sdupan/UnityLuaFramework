using UnityEngine;
using XLua;
using System.Collections.Generic;
using System.Collections;
using System;

namespace IdleGame
{
    public class Coroutine_Runner : MonoBehaviour
    {
        public void YieldAndCallback(object toYield, Action callback)
        {
            StartCoroutine(CoBody(toYield, callback));
        }

        private IEnumerator CoBody(object toYield, Action callback)
        {
            if (toYield is IEnumerator)
                yield return StartCoroutine((IEnumerator)toYield);
            else
                yield return toYield;
            callback();
        }
    }
}
