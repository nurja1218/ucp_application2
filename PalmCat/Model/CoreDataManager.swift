import Foundation
import CoreData
import AppKit

class CoreDataManager: NSObject {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? =  NSApp.delegate as! AppDelegate//NSApplication.shared.delegate as! AppDelegate
 
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName: String = "Users"
    
    var dbCnt:Int = 0
    
    func getUsers(ascending: Bool = false) -> [Users] {
        var models: [Users] = [Users]()
        
        if let context = context {
            let idSort: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: modelName)
            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [Users] = try context.fetch(fetchRequest) as? [Users] {
                    models = fetchResult
                }
            } catch let error as NSError {
                print("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        return models
    }
    func getUser(query:String) -> ( Users , sucess:Bool)   {
        //let query = "Rob"
        var model: Users = Users()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Users")
                      
                 
                 // The == syntax may also be used to search for an exact match
                 fetchRequest.predicate = NSPredicate(format: "userid == %@", query)
                  
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
                     //let name = fetchResult.name
                     
                     //let id = fetchResult.userid
                     if(fetchResult.count > 0)
                     {
                         print("find")
                        
                        for listEntity in fetchResult {
                            let user = listEntity as! Users
                            print(user as Any)
                            let userid = user.userid
                            let password = user.password
                            
                           
                            model = user
                            return (user , true)
                          
                        }
                     }
                     else
                     {
                      //  let data  = fetchResult as! Users
                        
                        return  (Users() , false)
                     }
                
                     
                     
                           // model = fetchResult
                 }
            
        }
     
       // model.userid = ""
      
        
        return  (Users() , false)
        
    }
    func istUser(query:String) -> ( Bool)   {
        //let query = "Rob"
        var model: Users = Users()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Users")
                      
                 
                 // The == syntax may also be used to search for an exact match
                 fetchRequest.predicate = NSPredicate(format: "userid == %@", query)
                  
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
                     //let name = fetchResult.name
                     
                     //let id = fetchResult.userid
                     if(fetchResult.count > 0)
                     {
                         print("find")
                        
                        for listEntity in fetchResult {
                            let user = listEntity as! Users
                            print(user as Any)
                            let userid = user.userid
                            let password = user.password
                            
                           
                            model = user
                            return (true)
                          
                        }
                     }
                     else
                     {
                      //  let data  = fetchResult as! Users
                        
                        return  ( false)
                     }
                
                     
                     
                           // model = fetchResult
                 }
            
        }
     
       // model.userid = ""
      
        
        return  ( false)
        
    }
    func saveUser(name:String, id: String, password: String,
                  country: String, answer:String, type:String, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                           = NSFetchRequest<NSManagedObject>(entityName: "Users")
                                   
               
            fetchRequest.predicate = NSPredicate(format: "userid == %@", id)
                                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
                if(fetchResult.count == 0)
                {
                    
                    let entity: NSEntityDescription
                        = NSEntityDescription.entity(forEntityName: modelName, in: context)!
                        
                    let user: Users = (NSManagedObject(entity: entity, insertInto: context) as? Users)!
                    
                    user.name = name
                    user.userid = id
                    user.country = country
                    user.password = password
                    user.type = type
                    user.answer = answer
                    
                    
                    contextSave { success in
                        onSuccess(success)
                    }
                }
                else
                {
                    
                    
                    fetchResult[0].setValue(name, forKey: "name")
                    fetchResult[0].setValue(id, forKey: "userid")
                    fetchResult[0].setValue(country, forKey: "country")
                                
                    fetchResult[0].setValue(password, forKey: "password")
                              
                    fetchResult[0].setValue(type, forKey: "type")
                     
                    fetchResult[0].setValue(answer, forKey: "answer")
                    contextSave { success in
                        onSuccess(success)
                    }

                }
            }
        }
        
        
    }
    func updateUser( id: String) {
        
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Users")
                      
                  
            fetchRequest.predicate = NSPredicate(format: "userid == %@", id)
              
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
         
                if(fetchResult.count > 0)
                {
                
                    var i:Int = 0
                    for listEntity in fetchResult {
                    
                        let user = listEntity as! Users
                        
                        print(user as Any)
                            
                     //   user.enable = false
                        if(user.userid == id )
                        {
                            fetchResult[i].setValue(true, forKey: "enable")
                         //   fetchResult[i].setValue(false, forKey: "touch")
                            //return
                
                        }
                        else
                        {
                            fetchResult[i].setValue(false, forKey: "enable")
                           // fetchResult[i].setValue(false, forKey: "touch")
                
                   
                        }
                           
                         i = i + 1
          
                        contextSave { success in
                           // onSuccess(success)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    func updateUser( id: String, touch:Bool) {
        
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Users")
                      
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
         
                if(fetchResult.count > 0)
                {
                
                    var i:Int = 0
                    for listEntity in fetchResult {
                    
                        let user = listEntity as! Users
                        
                        print(user as Any)
                            
                     //   user.enable = false
                        if(user.userid == id )
                        {
                        //    fetchResult[i].setValue(true, forKey: "enable")
                            fetchResult[i].setValue(touch, forKey: "touch")
                
                   
                            contextSave { success in
                               // onSuccess(success)
                                
                            }
                          
                            return
                     
                        }
                        
                           
                         i = i + 1
          
                       
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    func save( mode:Bool, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                           = NSFetchRequest<NSManagedObject>(entityName: "Dummy")
                                   
               
            //fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
                if(fetchResult.count == 0)
                {
                    
                    let entity: NSEntityDescription
                        = NSEntityDescription.entity(forEntityName: "Dummy", in: context)!
                        
                    let user: Dummy = (NSManagedObject(entity: entity, insertInto: context) as? Dummy)!
                    
                   
                    user.mode = mode
                    
                    contextSave { success in
                        onSuccess(success)
                        return
                    }
                }
                else
                {
                    
                    
                    fetchResult[0].setValue(mode, forKey: "mode")
                  
                  
                    contextSave { success in
                        onSuccess(success)
                        return
                    }

                }
            }
        }
        
        
    }
    
    func saveAppList(name:String, type: String, group: String,
                  process: String, etc:String, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                           = NSFetchRequest<NSManagedObject>(entityName: "AppList")
                                   
               
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
                if(fetchResult.count == 0)
                {
                    
                    let entity: NSEntityDescription
                        = NSEntityDescription.entity(forEntityName: "AppList", in: context)!
                        
                    let user: AppList = (NSManagedObject(entity: entity, insertInto: context) as? AppList)!
                    
                    user.name = name
                    user.type = type
                    user.group = group
                    user.etc = etc
                    user.process = process
                    
                    contextSave { success in
                        onSuccess(success)
                    }
                }
                else
                {
                    
                    
                    fetchResult[0].setValue(name, forKey: "name")
                    fetchResult[0].setValue(type, forKey: "type")
                    fetchResult[0].setValue(group, forKey: "group")
                                
                    fetchResult[0].setValue(etc, forKey: "etc")
                              
                    fetchResult[0].setValue(process, forKey: "process")
                     
                  
                    contextSave { success in
                        onSuccess(success)
                    }

                }
            }
        }
        
        
    }
    
    func saveGesture(code:String, name:String, appName:String,
                     shortcut:String,command:String,touch:String,onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                           = NSFetchRequest<NSManagedObject>(entityName: "Gestures")
                                   
               
            fetchRequest.predicate = NSPredicate(format: "code == %@", code)
                                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
               let entity: NSEntityDescription
                                    = NSEntityDescription.entity(forEntityName: "Gestures", in: context)!
                           
                  
                if(fetchResult.count == 0)
                {
                
                    let user: Gestures = (NSManagedObject(entity: entity, insertInto: context) as? Gestures)!
         
                    user.code = code
         
                    user.name = name
                    user.app_name = appName
                    user.shortcut = shortcut
                    user.command = command
                    user.touch = touch
                    
                    contextSave { success in
                        onSuccess(success)
                    }

                }
                else
                {
                    
                    fetchResult[0].setValue(code, forKey: "code")
                    fetchResult[0].setValue(name, forKey: "name")
                    fetchResult[0].setValue(appName, forKey: "app_name")
                    fetchResult[0].setValue(shortcut, forKey: "shortcut")
                    fetchResult[0].setValue(command, forKey: "command")
                    fetchResult[0].setValue(touch, forKey: "touch")
                  
                    contextSave { success in
                          onSuccess(success)
                      }
                    
                }
                
            }
        }
        
        
    }
      
    func getGesture(name:String, touch:String) -> [Gestures]   {
   

        if let context = context {
        
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                 = NSFetchRequest<NSManagedObject>(entityName: "Gestures")
                         
            
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
                return fetchResult as! [Gestures]
               
            }
            
        }
        
        return []
    }
    func updateCommand(name:String, type: String, group: String,
                       gesture: String, shortcut:String,command:String,enable:Bool, touch:String, id:String,onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context
        {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                           = NSFetchRequest<NSManagedObject>(entityName: "Command")
                                   
               
            fetchRequest.predicate = NSPredicate(format: "(name == %@)AND(command == %@)AND(userid == %@)", name, command,id)
      //      fetchRequest.predicate = NSPredicate(format: "(name == %@)AND(command == %@)", name, command)
  
            if let fetchResult = try? context.fetch(fetchRequest)  {
            
               let entity: NSEntityDescription
                                    = NSEntityDescription.entity(forEntityName: "Command", in: context)!
                           
                  if(fetchResult.count == 0)
                 
                  {
                        let user: Command = (NSManagedObject(entity: entity, insertInto: context) as? Command)!
                                
                                user.name = name
                                user.type = type
                                user.group = group
                                user.gesture = gesture
                               // user.shortcut = shortcut
                                user.command = command
                                user.enable = enable
                                user.touch = touch
                    user.userid = id
                                                
                                contextSave { success in
                                    onSuccess(success)
                                }

                
                }
                else
                  {
                      fetchResult[0].setValue(name, forKey: "name")
                      fetchResult[0].setValue(type, forKey: "type")
                      fetchResult[0].setValue(group, forKey: "group")
                                  
                      fetchResult[0].setValue(gesture, forKey: "gesture")
                                
                    //  fetchResult[0].setValue(shortcut, forKey: "shortcut")
                       fetchResult[0].setValue(command, forKey: "command")
                                  
                    fetchResult[0].setValue(enable, forKey: "enable")
                    fetchResult[0].setValue(touch, forKey: "touch")
                    fetchResult[0].setValue(id, forKey: "userid")
                 
                    contextSave { success in
                          onSuccess(success)
                      }
                    
                }
                
            }
        }
        
        
    }
    func saveCommand(name:String, id:String,type: String, group: String,
                      gesture: String, shortcut:String,command:String,enable:Bool, touch:String,onSuccess: @escaping ((Bool) -> Void)) {
         if let context = context
         {
             let fetchRequest: NSFetchRequest<NSManagedObject>
                                            = NSFetchRequest<NSManagedObject>(entityName: "Command")
                                    
                
             fetchRequest.predicate = NSPredicate(format: "(userid==%@)",id)
            
                                   
             if let fetchResult = try? context.fetch(fetchRequest)  {
 
                let entity: NSEntityDescription
                                     = NSEntityDescription.entity(forEntityName: "Command", in: context)!
                                     
                                 let user: Command = (NSManagedObject(entity: entity, insertInto: context) as? Command)!
                      
                if(fetchResult.count < dbCnt)
                {
                    user.userid = id
                     user.name = name
                     user.type = type
                     user.group = group
                     user.gesture = gesture
                     user.shortcut = shortcut
                     user.command = command
                     user.enable = enable
                     user.touch = touch
//
                                     
                     contextSave { success in
                         onSuccess(success)
                     }
                }
 
             }
         }
         
         
     }
    func getCommand(name:String, touch:String,id:String) -> [Command]   {
        //let query = "Rob"
        
        var model: Command = Command()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Command")
                      
                 
                 // The == syntax may also be used to search for an exact match
                 fetchRequest.predicate = NSPredicate(format: "(name==%@) AND (touch==%@) AND (userid==%@)", name, touch,id)
           // fetchRequest.predicate = NSPredicate(format: "(name==%@)AND(touch==%@)", name, touch)
        
       //     fetchRequest.predicate = NSPredicate(format: "(name==%@) AND(touch==%@)", name, touch)
            let sort = NSSortDescriptor(key: #keyPath(Command.name), ascending: true)
               
            fetchRequest.sortDescriptors = [sort]
               
   
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
 
                return fetchResult as! [Command]
                
            }
            
        }
     
      
        return []
        
    }
    func getCommandGesture(name:String, touch:String, gesture:String, id:String) -> [Command]   {
        //let query = "Rob"
        
        var model: Command = Command()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Command")
                      
                 
                 // The == syntax may also be used to search for an exact match
           //     fetchRequest.predicate = NSPredicate(format: "(name==%@) AND(touch==%@)AND(gesture==%@)", name, touch,gesture)
            fetchRequest.predicate = NSPredicate(format: "(name==%@) AND(touch==%@)AND(gesture==%@)AND(userid==%@)", name, touch,gesture,id)
         
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
 
                return fetchResult as! [Command]
                
            }
            
        }
     
      
        return []
        
    }
    func use(command:String, name:String,  touch:String) -> Bool   {
        //let query = "Rob"
        
        var model: Command = Command()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        var ret:Bool = false
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "Command")
                      
                 
                 // The == syntax may also be used to search for an exact match
                 fetchRequest.predicate = NSPredicate(format: "(name==%@) AND(touch==%@)AND(command==%@)", name, touch,command)
                  
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
 
                for c in fetchResult {
                    let command = c as! Command
                    
                    ret = command.enable
                    break
                }
            }
            
        }
     
      
        return ret
        
    }
    func deleteCommands()
    {
        if let context = context {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Command")

            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(batchDeleteRequest)
                contextSave { success in
                                   
                    //onSuccess(success)
                                       
                                   
                }

            } catch {
                // Error Handling
                print("error")
            }
        }
        
    }
    
    func deleteCommandsID(id:String)
    {
        if let context = context {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Command")

            fetchRequest.predicate = NSPredicate(format: "(userid==%@)", id)

            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(batchDeleteRequest)
                contextSave { success in
                                   
                    //onSuccess(success)
                                       
                                   
                }

            } catch {
                // Error Handling
                print("error")
            }
        }
        
    }
    
    
    
    func getAppList(query:String) -> AppList    {
        //let query = "Rob"
        
        var model: AppList = AppList()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
    
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "AppList")
                      
                 
                 // The == syntax may also be used to search for an exact match
                 fetchRequest.predicate = NSPredicate(format: "name == %@", query)
                  
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
                     //let name = fetchResult.name
                     
                     //let id = fetchResult.userid
                     if(fetchResult.count > 0)
                     {
                         print("find")
                        
                        for listEntity in fetchResult {
                            let app = listEntity as! AppList
                            
                           
                            model = app
                            return model
                          
                        }
                     }
                     
                     
                           // model = fetchResult
                 }
            
        }
     
      
        return model
        
    }
    func saveUserList(type:String, id: Int, answer: String,
                  onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context {
            
            
        
            let fetchRequest: NSFetchRequest<NSManagedObject>
                                    = NSFetchRequest<NSManagedObject>(entityName: "UserList")
                            
                       
                       // The == syntax may also be used to search for an exact match
        
        
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
                        
                
            if let fetchResult = try? context.fetch(fetchRequest)  {
                      
                if(fetchResult.count == 0)
                {
                    
                    let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "UserList" , in: context)!
                              
                              
                    let userList:UserList = (NSManagedObject(entity: entity, insertInto: context) as! UserList)
                    
                    userList.id = Int64(id)
                    
                    userList.type = type
                    
                    userList.answer = answer
                    
                    contextSave { success in
                    
                        onSuccess(success)
                        
                    }
                    
                    
                }
                else
                {
                    
                    fetchResult[0].setValue(Int64(id), forKey: "id")
                    
                    fetchResult[0].setValue(type, forKey: "type")
                    
                    fetchResult[0].setValue(answer, forKey: "answer")
                    contextSave { success in
                                       
                        onSuccess(success)
                                           
                                       
                    }
                    
                }
                  
            }
         
      
          
        }
    }
    func getUserType(query:String) -> String    {
        //let query = "Rob"
        var model: Users = Users()
        
    //    let request: NSFetchRequest<Users> = Users.fetchRequest()
        
        
     
        if let context = context {
            
            let fetchRequest: NSFetchRequest<NSManagedObject>
                              = NSFetchRequest<NSManagedObject>(entityName: "UserList")
                      
                 
                 // The == syntax may also be used to search for an exact match
          
            fetchRequest.predicate = NSPredicate(format: "answer == %@", query)
                  
                  
            if let fetchResult = try? context.fetch(fetchRequest)  {
                 
                     //let name = fetchResult.name
                     
                     //let id = fetchResult.userid
                     if(fetchResult.count > 0)
                     {
                         print("find")
                        
                        for listEntity in fetchResult {
                            let user = listEntity as! UserList
                         //   print(user as Any)
                            let type = user.type
                        //    context.delete(listEntity)
                          //  let password = user.password
                            
                           
                            //model = user
                            return type!
                          
                        }
                      //  try? context.save()

                     }
                     
                     
                           // model = fetchResult
                 }
            
        }
           return ""
            
       
    }
        
    
    func deleteUser(id: Int64, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
        
        do {
            if let results: [Users] = try context?.fetch(fetchRequest) as? [Users] {
                if results.count != 0 {
                    context?.delete(results[0])
                }
            }
        } catch let error as NSError {
            print("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension CoreDataManager {
    fileprivate func filteredRequest(id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        
        
        
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
    fileprivate func contextUpdate(onSuccess: ((Bool) -> Void)) {
           do {
                 
               try context?.save()
               onSuccess(true)
           } catch let error as NSError {
               print("Could not save🥶: \(error), \(error.userInfo)")
               onSuccess(false)
           }
       }
}
