package feint.system;

import feint.assets.macros.ApplicationSettings;
import js.Node;
import js.Node.__dirname;
import electron.main.App;
import electron.main.BrowserWindow;

class FeintElectron {
  static function main() {
    electron.main.App.on(ready, function(e) {
      var win = new BrowserWindow({
        width: ApplicationSettings.getAppWidth(),
        height: ApplicationSettings.getAppHeight(),
        useContentSize: true,
        resizable: false,
        webPreferences: {
          nodeIntegration: false
        }
      });
      win.on(closed, function() {
        win = null;
      });
      win.loadFile('index.html');
      // win.webContents.openDevTools();

      trace(__dirname);
      var tray = new electron.main.Tray('${__dirname}/icon-192.png');
    });

    electron.main.App.on(window_all_closed, function(e) {
      if (Node.process.platform != 'darwin')
        electron.main.App.quit();
    });
  }
}
