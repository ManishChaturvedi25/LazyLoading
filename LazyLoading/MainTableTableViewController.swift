//
//  MainTableTableViewController.swift
//  LazyLoading
//
//  Created by ctsuser1 on 4/27/17.
//  Copyright © 2017 ManishChaturvedi. All rights reserved.
//

import UIKit

class MainTableTableViewController: UITableViewController {

    let url = URL(string:"https://itunes.apple.com/search?term=flappy&entity=software")
    
    var applicationArray = Array<AnyObject>()
    
    var cache: NSCache<AnyObject, AnyObject>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cache = NSCache()
        
        fetchDetailsFromServer()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.applicationArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)

        // Configure the cell...
        let appDetail = self.applicationArray[indexPath.row] as! ApplicationDetail
        
        cell.textLabel?.text = appDetail.sellerName
        cell.imageView?.image = UIImage(named: "placeholder")

        if self.cache?.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil {
            print("Image already in use")
            
            cell.imageView?.image = cache?.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
            
        }else {
            
            let imageUrl = URL(string: appDetail.imageUrl)!
            
            URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, reposnse, error) in
                DispatchQueue.main.async(execute: {
                    let cellToUpdate = tableView.cellForRow(at: indexPath)
                    cellToUpdate?.imageView?.image = UIImage(data: data!)
                    self.cache?.setObject(data as AnyObject, forKey:(indexPath as NSIndexPath).row as AnyObject)
                    cellToUpdate?.setNeedsLayout()
                })
            }).resume()
        }

        return cell
    }
    
    func fetchDetailsFromServer()->Void {

        let sessionConfig = URLSessionConfiguration.default
        
        let urlSession = URLSession(configuration:sessionConfig)
        
        guard  let url = self.url else {
            print("Empty Url - set eror enum")
            return
        }
    
        let dataTask = urlSession.dataTask(with: url, completionHandler: {(responseData, response, error) in
        
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Handle error using error enum")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = responseData {
                   
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:AnyObject]
                        
                        guard let modelArray = json?["results"] as! Array<AnyObject>? else {
                            print("Error parsing JSON")
                            return
                            
                        }
                        for detail in modelArray {
                            guard let urlString = detail["artworkUrl100"] as? String , let sellerName =  detail["sellerName"] as? String else {
                                return
                            }
                            
                            let appDetail = ApplicationDetail(imageUrl: urlString, sellerName: sellerName)
                            
                            self.applicationArray.append(appDetail)
                        }
                        
                        DispatchQueue.main.async(execute: {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            self.tableView.reloadData()
                        })
                        
                    }catch {
                        
                        print("Generic error enum")
                        
                    }
                    
                }
                
                
            }
            
        })
            
        dataTask.resume()
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
