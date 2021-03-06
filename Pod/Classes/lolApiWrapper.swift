//
//  lolApiWrapper.swift
//  lol
//
//  Created by Mobin Zadeh Kochak on 04/09/2015.
//  Copyright (c) 2015 Mobin Zadeh Kochak. All rights reserved.
//

import UIKit

let APIURL = "https://{region}.api.pvp.net/api/lol/{region}"
let STATICURL = "https://global.api.pvp.net/api/lol/static-data/{region}"
let regions = ["euw", "na", "br", "eune", "kr", "lan", "las", "oce", "ru", "tr"]
let summonerAPIVersion        = "1.4"
let teamAPIVersion            = "2.4"
let statsAPIVersion           = "1.3"
let matchlistAPIVersion       = "2.2"
let matchAPIVersion           = "2.2"
let gameAPIVersion            = "1.3"
let championAPIVersion        = "1.2"
let leagueAPIVersion          = "2.5"
let lol_static_dataAPIVersion = "1.2"

public class lolApiWrapper: NSObject {
    
    // MARK: Initialised detail
    var APIKey: String
    var region: String?
    var miniURL: String!
    var result: NSDictionary!
    private var static_data: Bool
    private var is_version: Bool
    private var debugEnabled: Bool
    
    var delegate: LolAPIListener?
    static let sharedInstance: lolApiWrapper = lolApiWrapper()
    
    override init() {
        static_data = false
        is_version = false;
        debugEnabled = false
        APIKey = ""
    }
    
    public convenience init(withKey k: String) {
        self.init()
        APIKey = k
    }
    
    public convenience init(withKey k: String, andRegion r: String) {
        self.init()
        APIKey = k
        region = r
    }
    
    public convenience init(withKey k: String, andRegion r: String, debugEnabled e: Bool) {
        self.init()
        APIKey = k
        region = r
        debugEnabled = e
    }
    
    // MARK: Retrieve API
    public func get() -> NSDictionary {
        guard let r = region else {
            for r in 0..<regions.count {
                let finalURL = genURL(forRegion: regions[r])
                result = getJSON(finalURL)
                if result.count > 0 {
                    break
                }
            }
            return result
        }
        
        let finalURL = genURL(forRegion: r)
        result = getJSON(finalURL)
        
        if debugEnabled { print(result) }
        delegate?.didReturnResult(result)
        
        return result
    }
    
    private func genURL(forRegion r: String) -> String {
        let apiURL = ((static_data) ? STATICURL : APIURL).stringByReplacingOccurrencesOfString("{region}", withString: r, options: NSStringCompareOptions.LiteralSearch)
        
        let operand = ((miniURL.containsString("?")) ? "&" : "?")
        let finalURL = "\(apiURL)\(miniURL)\(operand)api_key=\(APIKey)"
        
        return finalURL
    }
    
    public func getJSON(urlToRequest: String) -> NSDictionary{
        
        var jsonDictionary = NSDictionary()
        let urlToRequest = urlToRequest.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if let jsonData = NSData(contentsOfURL: NSURL(string: urlToRequest)!) {
            // Parse data
            
            do {
                if(is_version) {
                    let jsonArray:NSArray = try (NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions.MutableContainers) as? NSArray)!
                    jsonDictionary = ["versions":jsonArray]
                }
                else {
                    jsonDictionary = try (NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary)!
                }
                

            } catch let error as NSError {
                delegate?.errorDidOccur(error, userString: error.localizedFailureReason)
                print(error)
            }
        } else {
            print("-------- URL IS INVALID --------\n")
            delegate?.submittedURLInvalid(urlToRequest)
        }
        
        return jsonDictionary
    }
    
    public func getArrayJSON(urlToRequest: String) -> NSArray{
        
        var jsonArray = NSArray()
        let urlToRequest = urlToRequest.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if let jsonData = NSData(contentsOfURL: NSURL(string: urlToRequest)!) {
            // Parse data
            
            do {
                jsonArray = try (NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions.MutableContainers) as? NSArray)!
                
            } catch let error as NSError {
                delegate?.errorDidOccur(error, userString: error.localizedFailureReason)
                print(error)
            }
        } else {
            print("-------- URL IS INVALID --------\n")
            delegate?.submittedURLInvalid(urlToRequest)
        }
        
        return jsonArray
    }
    
    // MARK: --- API
    
    // MARK: API - champion
    /**
    
    /champion   -> Retrieve all champions.
    /{id}       -> Retrieve champion by ID.
    
    */
    public func champion(url: String = "") -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + championAPIVersion + "/champion/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - game
    /**
    
    /by-summoner/{summonerId}/recent  -> Get recent games by summoner ID.
    
    */
    public func game(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + gameAPIVersion + "/game/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - league
    /**
    
    /by-summoner/{summonerIds}       -> Get leagues mapped by summoner ID for a given list of summoner IDs.
    /by-summoner/{summonerIds}/entry -> Get league entries mapped by summoner ID for a given list of summoner IDs.
    /by-team/{teamIds}               -> Get leagues mapped by team ID for a given list of team IDs.
    /by-team/{teamIds}/entry         -> Get league entries mapped by team ID for a given list of team IDs.
    /challenger                      -> Get challenger tier leagues.
    /master                          -> Get master tier leagues.
    
    */
    public func league(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + leagueAPIVersion + "/league/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - lol-static-data
    /**
    
    /champion            -> Retrieves champion list.
    /champion/{id}       -> Retrieves a champion by its id.
    /item                -> Retrieves item list.
    /item/{id}           -> Retrieves item by its unique id.
    /language-strings    -> Retrieve language strings data.
    /languages           -> Retrieve supported languages data.
    /map                 -> Retrieve map data.
    /mastery             -> Retrieves mastery list.
    /mastery/{id}        -> Retrieves mastery item by its unique id.
    /realm               -> Retrieve realm data.
    /rune                -> Retrieves rune list.
    /rune/{id}           -> Retrieves rune by its unique id.
    /summoner-spell      -> Retrieves summoner spell list.
    /summoner-spell/{id} -> Retrieves summoner spell by its unique id.
    /versions            -> Retrieve version data.
    
    */
    public func lol_static_data(url: String) -> lolApiWrapper {
        static_data = true;
        if(url == "/versions") {
            is_version = true
        }
        self.miniURL = "/v" + lol_static_dataAPIVersion + "/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - Match
    /**
    
    /{matchId}  -> Retrieve match by match ID.
    
    */
    public func match(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + matchAPIVersion + "/match/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - Matchlist
    /**
    
    /by-summoner/{summonerId}         -> Retrieve match list by summoner ID.
    
    */
    public func matchlist(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + matchlistAPIVersion + "/matchlist/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - Stats
    /**
    
    /by-summoner/{summonerId}/ranked  -> Get ranked stats by summoner ID.
    /by-summoner/{summonerId}/summary -> Get player stats summaries by summoner ID.
    
    */
    public func stats(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + statsAPIVersion + "/stats/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - Summoner
    /**
    
    /by-name/{summonerNames} -> Get summoner objects mapped by standardized summoner name for a given list of summoner names.
    /{summonerIds}           -> Get summoner objects mapped by summoner ID for a given list of summoner IDs.
    /{summonerIds}/masteries -> Get mastery pages mapped by summoner ID for a given list of summoner IDs.
    /{summonerIds}/name      -> Get summoner names mapped by summoner ID for a given list of summoner IDs.
    /{summonerIds}/runes     -> Get rune pages mapped by summoner ID for a given list of summoner IDs.
    
    */
    public func summoner(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + summonerAPIVersion + "/summoner/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    // MARK: API - Team
    /**
    
    /by-summoner/{summonerIds}   -> Get teams mapped by summoner ID for a given list of summoner IDs.
    /{teamIds}                   -> Get teams mapped by team ID for a given list of team IDs.
    
    */
    public func team(url: String) -> lolApiWrapper {
        static_data = false;
        is_version = false;
        self.miniURL = "/v" + teamAPIVersion + "/team/" + (url.hasPrefix("/") ? (url as NSString).substringFromIndex(1) : url)
        return self
    }
    
    
    
    
    
    
    
    // MARK: TO DO
    /*
    ADD:
    
    - current-game-v1.0
    - featured-games-v1.0
    - lol-status-v1.0
    */
    
}

protocol LolAPIListener {
    func didReturnResult(result: NSDictionary)
    func errorDidOccur(error: NSError, userString: String?)
    func submittedURLInvalid(url: String)
}
