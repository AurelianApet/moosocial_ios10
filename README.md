# CONTENTS OF THIS FILE
* [About](#about) 
* [Configuration and features](#configuration-and-features)
* [Installation profiles](#installation-profiles)
* [Developing](#developing) 
* [Building](#building) 

# About

It is IOS social app .

# Configuration and features

 It requires web server must install mooSocial Core , Api Plugin , MooApp Plugin

## mooSocial Core (Your can purchase it from moosocial.com)

  It  has what you need to get started with your website.

## Api Plugin  

  It provides robust, secure JSON REST API for moosocial . With this plugin, your website's moosocial installation can also be used as a backend for native mobile apps
  * REST API: This API uses standard HTTP methods such as PUT, GET, POST and DELETE.
  * Stateless: API is stateless as per norms, i.e., API clients need to include state information (OAuth token) in their requests to the server and vice versa.
  * JSON: Uses JSON for data exchange.
  * Familiar directory-structure-like URL structures.
  * Secure API 
   * OAuth : API uses the popular OAuth open standard for authorization for client as well as user authorization. Every user is assigned a unique, client-specific OAuth Token for identification.It is based on the [Resource Owner Password Credentials](http://tools.ietf.org/html/rfc6749#section-10.7)   flow of the   [OAuth 2 specification](http://tools.ietf.org/html/rfc6749#section-4.3) .
   * SSL (HTTPS) support: API requests and responses work well on HTTPS. We recommend all API requests to be sent on SSL.
   * API Secret Key for preveting spammer accessing the part of public api , ex singup api .

##  MooApp Plugin provides 
  * Theme for maximum iOS's performance 
  * Notificaiton integration allows mooSocial core send messages to iOS client apps  via Google Cloud Messaging (GCM) service


# Installation profiles


# Developing
## Structure
### Files 
#### Extentsion.swift 
It is used for sharing the common code . We use it to avoid code duplication in the project.
#### Commands.swift 
It is used for defining the commands that the application will support .

# Building
 You need to make sure the  config in appConfig.json file is correctly
* general.initialUrl  is your website link  
* general.enableGCM  is true in case your app using the Google Clound Messageing service . You need to make sure that your GoogleServie-Info.plist is correctly and download it from https://developers.google.com/cloud-messaging/ios/start
* general.apiKey is the API Secret Key which is configed by yourselft in yoursite/admin/api/api_plugins , your signup app feature will be broken in case the apiKey is not correctly . 
* menus.pages  is the page section in the More menu view in the mobile app .

## Cocoapods

Moosocial for iOS uses Cocoapods to manage third party libraries . Trying to build the project by itself (mooApp.xcproj) after launching will result in an error, as the resources managed by cocoapods are not included.
Run `pod install` from the command line to install dependencies for the project.

*CocoaPods 1.1.0+ is required*

## Xcode

Launch the workspace by either double clicking on mooApp.xcworkspace file, or launch Xcode and choose File > Open and browse to mooApp.xcworkspace.

*Moosocial for iOS requires Swift 3.0 and Xcode 8.1 or newer. *
