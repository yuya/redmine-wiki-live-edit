checkForValidUrl = (tabId, changeInfo, tab) ->
  if /redmine/.test(tab.url) && /\/edit$/.test(tab.url)
    chrome.pageAction.show tabId
    chrome.tabs.executeScript null,
      file: "content_script.js"

chrome.tabs.onUpdated.addListener checkForValidUrl
