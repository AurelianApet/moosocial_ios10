//
//  FirstViewController.swift
//  TabBar
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
public protocol WhatsNewViewDelegate{
    func openWeb()
}
class WhatsNewViewController: AppViewController, UIWebViewDelegate , WhatNewDelegate{

    @IBOutlet weak var webview: UIWebView!
    var delegateExt : WhatsNewViewDelegate?
    @IBOutlet weak var filter: UISegmentedControl!
    @IBOutlet var contentView: UIView!
    var filterData:[Any]?
    
    @IBOutlet weak var webviewIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.automaticallyAdjustsScrollViewInsets = false
        //navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view, typically from a nib.
        
        WebViewService.sharedInstance.set(webview,topVController: self)
        AppHelperService.sharedInstance.whatNewDelegate = self
        WebViewService.sharedInstance.goHome(true)
        addPullToRefreshToWebView()
        // config color for filter 
        filter.tintColor = AppConfigService.sharedInstance.config.color_title_fillter
        webviewIndicator.color = AppConfigService.sharedInstance.config.color_main_style
        webviewIndicator.tintColor = AppConfigService.sharedInstance.config.color_main_style
      }
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.addTarget(self, action: #selector(WhatsNewViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        //refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        refreshController.tintColor = UIColor.white
        webview.scrollView.addSubview(refreshController)
        
    }
    
    func refreshWebView(_ refresh:UIRefreshControl){
        webview.reload()
        refresh.endRefreshing()
    }
    
    override func viewDidLayoutSubviews(){
 
        super.viewDidLayoutSubviews()

        if delegateExt != nil{
            delegateExt?.openWeb()
 
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // setting the hidesBarsOnSwift property to false
        // since it doesn't make sense in this case,
        // but is was set to true in the last VC
        //navigationController?.hidesBarsOnSwipe = true
        //tabBarController?.hidesBottomBarWhenPushed=true
        // setting hidesBarsOnTap to true
        //navigationController?.hidesBarsOnTap = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark : WhatNewDelegate 
    func filtering(_ data: [Any]?) {
        // Reset 
        filter.removeAllSegments()
        filterData = data

        if data == nil{
            hideFillter()
        }else{
            showFilter()
            var i = 0
            var selectFilter = 0
            if filterData != nil && filterData!.count > 0 {
                //for data  in filterData as! NSArray {
                for case let item as [String:String] in filterData! as [Any]{
                    filter.insertSegment(withTitle: NSLocalizedString(item["label"]!,comment:item["label"]!), at: i, animated: false)
                    if WebViewService.sharedInstance.webParam.url! == (AppConfigService.sharedInstance.getBaseURL() + item["url"]!){
                        selectFilter = i
                    }
                    i += 1
                }
            }
            filter.selectedSegmentIndex = selectFilter
        }
        
    }
    func hideFillter(){
        setFilterConstraint(0,height: 0)
    }
    func showFilter(){
        if filterData != nil{
             setFilterConstraint(0,height: 44)
        }
        
    }
    func setFilterConstraint(_ topBot:CGFloat,height:CGFloat){
        for constraint in contentView.constraints{
            
            if constraint.identifier == "filter.top" || constraint.identifier == "filter.bot"{
                
                constraint.constant = topBot
            }
        }
        for subview in contentView.subviews as [UIView] {
            if subview.constraints.count > 0 {
                for constraint in subview.constraints{
                    if constraint.identifier == "filter.height"{
                        constraint.constant = height
                    }
                }
            }
        }
    }
    
    @IBAction func onSelectFilter(_ sender: AnyObject) {
        if sender.selectedSegmentIndex >= 0 {
            if let item = filterData![sender.selectedSegmentIndex] as? [String:String]{
                let url = (AppConfigService.sharedInstance.getBaseURL() as String) + item["url"]!
                WebViewService.sharedInstance.goURL(url)
            }
          
        }

        
    }
}
class WhatsNewSegmentedControl:UISegmentedControl{

    override init(frame: CGRect) {
        super.init(frame:frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView(){
        
        setDividerImage(dividerImageNonSelected(), forLeftSegmentState:UIControlState(), rightSegmentState: UIControlState(), barMetrics: UIBarMetrics.default)
        
        
        setDividerImage(dividerImageRightSelected(), forLeftSegmentState:UIControlState.selected, rightSegmentState: UIControlState(), barMetrics: UIBarMetrics.default)
        setDividerImage(dividerImageLeftSelected(), forLeftSegmentState:UIControlState.selected, rightSegmentState: UIControlState.selected, barMetrics: UIBarMetrics.default)
       
        setBackgroundImage(backgroundImageNomal(),for:UIControlState(),barMetrics: UIBarMetrics.default)
          setBackgroundImage(backgroundImageSelected(),for:UIControlState.selected,barMetrics: UIBarMetrics.default)
        
        
    }
    func dividerImageNonSelected() -> UIImage? {
        //return UIImage(named:"tabbar.segment.noneselected")
        // Setup our context
        let size = CGSize(width: 1, height: 40)
        let bounds = CGRect(origin: CGPoint.zero, size:size )
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        context?.setStrokeColor(UIColor(red:0.9294,green:0.9254,blue:0.9254,alpha:1.0).cgColor)
        context?.setLineWidth(1.0)
        
        //CGContextStrokeRect(context, bounds)
        
        context?.beginPath()
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        context?.strokePath()
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func  dividerImageLeftSelected()-> UIImage?{
        //return UIImage(named:"tabbar.segment.leftselected")
        return dividerImageNonSelected()
    }
    func  dividerImageRightSelected()-> UIImage?{
         //return UIImage(named:"tabbar.segment.rightselected")
        return dividerImageNonSelected()
    }
    func backgroundImageNomal()->UIImage{
        
        let size = CGSize(width: 1, height: 40)
        let bounds = CGRect(origin: CGPoint.zero, size:size )
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        context?.setStrokeColor(UIColor.clear.cgColor)
        context?.setLineWidth(1.0)
        
        //CGContextStrokeRect(context, bounds)
        
        context?.beginPath()
        context?.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        context?.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        context?.strokePath()
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    func backgroundImageSelected()->UIImage?{

         return UIImage(named: "tabbar.segment.bgselected")
    
    }
}
