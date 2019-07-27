//
//  ViewController.swift
//  訂飲料喝
//
//  Created by 邱冠儒 on 2019/7/25.

//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    

    

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var drinkTextField: UITextField!
    
    
    @IBOutlet weak var priceTextField: UITextField!
    
    
    @IBOutlet weak var suger: UISegmentedControl!
    
    @IBOutlet weak var ice: UISegmentedControl!
    
    //產生UIpickview
     let pickerView = UIPickerView()
    //物件陣列
    var drinkData: [drinkInfo] = []
    
    var choseSuger:String?
    var choseIce:String?
    
    
    // 讀取飲料店賣東西的txt檔
    func getDrinkTxt(){
        if let url = Bundle.main.url(forResource: "迷克夏", withExtension: "txt"),
            let content = try? String(contentsOf: url){
            //把讀取近來的資料用\n 移除
            let listArray = content.components(separatedBy: "\n")
            //把物件存進陣列
            for n in 0 ..< listArray.count{
                if n % 2 == 0{
                    let name = listArray[n]
                    if let price = Int(listArray[n + 1]){
                        drinkData.append(drinkInfo(name: name, price: price))
                    }
                    
                }
            }
            //debug用 可以刪掉
            print(drinkData)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //delegate  沒有這個不能用pickview
        pickerView.delegate = self
        pickerView.dataSource = self
        
       //飲料店menu
        getDrinkTxt()
        
        //加這個點飲料才會有選單可以選 （價錢不互動）
        drinkTextField.inputView = pickerView
        priceTextField.isUserInteractionEnabled = false
    }

    
    
    //Mark pickview
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return drinkData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        drinkTextField.text = drinkData[row].name
        priceTextField.text = "\(drinkData[row].price)"
    }
    
    
    //Mark  甜度冰塊判斷
    func checkSugerAndIce(){
        switch suger.selectedSegmentIndex {
        case 0:
            choseSuger = "正常"
        case 1:
            choseSuger = "半糖"
        case 2:
            choseSuger = "微糖"
        case 3:
            choseSuger = "無糖"
        default:
            break
        }
        
        switch ice.selectedSegmentIndex {
        case 0:
            choseIce = "正常"
        case 1:
            choseIce = "少冰"
        case 2:
            choseIce = "去冰"
        case 3:
            choseIce = "熱"
        default:
            break
        }
    }

    
    
    
    //上傳後台準備

    @IBAction func sendButton(_ sender: Any) {
        //檢查使用者輸入
        if nameTextField.text != "" && drinkTextField.text != "" {
            checkSugerAndIce()
            //上傳後台
            sendToServer()
            nameTextField.text = ""
            drinkTextField.text = ""
            priceTextField.text = ""
            
            let alert = UIAlertController(title: "訊息", message: "訂購成功↑", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert,animated: true, completion: nil)
            
        }else{
          
            let alert = UIAlertController(title: "訊息", message: "請填入完整訊息↑", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert,animated: true, completion: nil)
        }
    }
    
    
    // 將資料傳到後台
    func sendToServer(){
        let url = URL(string: "https://sheetdb.io/api/v1/q8vphijms65i4")
        var urlRequest = URLRequest(url: url!)
        
        //上傳前告訴後台格式 並將http設為Post
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //post 所提供的API value為物件的陣列 所以用字典實作
        let orderDictionary:[String: Any] = ["name": nameTextField.text!, "drink": drinkTextField.text!, "price": priceTextField.text!, "suger": choseSuger!, "ice" : choseIce!]
        
        //post API 須在物件內設定key值為data value 為一個物件的陣列
        let orderData: [String: Any] = ["data": orderDictionary]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: orderData, options: [])
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data, completionHandler: { (retData, res, err) in
                if let returnData = retData, let dic = (try? JSONSerialization.jsonObject(with: returnData)) as? [String:String] {
                    print(dic)
                }
                
            })
            task.resume()
        }
        catch{
            print(error)
        }
    }
    
    
    
    
    

}

