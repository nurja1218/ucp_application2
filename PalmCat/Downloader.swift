//
//  Downloader.swift
//  PalmCat
//
//  Created by Junsung Park on 2020/12/17.
//  Copyright © 2020 Junsung Park. All rights reserved.
//

import Cocoa
import Alamofire

class Downloader: NSViewController {

    @IBOutlet weak var progessBar:NSProgressIndicator!
    @IBOutlet weak var progessLabel:NSTextField!
  
    var name:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.window?.center()
     
        // Do view setup here.
    }
    override func viewWillAppear() {
        
        progessBar.isIndeterminate = false
        var down = "http://www.junsoft.org/firmware/" + name
        down = down.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let downUrl = URL(string: down)!

        
        downloadApp(filename: name, url: downUrl)
           
    }
    func downloadApp(filename:String, url:URL)
    {
        let manager = FileManager.default
               
        let path = String(format: "%@", filename)
     //   let pathUrl = dataFileURL(fileName: filename)

        var downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        downloadsDirectory.appendPathComponent(path)
        
        let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("desktopURL: " + String(describing: desktopURL))
        let fileURL = desktopURL.appendingPathComponent(path)

       // self.progessBar.startAnimation(nil)
        AF.download(url)
            .downloadProgress { [self] (progress) in
                     //  self.progressLabel.text = (String)(progress.fractionCompleted)
                print(progress)
                
                DispatchQueue.main.async { [self] in
                                                    
                
                    self.progessBar.doubleValue = 100 * progress.fractionCompleted
                    
                    let value = Int(100 * progress.fractionCompleted)
                                  
                    self.progessLabel.stringValue = String(format:"%d%%", value)
                   
                                                 
                }
                
                
           //     progessBar.increment(by: progress.fractionCompleted)
            }
            .responseData { (response) in
            if(response.error == nil)
            {
                let  data = response.value
                    // let bool = manager.createFile(atPath: downloadsDirectory.path, contents: data, attributes: nil)
                try! data!.write(to: downloadsDirectory)
                
              //  self.progessBar.stopAnimation(nil)

                print(data)
                NSWorkspace.shared.open(downloadsDirectory)
                NSApp.terminate(nil)
      
                
          //      self.performSegue(withIdentifier: "exec_download", sender: nil)
          
                
            }
        }
    }
}
