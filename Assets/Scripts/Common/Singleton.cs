using System;

namespace IdleGame
{
    public abstract class Singleton<T> where T : class, new()
    {
        private static T m_instance;
        public static T Instance
        {
            get
            {
                if (Singleton<T>.m_instance == null)
                {
                    Singleton<T>.m_instance = Activator.CreateInstance<T>();
                }

                return Singleton<T>.m_instance;
            }
        }

        public static void Release()
        {
            if (Singleton<T>.m_instance != null)
            {
                Singleton<T>.m_instance = (T)((object)null);
            }
        }

        public virtual void Init()
        {

        }

        public virtual void Dispose()
        {

        }
    }
}