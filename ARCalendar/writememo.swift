//
//  File2.swift
//  ARCalendar
//
//  Created by 安江洸希 on 2020/05/22.
//  Copyright © 2020 安江洸希. All rights reserved.
//

import UIKit
 
class writememo: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var nitijilabel: UILabel!
    @IBOutlet var memolabel: UILabel!
    @IBOutlet var textfield: UITextField!
    @IBOutlet var textview: UITextView!
    @IBOutlet var textfield_picker: UITextField!
    var pickerView: UIPickerView = UIPickerView()
    var years:[Int] = ([Int])(2000...2020)
    var months:[Int] = ([Int])(1...12)
    var days:[Int] = ([Int])(1...31)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton(frame: CGRect(x: (view.frame.size.width/2)-50,y: view.frame.size.height-125,width: 100,height:50))
        backButton.setTitle("保存", for: .normal)
        backButton.backgroundColor = UIColor.green
        backButton.addTarget(self, action: #selector(writememo.back(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        textview = UITextView(frame: CGRect(x: (view.frame.size.width/2)-(view.frame.size.width-50)/2, y: (view.frame.size.height/2), width: view.frame.size.width-50, height: 200))
        textview.layer.masksToBounds = true // 角に丸みをつける
        textview.layer.cornerRadius = 5.0 // 丸みのサイズを設定する
        textview.layer.borderWidth = 1 // 枠線の太さを設定する
        textview.layer.borderColor = UIColor.lightGray.cgColor // 枠線の色を黒に設定する
        textview.font = UIFont.systemFont(ofSize: 15) // フォントの設定をする
        textview.textColor = UIColor.black // フォントの色の設定をする
        textview.textAlignment = NSTextAlignment.left // 左詰めの設定をする
        //textview.dataDetectorTypes = UIDataDetectorTypes.All // リンク、日付などを自動的に検出してリンクに変換する
        textview.layer.shadowOpacity = 0.5 // 影の濃さを設定する
        //textview.isEditable = false // テキストを編集不可にする.
        //textViewのtextの量に応じて、textViewの高さを決める
        textview.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(textview) // TextViewをViewに追加する.
        
//        textfield = UITextField(frame: CGRect(x: 10, y: 100, width: UIScreen.main.bounds.size.width-20, height: 38))
//        textfield.placeholder = "入力してください。" //// プレースホルダを設定
//        textfield.keyboardType = .default // キーボードタイプを指定
//        textfield.borderStyle = .roundedRect // 枠線のスタイルを設定
//        textfield.returnKeyType = .done // 改行ボタンの種類を設定
//        textfield.clearButtonMode = .always // テキストを全消去するボタンを表示
//        self.view.addSubview(textfield) // UITextFieldを追加
//        textfield.delegate = self // デリゲートを指定
        
        nitijilabel = UILabel(frame: CGRect(x: (view.frame.size.width/2)-125, y: 150, width: 200, height: 36))
        nitijilabel.text = "日時を指定する"
        nitijilabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(nitijilabel)
        
        memolabel = UILabel(frame: CGRect(x: (view.frame.size.width/2)-(view.frame.size.width-50)/2, y: (view.frame.size.height/2)-50, width: 200, height: 36))
        memolabel.text = "メモに書く内容"
        memolabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(memolabel)
        
        textfield_picker = UITextField(frame: CGRect(x: (view.frame.size.width/2)-125, y: 200, width: 250, height: 36))
        textfield_picker.borderStyle = .roundedRect
        textfield_picker.placeholder = "日時の指定"
        //self.view.addSubview(textfield_picker)
        //pickerView = UIPickerView(frame: CGRect(x: 100, y: 200, width: 400, height: 300))
        //let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self  // 選択肢を自身に設定する
        textfield_picker.inputView = pickerView //表示されるキーボードをpickerViewに置き換える
        self.view.addSubview(textfield_picker)
        
        setKeyboardAccessory()
        
    }
    
    //ファイルにテキストファイルを作成して書き込む
    func createAndWriteTextFile(text: String) {
        //UserDefaults のインスタンス生成
        let userDefaults = UserDefaults.standard
        
        // 作成するテキストファイルの名前
        let textFileName = "try.txt"
        let initialText = text
         
        // DocumentディレクトリのfileURLを取得
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
         
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
             
            print("書き込むファイルのパス: \(targetTextFilePath)")
            //Documents下のパス情報をUserDefaultsに保存する
            userDefaults.set(targetTextFilePath, forKey: "userpath1")
             
            do {
                try initialText.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
        }
    }
    
    // テキストを追記するメソッド
    func appendText(fileURL: URL, text: String) {
         
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            // 改行を入れる
            let stringToWrite = "\n" + text
             
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
         
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }
    
    //前の画面に戻る
    @objc func back(_ sender: UIButton) {
        var sentence = ""
        //改行削除を行う
        if let range = self.textview.text.range(of: "\n") {
            self.textview.text.replaceSubrange(range, with: "")
            sentence = self.textfield_picker.text! + "\t" + self.textview.text
        } else {
            sentence = self.textfield_picker.text! + "\t" + self.textview.text
        }
        ///新しくファイルを作る場合
        //createAndWriteTextFile(text: sentence) //ファイル新規作成
        
        ///既存のファイルに追記する場合
        let path1 = UserDefaults.standard.url(forKey: "userpath1") //ファイルのURLをそのまま出す
        appendText(fileURL: path1!, text: sentence)
        self.dismiss(animated: true, completion: nil)
    }
    
    //UITextView
    //入力画面ないしkeyboardの外を押したら、キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textview.isFirstResponder) {
            self.textview.resignFirstResponder()
        }
    }
    
    //textfieldの設定
//    // 改行ボタンを押した時の処理
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("Return")
//        return true
//    }
//
//    // クリアボタンが押された時の処理
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        print("Clear")
//        return true
//    }
//
//    // テキストフィールドがフォーカスされた時の処理
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print("Start")
//        return true
//    }
//
//    // テキストフィールドでの編集が終了する直前での処理
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        print("End")
//        return true
//    }
    
    ///pickerViewの設定
    //列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    //行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else if component == 2 {
            return days.count
        } else {
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        } else if component == 1 {
            return "\(months[row])月"
        } else if component == 2 {
            return "\(days[row])日"
        } else {
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[pickerView.selectedRow(inComponent: 0)]
        let month = months[pickerView.selectedRow(inComponent: 1)]
        let day = days[pickerView.selectedRow(inComponent: 2)]
        textfield_picker.text = "\(year)年 \(month)月 \(day)日"
    }
    
    func setKeyboardAccessory() {
        let keyboardAccessory = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 36))
        keyboardAccessory.backgroundColor = UIColor.white
        textfield_picker.inputAccessoryView = keyboardAccessory

        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: keyboardAccessory.bounds.size.width, height: 0.5))
        topBorder.backgroundColor = UIColor.lightGray
        keyboardAccessory.addSubview(topBorder)

        let completeButton = UIButton(frame: CGRect(x: keyboardAccessory.bounds.size.width - 48, y: 0, width: 48, height: keyboardAccessory.bounds.size.height - 0.5 * 2))
        completeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        completeButton.setTitle("完了", for: .normal)
        completeButton.setTitleColor(UIColor.blue, for: .normal)
        completeButton.setTitleColor(UIColor.red, for: .highlighted)
        completeButton.addTarget(self, action: #selector(self.hidePickerView), for: .touchUpInside)
        keyboardAccessory.addSubview(completeButton)

        let bottomBorder = UIView(frame: CGRect(x: 0, y: keyboardAccessory.bounds.size.height - 0.5, width: keyboardAccessory.bounds.size.width, height: 0.5))
        bottomBorder.backgroundColor = UIColor.lightGray
        keyboardAccessory.addSubview(bottomBorder)
    }

    @objc func hidePickerView() {
        textfield_picker.resignFirstResponder()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
