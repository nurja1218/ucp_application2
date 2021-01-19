//
//  ViewController.swift
//  PalmCat
//
//  Created by Junsung Park on 2020/10/28.
//  Copyright © 2020 Junsung Park. All rights reserved.
//

import Cocoa
import WebKit
import OHMySQL
import Alamofire
import SwiftyJSON

import GameController

/*
private extension Selector {
    static let pushToNextViewController = #selector(ViewController.pushToNextViewController)
    static let popViewController = #selector(ViewController.popViewController)
}
 */
class ViewController: NSViewController , WKUIDelegate,WKNavigationDelegate, WKScriptMessageHandler{
    
    @IBOutlet weak var webView:WKWebView!

    @IBOutlet weak var button:NSButton!
    
    var timer = Timer()
    
    var tTimer = Timer()
    var uTimer = Timer()

    var handType:String = ""
    var usageType2:String = ""
    var usageType3:String = ""
    var usageType4:String = ""
    
    var usageType:String = ""
    
    var oldCommand:String = ""
    
    var user:Users = Users()
    
    var selectedApplication = "MacOS"
    var selectedGestureIndex:Int = 0
    var selectedGestureOldIndex:Int = 0
    
    var selectedGesture = "L"
    var selectedOldGesture = "L"
    
    var selectedCode = ModelManager.shared.Left()
    var selectedOldCode = ModelManager.shared.Left()

    var hidManager:IOHIDManager!

    var gamepad:GCMicroGamepad!
    
    var handIndex:Int = 0
    
    var nextFlag :Bool = false
    
    
    var down:Bool = false
    
    var downName:String!
    
    var version: String? {
         let dictionary = Bundle.main.infoDictionary
        let version = dictionary!["CFBundleShortVersionString"] as? String
             // let build = dictionary["CFBundleVersion"] as? String else {return nil}
     //   let versionAndBuild: String = "vserion: \(version), build: \(build)"
        return version
        
    }

    var compileDate:Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    override func awakeFromNib() {
    
        if self.view.layer != nil {
        
            let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
               self.view.layer?.backgroundColor = color
            webView.layer?.backgroundColor = color
           
        }

       
    }
    
    func documentsDirectoryURL() -> NSURL {
          let manager = FileManager.default
          let URLs = manager.urls(for: .documentDirectory, in: .userDomainMask)
          return URLs[0] as NSURL
      }
    func dataFileURL(fileName:String) -> NSURL {
          
          let path = String(format: "%@", fileName)
          let targetPath = documentsDirectoryURL()
          
          let manager = FileManager.default
        
          
          if(manager.fileExists(atPath: targetPath.path!))
          {
              print("exist")
          }
          else
          {
              do{
                  try   manager.createDirectory(at: targetPath as URL, withIntermediateDirectories: false, attributes: nil)
                  
              } catch {
                  print("Error: \(error.localizedDescription)")
              }
          }
          
          
          
          return documentsDirectoryURL().appendingPathComponent(path)! as NSURL
          
      }
    
    func writeFile(data:Data,downloadsDirectory:URL )
    {
        try! data.write(to: downloadsDirectory)

    }
    
    func downloadApp(filename:String, url:URL)
    {
        let manager = FileManager.default
               
        let path = String(format: "%@", filename)
        let pathUrl = dataFileURL(fileName: filename)

        var downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        downloadsDirectory.appendPathComponent(path)
        
        let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("desktopURL: " + String(describing: desktopURL))
        let fileURL = desktopURL.appendingPathComponent(path)

        AF.download(url)
            .downloadProgress { (progress) in
                     //  self.progressLabel.text = (String)(progress.fractionCompleted)
                print(progress)
            }
            .responseData { (response) in
            if(response.error == nil)
            {
                let  data = response.value
                    // let bool = manager.createFile(atPath: downloadsDirectory.path, contents: data, attributes: nil)
                try! data!.write(to: downloadsDirectory)

                print(data)
                self.performSegue(withIdentifier: "exec_download", sender: nil)
                //let data = manager.contents(atPath: pathUrl.path!)
                             
         //       let firmeware = DFUFirmware(zipFile:data!)
              
            
           //     self.selectedFirmware = filename
             //   self.performSegue(withIdentifier: "exec_update", sender: firmeware)
      
                
            }
        }
    }
    
   func getJson()
   {
     //   let url = "https://palmcat.co.kr/sw/palmcat_update.json"
    let url = "https://palmcat.co.kr/sw/update.json"
    var down = "http://www.junsoft.org/firmware/palmcat 0.0.1.pkg"
    down = down.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    let downUrl = URL(string: down)!

 //  let url = "http://www.junsoft.org/firmware/update.json"

        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json; charset=utf-8"
        ]

       
        AF.request(url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: headers)
        
                   .responseJSON {  [self] response in
            
            switch response.result {

            case .success(let value):
                let json = JSON(value)
                let items =  json["peroUCP"].dictionaryValue
                let app = items["macos"]?.dictionaryValue
                let version0 = app!["version"]?.stringValue
                let description = app!["description"]?.stringValue
                let installerDict = app!["installer"]?.dictionaryValue
                let name = installerDict!["path"]?.stringValue
       
                print(version)
                if(version != version0)
                {
                    
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "There is a new version. Do you want to update?"
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Cancel")
                    alert.alertStyle = NSAlert.Style.warning

                    alert.beginSheetModal(for: self.view.window!, completionHandler: { [self] (modalResponse) -> Void in
                        if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                            
                     
                            self.downName = name
                            self.performSegue(withIdentifier: "exec_download", sender: nil)
                     
                         //   self.downloadApp(filename: "palmcat 0.0.1.pkg", url: downUrl)
                            
                            
                         }
                     })
                    
                    
                }
                print(app)
           
                

            case .failure(let error):
            
                print("error : \(error)")
                //completion(false, JSON())
                
                break;
                
            }
        }
    
 
   }
    /*
    override func didReceiveMemoryWarning() {
       super.didReceiveMemoryWarning()
       print("**** MEMORY WARNING! ****")
       URLCache.shared.removeAllCachedResponses()
       URLCache.shared.diskCapacity = 0
       URLCache.shared.memoryCapacity = 0
    }
     */
   
    func deleteCache()
    {
    //    return
       /*
        DispatchQueue.main.async {
                 WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                     records.forEach { record in
                         WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                         print("[WebCacheCleaner] Record \(record) deleted")
                     }
                 }
             }
 */
       // print("**** MEMORY WARNING! ****")
    //    return
      //  URLCache.shared.removeAllCachedResponses()
      //  URLCache.shared.diskCapacity = 0
      //  URLCache.shared.memoryCapacity = 0
 
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // deleteCache()
     
        preferredContentSize = view.frame.size
        
        self.view.wantsLayer = true
             
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let webConfiguration = WKWebViewConfiguration()
        // Fix Fullscreen mode for video and autoplay
        webConfiguration.preferences.javaScriptEnabled = true
           
        webConfiguration.allowsAirPlayForMediaPlayback = true

        //webView.configuration = webConfiguration
        webView.navigationDelegate = self
        
  
        
        let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.view.layer?.backgroundColor = color
        
        webView.wantsLayer = true
        webView.layer?.backgroundColor = color
        
   
        connectDB()
        
        getJson()
       
   //     getServerUserList()
   //     getServerAppList()
       
   
    }
    
    
   
   
    func getServerUserList()
    {
    
        connectDB()
        

        let query = OHMySQLQueryRequestFactory.select("userlist", condition: nil)
        
        let response = try? OHMySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query)
        
        for _dict in ( response! as! NSArray)
        {
            let dict:[String:Any] = _dict as! [String:Any]
            let answer  = dict["answer"] as? String
            
            let id  = dict["id"] as? Int
            
            let type  = dict["user_TypeName"] as? String
            
            CoreDataManager.shared.saveUserList(type: type!, id: id!,  answer:answer!,  onSuccess: { (success) in
                
                print("success")
                
            })
            
            
        }
              
    }
    
    func getSelectEventListener() -> String
    {
        let script =
            "document.getElementsByClassName('select-field')[1]." +
                "addEventListener('change', function(event){ " +
                "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
                "}); " + // L1
        "document.getElementsByClassName('select-field')[2]." +
            "addEventListener('change', function(event){ " +
            "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
            "}); "  +   // L1

        "document.getElementsByClassName('select-field')[4]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); "  + // L2
        "document.getElementsByClassName('select-field')[5]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); "  + // L2

        "document.getElementsByClassName('select-field')[7]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + //L3
        "document.getElementsByClassName('select-field')[8]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + //L3
      
        "document.getElementsByClassName('select-field')[10]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L4
        "document.getElementsByClassName('select-field')[11]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L4

        "document.getElementsByClassName('select-field')[13]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L5
        "document.getElementsByClassName('select-field')[14]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L5

        "document.getElementsByClassName('select-field')[16]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L6
        "document.getElementsByClassName('select-field')[17]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L6

        "document.getElementsByClassName('select-field')[19]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L7
        "document.getElementsByClassName('select-field')[20]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L7

        "document.getElementsByClassName('select-field')[22]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L8
        "document.getElementsByClassName('select-field')[23]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L8

        "document.getElementsByClassName('select-field')[25]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L9
        "document.getElementsByClassName('select-field')[26]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L9

        "document.getElementsByClassName('select-field')[28]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L10
        "document.getElementsByClassName('select-field')[29]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L10

        "document.getElementsByClassName('select-field')[31]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L11
        "document.getElementsByClassName('select-field')[32]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L11

        "document.getElementsByClassName('select-field')[34]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L12
        "document.getElementsByClassName('select-field')[35]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L12

        "document.getElementsByClassName('select-field')[37]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L13
        "document.getElementsByClassName('select-field')[38]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L13

        "document.getElementsByClassName('select-field')[40]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L14
        "document.getElementsByClassName('select-field')[41]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L14

        "document.getElementsByClassName('select-field')[43]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L15
        "document.getElementsByClassName('select-field')[44]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); " + // L15

        "document.getElementsByClassName('select-field')[46]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t3'); " +
             "}); " + // L16
        "document.getElementsByClassName('select-field')[47]." +
             "addEventListener('change', function(event){ " +
             "window.webkit.messageHandlers.iosListener0.postMessage(event.target.value + '/t4'); " +
             "}); "  // L16

        
        return script
    }
    
    func getUserType(condition:String)
    {
    
     //   connectDB()
        let commands = CoreDataManager.shared.getCommand(name: condition, touch: "t3",id:self.user.userid!)
         
      
        var option = String()
        
       // if ( response == nil || (response! as! NSArray).count == 0)
        if(commands.count == 0)
        {
            option.append("<option>")
                                
                              
                    option.append("Not Selected")
                    
                    option.append("</option>")
               //     let script = "var sel1 = document.getElementsByTagName('select')[1];sel1.disabled = true; sel1.innerHTML = " + "'" + option + "'"
                 

            let script =  "var sel0 = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex) + "].disabled = true;" +
                         "var sel = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex + 1) + "];" +
                               "sel.disabled = true; sel.innerHTML = " +
                              "'" + option + "'"

                              
                     webView.evaluateJavaScript(script) { (result, error) in
                                   
                                       
                                   
                     }
                              
            
            return
            
        }
        
        option.append("<option disabled selected>")
        
        
        option.append("Select one...")
        option.append("</option>")
 
        
        //selectedGesture
        var isEnable :Bool = false
        for command in commands
        {
            
            if( command.enable == nil ||  command.gesture?.count == 0  )
              {
                    option.append("<option>")
                  
              }
              else
              {
                if(command.gesture == selectedGesture)
                {
                    isEnable = true
                    option.append("<option disabled selected>")
           
                }
                else
                {
                    option.append("<option disabled>")
       
                }
                  
              }
            option.append(command.command!)
              option.append("</option>")
            
        }
     //   let index0 = option.index(option.startIndex, offsetBy:0)
     //   option.remove(at: index0)
     //   let index1 = option.index(option.startIndex, offsetBy:1)
     //   option.remove(at: index1)
        
      //  option[index1] = "Not Selected..."
     
     //   let index2 = option.index(option.startIndex, offsetBy:2)
     //   option.remove(at: index1)

        if(isEnable == true)
        {
            option =  option.replacingOccurrences(of: "<option disabled selected>Select one...</option>", with: "<option>Not Selected...</option>")
     
        }
        //    option.insert("", at: 0)
    
        var gestureSrcript = getGestureNodeStr(index: selectedGestureIndex)
           
        gestureSrcript =  gestureSrcript + ""
        let script =
                   
                    "var sel0 = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex) + "].disabled = true;" +
                     "var sel = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex + 1) + "];" +
                           "sel.disabled = false; sel.innerHTML = " +
                           
                          "'" + option + "';"
   
        
        webView.evaluateJavaScript(script) { (result, error) in
                      
                          
                      
        }
    }
    func getUserType2(condition:String)
    {
    
        //connectDB()
         let commands = CoreDataManager.shared.getCommand(name: condition, touch: "t4",id:self.user.userid!)
        
  
        var option = String()
        
        if ( commands.count == 0)
        {
            option.append("<option>")
                        
                      
            option.append("Not Selected")
            
            option.append("</option>")
    
            let script =
                  
                      "var sel = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex + 2) + "];" +
                      
                      "sel.disabled = true; sel.innerHTML = " +
                      
                      "'" + option + "'"
                     
                      
                      
             webView.evaluateJavaScript(script) { (result, error) in
                           
                               
                           
             }
                      
            return
        }

        option.append("<option disabled selected>")
        
        
        option.append("Select one...")
        option.append("</option>")
 
        
        //selectedGesture
        var isEnable :Bool = false
        
        for command in commands
        {
            if( command.enable == nil || command.enable == false )
              {
                    option.append("<option>")
                  
              }
              else
              {
                    if(command.gesture == selectedGesture)
                    {
                        isEnable = true
                        option.append("<option disabled selected>")
               
                    }
                    else
                    {
                        option.append("<option disabled>")
           
                    }
                  
              }
            option.append(command.command!)
              option.append("</option>")
            
        }
        
        if(isEnable == true)
        {
            option =  option.replacingOccurrences(of: "<option disabled selected>Select one...</option>", with: "<option>Not Selected...</option>")
     
        }
        var gestureSrcript = getGestureNodeStr(index: selectedGestureIndex)
        
        gestureSrcript =  gestureSrcript + ""
        
        let script =
        
            
                "var sel = document.getElementsByClassName('select-field')" + "[" + String( 3 * selectedGestureIndex + 2) + "];" +
                
                "sel.disabled = false; sel.innerHTML = " +
                
                "'" + option + "';"
        
       webView.evaluateJavaScript(script) { (result, error) in
      
        }
       
            
   
    }
    func getServerAppList()
    {
    
        connectDB()
        

        let query = OHMySQLQueryRequestFactory.select("applist", condition: nil)
        
        let response = try? OHMySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query)
        
        for _dict in ( response! as! NSArray)
        {
            let dict:[String:Any] = _dict as! [String:Any]
            let group  = dict["app_GroupName"] as? String
            
            
            let name  = dict["app_Name"] as? String
            
            let type  = dict["app_TypeName"] as? String
            let process  = dict["process_Name"] as? String
            
            var etc  = dict["etc"] as? String
            if(etc == nil)
            {
                etc = ""
            }
                     
            CoreDataManager.shared.saveAppList(name: name!, type: type!, group: group!, process: process!, etc: etc!, onSuccess: { (success) in
                
                print("success")
            })
            
            
        }
              
    }
    func getServerCommand()
     {
     
         connectDB()
         

         let query = OHMySQLQueryRequestFactory.select("command", condition: nil)
         
         let response = try? OHMySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query)
         
        if( response == nil)
        {
            return
        }
         for _dict in ( response! as! NSArray)
         {
             let dict:[String:Any] = _dict as! [String:Any]
            let group  = dict["app_GroupName"] as? String
            let shortcut = dict["shortcut"] as? String
            var gesture = dict["gesture"] as? String
            let type = dict["app_TypeName"] as? String
            
            if(gesture == nil)
            {
                gesture = ""
            }
                  
            print(dict)
            
             
         }
               
     }
    func initLocalCommandDB()
    {
        /*
        var bInit =  UserDefaults.standard.bool(forKey: "INIT_DB")
        if(bInit == false)
        {
            CoreDataManager.shared.deleteCommands()
            let query = OHMySQLQueryRequestFactory.select(self.user.type!, condition: nil )
            
            let response = try? OHMySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query)
            
            if(response == nil)
            {
                return
            }
            
            for _dict in ( response! as! NSArray)
            {
                
             
                let dict:[String:Any] = _dict as! [String:Any]
            
                let name =  dict["app_Name"] as? String
             
                let command =  dict["command"] as? String
              
                let shortcut =  dict["shortcut"] as? String
              
                var touch =  dict["touch"] as? String
                if(touch == nil)
                {
                    touch = ""
                }
                
                CoreDataManager.shared.saveCommand(name: name!, type: user.type!, group: name!, gesture: "", shortcut: shortcut!, command: command!, enable: false, touch:touch!,onSuccess:{ (success) in
                    
                    UserDefaults.standard.setValue(true, forKey: "INIT_DB")
                    UserDefaults.standard.synchronize()
                  
                })
            
            }
        }
 */
        var userID =  UserDefaults.standard.string(forKey: "USER_ID")
        var bInit =  UserDefaults.standard.bool(forKey: "INIT_DB")
  
      //  if(userID != (self.user.userid ))
        if(bInit == false)
        {
            getServerUserList()
            let query = OHMySQLQueryRequestFactory.select(self.user.type!, condition: nil )
            
            let response = try? OHMySQLContainer.shared.mainQueryContext?.executeQueryRequestAndFetchResult(query)
            
            if(response == nil)
            {
                return
            }
            CoreDataManager.shared.dbCnt = ( response! as! NSArray).count
            for _dict in ( response! as! NSArray)
            {
                
             
                let dict:[String:Any] = _dict as! [String:Any]
            
                let name =  dict["app_Name"] as? String
                if(name == "MacOS")
                {
                    print("macos")
                }
                if(name == "MS word")
                {
                    print("MS word")
                }
             
             
                let command =  dict["command"] as? String
              
                var shortcut =  dict["shortcut"] as? String
              
                var touch =  dict["touch"] as? String
                if(touch == nil)
                {
                    touch = ""
                }
                if(shortcut == nil)
                {
                    shortcut = ""
                }
                print(dict)
                
                CoreDataManager.shared.saveCommand(name: name!,id:self.user.userid!, type: user.type!, group: name!, gesture: "", shortcut: shortcut!, command: command!, enable: false, touch:touch!,onSuccess:{ (success) in
                    
                    UserDefaults.standard.setValue(true, forKey: "INIT_DB")
                    UserDefaults.standard.synchronize()
                  
                })
            
            }
        }
        

    }
    
    override func viewWillAppear() {
        self.view.window?.center()
        let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.view.layer?.backgroundColor = color

        webView.wantsLayer = true
        
        webView.setValue(false, forKey: "drawsBackground")
        
        webView.layer?.backgroundColor = NSColor.clear.cgColor;
        
     
    }
   
    func Alert(question: String, text: String)  {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
      //  alert.addButton(withTitle: "Cancel")
        //return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    //ConfirmLogout
    func ConfirmDelete()  {
        let alert = NSAlert()
        alert.messageText = ""
        alert.informativeText = "Are you sure you would like to delete all settings?"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.warning

        alert.beginSheetModal(for: self.view.window!, completionHandler: { [self] (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                 print("Document deleted")
                UserDefaults.standard.setValue(false, forKey: "INIT_DB")
                UserDefaults.standard.synchronize()
                
            
                CoreDataManager.shared.deleteCommandsID(id: self.user.userid!)
                 //CoreDataManager.shared.deleteCommands()
                initLocalCommandDB()
                self.getUserType(condition: self.selectedApplication)
                self.getUserType2(condition: self.selectedApplication)
                
                
       
          //
                let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
                userDefaults!.set("", forKey: "USER_ID")
                userDefaults?.synchronize()
                
                
                UserDefaults.standard.set("",forKey: "USER_ID")
                UserDefaults.standard.synchronize()
           
             //   self.initLocalCommandDB()
             }
         })
    }
    //
    func ConfirmLogout()  {
        let alert = NSAlert()
        alert.messageText = ""
        alert.informativeText = "Are you sure you would like to log out?"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.warning

        alert.beginSheetModal(for: self.view.window!, completionHandler: { [self] (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
            
                
                UserDefaults.standard.set("",forKey: "USER_ID")
                UserDefaults.standard.synchronize()
                
                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.1", ofType: "html", inDirectory:"www/ucp-v03-home")!)
                
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
   
           
             //   self.initLocalCommandDB()
             }
         })
    }
    func processSignUp()
    {
     
        let countryS = "var index = document.getElementsByTagName('select')[0].selectedIndex; document.getElementsByTagName('option')[index].value"
          
        let nameS = "document.getElementsByTagName('input')[0].value"
        
        let idS = "document.getElementsByTagName('input')[1].value"
     
        let passS0 = "document.getElementsByTagName('input')[2].value"
         
        let passS1 = "document.getElementsByTagName('input')[3].value"
              
        let checkS1 = "document.getElementsByTagName('input')[4].checked"
        //checkbox-2
              
        webView.evaluateJavaScript(nameS) { (result, error) in
        
            if let name = result {
            
                self.webView.evaluateJavaScript(idS) { (result, error) in
                
                    if let email = result {
                        
                        let ret =  CoreDataManager.shared.istUser(query: email as! String)
                        if(ret == true)
                        {
                            self.Alert(question: "가입되어 있는 메일입니다.\n다른 메일을 사용하세요.", text: "")
                 
                            return
                        }
                    
                      self.webView.evaluateJavaScript(passS0) { (result, error) in
                      
                          if let pass0 = result {
                          
                            self.webView.evaluateJavaScript(passS1) { (result, error) in
                                               
                            
                                if let pass1 = result {
                                
                                    self.webView.evaluateJavaScript(checkS1) { (result, error) in
                                                                              
                                                           
                                                            
                                        if let check = result {
                                        
                                      //      let checkPrivacy = check as! Bool
                                            if((name as? String)!.count > 0 && (email as? String)!.count > 0 &&
                                                (pass0 as? String)!.count > 0 && (pass1 as? String)!.count > 0 )
                                            {
                                                if( pass0 as? String == pass1 as? String)
                                                {
                                                    if((check as! Bool) == true)
                                                    {
                                                        // Success
                                                        /*
                                                       
                                                        */
                                                         self.webView.evaluateJavaScript(countryS) { (result, error) in
                                                                      
                                                             if let country = result
                                                            {
                                                                if( (country as? String)!.count > 0)
                                                                {
                                                                    CoreDataManager.shared.saveUser(name: name as! String, id: email as! String, password: pass0 as! String, country: (country as? String)!,answer: "", type:"", onSuccess:{ (success) in
                                                                        var success:Bool = false
                                                                        (self.user, sucess:success ) = CoreDataManager.shared.getUser(query: email as! String)
                                                                    
                                                                        UserDefaults.standard.set(email,forKey: "USER_ID")
                                                                        UserDefaults.standard.setValue(false, forKey: "INIT_DB")
                                                                        UserDefaults.standard.synchronize()
                                                                
                                                                        UserDefaults.standard.synchronize()
                                                               
                                                                        CoreDataManager.shared.updateUser(id: email as! String)
                                                                        /*
                                                                        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.3", ofType: "html", inDirectory:"www/ucp-v03-g")!)
                                                                        
                                                                        self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
 */
                                                                        self.loadInitialize()
                                                                        
                                                                                                                  
                                                                    })
                                                                }
                                                                else
                                                                {
                                                                    // fail
                                                                    // 귝거채크
                                                                    self.Alert(question: "국가를 선택하셔야 가입이 됩니다.", text: "")
                                                        
                                                                }
                                                                
                                                            }
                                                                                                              
                                                        }
                                                        
                                                                                                     
                                                    }
                                                    else
                                                    {
                                                        //fail
                                                        // 정보 동의 체크
                                                        self.Alert(question: "정보 관련 사항을 동의하셔야 가입이 됩니다.", text: "")
                                            
                                                    }
                                               
                                                }
                                                else
                                                {
                                                    // 비밀번호를 체크
                                                    self.Alert(question: "비밀번호가 일치하지 않습니다.", text: "")
                                        
                                        
                                          
                                                    
                                                }
                                            }
                                            else
                                            {
                                                //
                                                self.Alert(question: "정보를 모두 정확하게 입력하세요.", text: "")
                                    
                                            }
                                            
                                           
                                            
                                        }
                                        
                                    }
                                
                                }
                                                   
                                            
                            }
                              
                          }
                          
                      }

                        
                    }
                    
                }
            }
            
        }
    }
    func processLogin()
    {
       
        let jsString0 = "document.getElementsByTagName('input')[0].value"
        
        let jsString1 = "document.getElementsByTagName('input')[1].value"
      
        
        webView.evaluateJavaScript(jsString0) { (result, error) in
        
            if let id = result {
            
                var sucess:Bool = false
                ( self.user, sucess:sucess ) = CoreDataManager.shared.getUser(query: id as! String)
                if(sucess == false )
                {
                    self.Alert(question: "회원가입이 되어있지 않습니다.", text: "")
        
                }
                      
                if((id as! String).count > 0  && self.user.userid!.count > 0 && self.user.userid == (id as! String))
                {
                    // userid 존재
                    self.webView.evaluateJavaScript(jsString1) { (result, error) in
                               
                                
                        if let pass = result {
                                   
                            if(self.user.password == pass as? String )
                            {
                                 
                                let oldUserId = UserDefaults.standard.string(forKey: "USER_ID")
                                if(oldUserId != self.user.userid!)
                                {
                                    UserDefaults.standard.setValue(false, forKey: "INIT_DB")
                                }
                            
                                UserDefaults.standard.set(self.user.userid!,forKey: "USER_ID")
                                UserDefaults.standard.synchronize()
                             
                                CoreDataManager.shared.updateUser(id:self.user.userid!)
                                /*
                                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.3", ofType: "html", inDirectory:"www/ucp-v03-g")!)
                                
                                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
 */
                                self.loadInitialize()
                       
                                
                            }
                            
                            else
                            {
                            
                                self.Alert(question: "패스워드를 정확하게 입력하세요.", text: "")
                                             

                            }
                            
                        }
                        else
                        {
                            self.Alert(question: "정보를 정확하게 입력하세요.", text: "")
                                
                        }
                        
                    
                
                    }
                }
                else{
                    
                                   
                         
                    self.Alert(question: "정보를 정확하게 입력하세요.", text: "")
                    
                    
                }
            
        
            }
            else
            {
                       
                self.Alert(question: "정보를 정확하게 입력하세요.", text: "")
                
            }
        }
                    
    }
    func goSignUp()
    {
        
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.2", ofType: "html", inDirectory:"www/ucp-v03-home")!)
        
        self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        
        
    }
    func getApplicationAnchorNode(index:Int) -> String
    {
        
        
        var script = "document.getElementById"
        
        if(index == 0)
        {
            script = script + "('MacOS')"
        }
        if(index == 1)
        {
            script = script + "('Pages')"
        }
        if(index == 2)
        {
            script = script + "('Keynote')"
        }
        if(index == 3)
        {
            script = script + "('Numbers')"
        }
        if(index == 4)
        {
            script = script + "('Safari')"
        }
        if(index == 5)
        {
            script = script + "('Chrome')"
        }
        if(index == 6)
        {
            script = script + "('Firefox')"
        }
        if(index == 7)
        {
            script = script + "('Youtube')"
        }
        if(index == 8)
        {
            script = script + "('Netflix')"
        }
        if(index == 9)
        {
            script = script + "('Google docs')"
        }
        if(index == 10)
        {
            script = script + "('Google spreadsheet')"
        }
        if(index == 11)
        {
            script = script + "('Google slides')"
        }
        if(index == 12)
        {
            script = script + "('MS word')"
        }
        if(index == 13)
        {
            script = script + "('MS Excel')"
        }
        if(index == 14)
        {
            script = script + "('MS Power point')"
        }
        if(index == 15)
        {
            script = script + "('Evernote')"
        }

      
       return script
        
       
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
        clean()
        
        deleteCache()
        
        
        if(webView != nil)
        {
    //        webView.evaluateJavaScript("document.body.remove()")
        }
      
        if navigationAction.navigationType == WKNavigationType.linkActivated {
        
            if(navigationAction.request.url?.absoluteString.contains("login.html") == true)
            {
                  
                processLogin()
               // NSWorkspace.shared.launchApplication("pero core")
                let mainAppIdentifier = "com.junsoft.Pero"
            
                let runningApps = NSWorkspace.shared.runningApplications
                let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

                if(!isRunning)
                {
                    NSWorkspace.shared.launchApplication("pero core")

                }
                
          
    
            }
            if(navigationAction.request.url?.absoluteString.contains("main.html") == true)
            {
                  
                
               // loadIntro()
                loadSettings()
    
            }
             
             
            if(navigationAction.request.url?.absoluteString.contains("signup.html") == true)
            {
                 goSignUp()
                
                
            }
            if(navigationAction.request.url?.absoluteString.contains("signup_submit.html") == true)
            {
                
                
                processSignUp()
                let mainAppIdentifier = "com.junsoft.Pero"
            
                let runningApps = NSWorkspace.shared.runningApplications
                let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

                if(!isRunning)
                {
                    NSWorkspace.shared.launchApplication("pero core")

                }
                
            }
            //signup_submit.html
            if(navigationAction.request.url?.absoluteString.contains("ustart.html") == true)
            {
                
                decisionHandler(.allow)
                startUsageType()
                
            }
            if(navigationAction.request.url?.absoluteString.contains("back.html") == true)
            {
               
                   decisionHandler(.allow)
                   backIntro()
               
            }
            if(navigationAction.request.url?.absoluteString.contains("lefthand.html") == true)
            {
               
                
                decisionHandler(.allow)
                
                setHandTypeL()
                
                handType = "1"
               
            }
            if(navigationAction.request.url?.absoluteString.contains("righthand.html") == true)
            {
               
                
                decisionHandler(.allow)
                
                setHandTypeR()
                
                handType = "2"
                
               
            }
            if(navigationAction.request.url?.absoluteString.contains("env.html") == true)
            {
             
               
                let list = navigationAction.request.url?.absoluteString.components(separatedBy:  "?")
                
                if(list!.count > 1)
                {
                
                    let strWork  = list![1]
                    
                    usageType4 = strWork
                    
                    usageType = handType + usageType2 + usageType3 + usageType4
                    
                    let ret =  CoreDataManager.shared.getUserType(query: usageType)
                    
                    let id = user.userid
                    let password = user.password
                    let country = user.country
                    let name = user.name
                    
                    
                    
                    CoreDataManager.shared.saveUser(name: name! , id: id!, password: password!, country: country!,answer: usageType, type:ret, onSuccess:{ (success) in
                                                                                               
                    
                        print(success)
                    
                        self.initLocalCommandDB()
                                                                                      
                    })
                    
                    
                    print(ret)
                }
                
                decisionHandler(.allow)
                
                setUserEnvironment()
             
            }
            if(navigationAction.request.url?.absoluteString.contains("no.9-1.html") == true)
            {
                setUserIndex()
            }
            //
            if(navigationAction.request.url?.absoluteString.contains("NO.6.html") == true)
            {
                   
                let list = navigationAction.request.url?.absoluteString.components(separatedBy:  "?")
                      
            
                if(list!.count > 1)
                {
                
                    let strWork  = list![1]
                    usageType2 = strWork
                    print(strWork)
                
                }
                decisionHandler(.allow)

                
                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.6", ofType: "html", inDirectory:"www/ucp-v03-g")!)
                
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                
                       
            }
            if(navigationAction.request.url?.absoluteString.contains("tutorial.html") == true)
            {
                   
               
                decisionHandler(.allow)

                
                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.17", ofType: "html", inDirectory:"www/ucp-v03-t")!)
                
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                
                       
            }
            if(navigationAction.request.url?.absoluteString.contains("delete.html") == true)
            {
                   
               
                decisionHandler(.allow)

                
                self.ConfirmDelete()
                
                       
            }
            if(navigationAction.request.url?.absoluteString.contains("logout.html") == true)
            {
                   
               
                decisionHandler(.allow)

                
                self.ConfirmLogout()
                
                       
            }
            if(navigationAction.request.url?.absoluteString.contains("initial.html") == true)
            {
                   
               
                UserDefaults.standard.setValue(true, forKey: "INIT_INITIAL")
                UserDefaults.standard.synchronize()
       
                initLocalCommandDB()
                decisionHandler(.allow)

                /*
                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.3", ofType: "html", inDirectory:"www/ucp-v03-g")!)
                
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
 */
                loadInitialize()
       
                
                       
            }
            //initial.html

            if(navigationAction.request.url?.absoluteString.contains("NO.7.html") == true)
            {
                   
                let list = navigationAction.request.url?.absoluteString.components(separatedBy:  "?")
                      
            
                if(list!.count > 1)
                {
                
                    let strWork  = list![1]
                    usageType3 = strWork
                    print(strWork)
                
                }
                decisionHandler(.allow)
                       
            }

 
        }
        else if navigationAction.navigationType == WKNavigationType.formSubmitted
        {
            print("")
        }
        else
        {
            print(navigationAction.navigationType)
        }

          decisionHandler(.allow)
    }
    // w--tab-active
    
    func initApplication()
    {
        deleteCache()
  
        UserDefaults.standard.setValue(false, forKey: "INIT_INITIAL")
        UserDefaults.standard.synchronize()

        selectedGestureIndex = 0
        selectedGestureOldIndex = 0
        
        selectedGesture = "L"
        selectedOldGesture = "L"
        
        selectedCode = ModelManager.shared.Left()
        selectedOldCode = ModelManager.shared.Left()

        getUserType(condition: selectedApplication)
        getUserType2(condition: selectedApplication)
            
        let jsString0 = "document.getElementsByTagName('h6')[2].innerHTML = " + "'" + String(self.user.name!) + "';"
         
        
        
        let str =  getSelectEventListener()
        
        var mouseover =
         "var arrow_a;" +
         "var arrow_element = document.getElementsByClassName('tab-link-g-img');" +
         "var arrow_element_a = document.getElementsByClassName('tab-link-g w-inline-block w-tab-link');" +
         "arrow_element[0].src = arrow_element[0].src.replace('1.', '2.');" +

         "for (var i = 0; i < 16; i++) {" +
         "    arrow_element[i].addEventListener('mouseover', mover);" +
         "   arrow_element[i].addEventListener('mouseout', mout);" +
         "    arrow_element[i].addEventListener('click', mcli);" +
         "    function mover() {" +
         "        var img_src = this.src;" +
         "        this.src = img_src.replace('1.', '2.');" +
         "    }" +
         "    function mout() {" +
         "        var img_src = this.src;" +
         "        if (this.parentNode.className != 'tab-link-g w-inline-block w-tab-link w--current') { " +
         "            this.src = img_src.replace('2.', '1.');" +
         "        }" +
         "    }" +
         "    function mcli() { " +
         "        for (var x = 0; x < 16; x++) {" +
         "            var clear = arrow_element[x].src;" +
         "            arrow_element[x].src = clear.replace('2.', '1.');" +
         "        }" +
         "        var img_src = this.src;" +
         "        this.src = img_src.replace('1.', '2.');" +
         "    }" +
         "}" +
         "for (var i = 16; i < 32; i++) {" +
         "    arrow_element[i].src = arrow_element[i].src.replace('1.', '2.');" +
         "}" +
            
         "for (var i = 0; i < arrow_element_a.length; i++) {" +
         "    arrow_element_a[i].addEventListener('click', mcli2);" +
         "    function mcli2() {" +
         "        var clear = this.childNodes[0].src;" +
         "        for (var x = 0; x < 16; x++) {" +
         "            arrow_element[x].src = arrow_element[x].src.replace('2.', '1.');" +
         "        }" +
         "        this.childNodes[0].src = clear;" +
         "    }" +
         "}"
        
        getGestureNodeStr(index: 0)
        
        let dictionary = Bundle.main.infoDictionary
       let version0 = dictionary!["CFBundleShortVersionString"] as? String

     //  let ver = self.version
        print(compileDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let dateString = dateFormatter.string(from: compileDate)
        
        
        var updateStr = "var version_info = document.getElementsByClassName('paragraph-3');" +
                        "version_info[0].innerHTML = " +
                        "'Ver " +
                        String(version0!) +
                        "<br />Last update " +
                        String(dateString) +
                        "<br /><strong>© palmcat corp. All Rights Reserved.</strong><br />'"
                   
        
    
        let source =
            jsString0
            +   "var g1 = " + getGestureNodeStr(index: 0) + ";"
        +   "g1.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L1' + 'g00');"
        +   "});"
            +   "var g2 = " + getGestureNodeStr(index: 1) + ";"
        +   "g2.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L2' + 'g01');"
        +   "});"
        
        +   "var g3 = " + getGestureNodeStr(index: 2) + ";"
        +   "g3.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L3' + 'g02');"
        +   "});"
            +   "var g4 = " + getGestureNodeStr(index: 3) + ";"
        +   "g4.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L4' + 'g03');"
        +   "});"
            +   "var g5 = " + getGestureNodeStr(index: 4) + ";"
        +   "g5.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L5' + 'g04');"
        +   "});"
            +   "var g6 = " + getGestureNodeStr(index: 5) + ";"
        +   "g6.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L6' + 'g05');"
        +   "});"
            +   "var g7 = " + getGestureNodeStr(index: 6) + ";"
        +   "g7.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L7' + 'g06');"
        +   "});"
            +   "var g8 = " + getGestureNodeStr(index: 7) + ";"
        +   "g8.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L8' + 'g07');"
        +   "});"
           
            +   "var g9 = " + getGestureNodeStr(index: 8) + ";"
        +   "g9.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L9' + 'g08');"
        +   "});"
            
            +   "var g10 = " + getGestureNodeStr(index: 9) + ";"
        +   "g10.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L10' + 'g09');"
        +   "});"
            
            +   "var g11 = " + getGestureNodeStr(index: 10) + ";"
        +   "g11.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L11' + 'g10');"
        +   "});"
            +   "var g12 = " + getGestureNodeStr(index: 11) + ";"
        +   "g12.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L12' + 'g11');"
        +   "});"
           
            +   "var g13 = " + getGestureNodeStr(index: 12) + ";"
        +   "g13.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L13' + 'g12');"
        +   "});"
            +   "var g14 = " + getGestureNodeStr(index: 13) + ";"
        +   "g14.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L14' + 'g13');"
        +   "});"
            +   "var g15 = " + getGestureNodeStr(index: 14) + ";"
        +   "g15.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L15' + 'g14');"
        +   "});"
            +   "var g16 = " + getGestureNodeStr(index: 15) + ";"
        +   "g16.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L16' + 'g15');"
        +   "});"
        + str + ";"  + mouseover + updateStr
        
     
   
        
 
        
        webView.evaluateJavaScript(source) { (result, error) in
        
                // 로그인 이름 설정
          
            
        }
    }
    
    func setAppInfo()
    {
        let dictionary = Bundle.main.infoDictionary
       let version0 = dictionary!["CFBundleShortVersionString"] as? String

     //  let ver = self.version
        print(compileDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let dateString = dateFormatter.string(from: compileDate)

        var updateStr = "var version_info = document.getElementsByClassName('paragraph-3');" +
                        "version_info[0].innerHTML = " +
                        "'Ver " +
                        String(version0!) +
                        "<br />Last update " +
                        String(dateString) +
                        "<br /><strong>© palmcat corp. All Rights Reserved.</strong><br />'"
             
        webView.evaluateJavaScript(updateStr) { (result, error) in
        
                //
          
            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //ready to be processed
        let title = webView.title
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
      
        setAppInfo()
        let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
        userDefaults!.set(false, forKey: "TOUCH_MODE")
        userDefaults!.set(userId, forKey: "USER_ID")
     
        userDefaults!.set(-1, forKey: "TOUCH_INDEX")
        userDefaults!.synchronize()
   
        if( title == "c2")
        {
    
        //    let userId = UserDefaults.standard.string(forKey: "USER_ID")
            CoreDataManager.shared.save(mode: false) { (success) in
                
            }
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            
 
        
        }
        else if(title == "g1")
        {
            //image-3
            print("g1")
        }
        else if(title == "f1")
        {
            appDelegate?.controller = self
            handIndex = 1
            appDelegate?.handIndex = handIndex
          
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(1, forKey: "TOUCH_INDEX")
       
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
  
        }
        else if(title == "f2")
        {
            handIndex = 2
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(2, forKey: "TOUCH_INDEX")
      
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
     
   
        }
        else if(title == "f3")
        {
            handIndex = 3
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(3, forKey: "TOUCH_INDEX")
      
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
   
   
        }
        else if(title == "f4")
        {
            handIndex = 4
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(-1, forKey: "TOUCH_INDEX")
      
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
     
   
        }
        else if(title == "f5")
        {
            handIndex = 5
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
       
            userDefaults!.set(1, forKey: "TOUCH_INDEX")
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
   
   
        }
        else if(title == "f6")
        {
            handIndex = 6
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(2, forKey: "TOUCH_INDEX")
      
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
     
   
        }
        else if(title == "f7")
        {
            handIndex = 7
            appDelegate?.handIndex = handIndex
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(true, forKey: "TOUCH_MODE")
            userDefaults!.set(3, forKey: "TOUCH_INDEX")
      
            userDefaults!.synchronize()
            CoreDataManager.shared.save(mode: true) { (success) in
                
            }
    
   
        }
        else if(title ==  "m2-app1")
        {
       
            selectedApplication = "MacOS"
            initApplication()
            
        }
        else if(title ==  "chrome")
        {
       
            selectedApplication = "Chrome"
            initApplication()
            
        }
        else if(title ==  "evernote")
        {
       
            selectedApplication = "Evernote"
            initApplication()
            
        }
        else if(title ==  "docs")
        {
       
            selectedApplication = "Google docs"
            initApplication()
            
        }
        else if(title ==  "firefox")
        {
       
            selectedApplication = "Firefox"
            initApplication()
            
        }
        else if(title ==  "keynote")
        {
       
            selectedApplication = "Keynote"
            initApplication()
            
        }
        else if(title ==  "msexcel")
        {
       
            selectedApplication = "MS Excel"
            initApplication()
            
        }
        else if(title ==  "msppt")
        {
       
            selectedApplication = "MS Powerpoint"
            initApplication()
            
        }
        else if(title ==  "msword")
        {
       
            selectedApplication = "MS word"
            initApplication()
            
        }
        else if(title ==  "netflix")
        {
       
            selectedApplication = "Netflix"
            initApplication()
            
        }
        else if(title ==  "numbers")
        {
       
            selectedApplication = "Numbers"
            initApplication()
            
        }
        else if(title ==  "pages")
        {
       
            selectedApplication = "Pages"
            initApplication()
            
        }
        else if(title ==  "safari")
        {
       
            selectedApplication = "Safari"
            initApplication()
            
        }
        else if(title ==  "slides")
        {
       
            selectedApplication = "Google slides"
            initApplication()
            
        }
        else if(title ==  "spreadsheet")
        {
       
            selectedApplication = "Google sheets"
            initApplication()
            
        }
        else if(title ==  "youtube")
        {
       
            selectedApplication = "Youtube"
            initApplication()
            
        }
        //
        
    }
    func getGestureNodeStr(index:Int) -> String
    {
        var ret:String = String()
        if(index == 0)
        {
            ret = "document.getElementById('w-node-4e0e9b926667-be8be136')"
        }
        if(index == 1)
        {
            ret = "document.getElementById('w-node-4e0e9b926669-be8be136')"
        }
        if(index == 2)
        {
            ret = "document.getElementById('w-node-4e0e9b92666b-be8be136')"
        }
        if(index == 3)
        {
            ret = "document.getElementById('w-node-4e0e9b92666d-be8be136')"
        }
        if(index == 4)
        {
            ret = "document.getElementById('w-node-4e0e9b92666f-be8be136')"
        }
        if(index == 5)
        {
            ret = "document.getElementById('w-node-4e0e9b926671-be8be136')" //
        }
        if(index == 6)
        {
            ret = "document.getElementById('w-node-4e0e9b926673-be8be136')"//
        }
        if(index == 7)
        {
            ret = "document.getElementById('w-node-4e0e9b926675-be8be136')"//
        }
        if(index == 8)
        {
            ret = "document.getElementById('w-node-4e0e9b92667a-be8be136')" //
        }
        if(index == 9)
        {
            ret = "document.getElementById('w-node-4e0e9b92667c-be8be136')" //
        }
        if(index == 10)
        {
            ret = "document.getElementById('w-node-4e0e9b92667e-be8be136')" //
        }
        if(index == 11)
        {
            ret = "document.getElementById('w-node-4e0e9b926680-be8be136')" //
        }
        if(index == 12)
        {
            ret = "document.getElementById('w-node-4e0e9b926682-be8be136')" //
        }
        if(index == 13)
        {
            ret = "document.getElementById('w-node-4e0e9b926684-be8be136')" //
        }
        if(index == 14)
        {
            ret = "document.getElementById('w-node-4e0e9b926686-be8be136')" //
        }
        if(index == 15)
        {
            ret = "document.getElementById('w-node-4e0e9b926688-be8be136')"
        }

        return ret
    
      
    }
    func getGestureSubTargetStr(index:Int) -> String
   
    {
    
        var ret:String = String()
         
        
        ret = "document.getElementById('L" + String(index + 1) + "')"
        
 

         return ret
     
       
     }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       
        DispatchQueue.main.async { [self] in
            deleteCache()
            
            
            
            
            let content = message.body as! String
            var msg = String()
            if(content.contains("logo") == true)
            {
                let ret =  UserDefaults.standard.bool(forKey:  "INIT_INITIAL")
              
                if(ret == true )
                {
                    loadSettings()
              
                }
                 return
            }
            for i in 0..<content.characters.count - 3{
               
                let index = content.index(content.startIndex, offsetBy:i)
                
                msg.append(content[index])
                
            }
            var msg2 = String()
            for i in content.characters.count - 3..<content.characters.count{
             
                let index = content.index(content.startIndex, offsetBy:i)
              
              msg2.append(content[index])
              
            }
               
        
            if(msg2.contains("t3") == true) // touch 3
            {
               
                print("message: \(msg)")
                let type =  CoreDataManager.shared.getUserType(query: usageType)
                
          
                let commands =  CoreDataManager.shared.getCommandGesture(name: selectedApplication, touch: "t3", gesture: selectedGesture,id:self.user.userid!)
          
                if(msg == "Not Selected...")
                {
                    for command in commands
                    {
                        CoreDataManager.shared.updateCommand(name: selectedApplication, type:type, group: selectedApplication, gesture: "", shortcut: "",
                                                             command: command.command!, enable:false,touch:"t3",id:self.user.userid!, onSuccess: { (success) in
                                                                       
                                
                        })
                    }
                    getUserType(condition: selectedApplication)
                    
               //     getUserType2(condition: selectedApplication)
             
                    return
                }
               
               
                for command in commands
                {
                    CoreDataManager.shared.updateCommand(name: selectedApplication, type:type, group: selectedApplication, gesture: "", shortcut: "",
                                                         command: command.command!, enable:false,touch:"t3",id:self.user.userid!, onSuccess: { (success) in
                                                                   
                            
                    })
                }
                
                let use =  CoreDataManager.shared.use(command: msg, name: selectedApplication, touch: "t3")
                   
                self.oldCommand = msg
                selectedOldGesture = selectedGesture
                
                selectedOldCode = selectedCode
                       
                
                CoreDataManager.shared.updateCommand(name: selectedApplication, type:type, group: selectedApplication, gesture: selectedGesture, shortcut: "",
                                                   command: msg, enable:true,touch:"t3",id:self.user.userid!, onSuccess: { (success) in
                                                    
                                                    
                })
                  
                getUserType(condition: selectedApplication)
                
               // getUserType2(condition: selectedApplication)
                
                UserDefaults.standard.set(self.user.userid,forKey: "USER_ID")
                UserDefaults.standard.synchronize()
          
                
            }
            else if(msg2.contains("t4") == true) // touch 4
            {
                  
                print("message: \(msg)")
                let type =  CoreDataManager.shared.getUserType(query: usageType)
                       
       
                let commands =  CoreDataManager.shared.getCommandGesture(name: selectedApplication, touch: "t4", gesture: selectedGesture,id:self.user.userid!)
                
                
                if(msg == "Not Selected...")
                {
                    for command in commands
                    {
                        CoreDataManager.shared.updateCommand(name: selectedApplication, type:type, group: selectedApplication, gesture: "", shortcut: "",
                                                             command: command.command!, enable:false,touch:"t4",id:self.user.userid!, onSuccess: { (success) in
                                                                       
                                
                        })
                    }
                    getUserType2(condition: selectedApplication)
             
                    return
                }
                
                
                for command in commands
                {
                    CoreDataManager.shared.updateCommand(name: selectedApplication, type:type, group: selectedApplication, gesture: "", shortcut: "",
                                                         command: command.command!, enable:false,touch:"t4",id:self.user.userid!, onSuccess: { (success) in
                                                                   
                            
                    })
                }
                self.oldCommand = msg
               
                selectedOldGesture = selectedGesture
                
                selectedOldCode = selectedCode
                CoreDataManager.shared.updateCommand(name: selectedApplication, type: type, group: selectedApplication, gesture: selectedGesture, shortcut: "",
                                                   command: msg, enable:true, touch:"t4",id:self.user.userid!,onSuccess: { (success) in
                           
                    
                })
           //     getUserType(condition: selectedApplication)
               getUserType2(condition: selectedApplication)
        
                UserDefaults.standard.set(self.user.userid,forKey: "USER_ID")
                UserDefaults.standard.synchronize()
          
            }
            
            else if(msg2 == "OPT")
            {
                // application 클릭
                if(msg == "Windows Default")
                {
                    msg = "Windows"
                }
                if(msg == "MS Power point")
                {
                    //
                    msg = "MS Powerpoint"
                }
                if(msg == "MS Power point")
                {
                   //
                    msg = "MS Powerpoint"
                }
                print("message: \(msg)")
                
                selectedApplication = msg
                //
                getUserType(condition: selectedApplication)
                getUserType2(condition: selectedApplication)
                
                var oldNode = getGestureNodeStr(index: selectedGestureOldIndex)
                
                oldNode = oldNode + ".click()"
                
                          
                                   
                
                webView.evaluateJavaScript(oldNode ) { (result, error) in
                             
                }
                

            }
                    
            if(msg2.contains("g") == true)
            {
                print("message: \(msg)")
                
                
                var num = String()
                 
                for i in content.characters.count - 2..<content.characters.count{
                
                    let index = content.index(content.startIndex, offsetBy:i)
                     num.append(content[index])
                         
                      
                }
                if(selectedGestureIndex != selectedGestureOldIndex)
                {
                    oldCommand = ""
                }
                if( num == "00")
                {
                    selectedGestureIndex = 0
                    selectedGesture = "L"
                    selectedCode = ModelManager.shared.Left()
                }
                else if( num == "01")
                {
                    selectedGestureIndex = 1
                    selectedGesture = "R"
                    selectedCode = ModelManager.shared.Right()
                }
                else if( num == "02")
                {

                    selectedGestureIndex = 2
                    selectedGesture = "U"
                    selectedCode = ModelManager.shared.Up()

                }
                else if( num == "03")
                {
                    selectedGestureIndex = 3
                    selectedGesture = "D"
                    selectedCode = ModelManager.shared.Down()

                }
                else if( num == "04")
                {
                    selectedGestureIndex = 4
                    selectedGesture = "LU"
                    selectedCode = ModelManager.shared.LeftUp()

                }
                else if( num == "05")
                {

                    selectedGestureIndex = 5
                    selectedGesture = "RU"
                    selectedCode = ModelManager.shared.RightUp()

                }
                else if( num == "06")
                {
                    selectedGestureIndex = 6
                    selectedGesture = "LD"
                    selectedCode = ModelManager.shared.LeftDown()

                }
                else if( num == "07")
                {
                    selectedGestureIndex = 7
                    selectedGesture = "RD"
                    selectedCode = ModelManager.shared.RightDown()

                }
                else if( num == "08")
                {

                    selectedGestureIndex = 8
                    selectedGesture = "LUC"
                    selectedCode = ModelManager.shared.LeftUpCurve()

                }
                else if( num == "09")
                {
                    selectedGestureIndex = 9
                    selectedGesture = "RUC"
                    selectedCode = ModelManager.shared.RightUpCurve()

                }
                else if( num == "10")
                {
                    selectedGestureIndex = 10
                    selectedGesture = "LDC"
                    selectedCode = ModelManager.shared.LeftDownCurve()


                }
                else if( num == "11")
                {
                    selectedGestureIndex = 11
                    selectedGesture = "RDC"
                    selectedCode = ModelManager.shared.RightDownCurve()


                }
                else if( num == "12")
                {
                    selectedGestureIndex = 12
                    selectedGesture = "LURU"
                    selectedCode = ModelManager.shared.LeftUpRightUpCurve()


                }
                else if( num == "13")
                {
                    selectedGestureIndex = 13
                    selectedGesture = "LDRD"
                    selectedCode = ModelManager.shared.LeftDownRightDownCurve()

                }
                else if( num == "14")
                {
                    selectedGestureIndex = 14
                    selectedGesture = "RULU"
                    selectedCode = ModelManager.shared.RightUpLeftUpCurve()


                }
                else if( num == "15")
                {
                    selectedGestureIndex = 15
                    selectedGesture = "RDLD"
                    selectedCode = ModelManager.shared.RightDownLeftDownCurve()

                }
                
                var oldNode = getGestureNodeStr(index: selectedGestureOldIndex)
                oldNode = oldNode + ".classList.remove('w--current');"
                  
                var curNode = getGestureNodeStr(index: selectedGestureIndex)

                curNode =  curNode + ".classList.add('w--current');"


                //

                var oldSub = getGestureSubTargetStr(index: selectedGestureOldIndex)

                oldSub = oldSub + ".classList.remove('w--tab-active');"

                var curSub = getGestureSubTargetStr(index: selectedGestureIndex)

                curSub =  curSub + ".classList.add('w--tab-active');"

                webView.evaluateJavaScript(oldNode + curNode + oldSub + curSub) { (result, error) in

                    self.getUserType(condition: self.selectedApplication)

                    self.getUserType2(condition: self.selectedApplication)

                }
                      
                
                selectedGestureOldIndex = selectedGestureIndex
                
                 
                 
        
                
               

            }
        }
 
        
        // and whatever other actions you want to take
    }
    
    /*
             
      */
  
    func clean()
    {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
               print("[WebCacheCleaner] All cookies deleted")
               
               WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                   records.forEach { record in
                       WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                       print("[WebCacheCleaner] Record \(record) deleted")
                   }
               }
    }
    
    func loadInitialize()
    {
        deleteCache()
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.3", ofType: "html", inDirectory:"www/ucp-v03-g")!)
        
        
        let config = WKWebViewConfiguration()
                  
     //   let processPool = WKProcessPool()
    //     config.processPool = processPool
    //   config.websiteDataStore = WKWebsiteDataStore.default()

        config.processPool = WKProcessPool()
        let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
      //  cookies.forEach({ config.websiteDataStore.httpCookieStore.setCookie($0, completionHandler: nil) })

        
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        CoreDataManager.shared.save(mode: false) { (success) in
            
        }
        
        let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
       
        userDefaults!.set(false, forKey: "TOUCH_MODE")
   
        userDefaults!.synchronize()
        if(webView != nil)
        {
            DispatchQueue.main.async {
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { [self] records in
                        
                    if(records.count == 0)
                    {
                        config.userContentController.removeScriptMessageHandler(forName: "iosListener0")
                        webView.navigationDelegate = nil
                     
                        webView.removeFromSuperview()
                        
                        webView.backForwardList.perform(Selector(("_removeAllItems")))
                        
                        let str =  getSelectEventListener()
                    
                        let source =
                            "var logo = document.getElementsByClassName('image-3');"
                        +   "logo[0].addEventListener('click', function(){ "
                        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'logo');"
                        +   "});"
                     
                     
                        
                        
                        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                        
                        config.userContentController.addUserScript(script)
                        
                        config.userContentController.add(self, name: "iosListener0")
                               
                     //   config.userContentController.add(self, name: "iosListener1")
                                      
                       
                        webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                             
                        
                        let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                       
                        webView.wantsLayer = true
                        
                        
                      //  webView.scrollView.isScrollEnabled = false
                        
                      //  webView.isOpaque = false
                        webView.setValue(false, forKey: "drawsBackground")
                        webView.layer?.backgroundColor = NSColor.clear.cgColor;
                        
                        webView.allowsMagnification = false
                        webView.allowsLinkPreview = false
            
                        webView.navigationDelegate = self
                        webView.uiDelegate = self
                        
                                   
                        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                       
                       self.view.addSubview(webView)
                        return
                    }
                    
                    
                    records.forEach { record in
                             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                             print("[WebCacheCleaner] Record \(record) deleted")
                            config.userContentController.removeScriptMessageHandler(forName: "iosListener0")
                            webView.navigationDelegate = nil
                         
                            webView.removeFromSuperview()
                            
                            webView.backForwardList.perform(Selector(("_removeAllItems")))
                            
                            let str =  getSelectEventListener()
                        
                            let source =
                                "var logo = document.getElementsByClassName('image-3');"
                            +   "logo[0].addEventListener('click', function(){ "
                            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'logo');"
                            +   "});"
                         
                         
                            
                            
                            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                            
                            config.userContentController.addUserScript(script)
                            
                            config.userContentController.add(self, name: "iosListener0")
                                   
                         //   config.userContentController.add(self, name: "iosListener1")
                                          
                           
                            webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                                 
                            
                            let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                           
                            webView.wantsLayer = true
                            
                            
                          //  webView.scrollView.isScrollEnabled = false
                            
                          //  webView.isOpaque = false
                            webView.setValue(false, forKey: "drawsBackground")
                            webView.layer?.backgroundColor = NSColor.clear.cgColor;
                            
                        webView.allowsMagnification = false
                        webView.allowsLinkPreview = false
            
                            webView.navigationDelegate = self
                        webView.uiDelegate = self
                            
                                       
                            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                           
                           self.view.addSubview(webView)
                         
                            
                         }
                     }
                 }
            
        }

        
        //getApplicationAnchorNode
  
    }
    
    func loadSettings()
    {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.16_default", ofType: "html", inDirectory:"www/cup-v03-m")!)
        
          
        let config = WKWebViewConfiguration()
               
        let mainAppIdentifier = "com.junsoft.Pero"
    
        /*
        let runningApps = NSWorkspace.shared.runningApplications
      //  print(runningApps.bundleIdentifier)
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if(!isRunning)
        {
            NSWorkspace.shared.launchApplication("/Applications/Pero")

        }
        */
        let wkDataStore = WKWebsiteDataStore.nonPersistent()

        config.processPool = WKProcessPool()
        let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
        cookies.forEach({ config.websiteDataStore.httpCookieStore.setCookie($0, completionHandler: nil) })

        
        
        
        //       config.processPool = processPool
  //     config.websiteDataStore = WKWebsiteDataStore.default()

       let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if(!isRunning)
        {
            NSWorkspace.shared.launchApplication("pero core")

        }
        ////////
        /*
        let sharedCookies: Array<HTTPCookie> = HTTPCookieStorage.shared.cookies!//(for: fileURL) ?? []
        let dispatchGroup = DispatchGroup()

        //Add each cookie to the created WKWebsiteDataStore
        //Wait until all setCookie completion handlers are fired and proceed
        if sharedCookies.count > 0 {
            //Iterate over cookies in sharedCookies and add them to webviews httpCookieStore
            for cookie in sharedCookies{
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie){
                    dispatchGroup.leave()
                }
            }
            
            //Wait for dispatchGroup to resolve to make shure that all cookies are set
            dispatchGroup.notify(queue: DispatchQueue.main) { [self] in
              //Add datastorage to configuration
              config.websiteDataStore = wkDataStore
              //Now crate a new instance of the wkwebview and add our configuration with the cookies to it
                let userId = UserDefaults.standard.string(forKey: "USER_ID")
                CoreDataManager.shared.save(mode: false) { (success) in
                    
                }
                
                let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
               
                userDefaults!.set(false, forKey: "TOUCH_MODE")
           
                userDefaults!.synchronize()
                
                //getApplicationAnchorNode
                let str =  getSelectEventListener()
            
                let source =
           
                    "document.body.style.overflow = 'hidden';" +
                    "var g1 = " + getGestureNodeStr(index: 0) + ";"
                +   "g1.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L1' + 'g00');"
                +   "});"
                    +   "var g2 = " + getGestureNodeStr(index: 1) + ";"
                +   "g2.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L2' + 'g01');"
                +   "});"
                
                +   "var g3 = " + getGestureNodeStr(index: 2) + ";"
                +   "g3.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L3' + 'g02');"
                +   "});"
                    +   "var g4 = " + getGestureNodeStr(index: 3) + ";"
                +   "g4.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L4' + 'g03');"
                +   "});"
                    +   "var g5 = " + getGestureNodeStr(index: 4) + ";"
                +   "g5.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L5' + 'g04');"
                +   "});"
                    +   "var g6 = " + getGestureNodeStr(index: 5) + ";"
                +   "g6.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L6' + 'g05');"
                +   "});"
                    +   "var g7 = " + getGestureNodeStr(index: 6) + ";"
                +   "g7.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L7' + 'g06');"
                +   "});"
                    +   "var g8 = " + getGestureNodeStr(index: 7) + ";"
                +   "g8.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L8' + 'g07');"
                +   "});"
                   
                    +   "var g9 = " + getGestureNodeStr(index: 8) + ";"
                +   "g9.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L9' + 'g08');"
                +   "});"
                    
                    +   "var g10 = " + getGestureNodeStr(index: 9) + ";"
                +   "g10.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L10' + 'g09');"
                +   "});"
                    
                    +   "var g11 = " + getGestureNodeStr(index: 10) + ";"
                +   "g11.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L11' + 'g10');"
                +   "});"
                    +   "var g12 = " + getGestureNodeStr(index: 11) + ";"
                +   "g12.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L12' + 'g11');"
                +   "});"
                   
                    +   "var g13 = " + getGestureNodeStr(index: 12) + ";"
                +   "g13.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L13' + 'g12');"
                +   "});"
                    +   "var g14 = " + getGestureNodeStr(index: 13) + ";"
                +   "g14.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L14' + 'g13');"
                +   "});"
                    +   "var g15 = " + getGestureNodeStr(index: 14) + ";"
                +   "g15.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L15' + 'g14');"
                +   "});"
                    +   "var g16 = " + getGestureNodeStr(index: 15) + ";"
                +   "g16.addEventListener('click', function(){ "
                +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L16' + 'g15');"
                +   "});"
                + str
             
                
                
                let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                
                config.userContentController.addUserScript(script)
                
                config.userContentController.add(self, name: "iosListener0")
                       
             //   config.userContentController.add(self, name: "iosListener1")
                              
                
                if(webView != nil)
                {
                    webView.evaluateJavaScript("document.body.remove()")
                    
                   
                    webView.removeFromSuperview()
                }
                webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                     
                
                let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
               
                webView.wantsLayer = true
                
                
              //  webView.scrollView.isScrollEnabled = false
                
              //  webView.isOpaque = false
                webView.setValue(false, forKey: "drawsBackground")
                webView.layer?.backgroundColor = NSColor.clear.cgColor;
                
                
                webView.navigationDelegate = self
                
                           
                webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
               
               self.view.addSubview(webView)
            }
        }
        else{
             //do something else
            let userId = UserDefaults.standard.string(forKey: "USER_ID")
            CoreDataManager.shared.save(mode: false) { (success) in
                
            }
            
            let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
           
            userDefaults!.set(false, forKey: "TOUCH_MODE")
       
            userDefaults!.synchronize()
            
            //getApplicationAnchorNode
            let str =  getSelectEventListener()
        
            let source =
       
                "document.body.style.overflow = 'hidden';" +
                "var g1 = " + getGestureNodeStr(index: 0) + ";"
            +   "g1.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L1' + 'g00');"
            +   "});"
                +   "var g2 = " + getGestureNodeStr(index: 1) + ";"
            +   "g2.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L2' + 'g01');"
            +   "});"
            
            +   "var g3 = " + getGestureNodeStr(index: 2) + ";"
            +   "g3.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L3' + 'g02');"
            +   "});"
                +   "var g4 = " + getGestureNodeStr(index: 3) + ";"
            +   "g4.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L4' + 'g03');"
            +   "});"
                +   "var g5 = " + getGestureNodeStr(index: 4) + ";"
            +   "g5.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L5' + 'g04');"
            +   "});"
                +   "var g6 = " + getGestureNodeStr(index: 5) + ";"
            +   "g6.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L6' + 'g05');"
            +   "});"
                +   "var g7 = " + getGestureNodeStr(index: 6) + ";"
            +   "g7.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L7' + 'g06');"
            +   "});"
                +   "var g8 = " + getGestureNodeStr(index: 7) + ";"
            +   "g8.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L8' + 'g07');"
            +   "});"
               
                +   "var g9 = " + getGestureNodeStr(index: 8) + ";"
            +   "g9.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L9' + 'g08');"
            +   "});"
                
                +   "var g10 = " + getGestureNodeStr(index: 9) + ";"
            +   "g10.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L10' + 'g09');"
            +   "});"
                
                +   "var g11 = " + getGestureNodeStr(index: 10) + ";"
            +   "g11.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L11' + 'g10');"
            +   "});"
                +   "var g12 = " + getGestureNodeStr(index: 11) + ";"
            +   "g12.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L12' + 'g11');"
            +   "});"
               
                +   "var g13 = " + getGestureNodeStr(index: 12) + ";"
            +   "g13.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L13' + 'g12');"
            +   "});"
                +   "var g14 = " + getGestureNodeStr(index: 13) + ";"
            +   "g14.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L14' + 'g13');"
            +   "});"
                +   "var g15 = " + getGestureNodeStr(index: 14) + ";"
            +   "g15.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L15' + 'g14');"
            +   "});"
                +   "var g16 = " + getGestureNodeStr(index: 15) + ";"
            +   "g16.addEventListener('click', function(){ "
            +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L16' + 'g15');"
            +   "});"
            + str
         
            
            
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            
            config.userContentController.addUserScript(script)
            
            config.userContentController.add(self, name: "iosListener0")
                   
         //   config.userContentController.add(self, name: "iosListener1")
                          
            
            if(webView != nil)
            {
                webView.evaluateJavaScript("document.body.remove()")
                
               
                webView.removeFromSuperview()
            }
            webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                 
            
            let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
           
            webView.wantsLayer = true
            
            
          //  webView.scrollView.isScrollEnabled = false
            
          //  webView.isOpaque = false
            webView.setValue(false, forKey: "drawsBackground")
            webView.layer?.backgroundColor = NSColor.clear.cgColor;
            
            
            webView.navigationDelegate = self
            
                       
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
           
           self.view.addSubview(webView)
        }
        */
        
        /////
        
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        CoreDataManager.shared.save(mode: false) { (success) in
            
        }
        
        let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
       
        userDefaults!.set(false, forKey: "TOUCH_MODE")
   
        userDefaults!.synchronize()
        
        //getApplicationAnchorNode
        let str =  getSelectEventListener()
    
        let source =
   
            "document.body.style.overflow = 'hidden';" +
            "var g1 = " + getGestureNodeStr(index: 0) + ";"
        +   "g1.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L1' + 'g00');"
        +   "});"
            +   "var g2 = " + getGestureNodeStr(index: 1) + ";"
        +   "g2.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L2' + 'g01');"
        +   "});"
        
        +   "var g3 = " + getGestureNodeStr(index: 2) + ";"
        +   "g3.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L3' + 'g02');"
        +   "});"
            +   "var g4 = " + getGestureNodeStr(index: 3) + ";"
        +   "g4.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L4' + 'g03');"
        +   "});"
            +   "var g5 = " + getGestureNodeStr(index: 4) + ";"
        +   "g5.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L5' + 'g04');"
        +   "});"
            +   "var g6 = " + getGestureNodeStr(index: 5) + ";"
        +   "g6.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L6' + 'g05');"
        +   "});"
            +   "var g7 = " + getGestureNodeStr(index: 6) + ";"
        +   "g7.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L7' + 'g06');"
        +   "});"
            +   "var g8 = " + getGestureNodeStr(index: 7) + ";"
        +   "g8.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L8' + 'g07');"
        +   "});"
           
            +   "var g9 = " + getGestureNodeStr(index: 8) + ";"
        +   "g9.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L9' + 'g08');"
        +   "});"
            
            +   "var g10 = " + getGestureNodeStr(index: 9) + ";"
        +   "g10.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L10' + 'g09');"
        +   "});"
            
            +   "var g11 = " + getGestureNodeStr(index: 10) + ";"
        +   "g11.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L11' + 'g10');"
        +   "});"
            +   "var g12 = " + getGestureNodeStr(index: 11) + ";"
        +   "g12.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L12' + 'g11');"
        +   "});"
           
            +   "var g13 = " + getGestureNodeStr(index: 12) + ";"
        +   "g13.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L13' + 'g12');"
        +   "});"
            +   "var g14 = " + getGestureNodeStr(index: 13) + ";"
        +   "g14.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L14' + 'g13');"
        +   "});"
            +   "var g15 = " + getGestureNodeStr(index: 14) + ";"
        +   "g15.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L15' + 'g14');"
        +   "});"
            +   "var g16 = " + getGestureNodeStr(index: 15) + ";"
        +   "g16.addEventListener('click', function(){ "
        +   "       window.webkit.messageHandlers.iosListener0.postMessage( 'L16' + 'g15');"
        +   "});"
        + str
     
        
        
              
     //   config.userContentController.add(self, name: "iosListener1")
                      
        
        if(webView != nil)
        {
            //webView.evaluateJavaScript("document.body.remove()")
            DispatchQueue.main.async {
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { [self] records in
                    
                
                    if(records.count == 0)
                    {
                        config.userContentController.removeScriptMessageHandler(forName: "iosListener0")
                        webView.navigationDelegate = nil
                     
                        webView.removeFromSuperview()
                        
                        webView.backForwardList.perform(Selector(("_removeAllItems")))
                        
                        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                        
                        config.userContentController.addUserScript(script)
                        
                        config.userContentController.add(self, name: "iosListener0")
                        
                        config.allowsAirPlayForMediaPlayback = false
                       
                        webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                             
                        
                        let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                       
                        webView.wantsLayer = true
                        
                        
                      //  webView.scrollView.isScrollEnabled = false
                        
                      //  webView.isOpaque = false
                        webView.setValue(false, forKey: "drawsBackground")
                        webView.layer?.backgroundColor = NSColor.clear.cgColor;
                        webView.allowsMagnification = false
                        webView.allowsLinkPreview = false
            
                        webView.allowsBackForwardNavigationGestures = false
                        webView.navigationDelegate = self
                        webView.uiDelegate = self
                  
                                   
                        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                       
                       self.view.addSubview(webView)
                        
                        return
                    }
                    
                    
                         records.forEach { record in
                             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                             print("[WebCacheCleaner] Record \(record) deleted")
                            config.userContentController.removeScriptMessageHandler(forName: "iosListener0")
                          
                            config.allowsAirPlayForMediaPlayback = false
                            webView.navigationDelegate = nil
                         
                            webView.removeFromSuperview()
                            
                            webView.backForwardList.perform(Selector(("_removeAllItems")))
                            
                            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                            
                            config.userContentController.addUserScript(script)
                            
                            config.userContentController.add(self, name: "iosListener0")
                           
                            webView = MyWKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 700), configuration: config)
                                 
                            
                            let color : CGColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                           
                            webView.wantsLayer = true
                            
                            
                          //  webView.scrollView.isScrollEnabled = false
                            
                          //  webView.isOpaque = false
                            webView.setValue(false, forKey: "drawsBackground")
                            webView.layer?.backgroundColor = NSColor.clear.cgColor;
                            
                      
                            webView.allowsMagnification = false
                            webView.allowsLinkPreview = false
                
                            webView.allowsBackForwardNavigationGestures = false
                         
                       //     webView.backForwardList.backList.removeAll()
                            webView.navigationDelegate = self
                            webView.uiDelegate = self
                      
                                       
                            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                           
                           self.view.addSubview(webView)
                            
                            
                         }
                     }
                 }
          
        }
        
  
 
   
    }
    @objc func timerAction(){

        loadSettings()

        timer.invalidate()
        
    }
 
    func nextFinger()
    {
        if(handIndex == 1)
        {
         
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.10", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
         

        }
        if(handIndex == 2)
        {
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.11", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

        }
        if(handIndex == 3)
        {
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.12", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

         
        }
        if(handIndex == 4)
        {
         
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.13", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

        }
        if(handIndex == 5)
        {
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.14", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

         
        }
        if(handIndex == 6)
        {
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.15", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

        }
        if(handIndex == 7)
        {
         
            appDelegate?.controller = nil
   
            let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "c2", ofType: "html", inDirectory:"www/ucp-v03-f")!)
              
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

        }
 }
    
    func  processTouchpanel(touch:Int, mode:Bool)
    {
        print(touch)
  
   
  
        if(touch > 0)
        {
        // good
            if(mode == true)
            {
                /*
                if(down == true)
                {
         
                    tTimer.invalidate()
                    tTimer.fire()
                    down = false
              
                }
                else
                {
                    nextFinger()
          
                }
                */
                
                nextFinger()

            //    nextFinger()
          
            }
            else
            {
                down = true
               
                changeRecocognitionText()
            
             //   tTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerAction0), userInfo: nil, repeats: false)
         
            }
        }
        else
        {
            if(mode == false)
            {
                let script =
                            "document.getElementById('invalid').click()"
                webView.evaluateJavaScript(script) { [self] (result, error) in
                      
                    
                //    tTimer.invalidate()
                //    tTimer.fire()
     
                    down = true
            
                }
            }
        
        }
    
   }
  
  
    func changeRecocognitionText()
    {
       //
        var script =
            "var release_txt = document.getElementsByClassName('g-q2');" +
            "var state_txt = document.getElementsByClassName('txt-ask-touch');" +
            "function toggle() {" +
            "    state_txt[0].innerHTML = '<b>Please take your finger off.<br></b>';" +
            "    state_txt[0].style.color = '#000000';" +
            "}" +
            "var msg = document.getElementsByClassName('div-block-21');" +
            "msg[0].classList.remove('div-block-21');" +
            "release_txt[0].innerHTML = '<div><b>OK</b> Touch recognition is complete</div>';" +
            "release_txt[0].style.color = '#f88901';" +
            "state_txt[0].classList.add('blink');" +
            "    state_txt[0].innerHTML = '<b>Please take your finger off.<br></b>';" +
            "    state_txt[0].style.color = '#000000';" 
          
  
         //
        
        webView.evaluateJavaScript(script) { (result, error) in
                      
                          
                      
        }
    }
    
    
    let appDelegate: AppDelegate? =  NSApp.delegate as! AppDelegate//NSApplication.shared.delegate as! AppDelegate

    override func viewDidAppear() {
        super.viewDidAppear()
        
     
        appDelegate?.controller = self
        
        view.superview?.addConstraints(viewConstraints())
    
        let userID = UserDefaults.standard.string(forKey: "USER_ID")
        let mainAppIdentifier = "com.junsoft.Pero"
  
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if(!isRunning)
        {
            NSWorkspace.shared.launchApplication("pero core")

        }

       
        let init0 =   UserDefaults.standard.bool(forKey: "PALMCAT_INIT")
        if(init0 == false)
        {
            UserDefaults.standard.setValue(true, forKey: "PALMCAT_INIT")
            UserDefaults.standard.synchronize()
            CoreDataManager.shared.deleteCommands()
  
     
        }
        
        if(userID == nil || userID!.count == 0)
        {
            loadIntro()
      
        }
        else
        {
                
            var success:Bool = false
            
            let mainAppIdentifier = "com.junsoft.Pero"
            
            /*
            let runningApps = NSWorkspace.shared.runningApplications
            let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

            if(!isRunning)
            {
                NSWorkspace.shared.launchApplication("pero core")

            }
 */
          //  NSWorkspace.shared.launchApplication("pero core")

         
            (self.user, sucess:success ) = CoreDataManager.shared.getUser(query: userID as! String)
     
            loadSettings()
     
        }
       // getApplication()

    }
 
    let query = NSMetadataQuery()
      
    func getApplication()
    {
    
        let predicate = NSPredicate(format: "kMDItemKind == 'Application'")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveWorkMainNotification(_:)), name: NSNotification.Name(rawValue: "NSMetadataQueryDidFinishGatheringNotification"), object: nil)
        
        query.predicate = predicate
        query.start()
           
      //  NSNotification.
    
    }
      @objc func didRecieveWorkMainNotification(_ notification: Notification) {
         // print("Test Notification")
    
       
      }
    
   
    func connectDB()
    {
       
        let user = OHMySQLUser(userName: "dev01", password: "palmcatDEV0!", serverName: "106.10.42.103", dbName: "jcp_macos_db", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        OHMySQLContainer.shared.mainQueryContext = context
    }
    func loadIntro()
    {
        
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.1", ofType: "html", inDirectory:"www/ucp-v03-home")!)
          
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
     

    }
    
    func startUsageType()
    {
       
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.4", ofType: "html", inDirectory:"www/ucp-v03-g")!)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
    func backIntro()
    {
       
      //  let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.3", ofType: "html", inDirectory:"www/ucp-v03-g")!)
      //  webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        loadInitialize()
    }
    func setHandTypeL()
    {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.5", ofType: "html", inDirectory:"www/ucp-v03-g")!)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

    }
    func setHandTypeR()
    {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.5", ofType: "html", inDirectory:"www/ucp-v03-g")!)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

    }
    func setUserEnvironment()
    {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.8", ofType: "html", inDirectory:"www/ucp-v03-f")!)
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        
        let userDefaults = UserDefaults(suiteName: "group.junsoft.data")
       
        userDefaults!.set(true, forKey: "TOUCH_MODE")
   
        userDefaults!.synchronize()
        
        CoreDataManager.shared.save(mode: true) { (success) in
            
        }

    }
    func setUserIndex()
    {
        //NO.9-1.html
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "NO.9-1", ofType: "html", inDirectory:"www/ucp-v03-f")!)
       
        
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)

    }

    func testKey()
       {
           let eventSource = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
           let key: CGKeyCode = 0x7a     // virtual key for 'a'
           let eventDown = CGEvent(keyboardEventSource: eventSource, virtualKey: key, keyDown: true)
           let eventUp = CGEvent(keyboardEventSource: eventSource, virtualKey: key, keyDown: false)
           let location = CGEventTapLocation.cghidEventTap
           eventDown!.post(tap: location)
           eventUp!.post(tap: location)
        print("key \(key) is down")

       }
    func keyboardKeyDown(key: CGKeyCode) {

            let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
            let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true)
            event?.post(tap: CGEventTapLocation.cghidEventTap)
            print("key \(key) is down")
        }

    // release the button
    func keyboardKeyUp(key: CGKeyCode) {
            let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
            let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false)
            event?.post(tap: CGEventTapLocation.cghidEventTap)
            print("key \(key) is released")
        }
    func newDoc()
       {
           let cmd_c_D = CGEvent(keyboardEventSource: nil, virtualKey: 0x2D, keyDown: true); // 0x08 is C cmd-c down key code
           cmd_c_D!.flags = CGEventFlags.maskCommand;
        //   CGEventPost(CGEventTapLocation.CGHIDEventTap, cmd-c-D);

           cmd_c_D!.post(tap: CGEventTapLocation.cghidEventTap)
           
           
           
           let cmd_c_U = CGEvent(keyboardEventSource: nil, virtualKey: 0x2D, keyDown: false); // cmd-c up
           cmd_c_U!.flags = CGEventFlags.maskCommand;
           cmd_c_U!.post(tap: CGEventTapLocation.cghidEventTap);
       }
    override func viewDidDisappear() {
        view.superview?.removeConstraints(viewConstraints())
    }
    
    @IBAction func Next(param:Int)
    {
   //     performSegue(withIdentifier: "exec_next", sender: nil)
       // self.navigationController?.pushViewController(NextViewController(), animated: true)
    }
    @IBAction func pushAction(_ sender: AnyObject) {
  //         self.navigationController?.pushViewController(ViewController(), animated: true)
//
      //      performSegue(withIdentifier: "exec_next", sender: nil)
        /*
        if let destinationViewController = destinationViewController {
                navigationController?.push(viewController: destinationViewController, animated: true)
            }
 */
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    fileprivate func viewConstraints() -> [NSLayoutConstraint] {
        let left = NSLayoutConstraint(
            item: view, attribute: .left, relatedBy: .equal,
            toItem: view.superview, attribute: .left,
            multiplier: 1.0, constant: 0.0
        )
        let right = NSLayoutConstraint(
            item: view, attribute: .right, relatedBy: .equal,
            toItem: view.superview, attribute: .right,
            multiplier: 1.0, constant: 0.0
        )
        let top = NSLayoutConstraint(
            item: view, attribute: .top, relatedBy: .equal,
            toItem: view.superview, attribute: .top,
            multiplier: 1.0, constant: 0.0
        )
        let bottom = NSLayoutConstraint(
            item: view, attribute: .bottom, relatedBy: .equal,
            toItem: view.superview, attribute: .bottom,
            multiplier: 1.0, constant: 0.0
        )
        return [left, right, top, bottom]
    }
    override func scrollWheel(with event: NSEvent) {
             print("NoScroll")     // Just to see scroll did not occur
       
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
 
        if segue.identifier == "exec_download"{
            if let down = segue.destinationController as? Downloader {
                   
                down.name = downName
                     
            }
        }
           
        
    }
    
}


class MyWKWebView: WKWebView {
    /*
    override func scrollWheel(with event: NSEvent) {
       //  print("NoScroll")     // Just to see scroll did not occur
    }
 */
}

extension URLRequest {
    var isHttpLink: Bool {
        return self.url?.scheme?.contains("#") ?? false
    }
}

