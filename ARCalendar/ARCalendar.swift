//
//  File.swift
//  ARCalendar
//
//  Created by 安江洸希 on 2020/05/20.
//  Copyright © 2020 安江洸希. All rights reserved.
//

import UIKit

class ARCalendar:UIViewController{
    
    var dayCount = 0;
    var upview: UIView!
    
    var monthlabel: UILabel!
    var daylabel: UILabel!
    var yearlabel: UILabel!
    var youbilabel: UILabel!
    var mojilabel: UILabel!
    
    var memolabel: UILabel!
    var memolabel2: UILabel!
    var memoview: UITextView!
    var memobutton: UIView!
    
    var textarray: [String] = []
    var jikanarray: [[String]] = []
    
    override func viewDidLoad() {
        
        // スクリーンサイズを取得
//        let screenWidth:CGFloat = view.frame.size.width //736.0
//        let screenHeight:CGFloat = view.frame.size.height //414.0
        
        upview = UIView(frame: CGRect(x: 0, y: 0, width: 850, height: 40))
        upview.backgroundColor = UIColor.darkGray
        self.view.addSubview(upview)
        
        mojilabel = UILabel(frame: CGRect(x:50, y:50, width:500, height:500))
        mojilabel.font = UIFont(name: "ShokakiUtage-FreeVer.",size: 50)
        mojilabel.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 244/255, alpha:0.8)
        mojilabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(mojilabel)

        yearlabel = UILabel(frame: CGRect(x:600, y:30, width:200, height:50))
        yearlabel.textAlignment = NSTextAlignment.center
        yearlabel.font = UIFont.italicSystemFont(ofSize: 30)
        yearlabel.backgroundColor = UIColor.white
        //self.view.addSubview(yearlabel)
        
        monthlabel = UILabel(frame: CGRect(x: 600, y: 100, width: 200, height: 50))
        monthlabel.font = UIFont.italicSystemFont(ofSize: 50)
        monthlabel.backgroundColor = UIColor.white
        monthlabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(monthlabel)
        
        daylabel = UILabel(frame: CGRect(x: 600, y: 150, width: 220, height: 200))
        daylabel.font = UIFont.italicSystemFont(ofSize: 120)
        daylabel.backgroundColor = UIColor.white
        daylabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(daylabel)
        
        youbilabel = UILabel(frame: CGRect(x: 600, y: 300, width: 200, height: 50))
        youbilabel.font = UIFont.boldSystemFont(ofSize: 30)
        youbilabel.backgroundColor = UIColor.white
        youbilabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(youbilabel)
        
        memolabel = UILabel(frame: CGRect(x: 650, y: 425, width: 120, height: 36))
        memolabel.text = "メモなし"
        memolabel.textColor = UIColor.black
        memolabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(memolabel)
        
        memobutton = UIView(frame: CGRect(x: 635, y: 460, width: 140, height: 36))
        memobutton.backgroundColor = UIColor.white
        self.view.addSubview(memobutton)
        memolabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 36))
        memolabel2.text = "Tapped"
        memolabel2.textColor = UIColor.black
        memolabel2.font = UIFont.boldSystemFont(ofSize: 40)
        memobutton.addSubview(memolabel2)
        memolabel2.isHidden = true
        
        memoview = UITextView(frame: CGRect(x: 600, y: 450, width: 200, height: 100))
        memoview.layer.masksToBounds = true
        memoview.layer.cornerRadius = 5.0
        memoview.layer.borderWidth = 1
        memoview.layer.borderColor = UIColor.lightGray.cgColor
        memoview.font = UIFont.systemFont(ofSize: 15)
        memoview.textColor = UIColor.black
        memoview.textAlignment = NSTextAlignment.left
        memoview.layer.shadowOpacity = 0.5
        memoview.isEditable = false
        memoview.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(memoview)
        memoview.isHidden = true

        //メモボタンを押したとき
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ARCalendar.singleTap))
        singleTapGesture.numberOfTapsRequired = 1
        memobutton.addGestureRecognizer(singleTapGesture)
        
        //スワイプでページめくり
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ARCalendar.prevDay))
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ARCalendar.nextDay))
        upSwipe.direction = .up
        self.view.addGestureRecognizer(upSwipe)
        
        if let path1 = UserDefaults.standard.url(forKey: "userpath1") {//ファイルのURLをそのまま出す
            //let path1 = UserDefaults.standard.url(forKey: "userpath")
            make_memo_jikan(fileURL: path1) //jikanarrayにDocumentsのテキストから日時部分を取り出して２次元配列として格納
        }
        else {
            createAndWriteTextFile() //何も書いていないテキストファイルを作成
        }
        showDate()
        
        _ = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        //グラデーションの開始色
        let topColor = UIColor.white//(red: 0.8, green: 1.0, blue: 1.0, alpha:1.0)
        //グラデーションの終わり色
        let bottomColor = UIColor.white//(red: 0.2, green: 1.0, blue: 1.0, alpha:1.0)
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 850, height: 600)//self.view.bounds
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        print("memobutton")
        memoview.isHidden = false
        memolabel.isHidden = true
        memolabel2.isHidden = true
        memobutton.isHidden = true
        let path1 = UserDefaults.standard.url(forKey: "userpath1") //ファイルのURLをそのまま出す
        readTextFile(fileURL: path1!)
    }
    
    //ファイルにテキストファイルを作成して書き込む
    func createAndWriteTextFile() {
        //UserDefaults のインスタンス生成
        let userDefaults = UserDefaults.standard
        
        // 作成するテキストファイルの名前
        let textFileName = "calendar.txt"
        let initialText = ""
         
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
    
    // テキストを読み込むメソッド
    func readTextFile(fileURL: URL) {
        do {
            let text = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            print(text) //テキスト全文
        } catch let error as NSError {
            print("failed to read: \(error)")
        }
    }
    
    //テキストから１行ずつ区切って、２次元配列に格納
    func make_memo_jikan(fileURL: URL) {
        let contents = ["年", "月", "日"]
        do {
            let text = try String(contentsOf: fileURL, encoding: String.Encoding.utf8) //テキストファイルを読み込む
            let array = text.components(separatedBy: .newlines)   // 改行コードで分割する
            for s in array {
                if (s.count < 5) {
                    continue
                }
                let hi = s.components(separatedBy: "\t")
                let nitiji = hi[0].components(separatedBy: " ") //空白で区切って配列に入れる
                var jikan: [String] = []
                var count = 0
                for toki in nitiji {
                    var sentence = toki
                    if let range = sentence.range(of: contents[count]) {//年・月・日の範囲を取り出す
                        sentence.replaceSubrange(range, with: "") //取り出した範囲から語句を消す
                        jikan.append(sentence)
                        count += 1
                    } else {
                        print("makememe:error")
                    }
                }
                jikan.append(hi[1])
                jikanarray.append(jikan)
            }
        } catch let error as NSError {
            print("failed to read: \(error)")
        }
    }
    
    @objc func update() {
        let path1 = UserDefaults.standard.url(forKey: "userpath1")
        make_memo_jikan(fileURL: path1!)
        make_memo_label()
    }
    
    func make_memo_label() {
        let ye = self.yearlabel.text
        var mo = self.monthlabel.text
        var da = self.daylabel.text
        
        for jikan in jikanarray {
            let year = jikan[0]
            let month = jikan[1]
            let day = jikan[2]
            let text = jikan[3]
            if let range = mo!.range(of: "月") {
                mo!.replaceSubrange(range, with: "")
            }
            if let range = da!.range(of: "日") {
                da!.replaceSubrange(range, with: "")
            }
            if (ye! == year) && (mo! == month) && (da! == day){
                memolabel.text = "メモあり"
                memolabel2.isHidden = false
                memolabel2.textColor = UIColor.red
//                UIView.animate(withDuration: 0.1, delay: 0.0, options: .repeat, animations: {
//                    self.memolabel2.alpha = 0.0
//                }, completion: nil)
                memoview.text = text
            }
        }
    }
    
    func showDate(){
        let calendar = Calendar.current
        let date = Date()
        let today = calendar.date(byAdding: .day, value: dayCount, to: calendar.startOfDay(for: date))
//        print(date)
//        print(today!) //optinal型になっている
        
        let year = calendar.component(.year, from: today!)
        let month = calendar.component(.month, from: today!)
        let day = calendar.component(.day, from: today!)
        let youbi = calendar.component(.weekday, from: today!)
        let yo = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let moji = ["アレもコレも\nほしがるなよ",
                    "背のびする自分\n卑下する自分\nどっちもいやだけど\nどっちも自分",
                    "その根っこは見えない\nその見えないところに\n大事な点がある",
                    "あたらしい門出をする者には\n新しい道がひらける",
                    "だれうらむことはない\n身から出たさびだなぁ",
                    "美しいものを、\n美しいと思える\nあなたの心が美しい。",
                    "いのちがけでほしいものを\nただひとつに的をしぼって\n言ってみな。",
                    "あってもなくてもいいものは、\nないほうがいいんだな。",
                    "やれなかった\nやらなかった\nどっちかな。",
                    "善悪、大小、かねの有る無し、\n社会的な地位の上下などという、\n人間の作った相対的な価値観を\n一切やめてみることです。",
                    "自分が自分になりきるということは、\nいま、ここの、自分のいのちを\n完全燃焼して生きることです。",
                    "与えられた今日のいのちを\nイキイキはつらつと生きる。\nそれが仏様の教えだと\n私は受け止めております。",
                    "いいことはおかげさま。\nわるいことは身から出たさび。",
                    "この自我、この我執を\nどう運転してゆくか。\nそれが人生ではないか\nと私は思っております。\nそして、その一生の運転手は\n自分です。",
                    "むりをしないで、\nなまけない。\nわたしは弱い人間だから。",
                    "とにかく具体的に\n動いてごらん…。\n具体的な答が出るから。",
                    "どのような道を歩くとも、\nいのちいっぱいに\n生きればいいぞ。",
                    "自分の心のどん底が\n納得しているかどうか。\nそこが大事。",
                    "外灯というのは\n人のために つけるんだよな\nわたしはどれだけ\n外灯を つけられるだろうか",
                    "夢はでっかく\n根はふかく。",
                    "花を支える枝\n枝を支える幹\n幹を支える根\n根は見えねんだなあ",
                    "あなたの心がきれいだから\nなんでもきれいに\n見えるんだなぁ",
                    "毎日毎日の足跡が\nおのずから人生の答えを出す\nきれいな足跡には\nきれいな水がたまる",
                    "人生において\n最も大切な時\nそれはいつでも\nいまです",
                    "あのときの あの苦しみも\nあのときの あの悲しみも\nみんな肥料になったんだなあ\nじぶんが自分になるための"
                    ]
        //print(moji.count) //配列の長さ
        mojilabel.numberOfLines = 8
        self.mojilabel.text = moji.randomElement()! + "\n\nみつを" //配列からランダムに取り出す
        
        self.yearlabel.text = String(year)
        self.monthlabel.text = String(month)
        self.daylabel.text = String(day)
        self.youbilabel.text = yo[youbi-1]
        
//        // attributedTextを作成する.
//        let attributedText = NSMutableAttributedString(string: String(year))
//        let range = NSMakeRange(0, 4)
//        // 下線を引くようの設定をする.
//        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//        yearlabel.attributedText = attributedText
        
        //UILabelに複数のテキストを載せる
        
        let attributes_m1: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.black,.verticalGlyphForm: 1]
        let attributedText_m1 =  NSAttributedString(string: String(month), attributes: attributes_m1)
        let mutableAttributedText_m1 = NSMutableAttributedString(attributedString: attributedText_m1)
        let attributes_m2: [NSAttributedString.Key : Any] = [.font : UIFont.boldSystemFont(ofSize: 20)]
        //monthlabel.numberOfLines = 2
        let mutableAttributedText_m2 = NSMutableAttributedString(string: "月", attributes: attributes_m2)
        mutableAttributedText_m1.append(mutableAttributedText_m2)
        monthlabel.attributedText = mutableAttributedText_m1

        let attributes_d1: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.black]
        let attributedText_d1 =  NSAttributedString(string: String(day), attributes: attributes_d1)
        let mutableAttributedText_d1 = NSMutableAttributedString(attributedString: attributedText_d1)
        let attributes_d2: [NSAttributedString.Key : Any] = [.font : UIFont.boldSystemFont(ofSize: 40)]
        //daylabel.numberOfLines = 2
        let mutableAttributedText_d2 = NSMutableAttributedString(string: "日", attributes: attributes_d2)
        mutableAttributedText_d1.append(mutableAttributedText_d2)
        daylabel.attributedText = mutableAttributedText_d1
        
//        let attributes_y1: [NSAttributedString.Key : Any] = [.foregroundColor : UIColor.black]
//        let attributedText_y1 =  NSAttributedString(string: yo[youbi-1], attributes: attributes_y1)
//        let mutableAttributedText_y1 = NSMutableAttributedString(attributedString: attributedText_y1)
//        let attributes_y2: [NSAttributedString.Key : Any] = [.font : UIFont.boldSystemFont(ofSize: 30)]
//        youbilabel.numberOfLines = 2
//        let mutableAttributedText_y2 = NSMutableAttributedString(string: "\nようび", attributes: attributes_y2)
//        mutableAttributedText_y1.append(mutableAttributedText_y2)
//        youbilabel.attributedText = mutableAttributedText_y1
        
    }
    
    @objc func prevDay(){
        self.dayCount -= 1;
        UIView.transition(with: self.view, duration: 1.0, options: [.transitionCurlDown, .curveLinear], animations: {},
                          completion:  { (finished: Bool) in})
        //memolabel.backgroundColor = UIColor.white
        memoview.text = ""
        memolabel.text = "メモなし"
        memoview.isHidden = true
        memolabel.isHidden = false
        memolabel2.isHidden = true
        memobutton.isHidden = false
        showDate()
    }
    @objc func nextDay(){
        dayCount += 1
        UIView.transition(with: self.view, duration: 1.0, options: [.transitionCurlUp, .curveLinear], animations: {},
                          completion:  { (finished: Bool) in})
        //memolabel.backgroundColor = UIColor.white
        memoview.text = ""
        memolabel.text = "メモなし"
        memoview.isHidden = true
        memolabel.isHidden = false
        memolabel2.isHidden = true
        memobutton.isHidden = false
        showDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
}
