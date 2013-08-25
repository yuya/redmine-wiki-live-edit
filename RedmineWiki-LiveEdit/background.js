var checkForValidUrl, isFirst;

isFirst = true;

checkForValidUrl = function(tabId, changeInfo, tab) {
  if (/redmine/.test(tab.url) && /\/edit$/.test(tab.url) && isFirst) {
    chrome.pageAction.show(tabId);
    chrome.tabs.executeScript(null, {
      file: "content_script.js"
    });
    return isFirst = false;
  }
};

chrome.tabs.onUpdated.addListener(checkForValidUrl);
