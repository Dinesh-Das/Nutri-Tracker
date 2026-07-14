{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    const workerUrl = new URL('sw.js', document.baseURI);
    navigator.serviceWorker.register(workerUrl).catch((error) => {
      console.warn('NutriTrack service worker registration failed.', error);
    });
  });
}

_flutter.loader.load({
  config: {
    // Keep the renderer same-origin so the custom worker can make the app shell
    // available offline instead of depending on the gstatic CDN cache.
    canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).toString()
  }
});
