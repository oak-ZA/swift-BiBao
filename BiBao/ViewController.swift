//
//  ViewController.swift
//  BiBao
//
//  Created by 张奥 on 2019/9/4.
//  Copyright © 2019年 张奥. All rights reserved.
//

import UIKit

//闭包形式一: typealias
typealias MyClosure = (String,String) -> (Void)

class ViewController: UIViewController {

    var myclosure: MyClosure?
    //闭包形式二: 闭包类型申明和变量的合并在一起
    var myclosure2: ((_ num1: Int, _ num2: Int) -> (Int))?
    //闭包形式三: 省略闭包收的形式,省略闭包体中的返回值
    var myclosure3: ((Int,Int) -> (Int))?
    //六: 闭包作为函数参数
    typealias Number = (_ num1: Int) -> (Int)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 80, y: 100, width: 80, height: 80)
        button.backgroundColor = UIColor.red
        view.addSubview(button)
        button.addTarget(self, action: #selector(clickButton(button:)), for: UIControlEvents.touchUpInside)
        
        //-:
        myclosure = {(string1: String,string2: String) in
            
            print(string1,string2)
        }
        
        //二:
        myclosure2 = {(_ num1: Int, _ num2: Int) -> (Int) in

            return num1 + num2
        }
        
        //三
        myclosure3 = {(num1: Int, num2: Int) -> (Int) in
            
            return num1 * num2
        }
        
        //四(在三的基础上简化)
        let myclosure4: (Int,Int) -> (Int) = {
            (num1,num2) in
            
            return num1 - num2
        }
        let result4 = myclosure4(4,6)
        print(result4)
        
        //五: 如果闭包没有接受参数省略 in
        let myclosure5: () -> (String) = {
            return "如果闭包没有接受参数省略 in"
        }
        let result5 = myclosure5()
        print(result5)
        
    }

   @objc func clickButton(button:UIButton) -> Void {
    //-:
        myclosure?("你好","世界")
    //二:
    let result = myclosure2?(4,6)
         print(result!)
    //三:
    let result2 = myclosure3?(4,6)
        print(result2!)
    
    //六
    xiuxi(handle: { (text, text1) -> (Void) in
        print("\(text),\(text1)")
    }, num: 4)
        print("12345678")
    }
    
    //六:
    func xiuxi(handle:(String,String) -> (Void),num: Int) {
        handle("hello","world\(num)")
    }
    
    //七: 逃逸闭包
//    如果一个闭包被作为一个参数传递给一个函数，并且在函数return之后才被唤起执行，那么我们称这个闭包的参数是“逃出”这个函数体外，这个闭包就是逃逸闭包。此时可以在形式参数前写 @escaping来明确闭包是允许逃逸的。
//    闭包可以逃逸的一种方法是被储存在定义于函数外的变量里。比如说，很多函数接收闭包实际参数来作为启动异步任务的回调。函数在启动任务后返回，但是闭包要直到任务完成——闭包需要逃逸，以便于稍后调用。用我们最常用的网络请求举例来说
//    func request(methodType:RequestMethodType,urlString:String,parameters:[String:AnyObject],completed: @escaping (AnyObject?,NSError?) -> ()) {
//
//        let successCallBack = { (task: URLSessionDataTask?, result: Any?) -> Void in
//            completed(result as AnyObject?, nil)
//
//        }
//
//        let failureCallBack = { (task: URLSessionDataTask?,erro: Error?) -> Void in
//            completed(nil,erro as NSError?)
//
//        }
//
//        //判断是哪种请求方式
//        if methodType == .get {
//            get(urlString, parameters: parameters, success: successCallBack, failure: failureCallBack)
//        } else {
//            post(urlString, parameters: parameters, success: successCallBack, failure: failureCallBack)
//        }
    
//    这里的completed闭包被作为一个参数传递给request函数，并且在函数调用get或post后才会被调用。
    
//    }
    
    
    //如何解决闭包的循环强引用：
//    方式一：类似于Objective-C中使用__weak解决block的循环引用，Swift中支持使用weak关键字将类实例声明为弱引用类型（注意，弱引用类型总是可选类型），打破类实例对闭包的强引用，当对象销毁之后会自动置为nil，对nil进行任何操作不会有反应
    //1.=================
    class ThirdViewController: UIViewController {
        var callBack: ((String) -> ())?
        override func viewDidLoad() {
            super.viewDidLoad()
            //将self申明为弱引用类型，打破循环引用
            weak var weakSelf = self
            printString { (text) in
                print(text)
                //闭包中铺捕获了self
                weakSelf?.view.backgroundColor = UIColor.red
            }
        }
        func printString(callBack:@escaping (String) -> ()) {
            callBack("这个闭包返回一段文字")
            //控制器强引用于着callBack
            self.callBack = callBack
        }
        deinit {
            print("ThirdViewController---释放了")
        }
    }
    
    //2.====================
//    方式二：作为第一种方式的简化操作，我们可以在闭包的第一个大括号后面紧接着插入这段代码[weak self]，后面的代码直接使用self？也能解决循环引用的问题。
    class FourViewController: UIViewController {
        var callBack: ((String) -> ())?
        override func viewDidLoad() {
            super.viewDidLoad()
            printString {[weak self]  (text) in
                print(text)
                self?.view.backgroundColor = UIColor.red
            }
        }
        func printString(callBack:@escaping (String) -> ()) {
            callBack("这个闭包返回一段文字")
            //控制器强引用于着callBack
            self.callBack = callBack
        }
        deinit {
            print("ThirdViewController---释放了")
        }
    }
    //3.==================
//    方式三：在闭包和捕获的实例总是互相引用并且总是同时释放时，可以将闭包内的捕获定义为无主引用unowned。
    class FiveViewController: UIViewController {
        var callBack: ((String) -> ())?
        override func viewDidLoad() {
            super.viewDidLoad()
            printString {[unowned self]  (text) in
                print(text)
                self?.view.backgroundColor = UIColor.red
            }
        }
        func printString(callBack:@escaping (String) -> ()) {
            callBack("这个闭包返回一段文字")
            //控制器强引用于着callBack
            self.callBack = callBack
        }
        deinit {
            print("ThirdViewController---释放了")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

