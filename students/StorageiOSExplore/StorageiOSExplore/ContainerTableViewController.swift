//
//  ContainerTableViewController.swift
//  StorageiOSExplore
//
//  Created by Home on 23/10/16.
//  Copyright © 2016 Alicia. All rights reserved.
//

import UIKit

class ContainerTableViewController: UITableViewController {

    var client: AZSCloudBlobClient?
    var container: AZSCloudBlobContainer?
    var model: [AZSCloudBlockBlob] = []
    
    @IBAction func addBlobToStorage(_ sender: AnyObject) {
        
        uploadBlob()
    }
    
    func uploadBlob() {
        
        // Create local blob
        
        let newBlob = container?.blockBlobReference(fromName: UUID().uuidString)
        
        // Take picture or take it from resources
        
        let image = UIImage(named: "jaredLeto-suicideSquad.jpg")
        
        // Upload
        newBlob?.upload(from: UIImageJPEGRepresentation(image!, 0.5)!, completionHandler: { (error) in
            
            if error != nil {
                print(error)
                return
            }
            
            self.readAllBlobs()
        })
        
    }
    
    func downloadBlobFromStorage(_ blob: AZSCloudBlockBlob) {
        
        blob.downloadToData{ (error, data) in
            
            if let _ = error {
                print (error)
                return
            }
            
            if let _ = data {
                let image = UIImage(data: data!)
                print("Image ok")
            }
        }
    }
    
    func readAllBlobs () {
        container?.listBlobsSegmented(with: nil,
                                      prefix: nil,
                                      useFlatBlobListing: true,
                                      blobListingDetails: AZSBlobListingDetails.all,
                                      maxResults: -1,
                                      completionHandler: { (error, results) in
        
        
                                        if let _ = error {
                                            print(error)
                                            return
                                        }
                                        
                                        if !self.model.isEmpty {
                                            self.model.removeAll()
                                        }
                                        
                                        for items in (results?.blobs)! {
                                            self.model.append(items as! AZSCloudBlockBlob)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
        })
    }
    
    func eraseBlockBlobs (_ theBlob: AZSCloudBlockBlob) {
        theBlob.delete{ error in
            
            if let _ = error {
                print(error)
                return
            }
            
            self.readAllBlobs()
        }
    }
    
    func uploadBlobWithSAS() {
        
        do {
        
            let sas = "sv=2015-04-05&ss=bfqt&srt=sco&sp=rwdlacup&se=2016-10-24T04:09:31Z&st=2016-10-23T20:09:31Z&spr=https&sig=4XyoFAaSCVvtYUuTQqt00l%2Bruiw1yXdKvTCZkvzOOmw%3D"
            let credentials = AZSStorageCredentials(sasToken: sas, accountName: "amdcboot3storage")
        
            let account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            let client = account.getBlobClient()
            
            // Take picture or take it from resources
            
            let image = UIImage(named: "jaredLeto-suicideSquad.jpg")
            
            let cont = client?.containerReference(fromName: (self.container?.name)!)
            let blob = cont?.blockBlobReference(fromName: UUID().uuidString)
            
            // Upload
            
            blob?.upload(from: UIImageJPEGRepresentation(image!, 0.5)!, completionHandler: { (error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                self.readAllBlobs()
            })
        } catch let ex {
            print(ex)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        title = container?.name
    
        readAllBlobs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if model.isEmpty{
            return 0
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty{
            return 0
        }
        
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELLBLOB", for: indexPath)

        let item = model[indexPath.row]
        cell.textLabel?.text = item.blobName

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.model[indexPath.row]
        
        downloadBlobFromStorage(item)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            let item = self.model[indexPath.row]
            model.remove(at: indexPath.row)
            self.eraseBlockBlobs(item)
            
            tableView.endUpdates()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
