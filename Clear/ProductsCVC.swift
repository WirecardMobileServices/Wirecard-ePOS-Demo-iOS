//
//  ProductsCVC.swift
//  Clear
//
//  Created by Danko, Radoslav on 16/04/2018.
//  Copyright © 2018 Danko, Radoslav. All rights reserved.
//

import UIKit
import WDePOS
private let reuseIdentifier = "CollectionCell"

class ProductsCVC: UICollectionViewController {

    var productCatalogues:[WDProductCatalogue]?
    var products:[WDProductCatalogueProduct]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(ProductCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCatalogues()
    }
    
    // MARK: - Custom Methods

    func getCatalogues(){
        let completion:ProductCatalogueCompletion!  = {(productCatalogues:[WDProductCatalogue]? , error:Error?) in
            Messages().hideActivity(onView: self.view)
            //productCatalogues - list of product catalogues of this merchant
            //                    having the latest changes after maintenance action was performed
            self.productCatalogues = productCatalogues
            if let productCatalogues = productCatalogues {
                if let productCatalogue = productCatalogues.first {
                    self.getProducts(catalogueId: productCatalogue.productCatalogueId!)
                }
            }
            
            if let  error = error{
                Messages().showError(title: "Catalogues", message: error.localizedDescription)
            }
        }
        
        //******************* RETRIEVE *******************//
        // GET the list of product catalogues for this merchant
        Messages().showActivity(onView: self.view)
        WDePOS.sharedInstance().inventoryManager.productCatalogues(((UIApplication.shared.delegate as! AppDelegate).currentUser?.merchant?.merchantId)! , // Merchant ID for which to obtain the product catalogue
            completion:completion)//End of query process
    }
    
    func getProducts(catalogueId:String){
        //End of Product Maintenance process
        let completion:ProductCatalogueProductCompletion = {(products:[WDProductCatalogueProduct]?, totalCount: NSNumber?, error:Error?) in
            //products - list of products from this catalogue
            //           having the latest changes after maintenance action was performed
            Messages().hideActivity(onView: self.view)
            self.products = products
            self.collectionView?.reloadData()
            
            if let  error = error{
                Messages().showError(title: "Products", message: error.localizedDescription)
            }
        }
        
        //******************* RETRIEVE *******************//
        //The simplest search will just yield all reasults for the product catalogue changes
        let query:WDProductsQuery =  WDProductsQuery.init(page: 0,
                                                          pageSize: 20,
                                                          catalogueId: catalogueId)// Your product catalogue Id
        
        Messages().showActivity(onView: self.view)
        WDePOS.sharedInstance().inventoryManager.products(query, // Query attributes
            uncategorized:false, // Return only products which are not assigned to any category, return all otherwise
            completion:completion)//End of query process
    }
    
    func getProductImage(catalogueId:String, productId:String, imageView:UIImageView){
        
        //End of product images process
        let completion:ProductCatalogueImageCompletion = {(productsImage:[WDProductImage]? ,  error:Error?) in
            //List of products images objects containing the information about product Id and URL of the image for the product
            Messages().hideActivity(onView: imageView)
            if let productsImage = productsImage {
                if let productImage = productsImage.first, let imagePath = productImage.imagePath {
                    let image = UIImage.init(contentsOfFile: imagePath.replacingOccurrences(of: "file://", with: ""))
                    imageView.image = image
                }
            }
            
            if let  error = error{
                Messages().showError(title: "Product Image", message: error.localizedDescription)
            }

        }
        
        let query = WDProductsQuery.init(catalogueId: catalogueId, productId: productId)
        
        Messages().showActivity(onView: imageView)
        WDePOS.sharedInstance().inventoryManager.productImage(query, // Array of queries - product ids and catalogue to get the image for
                completion:completion)//end of Product image query
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let products = self.products else {
            return 0
        }
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCell
    
        
        // Configure the cell
        if let productCatalogues = self.productCatalogues {
            if let products = self.products {
                let product:WDProductCatalogueProduct = products[indexPath.row]
                cell.productLabel.text = product.productName
                if cell.image.image == nil {
                    self.getProductImage(catalogueId: productCatalogues[0].productCatalogueId!, productId: product.productId!, imageView: cell.image)
                }
            }
        }
        
        return cell
    }
    
   override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)

        return headerView
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
