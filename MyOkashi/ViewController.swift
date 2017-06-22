//
//  ViewController.swift
//  MyOkashi
//
//  Created by pco2699 on 2017/06/17.
//  Copyright © 2017年 pco2699. All rights reserved.
//

import UIKit
import SafariServices


class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate{

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // SearchBarのdelegate通知先を設定
    searchText.delegate = self
    // 入力のヒントになる、プレースホルダを設定
    searchText.placeholder = "お菓子の名前を入力してください"
    // Table Viewのdatasourceを設定
    tableView.dataSource = self
    
    // Table Viewのdelegateを設定
    tableView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var searchText: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  // お菓子のリスト(タプル配列)
  var okashiList : [(maker:String, name:String, link:String, image:String)] = []
  
  // サーチボタンクリック時
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // キーボードを閉じる
    view.endEditing(true)
    // デバッグエリアに出力
    print(searchBar.text ?? "なにもないよ")
    
    if let searchWord = searchBar.text {
      // 入力されていたら、お菓子を検索
      searchOkashi(keyword : searchWord)
    }
  }
  
  // SearchOkashiメソッド
  // 第一引数:keyword 検索したいワード
  func searchOkashi(keyword : String){
    // お菓子の検索キーワードをURLエンコードする
    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    
    // URLオブジェクトの生成
    let url = URL(string: "http://www.sysbird.jp/toriko/api?apikey=guest&format=json&keyword=\(keyword_encode!)&max=10&order=r")
    print(url ?? "なにもないよ")
    
    // リクエストオブジェクトの生成
    let req = URLRequest(url: url!)
    
    // セッションの接続をカスタマイズできる
    // タイムアウト値、キャッシュポリシーなどが指定できる。今回はデフォルト値を使用
    let configuration = URLSessionConfiguration.default
    
    // セッション情報を取り出し
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)

    let task = session.dataTask(with: req, completionHandler: {
      (data, request, error) in
      print(data ?? "なにもないよ")
      // do try catch エラーハンドリング
      do {
        // 受け取ったJSONをパースして格納
        let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
//        print("count = \(json["count"] ?? -1)")
        // お菓子のリストを初期化
        self.okashiList.removeAll()
        
        if let items = json["item"] as? [[String:Any]] {
          // 取得しているお菓子の数だけ処理
          for item in items {
            // メーカー名
            guard let maker = item["maker"] as? String else {
              continue
            }
            // お菓子の名称
            guard let name = item["name"] as? String else {
              continue
            }
            // 掲載URL
            guard let link = item["url"] as? String else {
              continue
            }
            // 画像URL
            guard let image = item["image"] as? String else {
              continue
            }
            
            // 1つのお菓子をタプルでまとめて管理
            let okashi = (maker, name, link, image)
            // お菓子の配列へ追加
            self.okashiList.append(okashi)
          }
        }
        
        self.tableView.reloadData()
      } catch {
        // エラー処理
        print("エラー発生")
      }
    })
    
    // ダウンロード開始
    task.resume()
  }
  
  // Cellの総数を返すdatasourceメソッド
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  
  // Cellに値を設定するdatasourceメソッド
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // 今回表示を行う、Cellオブジェクト(1行)を取得する
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
    
    // お菓子のタイトル設定
    cell.textLabel?.text = okashiList[indexPath.row].name
    
    // お菓子画像のURLを取り出す
    let url = URL(string: okashiList[indexPath.row].image)
    
    // URLから画像を取得
    if let image_data = try? Data(contentsOf: url!) {
      // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
      cell.imageView?.image = UIImage(data: image_data)
    }
    
    // 設定済みのCellオブジェクトを画面に反映
    return cell
    
  }
  
  // Cellが選択された際に呼び出されるdelegateメソッド
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // ハイライト解除
    tableView.deselectRow(at: indexPath, animated: true)
    // URLをstring => URLへ変換
    let urlToLink = URL(string: okashiList[indexPath.row].link)
    
    // SFSafariViewを開く
    let safariViewController = SFSafariViewController(url: urlToLink!)
    
    // delegateの通知先を自分自身に設定
    safariViewController.delegate = self
    
    // SafariViewが開かれる
    present(safariViewController, animated: true, completion: nil)
  }
  
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true, completion: nil)
  }
  

}

