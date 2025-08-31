async function checkVersionAndUpdate() {
    if ('serviceWorker' in navigator) {
      try {
        // Запрашиваем версию из version.json
        const response = await fetch('/version.json', { cache: 'no-cache' });
        const data = await response.json();
        const newVersion = data.version; // Читаем версию из JSON

        // Получаем старую версию из локального хранилища
        const oldVersion = localStorage.getItem('app_version');

        if (oldVersion && oldVersion !== newVersion) {
          console.log(`Обнаружено обновление: ${oldVersion} → ${newVersion}`);

          // Удаляем старый Service Worker
          const registrations = await navigator.serviceWorker.getRegistrations();
          for (let registration of registrations) {
            await registration.unregister();
          }

          // Очищаем кеш браузера
          const cacheNames = await caches.keys();
          for (let cacheName of cacheNames) {
            await caches.delete(cacheName);
          }

          // Обновляем сохранённую версию
          localStorage.setItem('app_version', newVersion);

          // Принудительно перезагружаем страницу
          location.reload();
        } else {
          // Сохраняем версию, если ранее её не было
          localStorage.setItem('app_version', newVersion);
        }
      } catch (error) {
        console.error('Ошибка при проверке версии:', error);
      }
    }
  }

checkVersionAndUpdate();