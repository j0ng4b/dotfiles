pragma Singleton

import Quickshell
import Quickshell.Io


Singleton {
  id: root

  property string locale: Qt.locale().name
  property var translation: JSON.parse(translationFile.text());

  property string basePath: "translations/"


  FileView {
    id: translationFile
    path: Qt.resolvedUrl(root.basePath + root.locale + ".json")
    watchChanges: true
  }


  function tr(sourceText, params = {}) {
    let translation = root.translation[sourceText] || sourceText;

    // Handle pluralization
    if (typeof translation === "object" && params.count !== undefined) {
      const form = count === 1 ? "one" : "many";
      translation = translation[form];
    }

    return translation.replace(/\{(\w+)\}/g, (match, key) => {
      return params[key] !== undefined ? params[key] : match;
    });
  }
}

