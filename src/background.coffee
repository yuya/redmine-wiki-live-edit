isFirst = null

checkForValidUrl = (tabId, changeInfo, tab) ->
  isFirst = true
  if /redmine/.test(tab.url) && /\/edit$/.test(tab.url) && isFirst
    chrome.pageAction.show tabId
    chrome.tabs.executeScript null,
      file: "content_script.js"
    isFirst = false

chrome.tabs.onSelectionChanged.addListener ->
  isFirst = true

window.onload = ->
  isFirst = true
  chrome.tabs.onUpdated.addListener checkForValidUrl
